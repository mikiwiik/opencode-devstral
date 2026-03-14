#!/bin/bash
# Quick benchmark: measure tokens/s from vLLM endpoint
# Usage: ./benchmark.sh <API_URL> <API_KEY>
#
# Sample output (RTX 4500 Ada 24GB, Devstral Small 2):
#
#   === Timing ===
#   HTTP status: 200
#   Total time: 10.183783s
#   Time to first byte: 10.183567s
#
#   === Usage ===
#   {
#     "prompt_tokens": 16,
#     "total_tokens": 528,
#     "completion_tokens": 512
#   }
#
#   ~50 tokens/s (512 completion tokens / 10.18s)

API_URL="${1:?Usage: ./benchmark.sh <API_URL> <API_KEY>}"
API_KEY="${2:?Usage: ./benchmark.sh <API_URL> <API_KEY>}"
MODEL="mistralai/Devstral-Small-2-24B-Instruct-2512"

echo "POST ${API_URL}/v1/chat/completions"
echo "Model: ${MODEL}"
echo ""

RESPONSE=$(curl -w "\n\n=== Timing ===\nHTTP status: %{http_code}\nTotal time: %{time_total}s\nTime to first byte: %{time_starttransfer}s\n" \
  -s -X POST "${API_URL}/v1/chat/completions" \
  -H "Authorization: Bearer ${API_KEY}" \
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
