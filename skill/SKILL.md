---
name: quantum-randomness
description: Quantum-certified randomness infrastructure for Solana. Provides physics-guaranteed on-chain randomness for ZK privacy systems, DAO governance, fair ordering, and verifiable randomness — replacing trust-dependent solutions like VRF with quantum-source certificates. Use when building anything that needs provably unbiased randomness on Solana.
user-invocable: true
---

# Quantum Randomness Skill for Solana

> **Novel skill** — fills a genuine gap: no Solana skill addresses quantum-certified randomness or ZK trusted-setup replacement.

## What This Skill Is For

Use this skill when the user asks for:

### Verifiable Randomness (Beyond VRF)
- On-chain randomness that doesn't trust a single provider
- Fair NFT mints, lotteries, game outcomes with physics certificates
- Comparing Switchboard VRF / Orao VRF vs quantum sources
- Audit-ready randomness with public chain-of-custody

### ZK Privacy on Solana
- ZK trusted setup without a ceremony (no toxic waste)
- Nullifier generation for private transactions
- Parameter derivation for ZK programs on Solana
- Light Protocol / Compressed NFT privacy integration

### DAO & Governance Randomness
- MACI-style voting with certified randomness
- Leader election, committee selection, fair ordering
- Randomness that's legally and institutionally defensible
- Verifiable election results with physics-backed certificates

### Quantum Oracle Infrastructure
- Running a quantum randomness oracle (ANU QRNG, NIST Beacon)
- Publishing certified bits to Solana on-chain programs
- Building a trust ledger (Tier 1–4 source comparison)
- Certificate registry for public auditability

### SP1 / ZK Proof Integration
- Succinct SP1 Hypercube + quantum randomness
- Proving quantum seed usage inside a zkVM
- Groth16 trusted setup replacement
- On-chain proof verification for Solana programs

---

## Default Stack Decisions (Opinionated)

### 1) Solana Programs: Anchor 0.31+
- Anchor for program development
- Light Protocol for ZK compression
- Poseidon hasher for ZK-compatible hashing

### 2) Oracle Backend: FastAPI + Web3
- ANU QRNG API (Tier 2 — hardware quantum)
- NIST Randomness Beacon (Tier 3 — crypto anchor)
- Solana web3.js v2 / @solana/kit for on-chain publishing

### 3) ZK Proofs: SP1 Hypercube
- SP1 V6 (Hypercube) for zkVM programs
- Groth16 wrapping for compact on-chain verification
- Succinct Prover Network for proof generation

### 4) Frontend
- @solana/kit + React for dashboards
- Certificate viewer with QR-linkable proof URIs

### 5) Testing
- LiteSVM for Solana program unit tests
- NIST statistical test suite for randomness quality
- Anchor test framework for integration tests

---

## Operating Procedure

### 1. Classify the Task Layer

| Layer | Examples | Skill File |
|-------|----------|-----------|
| Quantum Sources | ANU QRNG, NIST Beacon, Bell test | [quantum-sources.md](quantum-sources.md) |
| Solana Programs | On-chain oracle, certificate registry | [solana-programs.md](solana-programs.md) |
| ZK Integration | SP1, trusted setup, nullifiers | [zk-integration.md](zk-integration.md) |
| Oracle Backend | FastAPI, publishing loop, verification | [oracle-backend.md](oracle-backend.md) |
| Governance | DAO voting, leader election, MACI | [governance.md](governance.md) |
| Trust Ledger | Tier comparison, public registry | [trust-ledger.md](trust-ledger.md) |

### 2. Pick the Right Agent

| Task Type | Agent | Model |
|-----------|-------|-------|
| Architecture / design decisions | quantum-architect | opus |
| Solana program implementation | solana-oracle-engineer | sonnet |
| ZK proof + SP1 implementation | zk-engineer | sonnet |
| Docs / README / audits | oracle-docs-writer | sonnet |

### 3. Trust Tier Decision

Always establish the required trust tier before building:

```
Tier 1 — Bell Certified     → Trust physics (future — ETH Zürich)
Tier 2 — Hardware Quantum   → Trust ANU QRNG / IBM Quantum
Tier 3 — Crypto Beacon      → Trust NIST Beacon (institutional)
Tier 4 — CSPRNG             → Trust software (Chainlink VRF level)
```

| Use Case | Minimum Tier |
|----------|-------------|
| ZK trusted setup | 2 |
| Nullifier generation | 2 |
| DAO governance | 3 |
| NFT mint / game | 3 |
| General lottery | 3 |

### 4. Certificate Requirements

Every randomness output must include:
- Source identifier
- Timestamp + NIST anchor
- Statistical test scores (4 NIST tests)
- Certificate hash (SHA256 of all fields)
- On-chain round reference

### 5. Deliverables

When implementing, always provide:
- Anchor program with certificate storage
- Oracle backend publishing loop
- Statistical verification pipeline
- Frontend certificate viewer
- Test suite (LiteSVM + NIST tests)

---

## Progressive Disclosure (Read When Needed)

### Core Quantum Skills

- [quantum-sources.md](quantum-sources.md) — ANU QRNG, NIST Beacon, Bell tests, API integration
- [oracle-backend.md](oracle-backend.md) — FastAPI oracle, verification pipeline, publishing loop
- [solana-programs.md](solana-programs.md) — Anchor programs: QuantumBeacon, CertificateRegistry
- [zk-integration.md](zk-integration.md) — SP1 Hypercube, trusted setup replacement, nullifiers
- [governance.md](governance.md) — DAO voting, MACI, leader election, fair ordering
- [trust-ledger.md](trust-ledger.md) — Tier system, public registry, auditability patterns

### Reference

- [resources.md](resources.md) — APIs, SDKs, papers, and tools

---

## Task Routing Guide

| User asks about... | Primary skill file |
|--------------------|-------------------|
| Getting quantum random numbers | quantum-sources.md |
| ANU QRNG integration | quantum-sources.md |
| NIST Beacon | quantum-sources.md |
| What is a Bell test | quantum-sources.md |
| Running an oracle backend | oracle-backend.md |
| FastAPI + Solana publishing | oracle-backend.md |
| Statistical verification | oracle-backend.md |
| Anchor randomness program | solana-programs.md |
| On-chain certificate registry | solana-programs.md |
| QuantumBeacon program | solana-programs.md |
| SP1 zkVM integration | zk-integration.md |
| Trusted setup replacement | zk-integration.md |
| Nullifier generation | zk-integration.md |
| ZK parameter generation | zk-integration.md |
| DAO voting randomness | governance.md |
| MACI / leader election | governance.md |
| Fair ordering | governance.md |
| Trust tier comparison | trust-ledger.md |
| Chainlink VRF vs quantum | trust-ledger.md |
| Orao VRF vs quantum | trust-ledger.md |
| Certificate audit | trust-ledger.md |
| Switchboard vs quantum | trust-ledger.md |

---

## Commands

| Command | Description |
|---------|-------------|
| /verify-randomness | Run NIST statistical tests on a hex value |
| /publish-round | Publish a certified round to Solana devnet |
| /check-certificate | Look up and verify a certificate hash |
| /compare-sources | Compare trust tiers for a given use case |

## Agents

| Agent | Purpose |
|-------|---------|
| **quantum-architect** | System design, trust tier decisions, architecture |
| **solana-oracle-engineer** | Anchor programs, on-chain publishing, PDAs |
| **zk-engineer** | SP1 programs, proof generation, trusted setup |
| **oracle-docs-writer** | README, audit reports, certificate documentation |
