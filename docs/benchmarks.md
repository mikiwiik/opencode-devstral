# Benchmarks

All benchmarks use [Devstral Small 2](https://huggingface.co/mistralai/Devstral-Small-2-24B-Instruct-2512) (24B) across providers. Results from March 2026.

## Quick dev tasks (synthetic)

**What it tests:** small-context, fast Q&A — represents everyday coding questions and short completions.

**Method:** [`benchmark.sh`](../scripts/benchmark.sh) — fizzbuzz prompt, `max_tokens=512`.

| | Local (M3 Max Pro 128GB, 32k ctx) | Verda A100 40GB | Verda A100 80GB | Verda RTX PRO 6000 | Mistral API |
|---|---|---|---|---|---|
| Speed | ~23 tok/s | ~50 tok/s | ~59 tok/s | ~53 tok/s | ~193 tok/s |
| Cost | Free | ~$0.28/h spot | ~$0.43/h spot | ~$0.79/h spot | ~$0.10/M in, $0.30/M out |

> **Config:** A100 40GB with `--max-model-len 32768`, A100 80GB with `--max-model-len 65536`, RTX PRO 6000 with `--max-model-len 131072`, local with `num_ctx 32768` (no q8_0 KV cache). Mistral API used `devstral-small-latest` (resolved to `devstral-small-2-25-12`).

## Codebase review (real-world)

**What it tests:** large-context analysis — represents code review, architecture analysis, and multi-file reasoning.

### Target codebase

[mikiwiik/data-serving-poc](https://github.com/mikiwiik/data-serving-poc) — Python/FastAPI data serving PoC.

| Category | Files | Lines |
|---|---|---|
| Python (app/) | 7 | 2,028 |
| HTML (static/) | 2 | 2,623 |
| Config/docs | 6 | 1,122 |
| **Total** | **15** | **5,773** |

### Prompt

```
review the codebase in the current repository. summarize the architecture, identify code quality issues, and suggest improvements
```

### Results

| | Mistral API | Verda RTX PRO 6000 | Verda A100 80GB | Local 98k | Local 32k |
|---|---|---|---|---|---|
| Model | devstral-small-latest | Devstral-Small-2-24B-Instruct-2512 | Devstral-Small-2-24B-Instruct-2512 | devstral-small-2-98k | devstral-small-2-32k |
| Time | **14s** | ~1 min | ~1.5 min | 28m 52s | 12m 12s |
| Tokens used | 76k (30% of 256k) | ~79k (61% of 131k) | 18k (compacted mid-run) | ~68k (55k subagent + 13k parent) | ~42k (31k subagent + 12k parent) |
| Context limit | 256k | 131k | 98k | 98k | 32k |
| Toolcalls | n/a | n/a | n/a | 19 | n/a |
| Quality | Good | Good | Good (created review file) | Best (most detailed) | Good |
| Cost | ~$0.003 | ~$0.79/h | ~$0.43/h | Free | Free |
| Approach | Read all files at once | Read all files at once | Read → compacted → continued | Subagent explore | Subagent explore |

### Observations

- **Mistral API** is ~120x faster than local for this task. The 256k context lets it load the entire codebase in one shot without compaction or subagents.
- **Verda RTX PRO 6000** (131k context) completed the review in ~1 min with no compaction — 79k tokens used only 61% of context. Slightly faster than A100 80GB despite ~10% lower tok/s (52.8 vs 59), because it avoids the compaction overhead.
- **Verda A100 80GB** (98k context) worked but hit the context limit mid-review and needed compaction. The 65k config from earlier failed entirely on this codebase (74k input tokens).
- **Local 98k** produced the most thorough review — more time meant more detailed analysis of naming conventions, code duplication, architecture patterns (DDD, CQRS), and security. OpenCode used an explore subagent with 55k tokens.
- **Local 32k** also succeeded by splitting work across subagents, avoiding the context limit. Faster than 98k but less detailed.
- **Quality is comparable** across all providers — same model weights produce similar insights. The main difference is depth of analysis (proportional to time spent).

### Cost per review

| Provider | Cost per review |
|---|---|
| Mistral API | ~$0.003 (76k × $0.10/M in + output × $0.30/M) |
| Verda A100 80GB | ~$0.01 (1.5 min of $0.43/h) |
| Verda RTX PRO 6000 | ~$0.014 (1.1 min of $0.79/h) |
| Local | Free |

At these prices, Mistral API is the clear winner for one-off reviews. Verda A100 80GB is the best value for self-hosted, but RTX PRO 6000 is worth the 40% cost premium when you need larger context (avoids compaction on bigger codebases). Local is free but slow.

## Recommendations

| Use case | Best provider | Why |
|---|---|---|
| Quick dev chat / small tasks | Mistral API | Fastest (~193 tok/s), cheapest per task |
| Sustained coding session | Verda A100 80GB | Best $/h value ($0.43/h), 65k context sufficient for most tasks |
| Large codebase analysis | Verda RTX PRO 6000 | 128k context avoids compaction, worth the premium for big codebases |
| Offline / free | Local Ollama | Slow but free, same model quality |

**Key insight:** speed matters most for dev chat (interactive latency), context size matters most for code review (avoiding compaction or subagent splits).

### Cost comparison across use cases

| | Mistral API | Verda RTX PRO 6000 | Verda A100 80GB | Local |
|---|---|---|---|---|
| 1 hour dev session (~50 prompts) | ~$0.15 | $0.79 | $0.43 | Free |
| Single code review (5k LOC) | ~$0.003 | ~$0.014 | ~$0.01 | Free |
| 8 hour workday | ~$1.20 | $6.32 | $3.44 | Free |

Mistral API is cheapest for light usage. Verda becomes cost-competitive if you're running the GPU for other tasks too (amortized across workloads).
