# ZK Integration — SP1 Hypercube + Quantum Randomness

Replacing trusted setup ceremonies with quantum-certified randomness for ZK systems on Solana.

---

## The Problem This Solves

Every ZK system using Groth16 or Plonk needs a **trusted setup**:

```
Old way:
  Coordinate N people → ceremony → hope nobody kept toxic waste
  Security = "trust that all N participants were honest"

New way:
  Fetch quantum-certified seed → SP1 proves derivation → publish on-chain
  Security = "trust the laws of quantum mechanics"
```

---

## SP1 Hypercube Overview

SP1 V6 (Hypercube) is the current production zkVM:

```
Write Rust program → compile to RISC-V ELF
→ SP1 proves execution → Groth16 wraps proof
→ Verify on-chain (cheap, ~200k gas EVM / ~50k CU Solana)
```

Key facts for 2026:
- SP1 Hypercube proves 99.7% of Ethereum blocks in under 12s on 16 GPUs
- Eliminated proximity gap conjecture dependency (stronger security)
- Available on Succinct Prover Network (mainnet)
- Formally verified RISC-V constraints with Nethermind + Ethereum Foundation

---

## SP1 Program Structure

```
sp1-quantum/
├── program/
│   ├── src/main.rs     ← Runs inside the proof
│   └── Cargo.toml
└── script/
    ├── src/bin/
    │   └── prove.rs    ← Generates + verifies proof
    ├── build.rs        ← Auto-compiles ELF
    └── Cargo.toml
```

---

## zkVM Program (Inside Proof)

```rust
// program/src/main.rs
#![no_main]
sp1_zkvm::entrypoint!(main);

use sha2::{Digest, Sha256};

pub fn main() {
    // Private inputs (not visible in proof)
    let seed: [u8; 32]         = sp1_zkvm::io::read();
    let cert_hash: [u8; 32]    = sp1_zkvm::io::read();
    let tier: u8               = sp1_zkvm::io::read();
    let stat_score: u16        = sp1_zkvm::io::read();
    let protocol_id: [u8; 32]  = sp1_zkvm::io::read();
    let usage_ctx: [u8; 32]    = sp1_zkvm::io::read();

    // Verify inputs
    assert!(tier >= 1 && tier <= 4);
    assert!(!seed.iter().all(|&b| b == 0), "Null seed rejected");
    assert!(!cert_hash.iter().all(|&b| b == 0), "Null cert rejected");

    // Minimum score per tier
    let min_score: u16 = match tier { 1 => 0, 2 => 8500, 3 => 9000, _ => 9500 };
    assert!(stat_score >= min_score);

    // Derive protocol-specific seed
    let mut h = Sha256::new();
    h.update(b"quantum_oracle_v1:");
    h.update(&seed);
    h.update(&protocol_id);
    h.update(&usage_ctx);
    h.update(&[tier]);
    let derived_seed: [u8; 32] = h.finalize().into();

    // Derivation commitment
    let mut h2 = Sha256::new();
    h2.update(b"derivation_commitment:");
    h2.update(&derived_seed);
    h2.update(&cert_hash);
    h2.update(&stat_score.to_le_bytes());
    let commitment: [u8; 32] = h2.finalize().into();

    // Binding hash — ties all inputs to all outputs
    let mut h3 = Sha256::new();
    h3.update(b"binding:");
    h3.update(&seed);
    h3.update(&cert_hash);
    h3.update(&derived_seed);
    h3.update(&commitment);
    h3.update(&[tier]);
    h3.update(&stat_score.to_le_bytes());
    let binding_hash: [u8; 32] = h3.finalize().into();

    // Public outputs — visible in the proof
    sp1_zkvm::io::commit(&derived_seed);
    sp1_zkvm::io::commit(&commitment);
    sp1_zkvm::io::commit(&(tier <= 2));  // physics_verified
    sp1_zkvm::io::commit(&tier);
    sp1_zkvm::io::commit(&stat_score);
    sp1_zkvm::io::commit(&binding_hash);
}
```

---

## Prover Script

```rust
// script/src/bin/prove.rs
use sp1_sdk::{include_elf, ProverClient, SP1Stdin};

pub const ELF: &[u8] = include_elf!("quantum-oracle-program");

#[tokio::main]
async fn main() {
    let client = ProverClient::from_env();
    let (pk, vk) = client.setup(ELF);

    // Feed quantum seed as private input
    let mut stdin = SP1Stdin::new();
    stdin.write(&seed_bytes);       // [u8; 32]
    stdin.write(&cert_bytes);       // [u8; 32]
    stdin.write(&tier);             // u8
    stdin.write(&stat_score);       // u16
    stdin.write(&protocol_id);      // [u8; 32]
    stdin.write(&usage_ctx);        // [u8; 32]

    // Generate Groth16 proof
    let proof = client
        .prove(&pk, &stdin)
        .groth16()
        .run()
        .expect("Proof generation failed");

    // Verify locally
    client.verify(&proof, &vk).expect("Verification failed");

    // Save
    proof.save("quantum_proof.bin").unwrap();
    println!("Verification key: {}", vk.bytes32());
}
```

**Run locally:**
```bash
cargo run --release --bin prove -- --execute   # Fast test
cargo run --release --bin prove -- --prove     # Full proof
```

**Run on Succinct Prover Network:**
```bash
export SP1_PRIVATE_KEY=your_key
SP1_PROVER=network cargo run --release --bin prove -- --prove
```

---

## Nullifier Generation

For private transactions (Tornado Cash pattern on Solana):

```rust
// In your ZK program — prove nullifier came from quantum seed

pub fn derive_nullifier(
    quantum_seed:   [u8; 32],
    deposit_index:  u64,
    user_secret:    [u8; 32],
) -> [u8; 32] {
    // Nullifier = H(quantum_seed || deposit_index || user_secret)
    // quantum_seed proved to be quantum-certified
    // Attacker cannot predict nullifier without the seed
    let mut h = Sha256::new();
    h.update(b"nullifier:");
    h.update(&quantum_seed);
    h.update(&deposit_index.to_le_bytes());
    h.update(&user_secret);
    h.finalize().into()
}
```

---

## Trusted Setup Replacement Flow

```
Step 1: Request quantum seed
  → Call QuantumBeacon Solana program
  → Receive certified [u8; 32] + certificate PDA

Step 2: Run SP1 proof
  → Feed seed as private input
  → Program derives protocol-specific seed
  → Commits derivation publicly
  → Generates Groth16 proof

Step 3: Submit proof on-chain
  → Call SP1QuantumVerifier program
  → Verify Groth16 proof (SP1 verifier program)
  → Cross-reference certificate PDA
  → Record: protocol X used quantum seed at round Y

Step 4: Initialize your ZK system
  → Use derived_seed for parameter generation
  → Publish parameter_commitment on-chain
  → Anyone can verify: seed → commitment → parameters
```

---

## Cargo.toml for SP1 Programs

```toml
# program/Cargo.toml
[package]
name    = "quantum-oracle-program"
version = "1.0.0"
edition = "2021"

[dependencies]
sp1-zkvm = "4.0.0"
sha2     = { version = "0.10", default-features = false }

# script/Cargo.toml
[package]
name    = "quantum-oracle-script"
version = "1.0.0"
edition = "2021"

[build-dependencies]
sp1-build = "4.0.0"

[dependencies]
sp1-sdk    = "4.0.0"
tokio      = { version = "1", features = ["full"] }
reqwest    = { version = "0.12", features = ["json"] }
serde      = { version = "1", features = ["derive"] }
serde_json = "1"
hex        = "0.4"
sha2       = "0.10"
```

---

## Installation

```bash
# Install SP1 toolchain
curl -L https://sp1.succinct.xyz | bash && sp1up

# Verify
cargo prove --version

# Create new SP1 project
cargo prove new --bare quantum-oracle
```

---

## Common Issues

| Issue | Cause | Fix |
|-------|-------|-----|
| `SP1_PROVER not set` | Using CPU prover | Set `SP1_PROVER=network` |
| `ELF not found` | Program not compiled | Run `cd program && cargo prove build` |
| `Proof verification failed` | Wrong vkey | Re-run `cargo run --bin vkey` after any program change |
| Out of memory locally | Proof too large | Use Succinct Prover Network |
