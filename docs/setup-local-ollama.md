# Local Setup: Devstral + Ollama + OpenCode

Run Devstral Small 2 (24B) locally via Ollama on macOS Apple Silicon, connect OpenCode as a coding agent.

## Prerequisites

- Apple Silicon Mac with 128 GB unified memory
- Homebrew installed

```sh
# optional but recommended — used by OpenCode for search
brew install fzf ripgrep

# check if already installed
which ollama && ollama --version
which opencode && opencode --version

# install Ollama and OpenCode
brew install --cask ollama
brew install opencode
# or: curl -fsSL https://opencode.ai/install | bash
```

## 1. Start Ollama and pull Devstral Small 2

Install the optimized start script to your PATH:

```sh
ln -sf "$(pwd)/scripts/ollama-start.sh" ~/.local/bin/ollama-start
```

Then start Ollama with tuned settings and pull the model:

```sh
ollama-start &

# ~16 GB download, requires Ollama 0.13.3+
ollama pull devstral-small-2
```

The script enables FlashAttention, KV cache quantization (q8_0), and keeps models loaded between sessions. See [`scripts/ollama-start.sh`](../scripts/ollama-start.sh) for details.

> **Optional**: unlock more GPU memory (resets on boot):
> ```sh
> sudo sysctl iogpu.wired_limit_mb=120000
> ```
> macOS caps GPU memory at ~75% by default. This makes ~120GB of your 128GB available.

Verify:

```sh
ollama list | grep devstral
```

## 2. Set context window to match Verda

Ollama defaults to a small context window (2048-4096 tokens). The Verda setup uses `--max-model-len 32768`, so we match that for a fair comparison:

```sh
ollama run devstral-small-2
/set parameter num_ctx 32768
/save devstral-small-2-32k
/bye
```

This creates a `devstral-small-2-32k` variant. Use this model name in the steps below.

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

## 4. Connect OpenCode

Install the config globally (recommended — works across all projects):

```sh
cp opencode.example.json ~/.config/opencode/opencode.json
```

To default to the local model, edit `~/.config/opencode/opencode.json` and change the top-level `"model"` to `"ollama/devstral-small-2-32k"`. Then run `opencode` from any project.

See [`opencode.example.json`](../opencode.example.json) for the full config (includes both Verda and local Ollama providers). A project-local `opencode.json` overrides the global config if needed.

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
- Expected on Apple Silicon — GPU memory bandwidth is the bottleneck for large models. Consider using the [Verda remote setup](setup-verda.md) for faster inference.

## References

- [Devstral Small 2 on HuggingFace](https://huggingface.co/mistralai/Devstral-Small-2-24B-Instruct-2512)
- [Devstral on Ollama](https://ollama.com/library/devstral-small-2)
- [OpenCode docs](https://opencode.ai/docs/)
- [Mistral local/offline docs](https://docs.mistral.ai/mistral-vibe/local)
