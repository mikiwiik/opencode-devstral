# Local Setup: Devstral + MLX + OpenCode

Run Devstral Small 2 (24B) locally via MLX on macOS Apple Silicon, connect OpenCode as a coding agent.

MLX is Apple's machine learning framework optimized for Apple Silicon's unified memory architecture. Unlike Ollama (which only utilizes the GPU), MLX efficiently uses both CPU and GPU, leading to better resource utilization and potentially faster inference.

## Prerequisites

- Apple Silicon Mac (M-series) with 32 GB+ unified memory
- [OpenCode and dependencies installed](prerequisites.md)
- [uv](https://docs.astral.sh/uv/) installed: `brew install uv`

## 1. Start the MLX server with Devstral Small 2

The 8-bit quantized version (~25 GB) offers the best quality-to-size ratio. For lower memory usage, use the 4-bit version instead.

`uvx` runs `mlx-lm` in an isolated environment without a global install:

```sh
# 8-bit (recommended for 128 GB machines)
uvx --from mlx-lm mlx_lm.server --model mlx-community/Devstral-Small-2-24B-Instruct-2512-8bit --port 8080 --max-tokens 4096

# 4-bit (smaller, works on 32 GB machines)
# uvx --from mlx-lm mlx_lm.server --model mlx-community/Devstral-Small-2-24B-Instruct-2512-4bit --port 8080 --max-tokens 4096
```

> **Important:** `--max-tokens 4096` is required for tool calls. The default (512) truncates tool call JSON, crashing the parser.

The model is downloaded from HuggingFace on first run and cached in `~/.cache/huggingface/hub/`.

The server exposes an OpenAI-compatible API at `http://localhost:8080/v1`.

## 2. Test the endpoint

No auth token needed — the server runs locally without authentication.

```sh
curl -s -X POST http://localhost:8080/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "mlx-community/Devstral-Small-2-24B-Instruct-2512-8bit",
    "messages": [{"role": "user", "content": "Hello"}],
    "max_tokens": 64
  }' | jq '.usage'
```

## 3. Connect OpenCode

Create `opencode.json` in your project root:

```json
{
  "$schema": "https://opencode.ai/config.json",
  "model": "mlx/mlx-community/Devstral-Small-2-24B-Instruct-2512-8bit",
  "provider": {
    "mlx": {
      "npm": "@ai-sdk/openai-compatible",
      "name": "MLX (local)",
      "options": {
        "baseURL": "http://localhost:8080/v1"
      },
      "models": {
        "mlx-community/Devstral-Small-2-24B-Instruct-2512-8bit": {
          "name": "Devstral Small 2 24B (MLX 8-bit)",
          "tools": true
        }
      }
    }
  }
}
```

Then run:

```sh
opencode
```

## Status: experimental

> **Not usable for agent tasks.** mlx-lm's Mistral tool parser has multiple bugs that prevent reliable tool calls with OpenCode. Benchmarking on M3 Max Pro 128GB:
>
> - **MLX 4-bit: ~26.7 tok/s** (synthetic), ~57.7s for a simple OpenCode task.
> - **MLX 8-bit: ~14.6 tok/s** (synthetic). Slower than Ollama (~23 tok/s). Tool calls broken even with `--max-tokens 4096`.
>
> **Tool call parser bugs (two distinct failures):**
> 1. **Truncated JSON** — default `--max-tokens 512` cuts off tool call arguments mid-JSON. Workaround: `--max-tokens 4096`.
> 2. **Multiple tool calls** — when the model calls multiple tools in one response (e.g. reading several files), the parser receives concatenated JSON objects (`{"path":"a"}{"path":"b"}`) and fails with `Extra data`. No workaround — this is a bug in mlx-lm's Mistral tool parser.
>
> Simple single-tool tasks (like "write fizzbuzz") work with the `--max-tokens` fix, but any agent task that requires reading multiple files fails immediately and loops forever.
>
> **Also slow with OpenCode:** OpenCode sends ~10k tokens of system prompt + tool definitions per request. Prompt prefill dominates — a simple task took 57.7s despite ~26.7 tok/s generation speed.

## MLX vs Ollama vs Verda

| | MLX 8-bit (local) | MLX 4-bit (local) | Ollama (local) | Verda (A100 80GB) |
|---|---|---|---|---|
| Cost | Free | Free | Free | ~$0.43/h spot |
| Speed | ~14.6 tok/s | ~26.7 tok/s | ~23 tok/s | ~59 tok/s |
| Tool calls | Broken (parser bugs) | Broken (parser bugs) | Working | Working |
| Quantization | 8-bit | 4-bit | Default Q4 | FP16 |
| Context | Limited by RAM | Limited by RAM | Limited by RAM | Limited by VRAM |

Tested on M3 Max Pro 128GB, 2026-03-25 (8-bit synthetic) and 2026-03-28 (4-bit synthetic + OpenCode, 8-bit OpenCode).

## Troubleshooting

**Model download fails or is slow**
- HuggingFace downloads can be large (~25 GB for 8-bit). Ensure sufficient disk space and a stable connection.
- Models are cached in `~/.cache/huggingface/hub/`.

**Tool calls not working / OpenCode loops forever**
- See [Status: experimental](#status-experimental) for details on the two known parser bugs and workarounds.
- Track upstream: [mlx-lm issues](https://github.com/ml-explore/mlx-examples/issues)

**Slow response in OpenCode**
- OpenCode sends ~10k tokens of system prompt + tool definitions per request. Prompt prefill dominates latency. This is expected — generation speed (~26.7 tok/s for 4-bit) is fine, but prefill is the bottleneck.

**Out of memory**
- Use the 4-bit quantization variant to reduce memory usage.
- Close other memory-intensive applications.

## Available quantization variants

| Variant | HuggingFace repo | Size |
|---|---|---|
| 4-bit | `mlx-community/Devstral-Small-2-24B-Instruct-2512-4bit` | ~13 GB |
| 6-bit | `mlx-community/Devstral-Small-2-24B-Instruct-2512-6bit` | ~19 GB |
| 8-bit | `mlx-community/Devstral-Small-2-24B-Instruct-2512-8bit` | ~25 GB |

## References

- [MLX framework](https://github.com/ml-explore/mlx)
- [mlx-lm on PyPI](https://pypi.org/project/mlx-lm/)
- [Devstral Small 2 MLX 8-bit on HuggingFace](https://huggingface.co/mlx-community/Devstral-Small-2-24B-Instruct-2512-8bit)
- [Devstral Small 2 MLX 4-bit on HuggingFace](https://huggingface.co/mlx-community/Devstral-Small-2-24B-Instruct-2512-4bit)
- [OpenCode docs](https://opencode.ai/docs/)
