#!/bin/bash
# Quick benchmark: measure tokens/s from vLLM endpoint
# Usage: ./benchmark.sh <API_URL> <API_KEY>

API_URL="${1:?Usage: ./benchmark.sh <API_URL> <API_KEY>}"
API_KEY="${2:?Usage: ./benchmark.sh <API_URL> <API_KEY>}"
MODEL="mistralai/Devstral-Small-2-24B-Instruct-2512"

time curl -s -X POST "${API_URL}/v1/chat/completions" \
  -H "Authorization: Bearer ${API_KEY}" \
  -H "Content-Type: application/json" \
  -d "{
    \"model\": \"${MODEL}\",
    \"messages\": [{\"role\": \"user\", \"content\": \"Write a Python function that solves the fizz / buzz coding puzzle\"}],
    \"max_tokens\": 512
  }" | jq '.usage'
