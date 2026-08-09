#!/usr/bin/env fish
# Kagi Search API client
# Uses KAGI_API_KEY environment variable
# Docs: https://kagi.com/api/docs

set -l API_BASE "https://kagi.com/api/v1"

function usage
    echo "Usage: search.fish <query> [options]"
    echo "       search.fish --extract-url <url> [--extract-url <url>...]"
    echo ""
    echo "Search options:"
    echo "  --workflow <type>        search (default), images, videos, news, podcasts"
    echo "  -n <num>                 Max results (default: 10, max: 1024)"
    echo "  --extract <num>          Extract full page markdown from top N results"
    echo "  --region <code>          ISO 3166-1 alpha-2 country code"
    echo "  --after <date>           Results after YYYY-MM-DD"
    echo "  --before <date>          Results before YYYY-MM-DD"
    echo "  --time-relative <p>      day, week, or month"
    echo "  --sites-included <d>     Restrict to domain (repeatable)"
    echo "  --sites-excluded <d>     Exclude domain (repeatable)"
    echo "  --keywords-included <k>  Require keyword (repeatable)"
    echo "  --keywords-excluded <k>  Exclude keyword (repeatable)"
    echo "  --file-type <type>       e.g. pdf, doc"
    echo "  --lens <id>              Kagi lens ID or URL"
    echo "  --format <fmt>           json (default) or markdown"
    echo "  --page <num>             Page number (1-10)"
    echo "  --timeout <secs>         0.5-4 seconds"
    echo ""
    echo "Extract options:"
    echo "  --extract-url <url>      URL to extract content from (repeatable, max 10)"
    echo ""
    echo "Environment:"
    echo "  KAGI_API_KEY             Required. Get one at https://kagi.com/api/keys"
    exit 1
end

if test -z "$KAGI_API_KEY"
    echo "Error: KAGI_API_KEY environment variable is not set." >&2
    echo "Get your API key at: https://kagi.com/api/keys" >&2
    exit 1
end

# ── Extract mode (--extract-url) ──────────────────────────────
set -l extract_mode false
for arg in $argv
    if test "$arg" = "--extract-url"
        set extract_mode true
        break
    end
end

if $extract_mode
    set -l urls
    set -l i 1
    while test $i -le (count $argv)
        if test "$argv[$i]" = "--extract-url"
            set i (math $i + 1)
            if test $i -le (count $argv)
                set -a urls $argv[$i]
            else
                usage
            end
        else
            set i (math $i + 1)
        end
    end

    if test (count $urls) -eq 0
        usage
    end

    if test (count $urls) -gt 10
        echo "Error: Maximum 10 URLs allowed for extraction." >&2
        exit 1
    end

    set -l parts
    for url in $urls
        # JSON-escape: backslash first, then double quote
        set -l escaped (string replace -a '\\' '\\\\' -- $url | string replace -a '"' '\\"')
        set -a parts "{\"url\":\"$escaped\"}"
    end
    set -l pages_json "["(string join "," $parts)"]"
    set -l body "{\"pages\":$pages_json}"

    set -l tmp_body (mktemp)
    set -l http_code (curl -s -w "%{http_code}" \
        -X POST "$API_BASE/extract" \
        -H "Authorization: Bearer $KAGI_API_KEY" \
        -H "Content-Type: application/json" \
        -H "Accept: application/json" \
        -d "$body" \
        -o "$tmp_body" 2>&1)

    if test "$http_code" != "200"
        echo "Error: HTTP $http_code" >&2
        cat "$tmp_body" >&2
        rm -f "$tmp_body"
        exit 1
    end

    jq -r '
        .data[] |
        "--- Page ---",
        "URL: \(.url)",
        if .markdown then "\nContent:\n\(.markdown)\n" else "" end,
        if .error then "\nError: \(.error)\n" else "" end,
        ""
    ' "$tmp_body"
    rm -f "$tmp_body"
    exit 0
end

# ── Search mode ────────────────────────────────────────────────
set -l query ""
set -l workflow "search"
set -l limit 10
set -l extract_num 0
set -l region ""
set -l after_date ""
set -l before_date ""
set -l time_relative ""
set -l sites_included
set -l sites_excluded
set -l keywords_included
set -l keywords_excluded
set -l file_type ""
set -l lens_id ""
set -l format "json"
set -l page 0
set -l timeout "null"

set -l i 1
while test $i -le (count $argv)
    switch $argv[$i]
        case --workflow
            set i (math $i + 1); test $i -le (count $argv) && set workflow $argv[$i] || usage
        case -n
            set i (math $i + 1); test $i -le (count $argv) && set limit $argv[$i] || usage
        case --extract
            set i (math $i + 1); test $i -le (count $argv) && set extract_num $argv[$i] || usage
        case --region
            set i (math $i + 1); test $i -le (count $argv) && set region $argv[$i] || usage
        case --after
            set i (math $i + 1); test $i -le (count $argv) && set after_date $argv[$i] || usage
        case --before
            set i (math $i + 1); test $i -le (count $argv) && set before_date $argv[$i] || usage
        case --time-relative
            set i (math $i + 1); test $i -le (count $argv) && set time_relative $argv[$i] || usage
        case --sites-included
            set i (math $i + 1); test $i -le (count $argv) && set -a sites_included $argv[$i] || usage
        case --sites-excluded
            set i (math $i + 1); test $i -le (count $argv) && set -a sites_excluded $argv[$i] || usage
        case --keywords-included
            set i (math $i + 1); test $i -le (count $argv) && set -a keywords_included $argv[$i] || usage
        case --keywords-excluded
            set i (math $i + 1); test $i -le (count $argv) && set -a keywords_excluded $argv[$i] || usage
        case --file-type
            set i (math $i + 1); test $i -le (count $argv) && set file_type $argv[$i] || usage
        case --lens
            set i (math $i + 1); test $i -le (count $argv) && set lens_id $argv[$i] || usage
        case --format
            set i (math $i + 1); test $i -le (count $argv) && set format $argv[$i] || usage
        case --page
            set i (math $i + 1); test $i -le (count $argv) && set page $argv[$i] || usage
        case --timeout
            set i (math $i + 1); test $i -le (count $argv) && set timeout $argv[$i] || usage
        case '-*'
            echo "Unknown option: $argv[$i]" >&2; usage
        case '*'
            if test -z "$query"
                set query $argv[$i]
            else
                set query "$query $argv[$i]"
            end
    end
    set i (math $i + 1)
end

if test -z "$query"
    usage
end

# ── Build JSON body ────────────────────────────────────────────

# Build lens object
set -l lens_json "null"
if test (count $sites_included) -gt 0 -o \
        (count $sites_excluded) -gt 0 -o \
        (count $keywords_included) -gt 0 -o \
        (count $keywords_excluded) -gt 0 -o \
        -n "$file_type" -o \
        -n "$time_relative" -o \
        -n "$region"
    set lens_json (jq -n \
        --argjson sites_inc (printf '%s\n' $sites_included | jq -R -s 'split("\n") | map(select(. != ""))') \
        --argjson sites_exc (printf '%s\n' $sites_excluded | jq -R -s 'split("\n") | map(select(. != ""))') \
        --argjson kw_inc (printf '%s\n' $keywords_included | jq -R -s 'split("\n") | map(select(. != ""))') \
        --argjson kw_exc (printf '%s\n' $keywords_excluded | jq -R -s 'split("\n") | map(select(. != ""))') \
        --arg file_type "$file_type" \
        --arg time_rel "$time_relative" \
        --arg search_region "$region" \
        '{
            sites_included: $sites_inc,
            sites_excluded: $sites_exc,
            keywords_included: $kw_inc,
            keywords_excluded: $kw_exc,
            file_type: $file_type,
            time_relative: $time_rel,
            search_region: $search_region
        } | with_entries(select(.value != null and .value != "" and .value != []))')
    if test (echo "$lens_json" | jq 'length') = "0"
        set lens_json "null"
    end
end

# Build extract object
set -l extract_json "null"
if test "$extract_num" -gt 0
    set extract_json "{\"count\":$extract_num}"
end

# Build filters object
set -l filters_json "null"
if test -n "$region" -o -n "$after_date" -o -n "$before_date"
    set filters_json (jq -n \
        --arg region "$region" \
        --arg after "$after_date" \
        --arg before "$before_date" \
        '{region: $region, after: $after, before: $before} | with_entries(select(.value != null and .value != ""))')
    if test (echo "$filters_json" | jq 'length') = "0"
        set filters_json "null"
    end
end

# Assemble final request body
set -l body (jq -n \
    --arg query "$query" \
    --arg workflow "$workflow" \
    --argjson limit "$limit" \
    --arg format "$format" \
    --argjson lens "$lens_json" \
    --argjson extract "$extract_json" \
    --argjson filters "$filters_json" \
    --argjson page "$page" \
    --argjson timeout "$timeout" \
    --arg lens_id "$lens_id" \
    '
    {
        query: $query,
        workflow: $workflow,
        limit: $limit,
        format: $format
    }
    + (if $lens_id != "" then {lens_id: $lens_id} else {} end)
    + (if $lens != null then {lens: $lens} else {} end)
    + (if $extract != null then {extract: $extract} else {} end)
    + (if $filters != null then {filters: $filters} else {} end)
    + (if $page > 0 then {page: $page} else {} end)
    + (if $timeout != null then {timeout: $timeout} else {} end)
    ')

# ── Call the API ───────────────────────────────────────────────
set -l tmp_body (mktemp)
set -l http_code (curl -s -w "%{http_code}" \
    -X POST "$API_BASE/search" \
    -H "Authorization: Bearer $KAGI_API_KEY" \
    -H "Content-Type: application/json" \
    -H "Accept: application/json" \
    -d "$body" \
    -o "$tmp_body" 2>&1)

if test "$http_code" != "200"
    echo "Error: HTTP $http_code" >&2
    cat "$tmp_body" >&2
    rm -f "$tmp_body"
    exit 1
end

# ── Format output ──────────────────────────────────────────────
if test "$format" = "markdown"
    cat "$tmp_body"
    rm -f "$tmp_body"
    exit 0
end

echo "=== Kagi Search Results ==="
echo "Query: $query"
echo ""

set -l data_count (jq '.data | length' "$tmp_body")
if test "$data_count" = "0"
    echo "No results found."
    rm -f "$tmp_body"
    exit 0
end

jq -r '
    .data | to_entries | .[] | .key as $section |
    "## \($section | ascii_upcase)",
    (.value | to_entries | .[] |
        "--- Result \(.key + 1) ---",
        "Title: \(.value.title // "N/A")",
        "URL: \(.value.url // "N/A")",
        (if .value.published then "Published: \(.value.published)" else "" end),
        (if .value.time then "Date: \(.value.time)" else "" end),
        (if .value.snippet then "\nSnippet: \(.value.snippet)" else "" end),
        ""
    )
' "$tmp_body"
rm -f "$tmp_body"
