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

Launch the Ollama app — it starts the server on `http://localhost:11434`.

## 1. Pull Devstral Small 2

```sh
# ~16 GB download, requires Ollama 0.13.3+
ollama pull devstral-small-2
```

Verify:

```sh
ollama list | grep devstral
```

## 2. Test the endpoint

Ollama exposes an OpenAI-compatible API at `localhost:11434/v1`.

```sh
curl -s -X POST http://localhost:11434/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "devstral-small-2",
    "messages": [{"role": "user", "content": "Hello"}],
    "max_tokens": 64
  }' | jq '.usage'
```

No auth token needed — Ollama runs locally without authentication.

## 3. Connect OpenCode

Create `opencode.json` in your project root:

```json
{
  "$schema": "https://opencode.ai/config.json",
  "model": "ollama/devstral-small-2",
  "provider": {
    "ollama": {
      "npm": "@ai-sdk/openai-compatible",
      "name": "Ollama (local)",
      "options": {
        "baseURL": "http://localhost:11434/v1"
      },
      "models": {
        "devstral-small-2": {
          "name": "Devstral Small 2 24B",
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

Devstral on Ollama should be pre-selected as the default model.

## Local vs Verda performance

| | Local (M3 Max Pro 128GB) | Verda (A100 40GB) |
|---|---|---|
| Cost | Free | ~$0.28/h spot |
| Speed | ~5-15 tok/s (estimate) | ~50 tok/s |
| Latency | No network overhead | Network round-trip |
| Context | Limited by RAM | Limited by VRAM |

Local is good for quick experiments and offline work. For sustained coding sessions, the Verda GPU is significantly faster. See [setup-verda.md](setup-verda.md) for the remote setup.

## Troubleshooting

**Connection refused**
- Ensure Ollama is running: `ollama serve` (or launch the Ollama app)
- Verify: `curl http://localhost:11434/api/tags`

**Model not appearing in OpenCode**
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
