# Local Setup: Devstral + Ollama

Run Devstral Small 2 (24B) locally via Ollama on macOS Apple Silicon.

**Prerequisites**: [Install OpenCode and global config](prerequisites.md) first. You also need:
- Apple Silicon Mac with 128 GB unified memory
- Homebrew installed

## 1. Install and start Ollama

```sh
brew install --cask ollama
```

Install the optimized start script to your PATH:

```sh
ln -sf "$(pwd)/scripts/ollama-start.sh" ~/.local/bin/ollama-start
```

Start Ollama and pull the model:

```sh
ollama-start &

# ~16 GB download, requires Ollama 0.13.3+
ollama pull devstral-small-2
```

The script enables FlashAttention and keeps models loaded between sessions. Use `ollama-start --large-ctx` for q8_0 KV cache quantization on large context tasks. See [`scripts/ollama-start.sh`](../scripts/ollama-start.sh).

> **Optional**: unlock more GPU memory (resets on boot):
> ```sh
> sudo sysctl iogpu.wired_limit_mb=120000
> ```
> macOS caps GPU memory at ~75% by default. This makes ~120GB of your 128GB available.

Verify:

```sh
ollama list | grep devstral
```

## 2. Set context window

Ollama defaults to a small context window (2048-4096 tokens). Create a variant with 32k context:

```sh
ollama run devstral-small-2
/set parameter num_ctx 32768
/save devstral-small-2-32k
/bye
```

This creates a `devstral-small-2-32k` variant used by the OpenCode config.

## 3. Test the endpoint

Ollama exposes an OpenAI-compatible API at `localhost:11434/v1`.

```sh
curl -s -X POST http://localhost:11434/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "devstral-small-2-32k",
    "messages": [{"role": "user", "content": "Hello"}],
    "max_tokens": 64
  }' | jq '.usage'
```

No auth token needed — Ollama runs locally without authentication.

## 4. Set default model (optional)

To default to the local model, edit `~/.config/opencode/opencode.json` and change the top-level `"model"` to `"ollama/devstral-small-2-32k"`.

## Troubleshooting

**Connection refused**
- Ensure Ollama is running: `ollama serve` (or launch the Ollama app)
- Verify: `curl http://localhost:11434/api/tags`

**Model not appearing in OpenCode**
- Start Ollama **before** OpenCode — OpenCode checks provider availability at launch. Restart OpenCode if you started Ollama after.
- The model key in `opencode.json` must exactly match `ollama list` output

**Tool calls not working**
- Known issue with multi-turn tool call sequences ([ollama/ollama#11296](https://github.com/ollama/ollama/issues/11296)). If tool calls break mid-conversation, try starting a new session.

**Slow generation**
- Expected on Apple Silicon — GPU memory bandwidth is the bottleneck for large models.
