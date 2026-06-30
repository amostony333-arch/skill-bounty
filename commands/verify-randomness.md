---
description: "Run NIST statistical tests on a hex value to verify randomness quality"
---

You are verifying the quality of a random hex value using NIST statistical tests.

## Step 1: Parse Input

Ask the user for the hex value if not provided. Accept any length — use first 256 hex chars (1024 bits) for tests.

## Step 2: Run Tests

Run these 4 tests and report scores 0.0–1.0:

1. **Frequency (Monobit)** — ratio of 1s to 0s. Score = min/max ratio
2. **Runs** — oscillation between 0s and 1s. Score = 1 - deviation from expected
3. **Block Frequency** — uniformity within 8-bit blocks. Score = 1 - (variance × 10)
4. **Shannon Entropy** — bits per bit. Score 0–1 (1.0 = perfect)

Overall = average of all 4.

## Step 3: Report

```
NIST Statistical Verification
══════════════════════════════
Value (first 32 chars): {hex[:32]}...

Test Results:
  Frequency Test:       {score:.2%} {'✓' if score > 0.85 else '✗'}
  Runs Test:            {score:.2%} {'✓' if score > 0.85 else '✗'}
  Block Frequency Test: {score:.2%} {'✓' if score > 0.85 else '✗'}
  Shannon Entropy:      {score:.2%} {'✓' if score > 0.85 else '✗'}

Overall Score: {overall:.2%}
Verdict: {'PASS ✓' if overall > 0.85 else 'FAIL ✗ — do not use for ZK applications'}

Recommended tier for this score:
  - Tier 2 min: 85%   {'✓ meets requirement' if overall >= 0.85 else '✗'}
  - Tier 3 min: 90%   {'✓ meets requirement' if overall >= 0.90 else '✗'}
```
