#!/usr/bin/env bash
# IP geolocation with curl — no dependencies.
#   https://bgp.cx
set -euo pipefail

echo "=== Your own IP ==="
curl -s https://bgp.cx
echo

echo "=== A specific IP (plain text) ==="
curl -s https://bgp.cx/ip/8.8.8.8

echo
echo "=== The same IP as JSON ==="
curl -s https://bgp.cx/api/ip/8.8.8.8

echo
echo "=== A single field ==="
country=$(curl -s https://bgp.cx/ip/8.8.8.8/country)
echo "country: $country"

echo
echo "=== A domain name (resolved for you) ==="
curl -s https://bgp.cx/ip/github.com

echo
echo "=== An ASN and its prefixes ==="
curl -s "https://bgp.cx/api/asn/15169?limit=5"

echo
echo "=== IPv6 ==="
curl -s https://bgp.cx/api/ip/2606:4700:4700::1111

echo
echo "=== English results ==="
curl -s "https://bgp.cx/ip/8.8.8.8?lang=en" | head -5

echo
echo "=== With an API key (higher quota) ==="
if [ -n "${IPLOOKUP_KEY:-}" ]; then
  curl -s -H "Authorization: Bearer $IPLOOKUP_KEY" https://bgp.cx/api/ip/1.1.1.1
else
  echo "set IPLOOKUP_KEY=ipk_... to try this"
fi
