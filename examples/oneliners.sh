#!/usr/bin/env bash
# Handy one-liners for the IP lookup API. Needs curl; jq for the JSON ones.
set -euo pipefail

BASE=https://bgp.cx

echo "=== Your public IP ==="
curl -s "$BASE"

echo; echo "=== Just the IP as JSON ==="
curl -s "$BASE/jsonip"

echo; echo "=== Full details for your own connection ==="
curl -s "$BASE/info"

echo; echo "=== Country only (single field, plain text) ==="
curl -s "$BASE/ip/me/country"

echo; echo "=== Coordinates only ==="
curl -s "$BASE/ip/me/loc"

echo; echo "=== Look up any IP ==="
curl -s "$BASE/ip/8.8.8.8"

echo; echo "=== Look up a domain (resolved automatically) ==="
curl -s "$BASE/ip/example.com/country"

echo; echo "=== JSON, and pull one field with jq ==="
curl -s "$BASE/api/ip/1.1.1.1" | jq -r '"\(.country_code) \(.city) (\(.isp), AS\(.asn))"'

echo; echo "=== ASN summary with jq ==="
curl -s "$BASE/api/asn/15169" | jq '{asn, name, country_code, ipv4_prefixes, ipv6_prefixes}'

echo; echo "=== Force JSON from a text endpoint ==="
curl -s "$BASE/ip/8.8.8.8?format=json&pretty=true" | head -5

echo; echo "=== English results ==="
curl -s "$BASE/ip/8.8.8.8/city?lang=en"

echo; echo "=== IPv6 ==="
curl -s "$BASE/ip/2606:4700:4700::1111/city"

echo; echo "=== Shell variable (no jq) — grab the country into a var ==="
country=$(curl -s "$BASE/ip/8.8.8.8/country")
echo "country=$country"

echo; echo "=== Fail fast on a bad address ==="
curl -s -o /dev/null -w 'HTTP %{http_code}\n' "$BASE/api/ip/not-an-ip" || true

echo; echo "=== With an API key (higher quota; keep it in a header, not the URL) ==="
if [ -n "${IPLOOKUP_KEY:-}" ]; then
  curl -s -H "Authorization: Bearer $IPLOOKUP_KEY" "$BASE/api/ip/8.8.8.8/city"
else
  echo "set IPLOOKUP_KEY=ipk_... to try this"
fi
