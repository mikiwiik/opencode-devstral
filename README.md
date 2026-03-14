# Devstral + OpenCode

Run Devstral Small 2 (24B) as a coding agent via OpenCode. Two deployment options:

| Setup | Guide | Cost | Speed |
|---|---|---|---|
| Verda GPU (remote) | [docs/setup-verda.md](docs/setup-verda.md) | ~$0.28/h spot (A100 40GB) | ~50 tok/s |
| Ollama (local) | [docs/setup-local-ollama.md](docs/setup-local-ollama.md) | Free | Slower (Apple Silicon) |

## Performance comparison

| | Local (M3 Max Pro 128GB) | Verda (A100 40GB) |
|---|---|---|
| Cost | Free | ~$0.28/h spot |
| Speed | ~5-15 tok/s (estimate) | ~50 tok/s |
| Latency | No network overhead | Network round-trip |
| Context | Limited by RAM | Limited by VRAM |

Local is good for quick experiments and offline work. For sustained coding sessions, the remote GPU is significantly faster.

## Quick start

Pick a setup guide above, then run `opencode` from your project directory.

## Model

[Devstral Small 2](https://huggingface.co/mistralai/Devstral-Small-2-24B-Instruct-2512) — 24B parameter coding model by Mistral. Apache 2.0, 128K+ context, tool-call support.

## See also

- [TODO.md](TODO.md) — next steps (GPU benchmarking, more models, alternative tools)
- [benchmark.sh](benchmark.sh) — quick inference speed test
