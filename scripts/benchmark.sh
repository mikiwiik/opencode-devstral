#!/bin/bash
# Quick benchmark: measure tokens/s from any OpenAI-compatible endpoint
#
# Usage:
#   ./benchmark.sh --mistral
#   ./benchmark.sh --verda <API_URL>
#   ./benchmark.sh --local [MODEL]
#
# API keys are read from .env or environment variables.
# See .env.example for the template.

# Source .env if it exists (look relative to script location, then CWD)
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ENV_FILE="$SCRIPT_DIR/../.env"
[ ! -f "$ENV_FILE" ] && ENV_FILE=".env"
if [ -f "$ENV_FILE" ]; then
  set -a
  source "$ENV_FILE"
  set +a
fi

case "$1" in
  --mistral)
    API_URL="https://api.mistral.ai"
    API_KEY="$MISTRAL_API_KEY"
    MODEL="devstral-small-latest"
    if [ -z "$API_KEY" ]; then
      echo "Error: MISTRAL_API_KEY not set (add to .env or export)" >&2
      exit 1
    fi
    ;;
  --verda)
    if [ -z "$2" ]; then
      echo "Error: Usage: ./benchmark.sh --verda <API_URL>" >&2
      exit 1
    fi
    API_URL="$2"
    API_KEY="$VERDA_API_KEY"
    MODEL="mistralai/Devstral-Small-2-24B-Instruct-2512"
    if [ -z "$API_KEY" ]; then
      echo "Error: VERDA_API_KEY not set (add to .env or export)" >&2
      exit 1
    fi
    ;;
  --local)
    API_URL="http://localhost:11434"
    API_KEY=""
    MODEL="${2:-devstral-small-2-32k}"
    ;;
  *)
    echo "Usage:"
    echo "  ./benchmark.sh --mistral              # Mistral API (key from .env)"
    echo "  ./benchmark.sh --verda <API_URL>       # Verda endpoint (key from .env)"
    echo "  ./benchmark.sh --local [MODEL]         # Local Ollama (default: devstral-small-2-32k)"
    echo ""
    echo "API keys are read from .env or environment variables."
    echo "See .env.example for the template."
    exit 1
    ;;
esac

echo "POST ${API_URL}/v1/chat/completions"
echo "Model: ${MODEL}"
echo "Auth: ${API_KEY:+yes}${API_KEY:-none}"
echo ""

RESPONSE=$(curl -w "\n\n=== Timing ===\nHTTP status: %{http_code}\nTotal time: %{time_total}s\nTime to first byte: %{time_starttransfer}s\n" \
  -s -X POST "${API_URL}/v1/chat/completions" \
  ${API_KEY:+-H "Authorization: Bearer ${API_KEY}"} \
  -H "Content-Type: application/json" \
  -d "{
    \"model\": \"${MODEL}\",
    \"messages\": [{\"role\": \"user\", \"content\": \"Write a Python function that solves the fizz / buzz coding puzzle\"}],
    \"max_tokens\": 512
  }")

echo "=== Full response ==="
echo "$RESPONSE"
echo ""
echo "=== Usage ==="
echo "$RESPONSE" | sed '/=== Timing ===/,$d' | jq '.usage' 2>/dev/null || echo "(could not parse usage)"
