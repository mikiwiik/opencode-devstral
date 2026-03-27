# Local Setup: Devstral + MLX + OpenCode

Run Devstral Small 2 (24B) locally via MLX on macOS Apple Silicon, connect OpenCode as a coding agent.

MLX is Apple's machine learning framework optimized for Apple Silicon's unified memory architecture. Unlike Ollama (which only utilizes the GPU), MLX efficiently uses both CPU and GPU, leading to better resource utilization and potentially faster inference.

## Prerequisites

- Apple Silicon Mac (M-series) with 32 GB+ unified memory
- Homebrew installed

```sh
# optional but recommended — used by OpenCode for search
brew install fzf ripgrep

# install uv (fast Python package manager) and OpenCode
brew install uv opencode
# or install OpenCode via: curl -fsSL https://opencode.ai/install | bash
```

## 1. Start the MLX server with Devstral Small 2

The 8-bit quantized version (~25 GB) offers the best quality-to-size ratio. For lower memory usage, use the 4-bit version instead.

`uvx` runs `mlx-lm` in an isolated environment without a global install:

```sh
# 8-bit (recommended for 128 GB machines)
uvx --from mlx-lm mlx_lm.server --model mlx-community/Devstral-Small-2-24B-Instruct-2512-8bit --port 8080

# 4-bit (smaller, works on 32 GB machines)
# uvx --from mlx-lm mlx_lm.server --model mlx-community/Devstral-Small-2-24B-Instruct-2512-4bit --port 8080
```

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

> **Not recommended for agent use yet.** Benchmarking on M3 Max Pro 128GB revealed two blockers:
>
> 1. **Slower than Ollama** — MLX 8-bit measured ~14.6 tok/s vs Ollama's ~23 tok/s for the same model.
> 2. **Tool call parsing is broken** — mlx-lm's Mistral tool parser fails with `JSONDecodeError` when parsing tool call arguments. The server returns HTTP 200 but with malformed tool calls, causing OpenCode to hang or fail silently. A 2-hour coding session produced no output.
>
> Simple (non-tool) completions work. Agent use requires the tool parsing fix upstream in [mlx-lm](https://github.com/ml-explore/mlx-examples/issues).

## MLX vs Ollama vs Verda

| | MLX 8-bit (local) | MLX 4-bit (local) | Ollama (local) | Verda (A100 80GB) |
|---|---|---|---|---|
| Cost | Free | Free | Free | ~$0.43/h spot |
| Speed | ~14.6 tok/s | TBD | ~23 tok/s | ~59 tok/s |
| Tool calls | Broken | TBD | Working | Working |
| Quantization | 8-bit | 4-bit | Default Q4 | FP16 |
| Context | Limited by RAM | Limited by RAM | Limited by RAM | Limited by VRAM |

Tested on M3 Max Pro 128GB, 2026-03-25.

## Troubleshooting

**Model download fails or is slow**
- HuggingFace downloads can be large (~25 GB for 8-bit). Ensure sufficient disk space and a stable connection.
- Models are cached in `~/.cache/huggingface/hub/`.

**Tool calls not working / OpenCode hangs**
- Known issue: mlx-lm's Mistral tool parser fails with `JSONDecodeError` when parsing tool call arguments. The server returns 200 but the tool call payload is malformed, causing OpenCode to hang.
- Check for fixes in newer mlx-lm versions: `uvx --from mlx-lm@latest mlx_lm.server ...`
- Track upstream: [mlx-lm issues](https://github.com/ml-explore/mlx-examples/issues)

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
