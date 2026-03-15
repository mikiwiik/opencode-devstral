# TODO

## High priority

- [ ] Test running Devstral Small 2 locally on Dell Pro Max GB10
  - NVIDIA GB10 Grace Blackwell Superchip, 128GB unified memory
  - **Use vLLM, not Ollama** — Blackwell has native FP8 support which vLLM exploits; Ollama (llama.cpp) doesn't leverage FP8 compute
  - Memory bandwidth (~273 GB/s LPDDR5X) is lower than M3 Max Pro (~400 GB/s) — raw Ollama tok/s may actually be slower than Mac
  - The win is FP8 + CUDA optimizations via vLLM/TensorRT-LLM, which could match or beat Verda A100 80GB (~59 tok/s)
  - Benchmark: compare vLLM on GB10 vs Ollama on M3 Max Pro vs Verda A100 80GB
  - Use same start command as Verda: `--model mistralai/Devstral-Small-2-24B-Instruct-2512 --gpu-memory-utilization 0.9 --max-model-len 98304 --tool-call-parser mistral --enable-auto-tool-choice`

- [ ] Evaluate if H100 native FP8 is worth the cost premium
  - Current: A100 80GB ($0.43/h spot), no native FP8 — vLLM uses Marlin kernel fallback
  - H100 80GB ($0.88/h spot) has native FP8 — potentially faster inference
  - Test: benchmark A100 80GB vs H100 to see if ~2x cost is justified by speed

- [ ] Expand benchmark script for proper performance evaluation
  - Current: simple curl + jq one-shot (`benchmark.sh`)
  - Add: multiple runs, average tokens/s, TTFT
  - Test with `"stream": true` — current benchmark shows TTFT ≈ total time (no streaming), streaming should give much faster first token
  - Compare across GPU tiers to inform instance selection


- [ ] Test different output token limits in OpenCode config
  - Current: 8192 — reasonable default for code generation
  - Try: 4096 (more input room), 16384 (longer code output)
  - Measure: does reducing output improve codebase review? Does increasing it help code generation?

- [ ] Tune local Ollama settings for best performance
  - Test different `num_ctx` values (8k, 16k, 32k) — smaller context = faster inference
  - Test quantization variants (Q4_K_M vs Q8) — trade quality for speed
  - Benchmark with `benchmark.sh` pointing at `localhost:11434`

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
