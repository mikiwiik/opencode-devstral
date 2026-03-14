#!/bin/bash
# Quick benchmark: measure tokens/s from any OpenAI-compatible endpoint
# Usage: ./benchmark.sh <API_URL> [API_KEY] [MODEL]
#
# Examples:
#   ./benchmark.sh https://containers.datacrunch.io/my-container dc_abc123
#   ./benchmark.sh http://localhost:11434 "" devstral-small-2-32k
#   ./benchmark.sh https://api.mistral.ai "$MISTRAL_API_KEY" devstral-small-latest


if [ -z "$1" ]; then
  echo "Usage: ./benchmark.sh <API_URL> [API_KEY] [MODEL]"
  exit 1
fi

API_URL="$1"
API_KEY="${2:-}"
MODEL="${3:-mistralai/Devstral-Small-2-24B-Instruct-2512}"

AUTH_HEADER=""
if [ -n "$API_KEY" ]; then
  AUTH_HEADER="-H \"Authorization: Bearer ${API_KEY}\""
fi

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
