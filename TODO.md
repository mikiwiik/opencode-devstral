# TODO

## High priority

- [ ] Evaluate FP8 performance impact on current GPU
  - Current GPU lacks native FP8 — vLLM falls back to Marlin kernel (slower)
  - Native FP8 requires H100/H200/B200
  - Test: measure tokens/s on current instance, compare with H100 ($0.88/h spot)
  - If too slow, upgrade to H100 80GB (native FP8 + 80GB VRAM) or H200 141GB

- [ ] Select optimal Verda GPU instance for Devstral Small 2
  - Current GPU: ~34GB VRAM, no native FP8, model weights use 24 GiB leaving only ~10 GiB for KV cache
  - Consider: H100 80GB ($0.88/h, native FP8), A100 80GB ($0.50/h), A100 40GB ($0.28/h)
  - Benchmark: compare inference speed (tokens/s) vs cost across tiers
  - Key tradeoff: native FP8 (H100+) = faster inference, non-FP8 GPUs = cheaper but slower

## Medium priority

- [ ] Try alternative coding tools
  - [ ] [Mistral Vibe](https://docs.mistral.ai/mistral-vibe/local) — Mistral's own CLI, purpose-built for Devstral
  - [ ] [aider](https://aider.chat) — popular open-source coding assistant
  - [ ] Compare: latency, tool-use reliability, UX

- [ ] Add more models
  - [ ] Devstral Small 2507 (older, compare quality)
  - [ ] Qwen 2.5 Coder 32B
  - [ ] DeepSeek Coder V2

## Low priority

- [ ] Create launch/teardown scripts for Verda containers
- [ ] Automate `opencode.json` generation from Verda deployment URL
- [ ] Document cost tracking / budget alerts on Verda
