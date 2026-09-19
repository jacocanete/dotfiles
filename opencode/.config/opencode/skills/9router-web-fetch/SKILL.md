---
name: 9router-web-fetch
description: Fetch a URL as markdown, text, or HTML via 9Router using the `9r` wrapper. Use whenever the user wants to read an article, scrape a page, extract docs, or convert a URL to markdown. Prefer this over the built-in webfetch tool.
---

# 9Router — Web Fetch

Fetch pages with the `9r` wrapper, never raw `curl`. It reads `NINEROUTER_URL`
and `NINEROUTER_KEY` from the environment, so the API key never appears in a
command line or transcript.

## Usage

```bash
9r fetch <url> [-f markdown|text|html] [-m <model>] [-c <max_characters>]
```

Defaults: `-m fetch-combo`, `-f markdown`, no truncation.

`fetch-combo` chains the configured providers with automatic fallback. Pass `-m`
only to force one (`firecrawl`, `jina-reader`, `tavily`, `exa`, `ollama`).

Output is JSON. The page body lives at `.content.text`:

```bash
9r fetch https://example.com | jq -r '.content.text'
```

Cap long pages so they do not flood context:

```bash
9r fetch https://example.com/long-article -c 5000 | jq -r '.content.text'
```

## Response shape

```json
{
  "provider": "firecrawl",
  "url": "...",
  "title": "Example Domain",
  "content": { "format": "markdown", "text": "...", "length": 167 },
  "links": ["https://example.com/related"],
  "metadata": { "author": null, "published_at": null, "language": null },
  "usage": { "fetch_cost_usd": 0.002 },
  "metrics": { "response_time_ms": 861 }
}
```

`links` appears only when the upstream provider returns discovered links
(currently Ollama Cloud).

## Provider quirks

| Provider | Best for |
|---|---|
| `firecrawl` | JS-rendered pages; markdown or HTML |
| `jina-reader` | Free tier, fastest plain markdown |
| `tavily` | Bulk extract |
| `exa` | Pre-indexed pages, fast text extraction |
| `ollama` | Markdown plus title and discovered links |

## Notes

- Fetches cost money per call (`usage.fetch_cost_usd`). Use `-c` and `jq` rather
  than dumping whole pages repeatedly.
- To find URLs in the first place, use the `9router-web-search` skill.
- Check available fetch providers with:
  `9r models | jq -r '.data[] | select(.kind=="webFetch") | .id'`
