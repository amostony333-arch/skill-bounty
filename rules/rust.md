---
globs:
  - "**/*.rs"
exclude:
  - "**/target/**"
---

# Rust / Anchor Standards for Quantum Oracle Programs

## Never Use unwrap() in Program Code

```rust
// BAD
let value = some_option.unwrap();

// GOOD
let value = some_option.ok_or(QuantumError::MissingValue)?;
```

`unwrap()` is acceptable in tests and build scripts only.

## Always Use require! for Constraints

```rust
// BAD
if tier < 1 || tier > 4 {
    return Err(QuantumError::InvalidTier.into());
}

// GOOD
require!(tier >= 1 && tier <= 4, QuantumError::InvalidTier);
```

## Emit Events for All State Changes

```rust
// Every instruction that changes state must emit an event
emit!(RoundPublished {
    round_id,
    tier,
    physics_verified: tier <= 2,
    statistical_score,
    timestamp: Clock::get()?.unix_timestamp,
});
```

## Use InitSpace on All Accounts

```rust
// Always derive InitSpace — never hardcode space
#[account]
#[derive(InitSpace)]
pub struct Round {
    pub round_id: u64,
    // ...
}

// In context:
space = 8 + Round::INIT_SPACE,
```

## PDA Seed Conventions

```rust
// Always use descriptive, lowercase byte string seeds
seeds = [b"round", round_id.to_le_bytes().as_ref()]
seeds = [b"beacon_config"]
seeds = [b"certificate", cert_hash.as_ref()]
```

## Statistical Score Convention

Statistical scores are stored as `u16` with 4 decimal precision:
- 0.9850 → stored as `9850`
- Always divide by 10000 when displaying

```rust
// Store
statistical_score: u16  // 0–10000

// Display (off-chain)
let pct = statistical_score as f64 / 100.0;  // e.g. 98.50%
```
