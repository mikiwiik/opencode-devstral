# Verda Setup: Devstral on Remote GPU

Run Devstral Small 2 (24B) on a [Verda](https://verda.com) (formerly [DataCrunch](https://datacrunch.io)) GPU instance via [vLLM](https://github.com/vllm-project/vllm).

**Prerequisites**: [Install OpenCode and global config](prerequisites.md) first. You also need a [Verda](https://verda.com) account with credits.

## 1. Deploy Devstral on Verda

Follow [Verda's vLLM tutorial](https://docs.verda.com/containers/tutorials/deploy-with-vllm-quick) with these settings:

| Setting | Value |
|---|---|
| Container image | `docker.io/vllm/vllm-openai` (tag: see below) |
| GPU | A100 40GB, A100 80GB, or RTX PRO 6000 — see below |
| HTTP port | `8000` |
| Healthcheck | port `8000`, path `/health` |
| Public access | On |

**Choosing a GPU:**

| GPU | Spot price | Speed | `--max-model-len` | Context | Best for |
|---|---|---|---|---|---|
| A100 40GB | ~$0.28/h | ~50 tok/s | `32768` | ~32k | Budget / quick tasks |
| A100 80GB | ~$0.43/h | ~59 tok/s | `98304` | ~98k | **Recommended** — good balance of speed, context, and cost |
| RTX PRO 6000 | ~$0.79/h | ~53 tok/s | `131072` | ~128k | Large context tasks (full codebase review without compaction) |

Use the `--max-model-len` value from the table in your start command and set matching `context` in `opencode.json`.

All three GPUs lack native FP8 (vLLM falls back to Marlin kernel). For native FP8, consider H100 ($0.88/h) — see TODO.md.

> **How context limits are derived:** Model weights take ~24 GiB. With `--gpu-memory-utilization 0.9`, the remaining VRAM is available for KV cache. A100 40GB → ~12 GiB KV → 32k. A100 80GB → ~48 GiB KV → 98k. RTX PRO 6000 → ~62 GiB KV → 128k. If RTX PRO 6000 hits OOM at 131072, fall back to `114688`.

**Choosing a vLLM image tag:**

Verda lists many tags — ignore the `cu*-nightly-*` ones (unstable dev builds). Pick the latest stable `vX.Y.Z` release. As of March 2026 that's `v0.17.1`.

Devstral Small 2 requires `mistral_common >= 1.8.6` for tool-call parsing ([model card](https://huggingface.co/mistralai/Devstral-Small-2-24B-Instruct-2512)), which is bundled in recent vLLM stable releases. Verda's own tutorial uses the same `vllm-openai` image ([docs](https://docs.verda.com/containers/tutorials/deploy-with-vllm-quick)).

Check [vLLM releases](https://github.com/vllm-project/vllm/releases) for newer versions.

**Environment variables:**

| Key | Value |
|---|---|
| `HF_TOKEN` | *(optional — see below)* |

vLLM downloads model weights from HuggingFace at container startup. Devstral Small 2 is public (Apache 2.0, no login required), so you **don't need a token** for a first deploy. Only set `HF_TOKEN` (a [HuggingFace access token](https://huggingface.co/settings/tokens)) if you hit download rate limits from frequent redeployments.

**Start command** (toggle on, select CMD):

```
--model mistralai/Devstral-Small-2-24B-Instruct-2512 --gpu-memory-utilization 0.9 --max-model-len <VALUE> --tool-call-parser mistral --enable-auto-tool-choice
```

Replace `<VALUE>` with the `--max-model-len` from the GPU table above (`32768` / `98304` / `131072`).

Wait for the healthcheck to go green.

## 2. Get your API URL and token

1. **API URL**: go to your container's detail page — the base URL is shown in the top-left under "Containers API" (e.g., `https://containers.datacrunch.io/your-container-name/`)
2. **Bearer token**: go to **Keys > Inference API Keys > Create** ([docs](https://docs.verda.com/inference/authorization)). Save the token — it won't be shown again.

## 3. Test the endpoint

**Quick test via Verda UI**: go to the **API** tab on your container's page. Append `v1/chat/completions` to the URL field, paste your bearer token into the Authorization header, and use this payload:

```json
{
  "model": "mistralai/Devstral-Small-2-24B-Instruct-2512",
  "messages": [{"role": "user", "content": "Hello"}],
  "max_tokens": 64
}
```

Hit "Send Request" to verify the model responds.

**Or via curl:**

```sh
curl -X POST https://containers.datacrunch.io/YOUR-CONTAINER/v1/chat/completions \
  -H "Authorization: Bearer YOUR_INFERENCE_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "mistralai/Devstral-Small-2-24B-Instruct-2512",
    "messages": [{"role": "user", "content": "Hello"}],
    "max_tokens": 64
  }'
```

## 4. Configure your Verda URL

Edit `~/.config/opencode/opencode.json`: replace `<YOUR_VERDA_API_URL>` with your container URL. Then run `opencode` from any project.
