#!/bin/sh
# headersHelper for the Coolify MCP server: Cloudflare Access service token + Coolify API token.
# Secrets live in the 0600 credentials file beside this script, not in ~/.claude.json.
# The file is parsed, not sourced: Coolify tokens contain '|', which a shell would run as a pipe.
set -e
creds="$(dirname "$0")/credentials"
get() { sed -n "s/^$1=//p" "$creds" | tail -n1; }
jq -cn --arg auth "Bearer $(get COOLIFY_API_TOKEN)" --arg id "$(get CF_ACCESS_CLIENT_ID)" --arg secret "$(get CF_ACCESS_CLIENT_SECRET)" \
	'{"Authorization":$auth,"CF-Access-Client-Id":$id,"CF-Access-Client-Secret":$secret}'
