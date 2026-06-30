# Quantum Randomness Skill for Solana AI Kit

A Claude Code / Codex skill that turns any AI coding agent into an expert on **quantum-certified randomness infrastructure for Solana** — replacing trust-dependent VRF solutions with physics-guaranteed certificates.

> **Novel skill** — fills a genuine gap in the ecosystem. No existing Solana skill addresses quantum randomness, ZK trusted setup replacement, or Bell-certified certificate infrastructure.

---

## The Problem

Every Solana application needing randomness today trusts an oracle:

```
Switchboard VRF → trust the oracle network
Orao VRF       → trust the multi-sig operators
Chainlink VRF  → trust Chainlink nodes
```

The trust question is always: **"Do you trust the provider?"**

For high-stakes applications — ZK trusted setups, large DAO treasury votes, bridge security, private transaction nullifiers — that's not good enough.

Quantum randomness shifts the question to: **"Do you trust the laws of physics?"**

---

## What This Skill Enables

Any Claude Code / Codex agent with this skill can immediately help builders:

- **Set up a quantum oracle** — FastAPI backend consuming ANU QRNG + NIST Beacon, publishing to Solana every 60s
- **Build Anchor programs** — QuantumBeacon, CertificateRegistry PDAs with full test coverage
- **Replace ZK trusted setups** — SP1 Hypercube zkVM proves quantum seed usage, eliminating ceremony coordination
- **Generate certified nullifiers** — Physics-backed nullifiers for private transactions on Solana
- **Audit randomness quality** — NIST statistical test suite built-in, 4 tests on every output
- **Choose the right tier** — Trust tier comparison: quantum vs NIST vs VRF for any use case
- **Governance applications** — DAO voting, leader election, fair ordering with public certificate trail

---

## Skill Structure

```
quantum-randomness-skill/
├── skill/
│   ├── SKILL.md                ← Entry point + routing
│   ├── quantum-sources.md      ← ANU QRNG, NIST Beacon, Bell tests, stats
│   ├── solana-programs.md      ← Anchor programs, PDAs, LiteSVM tests
│   ├── zk-integration.md       ← SP1 Hypercube, trusted setup, nullifiers
│   ├── oracle-backend.md       ← FastAPI, publishing loop, deployment
│   ├── governance.md           ← DAO voting, MACI, trust tier comparison
│   └── resources.md            ← APIs, papers, SDK links
├── agents/
│   ├── quantum-architect.md    ← System design, trust tier decisions
│   ├── solana-oracle-engineer.md ← Anchor program implementation
│   └── zk-engineer.md          ← SP1 zkVM programs + proof generation
├── commands/
│   ├── verify-randomness.md    ← Run NIST tests on a hex value
│   └── compare-sources.md      ← Compare trust tiers for a use case
├── rules/
│   └── rust.md                 ← Anchor/Rust code standards
├── install.sh
└── README.md
```

---

## Installation

```bash
git clone https://github.com/YOUR_USERNAME/quantum-randomness-skill
cd quantum-randomness-skill
chmod +x install.sh
./install.sh
```

Or with `-y` to skip confirmation:

```bash
./install.sh -y
```

Installs to `~/.claude/skills/quantum-randomness/`

---

## What Makes This Different

### Novel Problem
No Solana skill exists for quantum randomness infrastructure. The DoraHacks Quantum Newsletter (June 2026) explicitly identified this as the most immediately actionable direction for Web3 — and called for exactly this kind of trust ledger and infrastructure layer.

### Production-Grade, Not AI Slop
- Real APIs: ANU QRNG, NIST Beacon (both freely accessible)
- Real ZK: SP1 Hypercube V6 (current production zkVM)
- Real Solana: Anchor 0.31+ with LiteSVM tests, PDA design, proper error handling
- Real crypto: SHA256 certificates, NIST statistical test suite
- Real trust model: Explicit tier system with clear security assumptions

### Cross-Domain
Bridges quantum physics → ZK cryptography → Solana programs → governance applications. Genuinely cross-domain in a way that benefits the entire Solana builder ecosystem.

### Progressive / Token-Efficient
SKILL.md routes to focused files only when needed. An agent building an NFT mint never loads the ZK integration docs. An agent replacing a Groth16 trusted setup only loads zk-integration.md.

---

## Trust Tier System

| Tier | Source | Trust Anchor | Available |
|------|--------|-------------|-----------|
| 1 | Bell Certified (ETH Zürich) | Laws of physics | Lab only (future) |
| 2 | ANU QRNG / IBM Quantum | Quantum hardware | Now (API) |
| 3 | NIST Randomness Beacon | Institution + hash chain | Now (free) |
| 4 | Switchboard / Orao / Chainlink | Oracle network | Now on Solana |

This skill helps builders choose the right tier and implement it.

---

## License

MIT
