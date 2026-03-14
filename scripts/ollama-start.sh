#!/bin/bash
# Start Ollama with optimized settings for Apple Silicon (128GB)
#
# Usage: ollama-start [--large-ctx]
#
# --large-ctx   Enable q8_0 KV cache quantization for large context tasks
#               (codebase review, multi-file analysis). Adds slight overhead
#               on small prompts but halves KV cache memory, enabling much
#               larger context windows.
#
# Install: ln -sf "$(pwd)/scripts/ollama-start.sh" ~/.local/bin/ollama-start
#
# Optional: increase GPU memory allocation (resets on boot)
#   sudo sysctl iogpu.wired_limit_mb=120000

# Enable FlashAttention — faster attention for longer sequences
export OLLAMA_FLASH_ATTENTION=1

# Keep models loaded between sessions (avoid reload latency)
export OLLAMA_KEEP_ALIVE=24h

# Enable KV cache quantization only when requested
if [ "$1" = "--large-ctx" ]; then
  export OLLAMA_KV_CACHE_TYPE=q8_0
fi

echo "Starting Ollama with settings:"
echo "  OLLAMA_FLASH_ATTENTION=$OLLAMA_FLASH_ATTENTION"
echo "  OLLAMA_KV_CACHE_TYPE=${OLLAMA_KV_CACHE_TYPE:-f16 (default)}"
echo "  OLLAMA_KEEP_ALIVE=$OLLAMA_KEEP_ALIVE"
echo ""

ollama serve
