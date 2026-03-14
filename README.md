# Verda + Devstral + OpenCode

Run Devstral Small 2 (24B) on a Verda GPU instance, connect OpenCode to it as a remote coding agent.

## Prerequisites

- [Verda](https://verda.com) account with credits
- OpenCode installed locally:
  ```sh
  # check if already installed
  which opencode && opencode --version

  # install via brew (or curl)
  brew install opencode
  # or: curl -fsSL https://opencode.ai/install | bash
  ```

## 1. Deploy Devstral on Verda

Follow [Verda's vLLM tutorial](https://docs.verda.com/containers/tutorials/deploy-with-vllm-quick) with these settings:

| Setting | Value |
|---|---|
| Container image | `docker.io/vllm/vllm-openai` (tag: see below) |
| GPU | A100 40GB ($0.28/h spot) or better — see TODO.md |
| HTTP port | `8000` |
| Healthcheck | port `8000`, path `/health` |
| Public access | On |

**Choosing a vLLM image tag:**

Verda lists many tags — ignore the `cu*-nightly-*` ones (unstable dev builds). Pick the latest stable `vX.Y.Z` release. As of March 2026 that's `v0.17.1`.

Devstral Small 2 requires `mistral_common >= 1.8.6` for tool-call parsing ([model card](https://huggingface.co/mistralai/Devstral-Small-2-24B-Instruct-2512)), which is bundled in recent vLLM stable releases. Verda's own tutorial uses the same `vllm-openai` image ([docs](https://docs.verda.com/containers/tutorials/deploy-with-vllm-quick)).

Check [vLLM releases](https://github.com/vllm-project/vllm/releases) for newer versions.

**Environment variables:**

| Key | Value |
|---|---|
| `HF_TOKEN` | *(optional — see below)* |

vLLM downloads model weights from HuggingFace at container startup. Devstral Small 2 is public (Apache 2.0, no login required), so you **don't need a token** for a first deploy. Only set `HF_TOKEN` (a [HuggingFace access token](https://huggingface.co/settings/tokens)) if you hit download rate limits from frequent redeployments.

**Start command:**

```
--model mistralai/Devstral-Small-2-24B-Instruct-2512 --gpu-memory-utilization 0.9 --tool-call-parser mistral --enable-auto-tool-choice
```

Wait for the healthcheck to go green. Note your container's API URL.

## 2. Test the endpoint

```sh
curl -X POST <YOUR_API_URL>/v1/chat/completions \
  -H "Authorization: Bearer <YOUR_INFERENCE_API_KEY>" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "mistralai/Devstral-Small-2-24B-Instruct-2512",
    "messages": [{"role": "user", "content": "Hello"}],
    "max_tokens": 64
  }'
```

## 3. Connect OpenCode

Create `opencode.json` in your project root:

```json
{
  "provider": {
    "verda": {
      "id": "openai-compatible",
      "options": {
        "baseURL": "<YOUR_API_URL>/v1",
        "apiKey": "<YOUR_INFERENCE_API_KEY>"
      },
      "models": {
        "mistralai/Devstral-Small-2-24B-Instruct-2512": {
          "maxTokens": 8192,
          "contextWindow": 128000
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

Select the Verda/Devstral model from the model picker.

## References

- [Verda container docs](https://docs.verda.com/containers/tutorials/deploy-with-vllm-quick)
- [Devstral Small 2 on HuggingFace](https://huggingface.co/mistralai/Devstral-Small-2-24B-Instruct-2512)
- [OpenCode docs](https://opencode.ai/docs/)
- [Mistral local/offline docs](https://docs.mistral.ai/mistral-vibe/local)
