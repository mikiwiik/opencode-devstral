# Devstral + OpenCode

Run Devstral Small 2 (24B) as a coding agent via OpenCode. Two deployment options:

| Setup | Guide | Cost | Speed |
|---|---|---|---|
| Verda GPU (remote) | [docs/setup-verda.md](docs/setup-verda.md) | ~$0.28/h spot (A100 40GB) | ~50 tok/s |
| Ollama (local) | [docs/setup-local-ollama.md](docs/setup-local-ollama.md) | Free | ~23 tok/s |

## Performance comparison

Measured with `benchmark.sh` — fizzbuzz prompt, `max_tokens=512`, Devstral Small 2.

| | Local (M3 Max Pro 128GB) | Verda (A100 40GB spot) |
|---|---|---|
| Cost | Free | ~$0.28/h |
| Speed | ~23 tok/s | ~50 tok/s |
| Latency | No network overhead | Network round-trip |
| Max context | ~128k (RAM limited) | ~32k (40GB VRAM limited) |

> **Benchmark config**: both setups used 32k context at time of measurement. Local can go much higher given 128GB unified memory. Verda is capped at 32k on A100 40GB (~10 GiB free for KV cache after model weights). A larger GPU (A100 80GB, H100) would allow more context on Verda.

> **Local tuning results**: FlashAttention enabled by default (~23 tok/s, no overhead). KV cache quantization (q8_0) available via `ollama-start --large-ctx` — trades ~5% speed for 2x KV cache capacity on large context tasks. See [`scripts/ollama-start.sh`](scripts/ollama-start.sh).

Verda is ~2x faster at generation, but the local setup supports much larger context windows — making it better suited for tasks like codebase review that require loading many files.

## Quick start

1. Follow a setup guide above (Verda, Ollama, or both)
2. Install the OpenCode config globally so it works across all projects:
   ```sh
   cp opencode.example.json ~/.config/opencode/opencode.json
   # edit ~/.config/opencode/opencode.json: fill in your Verda API URL
   ```
3. Set your Verda API key (if using Verda):
   ```sh
   # add to your ~/.zshrc or ~/.bashrc
   export VERDA_API_KEY="your-inference-api-key"
   ```
4. Run `opencode` from any project directory

## Model

[Devstral Small 2](https://huggingface.co/mistralai/Devstral-Small-2-24B-Instruct-2512) — 24B parameter coding model by Mistral. Apache 2.0, 128K+ context, tool-call support.

## See also

- [TODO.md](TODO.md) — next steps (GPU benchmarking, more models, alternative tools)
- [benchmark.sh](benchmark.sh) — quick inference speed test
