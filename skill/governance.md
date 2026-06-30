# Governance & Trust Ledger

Quantum randomness for DAO voting, leader election, and public auditability.

---

## Governance Use Cases

### DAO Voting — MACI Pattern
```
Problem: Who picks which votes get randomized?
Solution: QuantumBeacon round seed used to shuffle vote ordering
Result:   Nobody can predict ordering → no front-running votes
```

### Leader Election
```
Problem: Who picks the next block producer / committee member?
Solution: Certified round value used as VRF seed
Result:   Selection is physics-backed, not trust-backed
```

### Fair Ordering
```
Problem: MEV / sandwich attacks on transaction ordering
Solution: Quantum seed determines slot ordering
Result:   Provably random, certificate publicly verifiable
```

---

## Trust Tier vs Current Solana Solutions

| Solution | Trust Anchor | Tier Equivalent |
|----------|-------------|----------------|
| Switchboard VRF | Oracle network consensus | 4 |
| Orao VRF | Multi-sig oracle | 4 |
| Chainlink VRF | Chainlink nodes | 4 |
| DRAND | Threshold network | 3–4 |
| NIST Beacon | US government institution | 3 |
| ANU QRNG | Quantum hardware | 2 |
| Bell-certified | Laws of physics | 1 |

**Key distinction:**
- Tier 4: "Trust us, we didn't manipulate it" + cryptographic proof
- Tier 2: "Trust our quantum hardware" + quantum measurement proof
- Tier 1: "Trust physics" + Bell inequality violation certificate

---

## Public Trust Ledger

The CertificateRegistry Solana program acts as a public trust ledger:

```
Protocol registers → CertificateEntry PDA created
Anyone queries  → Can verify which protocols used quantum randomness
Auditors check  → Full chain-of-custody from quantum source to usage
```

### Querying the Ledger

```typescript
// Check if a protocol used quantum randomness
const [certPda] = PublicKey.findProgramAddressSync(
    [Buffer.from("certificate"), certHash],
    PROGRAM_ID
);
const certAccount = await program.account.certificateEntry.fetch(certPda);

console.log({
    consumer:        certAccount.consumer.toString(),
    tier:            certAccount.tier,
    physicsVerified: certAccount.physicsVerified,
    usageContext:    certAccount.usageContext,
    timestamp:       certAccount.timestamp.toNumber(),
});
```

---

## Defensibility Matrix

| Scenario | Tier 4 (VRF) | Tier 2 (Quantum) |
|----------|-------------|-----------------|
| Startup DAO vote | ✓ sufficient | overkill |
| $10M treasury vote | arguable | recommended |
| Government-level | insufficient | required |
| Legal challenge | "trust us" | physics cert |
| Regulatory audit | provider logs | public ledger |
| Court evidence | hard to prove | certificate |

The upgrade from Tier 4 → Tier 2 changes:
> "Do you trust Chainlink?"
to:
> "Do you trust the laws of quantum mechanics?"
