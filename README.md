# opencode-devstral

Run [Devstral](https://mistral.ai/news/devstral-2-vibe-cli) coding models with [OpenCode](https://opencode.ai) — setup guides, benchmarks, and tuning for multiple deployment options.

Currently tested with [Devstral Small 2](https://huggingface.co/mistralai/Devstral-Small-2-24B-Instruct-2512) (24B, Apache 2.0, 128K+ context, tool-call support).

## Quick start

1. [Install OpenCode and global config](docs/prerequisites.md)
2. Pick a deployment option below and follow the guide
3. Run `opencode` from any project directory

## Deployment options

| Setup | Guide | Cost | Speed | Max context |
|---|---|---|---|---|
| Mistral API (hosted) | [setup](docs/setup-mistral-api.md) | ~$0.10/M in, $0.30/M out | ~193 tok/s | 256k |
| Verda GPU (remote) | [setup](docs/setup-verda.md) | ~$0.43/h spot (A100 80GB) | ~59 tok/s | ~65k |
| Verda GPU (remote) | [setup](docs/setup-verda.md) | ~$0.79/h spot (RTX PRO 6000) | ~53 tok/s | ~128k |
| Ollama (local macOS) | [setup](docs/setup-local-ollama.md) | Free | ~23 tok/s | ~98k+ |

All three use the same model weights. The [OpenCode config](opencode.example.json) includes all providers — switch between them in the model picker.

## Benchmarks

### Synthetic (tok/s)

Measured with [`benchmark.sh`](benchmark.sh) — fizzbuzz prompt, `max_tokens=512`.

| | Local (M3 Max Pro 128GB, 32k ctx) | Verda A100 40GB | Verda A100 80GB | Verda RTX PRO 6000 | Mistral API |
|---|---|---|---|---|---|
| Speed | ~23 tok/s | ~50 tok/s | ~59 tok/s | ~53 tok/s | ~193 tok/s |
| Cost | Free | ~$0.28/h spot | ~$0.43/h spot | ~$0.79/h spot | ~$0.10/M in, $0.30/M out |

> Benchmark config (March 2026): A100 40GB with `--max-model-len 32768`, A100 80GB with `--max-model-len 65536`, RTX PRO 6000 with `--max-model-len 131072`, local with `num_ctx 32768` (no q8_0 KV cache). Mistral API used `devstral-small-latest` (resolved to `devstral-small-2-25-12`).

### Real-world: codebase review

Reviewed a [5.7k line Python/FastAPI project](https://github.com/mikiwiik/data-serving-poc). Full results in [docs/benchmark-code-review.md](docs/benchmark-code-review.md). Local used `num_ctx 98304` with `OLLAMA_KV_CACHE_TYPE=q8_0` (`ollama-start --large-ctx`).

| | Mistral API | Verda RTX PRO 6000 | Verda A100 80GB | Local (98k ctx) |
|---|---|---|---|---|
| Time | **14s** | ~1 min | ~1.5 min | ~29 min |
| Quality | Good | Good | Good | Best (most detailed) |
| Cost | ~$0.003 | ~$0.014 | ~$0.01 | Free |

Mistral API is ~120x faster than local. RTX PRO 6000 edges out A100 80GB on this task — the 131k context avoids compaction that slows the A100 80GB run. Quality is comparable across all providers.

## Local tuning (Apple Silicon)

The [`ollama-start`](scripts/ollama-start.sh) script includes optimizations (FlashAttention, keep-alive) that showed minor performance improvements in benchmarking on M3 Max Pro 128GB. Use `ollama-start --large-ctx` for large context tasks like codebase review — enables q8_0 KV cache quantization, trading ~5% speed for 2x KV cache capacity.

## See also

- [TODO.md](TODO.md) — next steps (more models, GPU tiers, alternative tools)
- [docs/prerequisites.md](docs/prerequisites.md) — shared setup steps
- [opencode.example.json](opencode.example.json) — combined config for all providers
