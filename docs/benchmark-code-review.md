# Benchmark: Codebase Review

Real-world benchmark comparing all three providers on a code review task.

## Target codebase

[mikiwiik/data-serving-poc](https://github.com/mikiwiik/data-serving-poc) — Python/FastAPI data serving PoC.

| Category | Files | Lines |
|---|---|---|
| Python (app/) | 7 | 2,028 |
| HTML (static/) | 2 | 2,623 |
| Config/docs | 6 | 1,122 |
| **Total** | **15** | **5,773** |

## Prompt

```
review the codebase in the current repository. summarize the architecture, identify code quality issues, and suggest improvements
```

## Results (March 2026)

| | Mistral API | Verda A100 80GB | Local 98k | Local 32k |
|---|---|---|---|---|
| Model | devstral-small-latest | Devstral-Small-2-24B-Instruct-2512 | devstral-small-2-98k | devstral-small-2-32k |
| Time | **14s** | ~1.5 min | 28m 52s | 12m 12s |
| Tokens used | 76k (30% of 256k) | 18k (compacted mid-run) | ~68k (55k subagent + 13k parent) | ~42k (31k subagent + 12k parent) |
| Context limit | 256k | 98k | 98k | 32k |
| Toolcalls | n/a | n/a | 19 | n/a |
| Quality | Good | Good (created review file) | Best (most detailed) | Good |
| Cost | ~$0.003 | ~$0.43/h | Free | Free |
| Approach | Read all files at once | Read → compacted → continued | Subagent explore | Subagent explore |

## Observations

- **Mistral API** is ~120x faster than local for this task. The 256k context lets it load the entire codebase in one shot without compaction or subagents.
- **Verda A100 80GB** (98k context) worked but hit the context limit mid-review and needed compaction. The 65k config from earlier failed entirely on this codebase (74k input tokens).
- **Local 98k** produced the most thorough review — more time meant more detailed analysis of naming conventions, code duplication, architecture patterns (DDD, CQRS), and security. OpenCode used an explore subagent with 55k tokens.
- **Local 32k** also succeeded by splitting work across subagents, avoiding the context limit. Faster than 98k but less detailed.
- **Quality is comparable** across all providers — same model weights produce similar insights. The main difference is depth of analysis (proportional to time spent).

## Cost analysis for this task

| Provider | Cost per review |
|---|---|
| Mistral API | ~$0.003 (76k × $0.10/M in + output × $0.30/M) |
| Verda A100 80GB | ~$0.01 (1.5 min of $0.43/h) |
| Local | Free |

At these prices, Mistral API is the clear winner for one-off reviews. Verda makes sense for sustained sessions. Local is free but slow.
