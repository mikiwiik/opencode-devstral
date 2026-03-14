# Devstral + OpenCode

Run Devstral Small 2 (24B) as a coding agent via OpenCode. Three deployment options:

| Setup | Guide | Cost | Speed |
|---|---|---|---|
| Mistral API | [docs/setup-mistral-api.md](docs/setup-mistral-api.md) | ~$0.10/M in, $0.30/M out | TBD |
| Verda GPU (remote) | [docs/setup-verda.md](docs/setup-verda.md) | ~$0.43/h spot (A100 80GB) | ~59 tok/s |
| Ollama (local) | [docs/setup-local-ollama.md](docs/setup-local-ollama.md) | Free | ~23 tok/s |

## Performance comparison

Measured with `benchmark.sh` — fizzbuzz prompt, `max_tokens=512`, Devstral Small 2.

| | Local (M3 Max Pro 128GB) | Verda A100 40GB | Verda A100 80GB | Mistral API |
|---|---|---|---|---|
| Cost | Free | ~$0.28/h spot | ~$0.43/h spot | ~$0.10/M in, $0.30/M out |
| Speed | ~23 tok/s | ~50 tok/s | ~59 tok/s | TBD |
| Max context | ~128k (RAM limited) | ~32k | ~65k | 256k |

> **Benchmark config**: A100 40GB measured with `--max-model-len 32768`, A100 80GB with `--max-model-len 65536`. Local used `num_ctx 32768`. A100 80GB is ~18% faster than 40GB and supports 2x the context for ~54% more cost.

> **Local tuning results**: FlashAttention enabled by default (~23 tok/s, no overhead). KV cache quantization (q8_0) available via `ollama-start --large-ctx` — trades ~5% speed for 2x KV cache capacity on large context tasks. See [`scripts/ollama-start.sh`](scripts/ollama-start.sh).

Verda is ~2.5x faster at generation. Local supports larger context windows and is free — better for offline work and large codebase review.

## Quick start

1. Follow a setup guide above (one or more)
2. Install the OpenCode config globally so it works across all projects:
   ```sh
   cp opencode.example.json ~/.config/opencode/opencode.json
   # edit: fill in your API URLs/keys
   ```
3. Set API keys for your providers (add to `~/.zshrc` or `~/.bashrc`):
   ```sh
   export VERDA_API_KEY="your-verda-key"       # if using Verda
   export MISTRAL_API_KEY="your-mistral-key"   # if using Mistral API
   ```
4. Run `opencode` from any project directory

## Model

[Devstral Small 2](https://huggingface.co/mistralai/Devstral-Small-2-24B-Instruct-2512) — 24B parameter coding model by Mistral. Apache 2.0, 128K+ context, tool-call support.

## See also

- [TODO.md](TODO.md) — next steps (GPU benchmarking, more models, alternative tools)
- [benchmark.sh](benchmark.sh) — quick inference speed test
