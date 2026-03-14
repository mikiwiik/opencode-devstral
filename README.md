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
| Verda GPU (remote) | [setup](docs/setup-verda.md) | ~$0.43/h spot (A100 80GB) | ~59 tok/s | ~98k |
| Ollama (local macOS) | [setup](docs/setup-local-ollama.md) | Free | ~23 tok/s | ~98k+ |

All three use the same model weights. The [OpenCode config](opencode.example.json) includes all providers — switch between them in the model picker.

## Benchmarks

### Synthetic (tok/s)

Measured with [`benchmark.sh`](benchmark.sh) — fizzbuzz prompt, `max_tokens=512`.

| | Local (M3 Max Pro 128GB) | Verda A100 40GB | Verda A100 80GB | Mistral API |
|---|---|---|---|---|
| Speed | ~23 tok/s | ~50 tok/s | ~59 tok/s | ~193 tok/s |
| Cost | Free | ~$0.28/h spot | ~$0.43/h spot | ~$0.10/M in, $0.30/M out |

> Benchmark config (March 2026): A100 40GB with `--max-model-len 32768`, A100 80GB with `--max-model-len 65536`, local with `num_ctx 32768`. Mistral API used `devstral-small-latest` (resolved to `devstral-small-2-25-12`).

### Real-world: codebase review

Reviewed a [5.7k line Python/FastAPI project](https://github.com/mikiwiik/data-serving-poc). Full results in [docs/benchmark-code-review.md](docs/benchmark-code-review.md).

| | Mistral API | Verda A100 80GB | Local (98k ctx) |
|---|---|---|---|
| Time | **14s** | ~1.5 min | ~29 min |
| Quality | Good | Good | Best (most detailed) |
| Cost | ~$0.003 | ~$0.01 | Free |

Mistral API is ~120x faster than local. Quality is comparable — same model weights produce similar insights, but the local run spent more time and produced more detailed analysis.

## Local tuning (Apple Silicon)

FlashAttention enabled by default (~23 tok/s, no overhead). For large context tasks (codebase review), use `ollama-start --large-ctx` to enable q8_0 KV cache quantization — trades ~5% speed for 2x KV cache capacity. See [`scripts/ollama-start.sh`](scripts/ollama-start.sh).

## See also

- [TODO.md](TODO.md) — next steps (more models, GPU tiers, alternative tools)
- [docs/prerequisites.md](docs/prerequisites.md) — shared setup steps
- [opencode.example.json](opencode.example.json) — combined config for all providers
