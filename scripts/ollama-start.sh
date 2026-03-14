#!/bin/bash
# Start Ollama with optimized settings for Apple Silicon (128GB)
#
# Install: ln -sf "$(pwd)/scripts/ollama-start.sh" /usr/local/bin/ollama-start
#
# Optional: increase GPU memory allocation (resets on boot)
#   sudo sysctl iogpu.wired_limit_mb=120000

# Enable FlashAttention — faster attention, required for KV cache quantization
export OLLAMA_FLASH_ATTENTION=1

# Quantize KV cache to q8_0 — halves cache memory with negligible quality loss
export OLLAMA_KV_CACHE_TYPE=q8_0

# Keep models loaded between sessions (avoid reload latency)
export OLLAMA_KEEP_ALIVE=24h

echo "Starting Ollama with optimized settings:"
echo "  OLLAMA_FLASH_ATTENTION=$OLLAMA_FLASH_ATTENTION"
echo "  OLLAMA_KV_CACHE_TYPE=$OLLAMA_KV_CACHE_TYPE"
echo "  OLLAMA_KEEP_ALIVE=$OLLAMA_KEEP_ALIVE"
echo ""

ollama serve
