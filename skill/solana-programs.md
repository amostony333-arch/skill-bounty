# Solana Programs — Quantum Oracle

Anchor programs for on-chain quantum randomness registry.

---

## Program Architecture

```
quantum_beacon (program)
├── instructions/
│   ├── publish_round.rs      ← Oracle publishes certified bits
│   ├── consume_randomness.rs ← Protocol consumes a round
│   └── register_certificate.rs ← Record usage in public ledger
├── state/
│   ├── beacon_config.rs      ← Global config PDA
│   ├── round.rs              ← Per-round randomness package
│   └── certificate.rs        ← Certificate registry entry
└── errors.rs
```

---

## State Accounts

```rust
// state/round.rs
use anchor_lang::prelude::*;

#[account]
#[derive(InitSpace)]
pub struct Round {
    pub round_id:          u64,
    pub value:             [u8; 32],      // Certified random value
    pub tier:              u8,            // 1=Bell 2=Quantum 3=Crypto 4=PRNG
    pub timestamp:         i64,
    pub certificate_hash:  [u8; 32],
    pub physics_verified:  bool,
    pub statistical_score: u16,           // score * 10000
    pub consumed:          bool,
    pub consumed_by:       Option<Pubkey>,
    pub bump:              u8,
}

#[account]
#[derive(InitSpace)]
pub struct BeaconConfig {
    pub authority:     Pubkey,   // Oracle wallet
    pub current_round: u64,
    pub total_rounds:  u64,
    pub bump:          u8,
}

#[account]
#[derive(InitSpace)]
pub struct CertificateEntry {
    pub certificate_hash:  [u8; 32],
    pub consumer:          Pubkey,
    pub round_id:          u64,
    pub tier:              u8,
    pub statistical_score: u16,
    pub timestamp:         i64,
    #[max_len(32)]
    pub usage_context:     String,
    pub physics_verified:  bool,
    pub bump:              u8,
}
```

---

## Instructions

### publish_round

```rust
// instructions/publish_round.rs
use anchor_lang::prelude::*;
use crate::state::*;
use crate::errors::QuantumError;

#[derive(Accounts)]
#[instruction(round_id: u64)]
pub struct PublishRound<'info> {
    #[account(
        init,
        payer = oracle,
        space = 8 + Round::INIT_SPACE,
        seeds = [b"round", round_id.to_le_bytes().as_ref()],
        bump
    )]
    pub round: Account<'info, Round>,

    #[account(
        mut,
        seeds = [b"beacon_config"],
        bump = config.bump,
        constraint = config.authority == oracle.key() @ QuantumError::Unauthorized
    )]
    pub config: Account<'info, BeaconConfig>,

    #[account(mut)]
    pub oracle: Signer<'info>,

    pub system_program: Program<'info, System>,
}

pub fn publish_round(
    ctx: Context<PublishRound>,
    round_id:          u64,
    value:             [u8; 32],
    tier:              u8,
    certificate_hash:  [u8; 32],
    statistical_score: u16,
) -> Result<()> {
    require!(tier >= 1 && tier <= 4, QuantumError::InvalidTier);
    require!(statistical_score <= 10000, QuantumError::InvalidScore);
    require!(
        round_id == ctx.accounts.config.current_round + 1,
        QuantumError::InvalidRoundId
    );

    let round = &mut ctx.accounts.round;
    round.round_id          = round_id;
    round.value             = value;
    round.tier              = tier;
    round.timestamp         = Clock::get()?.unix_timestamp;
    round.certificate_hash  = certificate_hash;
    round.physics_verified  = tier <= 2;
    round.statistical_score = statistical_score;
    round.consumed          = false;
    round.consumed_by       = None;
    round.bump              = ctx.bumps.round;

    let config = &mut ctx.accounts.config;
    config.current_round = round_id;
    config.total_rounds  += 1;

    emit!(RoundPublished {
        round_id,
        tier,
        physics_verified: tier <= 2,
        statistical_score,
        timestamp: round.timestamp,
    });

    Ok(())
}

#[event]
pub struct RoundPublished {
    pub round_id:          u64,
    pub tier:              u8,
    pub physics_verified:  bool,
    pub statistical_score: u16,
    pub timestamp:         i64,
}
```

### consume_randomness

```rust
// instructions/consume_randomness.rs
use anchor_lang::prelude::*;
use crate::state::*;
use crate::errors::QuantumError;

#[derive(Accounts)]
#[instruction(round_id: u64)]
pub struct ConsumeRandomness<'info> {
    #[account(
        mut,
        seeds = [b"round", round_id.to_le_bytes().as_ref()],
        bump = round.bump,
        constraint = !round.consumed @ QuantumError::AlreadyConsumed,
    )]
    pub round: Account<'info, Round>,

    pub consumer: Signer<'info>,
}

pub fn consume_randomness(
    ctx:          Context<ConsumeRandomness>,
    round_id:     u64,
    minimum_tier: u8,
) -> Result<[u8; 32]> {
    let round = &mut ctx.accounts.round;
    require!(round.tier <= minimum_tier, QuantumError::TierNotMet);

    round.consumed    = true;
    round.consumed_by = Some(ctx.accounts.consumer.key());

    emit!(RandomnessConsumed {
        round_id,
        consumer:  ctx.accounts.consumer.key(),
        tier:      round.tier,
        value:     round.value,
    });

    Ok(round.value)
}

#[event]
pub struct RandomnessConsumed {
    pub round_id: u64,
    pub consumer: Pubkey,
    pub tier:     u8,
    pub value:    [u8; 32],
}
```

---

## PDA Seeds Reference

| Account | Seeds |
|---------|-------|
| `BeaconConfig` | `["beacon_config"]` |
| `Round` | `["round", round_id.to_le_bytes()]` |
| `CertificateEntry` | `["certificate", cert_hash]` |

---

## Errors

```rust
// errors.rs
use anchor_lang::prelude::*;

#[error_code]
pub enum QuantumError {
    #[msg("Caller is not the authorized oracle")]
    Unauthorized,
    #[msg("Tier must be between 1 and 4")]
    InvalidTier,
    #[msg("Statistical score must be 0–10000")]
    InvalidScore,
    #[msg("Round ID must be sequential")]
    InvalidRoundId,
    #[msg("This round has already been consumed")]
    AlreadyConsumed,
    #[msg("Source tier does not meet minimum requirement")]
    TierNotMet,
    #[msg("Certificate already registered")]
    DuplicateCertificate,
}
```

---

## Initialize Beacon Config

```rust
pub fn initialize(ctx: Context<Initialize>) -> Result<()> {
    let config         = &mut ctx.accounts.config;
    config.authority   = ctx.accounts.authority.key();
    config.current_round = 0;
    config.total_rounds  = 0;
    config.bump        = ctx.bumps.config;
    Ok(())
}

#[derive(Accounts)]
pub struct Initialize<'info> {
    #[account(
        init,
        payer = authority,
        space = 8 + BeaconConfig::INIT_SPACE,
        seeds = [b"beacon_config"],
        bump
    )]
    pub config: Account<'info, BeaconConfig>,
    #[account(mut)]
    pub authority: Signer<'info>,
    pub system_program: Program<'info, System>,
}
```

---

## Python: Publishing to Solana

```python
# publish_solana.py
import asyncio
from solders.keypair import Keypair
from solders.pubkey import Pubkey
from anchorpy import Program, Provider, Wallet
from anchorpy.provider import DEFAULT_OPTIONS

async def publish_round_to_solana(
    program:          Program,
    oracle_keypair:   Keypair,
    round_id:         int,
    value:            bytes,      # 32 bytes
    tier:             int,
    certificate_hash: bytes,      # 32 bytes
    statistical_score: int,       # 0-10000
):
    # Derive PDAs
    config_pda, _ = Pubkey.find_program_address(
        [b"beacon_config"],
        program.program_id
    )
    round_pda, _ = Pubkey.find_program_address(
        [b"round", round_id.to_bytes(8, "little")],
        program.program_id
    )

    await program.rpc["publish_round"](
        round_id,
        list(value),
        tier,
        list(certificate_hash),
        statistical_score,
        ctx=Context(
            accounts={
                "round":          round_pda,
                "config":         config_pda,
                "oracle":         oracle_keypair.pubkey(),
                "system_program": SYS_PROGRAM_ID,
            },
            signers=[oracle_keypair],
        )
    )
    print(f"Round {round_id} published on-chain ✓")
```

---

## Testing with LiteSVM

```rust
// tests/quantum_beacon.rs
use litesvm::LiteSVM;
use solana_sdk::{signature::Keypair, signer::Signer};

#[test]
fn test_publish_and_consume() {
    let mut svm   = LiteSVM::new();
    let oracle    = Keypair::new();
    let consumer  = Keypair::new();

    // Airdrop
    svm.airdrop(&oracle.pubkey(), 10_000_000_000).unwrap();
    svm.airdrop(&consumer.pubkey(), 1_000_000_000).unwrap();

    // Initialize + publish + consume
    // ... (standard Anchor test pattern)

    // Assert round consumed
    let round: Round = get_account(&svm, round_pda);
    assert!(round.consumed);
    assert_eq!(round.consumed_by, Some(consumer.pubkey()));
}

#[test]
fn test_tier_enforcement() {
    // Publish a Tier 3 round
    // Try to consume with minimum_tier = 2
    // Should fail with TierNotMet
}

#[test]
fn test_sequential_round_ids() {
    // Publishing round 3 when current is 1 should fail
}
```

---

## Deployment

```bash
# Build
anchor build

# Deploy to devnet
anchor deploy --provider.cluster devnet

# Run tests
anchor test

# Verify program
solana program show <PROGRAM_ID>
```
