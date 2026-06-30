# Oracle Backend — FastAPI Publishing Loop

Reference for running the quantum oracle backend and publishing to Solana.

---

## FastAPI Endpoint Summary

```python
# main.py key endpoints
GET  /randomness/latest   → Latest certified package
GET  /randomness/fresh    → Force-fetch new randomness
GET  /ledger?limit=50     → Public trust ledger
GET  /certificate/{hash}  → Verify a certificate hash
GET  /stats               → Protocol statistics
POST /consume             → Protocol consumes randomness
```

---

## Background Publishing Loop

```python
import asyncio
from solders.keypair import Keypair

async def oracle_loop(program, oracle_keypair: Keypair):
    """Fetch + verify + publish every 60 seconds."""
    round_id = 1
    while True:
        try:
            # 1. Fetch quantum randomness
            pkg = await fetch_combined_randomness()

            # 2. Run statistical tests
            stats = run_all_tests(pkg["value"])
            if not stats["passed"]:
                print(f"⚠ Statistical test failed: {stats}")
                await asyncio.sleep(60)
                continue

            # 3. Generate certificate
            cert = generate_certificate(
                pkg["value"], pkg["source"],
                pkg["tier"], stats
            )

            # 4. Publish to Solana
            value_bytes = bytes.fromhex(pkg["value"][:64])
            cert_bytes  = bytes.fromhex(cert["cert_hash"][:64])
            score_int   = int(stats["overall_score"] * 10000)

            await publish_round_to_solana(
                program, oracle_keypair,
                round_id, value_bytes,
                pkg["tier"], cert_bytes, score_int
            )

            round_id += 1
            print(f"✓ Round {round_id} | Tier {pkg['tier']} | Score {stats['overall_score']:.4f}")

        except Exception as e:
            print(f"Oracle loop error: {e}")

        await asyncio.sleep(60)
```

---

## Environment Variables

```bash
# .env
ORACLE_PRIVATE_KEY=your_base58_solana_oracle_keypair
SOLANA_RPC_URL=https://api.devnet.solana.com
PROGRAM_ID=your_deployed_program_id
API_BASE=http://localhost:8000
```

---

## Startup

```bash
# Install
pip install fastapi uvicorn httpx solders anchorpy python-dotenv

# Run oracle backend
uvicorn main:app --reload --port 8000

# Run publishing loop (separate process)
python publish_solana.py
```
