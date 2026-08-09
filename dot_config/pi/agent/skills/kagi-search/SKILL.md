---
name: kagi-search
description: Web search, content extraction, images, videos, news, and podcasts via Kagi Search API. Use for searching documentation, facts, current information, or any web content. Supports lenses, region filters, date ranges, and markdown extraction.
---

# Kagi Search

Web search and content extraction using the Kagi Search API. No browser required.

## Setup

Requires a Kagi API key in the `KAGI_API_KEY` environment variable.

Get your API key at: https://kagi.com/api/keys

## Search

```fish
{baseDir}/search.fish "query"                              # Basic web search
{baseDir}/search.fish "query" --workflow images            # Image search
{baseDir}/search.fish "query" --workflow videos            # Video search
{baseDir}/search.fish "query" --workflow news              # News search
{baseDir}/search.fish "query" --workflow podcasts          # Podcast search
{baseDir}/search.fish "query" -n 10                        # Limit to 10 results (max 1024)
{baseDir}/search.fish "query" --extract 5                  # Extract full content from top 5 results
{baseDir}/search.fish "query" --region DE                  # Results from Germany
{baseDir}/search.fish "query" --after 2024-01-01           # Results after date
{baseDir}/search.fish "query" --before 2024-12-31          # Results before date
{baseDir}/search.fish "query" --time-relative week         # Results from past day/week/month
{baseDir}/search.fish "query" --sites-included wikipedia.org  # Restrict to domains
{baseDir}/search.fish "query" --sites-excluded reddit.com  # Exclude domains
{baseDir}/search.fish "query" --file-type pdf              # File type filter
{baseDir}/search.fish "query" --lens research              # Use a Kagi lens
{baseDir}/search.fish "query" --format markdown            # Markdown output (experimental)
```

### Options

- `--workflow <type>` - `search` (default), `images`, `videos`, `news`, `podcasts`
- `-n <num>` - Max results (default: 10, max: 1024)
- `--extract <num>` - Extract full page markdown from top N results
- `--region <code>` - ISO 3166-1 alpha-2 country code
- `--after <date>` - Results after YYYY-MM-DD
- `--before <date>` - Results before YYYY-MM-DD
- `--time-relative <period>` - `day`, `week`, or `month`
- `--sites-included <domain>` - Restrict to domain (repeatable)
- `--sites-excluded <domain>` - Exclude domain (repeatable)
- `--keywords-included <keyword>` - Require keyword (repeatable)
- `--keywords-excluded <keyword>` - Exclude keyword (repeatable)
- `--file-type <type>` - e.g. `pdf`, `doc`
- `--lens <id>` - Kagi lens ID or URL
- `--format <fmt>` - `json` (default) or `markdown`
- `--page <num>` - Page number (1-10)
- `--timeout <secs>` - 0.5-4 seconds

## Extract Page Content

```fish
{baseDir}/search.fish --extract-url https://example.com/article
{baseDir}/search.fish --extract-url URL1 --extract-url URL2  # Up to 10 URLs
```

## Output Format

Each result shows title, URL, date, and snippet. With `--extract`, full page markdown is appended.

## When to Use

- Searching for documentation, API references, or technical information
- Looking up current facts, news, or recent information
- Finding images, videos, or podcasts on a topic
- Extracting readable content from web pages
- Any task requiring web search without interactive browsing
