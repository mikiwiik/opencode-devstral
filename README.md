# Devstral + OpenCode

Run Devstral Small 2 (24B) as a coding agent via OpenCode. Three deployment options:

| Setup | Guide | Cost | Speed |
|---|---|---|---|
| Mistral API | [docs/setup-mistral-api.md](docs/setup-mistral-api.md) | ~$0.10/M in, $0.30/M out | ~193 tok/s |
| Verda GPU (remote) | [docs/setup-verda.md](docs/setup-verda.md) | ~$0.43/h spot (A100 80GB) | ~59 tok/s |
| Ollama (local) | [docs/setup-local-ollama.md](docs/setup-local-ollama.md) | Free | ~23 tok/s |

## Performance comparison

Measured with `benchmark.sh` — fizzbuzz prompt, `max_tokens=512`, Devstral Small 2.

| | Local (M3 Max Pro 128GB) | Verda A100 40GB | Verda A100 80GB | Mistral API |
|---|---|---|---|---|
| Cost | Free | ~$0.28/h spot | ~$0.43/h spot | ~$0.10/M in, $0.30/M out |
| Speed | ~23 tok/s | ~50 tok/s | ~59 tok/s | ~193 tok/s |
| Max context | ~128k (RAM limited) | ~32k | ~65k | 256k |

> **Benchmark config** (March 2026): A100 40GB with `--max-model-len 32768`, A100 80GB with `--max-model-len 65536`, local with `num_ctx 32768`. Mistral API used `devstral-small-latest` (resolved to `devstral-small-2-25-12` at time of testing).

> **Local tuning results**: FlashAttention enabled by default (~23 tok/s, no overhead). KV cache quantization (q8_0) available via `ollama-start --large-ctx` — trades ~5% speed for 2x KV cache capacity on large context tasks. See [`scripts/ollama-start.sh`](scripts/ollama-start.sh).

Mistral API is by far the fastest (~193 tok/s) with the largest context (256k) and pay-per-token pricing. Verda is a good middle ground for sustained use. Local is free and offline but slowest.

## Quick start

1. [Install OpenCode and global config](docs/prerequisites.md)
2. Follow one or more provider setup guides above
3. Run `opencode` from any project directory

## Model

[Devstral Small 2](https://huggingface.co/mistralai/Devstral-Small-2-24B-Instruct-2512) — 24B parameter coding model by Mistral. Apache 2.0, 128K+ context, tool-call support.

## See also

- [TODO.md](TODO.md) — next steps (GPU benchmarking, more models, alternative tools)
- [benchmark.sh](benchmark.sh) — quick inference speed test
- [docs/benchmark-code-review.md](docs/benchmark-code-review.md) — real-world codebase review benchmark results
