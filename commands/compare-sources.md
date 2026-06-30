---
description: "Compare quantum randomness trust tiers for a given use case and recommend the minimum required source"
---

You are helping a Solana builder choose the right randomness source for their use case.

## Step 1: Identify the Use Case

Ask if not clear:
- What is the randomness being used for?
- What is the value at stake?
- Who needs to trust the result? (team only, community, regulators, courts?)
- Is legal/audit defensibility required?

## Step 2: Map to Trust Tier

| Use Case | Value at Stake | Recommended Tier |
|----------|---------------|-----------------|
| NFT mint / game outcome | Any | Tier 3–4 |
| DAO parameter vote | < $100K | Tier 3 |
| DAO treasury vote | $100K–$1M | Tier 2–3 |
| ZK trusted setup | Any | Tier 2 |
| Nullifier generation | Any | Tier 2 |
| Protocol-level governance | > $1M | Tier 2 |
| Bridge security | > $10M | Tier 2 |
| Legal/court-defensible | Any | Tier 1 (future) |

## Step 3: Compare Current Options

For each tier, describe:

**Tier 4 — Switchboard VRF / Orao VRF (available now on Solana)**
- Trust: Oracle network consensus
- Cost: ~0.001 SOL per request
- Latency: 1–2 slots
- Certificate: Cryptographic proof (VRF output)
- Weakness: Trust multi-sig oracle operators

**Tier 3 — NIST Beacon (via our oracle)**
- Trust: US Government institution + SHA-3 chain
- Cost: Oracle gas only
- Latency: 60 seconds (beacon cadence)
- Certificate: NIST signature + chain index
- Weakness: Trust NIST infrastructure

**Tier 2 — ANU QRNG (via our oracle, available now)**
- Trust: Quantum hardware at ANU
- Cost: Oracle gas only
- Latency: 60 seconds (oracle cadence)
- Certificate: Quantum source + NIST anchor + 4 statistical tests
- Weakness: Trust ANU hardware vendor

**Tier 1 — Bell Certified (future)**
- Trust: Laws of physics (Bell inequality)
- Cost: TBD (commercial not yet available)
- Latency: TBD
- Certificate: Physics-guaranteed
- Weakness: None (trust physics)

## Step 4: Recommendation

State clearly:
1. Minimum tier for their use case
2. Which source to use today
3. Migration path to higher tier when available
4. Whether to use our QuantumBeacon program or an existing VRF
