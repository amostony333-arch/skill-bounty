# Trust Ledger — Tier System & Public Auditability

Reference for comparing randomness sources by trust tier and building public audit trails.

---

## Trust Tier System

```
Tier 1 — Bell Certified
  Trust anchor: Laws of physics (Bell inequality violation)
  Source: ETH Zürich lab (Nature 2026) — not yet commercial
  Certificate: Physics-guaranteed, loophole-free

Tier 2 — Hardware Quantum
  Trust anchor: Quantum hardware vendor
  Source: ANU QRNG, IBM Quantum
  Certificate: Quantum source + NIST anchor + 4 statistical tests

Tier 3 — Cryptographic Beacon
  Trust anchor: Institution + hash chain
  Source: NIST Randomness Beacon
  Certificate: ECDSA signed, chained pulse index

Tier 4 — VRF / CSPRNG
  Trust anchor: Oracle network or software
  Source: Switchboard VRF, Orao VRF, Chainlink VRF
  Certificate: Cryptographic VRF proof
```

---

## Tier vs Current Solana Solutions

| Solution | Trust Anchor | Tier |
|----------|-------------|------|
| Switchboard VRF | Oracle network consensus | 4 |
| Orao VRF | Multi-sig oracle | 4 |
| Chainlink VRF | Chainlink nodes | 4 |
| DRAND | Threshold network | 3–4 |
| NIST Beacon | US government + hash chain | 3 |
| ANU QRNG | Quantum hardware | 2 |
| Bell-certified | Laws of physics | 1 |

**The key shift:**
```
Tier 4: "Do you trust Chainlink?"
Tier 2: "Do you trust ANU's quantum hardware?"
Tier 1: "Do you trust the laws of physics?"
```

---

## Minimum Tier By Use Case

| Use Case | Min Tier | Rationale |
|----------|---------|-----------|
| NFT mint / casual game | 4 | Low stakes, VRF sufficient |
| DAO vote < $100K | 3 | Community trust acceptable |
| DAO vote > $1M | 2 | Quantum source defensible |
| ZK trusted setup | 2 | Ceremony replacement requires quantum |
| Nullifier generation | 2 | Predictability breaks privacy |
| Bridge security | 2 | High value target |
| Legal / court-defensible | 1 | Physics certificate required |

---

## Public Trust Ledger On-Chain

The `CertificateRegistry` Solana program is the public trust ledger:

```
Protocol calls registerCertificate()
→ CertificateEntry PDA permanently recorded
→ Fields: consumer, round_id, tier, usage_context, physics_verified

Anyone queries:
→ "Did Protocol X use quantum randomness?"
→ "What tier was used?"
→ "What was the certificate hash?"
→ Full chain of custody: source → oracle → on-chain → usage
```

### Querying

```typescript
const [certPda] = PublicKey.findProgramAddressSync(
    [Buffer.from("certificate"), certHash],
    PROGRAM_ID
);
const cert = await program.account.certificateEntry.fetch(certPda);

console.log({
    consumer:        cert.consumer.toString(),
    tier:            cert.tier,           // 1-4
    physicsVerified: cert.physicsVerified, // true if tier <= 2
    usageContext:    cert.usageContext,    // "zk_setup" | "nullifier" | etc
    roundId:         cert.roundId.toNumber(),
    timestamp:       cert.timestamp.toNumber(),
});
```

---

## Defensibility Matrix

| Scenario | Tier 4 (VRF) | Tier 2 (Quantum) |
|----------|-------------|-----------------|
| Internal audit | ✓ sufficient | overkill |
| Community governance | ✓ sufficient | bonus |
| $10M treasury vote | arguable | recommended |
| Regulatory review | provider logs | public ledger |
| Legal challenge | "trust us" | physics cert |
| Court evidence | hard to prove | certificate |
| Government-level | insufficient | required |

---

## Certificate Anatomy

Every certified package contains:

```json
{
  "version": "1.0",
  "source": "ANU+NIST_COMBINED",
  "tier": 2,
  "timestamp": 1751234567,
  "value_hash": "sha256_of_random_value",
  "statistical_tests": {
    "frequency_test": 0.9823,
    "runs_test": 0.9741,
    "block_frequency_test": 0.9654,
    "entropy_estimate": 0.9987,
    "overall_score": 0.9801,
    "passed": true
  },
  "physics_verified": true,
  "nist_anchor": "first_64_chars_of_nist_signature",
  "nist_pulse": 3847291,
  "cert_hash": "sha256_of_all_above_fields"
}
```

The `cert_hash` is what gets stored on-chain in `QuantumBeacon` and `CertificateRegistry`.
Anyone can reconstruct and verify it independently.

---

## Comparing Sources For A Specific Use Case

Use the `/compare-sources` command to get a recommendation:
→ [compare-sources.md](../commands/compare-sources.md)
