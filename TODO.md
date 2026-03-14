# TODO

## High priority

- [ ] Select optimal Verda GPU instance for Devstral Small 2
  - Current: A100 40GB (40GB VRAM, $0.28/h spot) — minimum viable
  - Consider: A100 80GB ($0.50/h), L40S 48GB ($0.35/h), RTX PRO 6000 96GB ($0.79/h)
  - Benchmark: compare inference speed (tokens/s) vs cost across tiers
  - FP8 on A100 80GB likely the sweet spot for speed vs cost

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
