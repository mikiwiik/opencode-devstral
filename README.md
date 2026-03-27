# opencode-devstral

Run [Devstral](https://mistral.ai/news/devstral-2-vibe-cli) coding models with [OpenCode](https://opencode.ai) — setup guides, benchmarks, and tuning for multiple deployment options.

Currently tested with [Devstral Small 2](https://huggingface.co/mistralai/Devstral-Small-2-24B-Instruct-2512) (24B, Apache 2.0, 128K+ context, tool-call support).

## Quick start

1. [Install OpenCode and global config](docs/prerequisites.md)
2. Pick a deployment option below and follow the guide
3. Run `opencode` from any project directory

## Deployment options

| Setup | Guide | Cost | Speed (synthetic) | Max context |
|---|---|---|---|---|
| Mistral API (hosted) | [setup](docs/setup-mistral-api.md) | ~$0.10/M in, $0.30/M out | ~193 tok/s | 256k |
| Verda GPU (remote) | [setup](docs/setup-verda.md) | ~$0.43/h spot (A100 80GB) | ~59 tok/s | ~98k |
| Verda GPU (remote) | [setup](docs/setup-verda.md) | ~$0.79/h spot (RTX PRO 6000) | ~53 tok/s | ~128k |
| MLX 8-bit (local macOS) | [setup](docs/setup-local-mlx.md) | Free | ~14.6 tok/s | TBD (experimental — tool calls broken) |
| Ollama (local macOS) | [setup](docs/setup-local-ollama.md) | Free | ~23 tok/s | ~98k+ |

All three use the same model weights. The [OpenCode config](opencode.example.json) includes all providers — switch between them in the model picker.

## Benchmarks

| Provider | Speed | Code review | Cost/review | Cost/hour | Best for |
|---|---|---|---|---|---|
| Mistral API | ~193 tok/s | 14s | ~$0.003 | ~$0.15 | Quick dev tasks, one-off reviews |
| Verda RTX PRO 6000 | ~53 tok/s | ~1 min | ~$0.014 | $0.79 | Large codebase analysis (128k ctx) |
| Verda A100 80GB | ~59 tok/s | ~1.5 min | ~$0.01 | $0.43 | Sustained coding sessions |
| Local (M3 Max Pro) | ~23 tok/s | ~29 min | Free | Free | Offline / no cost |

Full results, methodology, and per-use-case recommendations in [docs/benchmarks.md](docs/benchmarks.md).

## Local tuning (Apple Silicon)

The [`ollama-start`](scripts/ollama-start.sh) script includes optimizations (FlashAttention, keep-alive) that showed minor performance improvements in benchmarking on M3 Max Pro 128GB. Use `ollama-start --large-ctx` for large context tasks like codebase review — enables q8_0 KV cache quantization, trading ~5% speed for 2x KV cache capacity.

## See also

- [TODO.md](TODO.md) — next steps (more models, GPU tiers, alternative tools)
- [docs/prerequisites.md](docs/prerequisites.md) — shared setup steps
- [opencode.example.json](opencode.example.json) — combined config for all providers
