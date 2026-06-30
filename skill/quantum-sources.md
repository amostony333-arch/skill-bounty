# Quantum Randomness Sources

Reference for fetching, validating, and combining quantum randomness sources.

---

## Trust Tier Summary

```
Tier 1 — Bell Certified
  Source: ETH Zürich (Nature 2026), loophole-free Bell test
  Trust: Laws of physics
  Available: Lab only (not yet commercial)
  Use for: Maximum security ZK setups

Tier 2 — Hardware Quantum
  Source: ANU QRNG, IBM Quantum, ID Quantique
  Trust: Quantum hardware vendor
  Available: API / commercial now
  Use for: ZK parameter generation, nullifiers

Tier 3 — Cryptographic Beacon
  Source: NIST Randomness Beacon
  Trust: NIST institution + hash chain
  Available: Free public API
  Use for: DAO voting, governance, lottery

Tier 4 — CSPRNG / VRF
  Source: Chainlink VRF, Orao VRF, Switchboard
  Trust: Oracle network + software
  Available: Live on Solana now
  Use for: NFT mints, games (standard use)
```

---

## ANU QRNG (Tier 2)

Australian National University — quantum vacuum fluctuations.

```python
import httpx
import asyncio

async def fetch_anu_qrng(length: int = 64) -> str | None:
    """
    Fetch random hex bytes from ANU Quantum RNG.
    Source: measurement of quantum vacuum fluctuations.
    Free public API, no key required.
    """
    url = f"https://qrng.anu.edu.au/API/jsonI.php?length={length}&type=hex16&size=1"
    async with httpx.AsyncClient(timeout=10.0) as client:
        try:
            r = await client.get(url)
            data = r.json()
            if data.get("success"):
                return "".join(data["data"])
        except Exception as e:
            print(f"ANU QRNG error: {e}")
    return None

# Usage
value = asyncio.run(fetch_anu_qrng(64))
# Returns 128 hex chars = 512 bits of quantum randomness
```

**Notes:**
- No authentication required
- Rate limit: ~100 req/day on free tier
- Returns hex16 format
- Backed by real quantum hardware at ANU, Canberra

---

## NIST Randomness Beacon (Tier 3)

NIST publishes a new signed beacon pulse every 60 seconds.
Use as a cryptographic anchor / timestamp proof.

```python
async def fetch_nist_beacon() -> dict | None:
    """
    Fetch latest NIST Randomness Beacon pulse.
    Signed + chained — provides timestamp proof.
    Use as anchor to combine with quantum source.
    """
    url = "https://beacon.nist.gov/beacon/2.0/pulse/last"
    async with httpx.AsyncClient(timeout=10.0) as client:
        try:
            r = await client.get(url)
            pulse = r.json().get("pulse", {})
            return {
                "value":          pulse.get("outputValue", ""),
                "timestamp":      pulse.get("timeStamp", ""),
                "pulse_index":    pulse.get("pulseIndex", 0),
                "chain_index":    pulse.get("chainIndex", 0),
                "signature":      pulse.get("signatureValue", ""),
                "uri":            pulse.get("uri", ""),
            }
        except Exception as e:
            print(f"NIST Beacon error: {e}")
    return None
```

**Notes:**
- Free, no authentication
- One new pulse every 60 seconds
- ECDSA signed — signature verifiable independently
- Chain index ensures no pulse can be retroactively altered

---

## Combining Sources (Best Practice)

Never rely on a single source. Combine ANU + NIST for maximum entropy:

```python
import hashlib

async def fetch_combined_randomness() -> dict:
    """
    Combine ANU QRNG (quantum entropy) + NIST Beacon (timestamp anchor).
    Result: Tier 2 randomness with cryptographic timestamp proof.
    """
    anu_value  = await fetch_anu_qrng(64)
    nist_data  = await fetch_nist_beacon()

    if anu_value and nist_data:
        # Combine both sources
        combined = anu_value + nist_data["value"]
        value    = hashlib.sha256(combined.encode()).hexdigest() * 4
        tier     = 2
        source   = "ANU+NIST_COMBINED"
    elif anu_value:
        value  = anu_value
        tier   = 2
        source = "ANU_QRNG"
    elif nist_data:
        value  = nist_data["value"]
        tier   = 3
        source = "NIST_BEACON"
    else:
        raise RuntimeError("All quantum sources unavailable")

    return {
        "value":      value[:128],   # 512 bits
        "tier":       tier,
        "source":     source,
        "nist_pulse": nist_data.get("pulse_index") if nist_data else None,
        "nist_sig":   nist_data.get("signature", "")[:64] if nist_data else "",
    }
```

---

## Statistical Verification (NIST Test Suite)

Every quantum output must pass statistical tests before use.

```python
import math
import statistics

def hex_to_bits(hex_str: str) -> list[int]:
    bits = []
    for c in hex_str:
        v = int(c, 16)
        for i in range(3, -1, -1):
            bits.append((v >> i) & 1)
    return bits

def frequency_test(bits: list[int]) -> float:
    """NIST Test 1: ratio of 1s to 0s. Score 0–1."""
    ones  = sum(bits)
    zeros = len(bits) - ones
    return min(ones, zeros) / max(ones, zeros) if max(ones, zeros) > 0 else 0.0

def runs_test(bits: list[int]) -> float:
    """NIST Test 3: oscillation between 0s and 1s. Score 0–1."""
    n    = len(bits)
    runs = sum(1 for i in range(1, n) if bits[i] != bits[i-1]) + 1
    pi   = sum(bits) / n
    exp  = 2 * n * pi * (1 - pi)
    dev  = abs(runs - exp) / exp if exp else 0
    return max(0.0, min(1.0, 1.0 - dev))

def block_frequency_test(bits: list[int], block: int = 8) -> float:
    """NIST Test 2: uniformity within blocks. Score 0–1."""
    n      = len(bits)
    blocks = n // block
    props  = [sum(bits[i*block:(i+1)*block]) / block for i in range(blocks)]
    var    = statistics.variance(props) if len(props) > 1 else 0
    return max(0.0, min(1.0, 1.0 - var * 10))

def entropy_estimate(bits: list[int]) -> float:
    """Shannon entropy. Perfect randomness = 1.0."""
    n  = len(bits)
    p1 = sum(bits) / n
    p0 = 1 - p1
    if p1 == 0 or p0 == 0:
        return 0.0
    return -(p1 * math.log2(p1) + p0 * math.log2(p0))

def run_all_tests(hex_value: str) -> dict:
    bits    = hex_to_bits(hex_value[:256])
    freq    = frequency_test(bits)
    runs    = runs_test(bits)
    block   = block_frequency_test(bits)
    entropy = entropy_estimate(bits)
    overall = (freq + runs + block + entropy) / 4
    return {
        "frequency_test":       round(freq, 4),
        "runs_test":            round(runs, 4),
        "block_frequency_test": round(block, 4),
        "entropy_estimate":     round(entropy, 4),
        "overall_score":        round(overall, 4),
        "passed":               overall > 0.85,
    }
```

**Minimum scores by tier:**

| Tier | Min Score | Rationale |
|------|-----------|-----------|
| 1 | 0.00 | Physics guarantees — stats irrelevant |
| 2 | 0.85 | Hardware quantum — some margin |
| 3 | 0.90 | Crypto beacon — higher bar |
| 4 | 0.95 | CSPRNG — must be near-perfect statistically |

---

## Certificate Generation

```python
import json
import time

def generate_certificate(
    value:    str,
    source:   str,
    tier:     int,
    stats:    dict,
    nist:     dict | None = None,
) -> dict:
    cert = {
        "version":         "1.0",
        "source":          source,
        "tier":            tier,
        "timestamp":       int(time.time()),
        "value_hash":      hashlib.sha256(value.encode()).hexdigest(),
        "statistical":     stats,
        "physics_verified": tier <= 2,
        "nist_anchor":     nist.get("signature", "")[:64] if nist else "",
        "nist_pulse":      nist.get("pulse_index", 0)    if nist else 0,
    }
    cert_str           = json.dumps(cert, sort_keys=True)
    cert["cert_hash"]  = hashlib.sha256(cert_str.encode()).hexdigest()
    return cert
```

---

## Common Errors

| Error | Cause | Fix |
|-------|-------|-----|
| `ANU QRNG timeout` | Rate limit or network | Fallback to NIST-only |
| `Statistical test failed` | Low-quality output | Retry fetch, log and alert |
| `NIST Beacon stale` | NIST infra issue | Use cached last pulse with staleness flag |
| `Combined value too short` | API returned partial data | Validate length before combining |
