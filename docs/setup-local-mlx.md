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

## 3. Test the endpoint

```sh
curl -s -X POST http://localhost:8080/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "mlx-community/Devstral-Small-2-24B-Instruct-2512-8bit",
    "messages": [{"role": "user", "content": "Hello"}],
    "max_tokens": 64
  }' | jq '.usage'
```

## 4. Connect OpenCode

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

## MLX vs Ollama vs Verda

| | MLX (local) | Ollama (local) | Verda (A100 40GB) |
|---|---|---|---|
| Cost | Free | Free | ~$0.28/h spot |
| CPU+GPU utilization | Both (unified) | GPU only | N/A |
| Quantization options | 4/6/8-bit | Default Q4 | FP16 |
| Speed | TBD — benchmark | ~5-15 tok/s | ~50 tok/s |
| Context | Limited by RAM | Limited by RAM | Limited by VRAM |

MLX is designed for Apple Silicon and should better utilize the unified memory architecture compared to Ollama. Run the benchmark to compare.

## Troubleshooting

**Model download fails or is slow**
- HuggingFace downloads can be large (~25 GB for 8-bit). Ensure sufficient disk space and a stable connection.
- Models are cached in `~/.cache/huggingface/hub/`.

**Tool calls not working**
- MLX server tool-call support depends on the mlx-lm version. Force the latest with: `uvx --from mlx-lm@latest mlx_lm.server ...`
- If tool calls break, try the 4-bit variant or check [mlx-lm issues](https://github.com/ml-explore/mlx-examples/issues).

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
- [Devstral Small 2 MLX 8-bit on HuggingFace](https://huggingface.co/mlx-community/mistralai_Devstral-Small-2-24B-Instruct-2512-MLX-8Bit)
- [Devstral Small 2 MLX 4-bit on HuggingFace](https://huggingface.co/mlx-community/Devstral-Small-2-24B-Instruct-2512-4bit)
- [OpenCode docs](https://opencode.ai/docs/)
