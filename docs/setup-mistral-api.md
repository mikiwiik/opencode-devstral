# Mistral API Setup: Devstral + OpenCode

Run Devstral Small 2 (24B) via Mistral's hosted API — no GPU infrastructure to manage.

## Prerequisites

```sh
# check if already installed
which opencode && opencode --version

# install OpenCode
brew install opencode
# or: curl -fsSL https://opencode.ai/install | bash
```

## 1. Get a Mistral API key

1. Create an account or sign in at [console.mistral.ai](https://console.mistral.ai)
2. Go to [admin.mistral.ai](https://admin.mistral.ai) > Billing, add payment info (free tier available)
3. Go to console.mistral.ai > API keys > Create new key
4. Save the key securely — it won't be shown again

## 2. Test the endpoint

```sh
curl -s -X POST https://api.mistral.ai/v1/chat/completions \
  -H "Authorization: Bearer YOUR_MISTRAL_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "devstral-small-latest",
    "messages": [{"role": "user", "content": "Hello"}],
    "max_tokens": 64
  }' | jq '.usage'
```

## 3. Connect OpenCode

Install the config globally (recommended):

```sh
cp opencode.example.json ~/.config/opencode/opencode.json
```

To default to Mistral's hosted model, edit `~/.config/opencode/opencode.json` and change the top-level `"model"` to `"mistral/devstral-small-latest"`. Then set your API key:

```sh
# add to your ~/.zshrc or ~/.bashrc
export MISTRAL_API_KEY="your-mistral-api-key"
```

Run `opencode` from any project. See [`opencode.example.json`](../opencode.example.json) for the full config.

## Pricing

| | Price |
|---|---|
| Input | $0.10 / 1M tokens |
| Output | $0.30 / 1M tokens |
| Context window | 256k tokens |

Currently offered with a free introductory tier. Same model weights as self-hosted Devstral Small 2.

## References

- [Devstral Small 2 docs](https://docs.mistral.ai/models/devstral-small-2-25-12)
- [Mistral pricing](https://mistral.ai/pricing)
- [Mistral console](https://console.mistral.ai)
- [OpenCode docs](https://opencode.ai/docs/)
