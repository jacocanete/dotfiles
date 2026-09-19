---
name: 9router-web-search
description: Search the web, news, or public X posts via 9Router using the `9r` wrapper. Use whenever the user wants current information, articles, docs, release notes, or anything beyond the local repo and training data. Prefer this over the built-in websearch tool.
---

# 9Router — Web Search

Run searches with the `9r` wrapper, never raw `curl`. It reads `NINEROUTER_URL`
and `NINEROUTER_KEY` from the environment, so the API key never appears in a
command line or transcript.

## Usage

```bash
9r search "<query>" [-n <max_results>] [-m <model>] [-t web|news|x]
```

Defaults: `-m search-combo`, `-n 5`, `-t web`.

`search-combo` chains the configured providers with automatic fallback, so it is
the right choice unless a specific provider is needed. Pass `-m` only to force
one: `tavily`, `brave`, `exa`, `serper`, `searchapi`, `linkup`, `ollama-search`.

Output is JSON. Pipe through `jq` to keep it readable — the raw payload is large
and includes base64 favicon URLs:

```bash
9r search "opencode agent skills" -n 3 | jq -r '.results[] | "\(.title)\n\(.url)\n\(.snippet)\n"'
```

Discover what is actually configured on this instance:

```bash
9r models | jq -r '.data[] | select(.kind=="webSearch") | .id'
```

## Response shape

```json
{
  "provider": "tavily",
  "query": "...",
  "results": [
    { "title": "...", "url": "...", "snippet": "...", "position": 1, "published_at": "..." }
  ],
  "answer": null,
  "usage": { "queries_used": 1, "search_cost_usd": 0.005 },
  "metrics": { "response_time_ms": 801 }
}
```

`provider` reports which upstream actually served the request, which may differ
between calls when using a combo. Cite the `url` of any result you rely on.

## Notes

- Searches cost money per query (`usage.search_cost_usd`). Search once with a
  good query rather than repeatedly with vague ones.
- To read the full text of a result, hand the `url` to the `9router-web-fetch`
  skill; search snippets are truncated.
- `-t x` requires an X-capable provider (Xquik) to be configured. Most providers
  are web-only; check `searchTypes` before forcing `-t news` or `-t x`:
  `curl -fsS "$NINEROUTER_URL/v1/models/info?id=linkup/search" -H "Authorization: Bearer $NINEROUTER_KEY"`
