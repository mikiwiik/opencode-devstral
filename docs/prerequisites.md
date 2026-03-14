# Prerequisites & OpenCode Setup

Shared setup steps for all deployment options ([Verda](https://verda.com), [Ollama](https://ollama.com), [Mistral API](https://console.mistral.ai)).

## 1. Install OpenCode and dependencies

```sh
# optional but recommended — used by OpenCode for search
brew install fzf ripgrep

# check if already installed
which opencode && opencode --version

# install OpenCode
brew install opencode
# or: curl -fsSL https://opencode.ai/install | bash
```

## 2. Install global OpenCode config

The config includes all three providers (Verda, Ollama, Mistral API). Install it once:

```sh
cp opencode.example.json ~/.config/opencode/opencode.json
```

Edit `~/.config/opencode/opencode.json` to:
- Fill in your Verda API URL (if using Verda)
- Set the top-level `"model"` to your preferred default provider/model

A project-local `opencode.json` overrides the global config if needed. See [`opencode.example.json`](../opencode.example.json) for the full config.

## 3. Set API keys

Add to your `~/.zshrc` or `~/.bashrc` (only for providers you use):

```sh
export VERDA_API_KEY="your-verda-key"         # Verda
export MISTRAL_API_KEY="your-mistral-key"     # Mistral API
# Ollama needs no API key
```

## 4. Run OpenCode

```sh
opencode
```

Select your model from the picker. Use the setup guides for provider-specific configuration:
- [Verda (remote GPU)](setup-verda.md)
- [Ollama (local)](setup-local-ollama.md)
- [Mistral API (hosted)](setup-mistral-api.md)

## References

- [OpenCode](https://opencode.ai) — [docs](https://opencode.ai/docs/)
- [Devstral Small 2](https://huggingface.co/mistralai/Devstral-Small-2-24B-Instruct-2512) — [Mistral docs](https://docs.mistral.ai/models/devstral-small-2-25-12)
- [Ollama](https://ollama.com) — local model serving
- [Verda](https://verda.com) (formerly [DataCrunch](https://datacrunch.io)) — GPU cloud, `containers.datacrunch.io` URLs are Verda's container API
- [vLLM](https://github.com/vllm-project/vllm) — [docs](https://docs.vllm.ai) — model serving engine used on Verda
- [Mistral local/offline docs](https://docs.mistral.ai/mistral-vibe/local)
