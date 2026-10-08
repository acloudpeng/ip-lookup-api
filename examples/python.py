#!/usr/bin/env python3
"""IP geolocation from Python.

    pip install requests
    python python.py [ip-or-domain]

Works without an API key. Set IPLOOKUP_KEY to use your account quota instead of the
anonymous per-IP limit.
"""
import json
import os
import sys

import requests

BASE = "https://bgp.cx"
API_KEY = os.environ.get("IPLOOKUP_KEY", "")


def lookup(target: str = "", lang: str = "en") -> dict:
    """Look up an IP or domain. An empty target queries the caller's own address."""
    url = f"{BASE}/api/ip/{target}" if target else f"{BASE}/api/ip"
    headers = {"Authorization": f"Bearer {API_KEY}"} if API_KEY else {}
    r = requests.get(url, params={"lang": lang}, headers=headers, timeout=10)
    r.raise_for_status()
    return r.json()


def field(target: str, name: str) -> str:
    """Fetch a single field as plain text — cheapest response to parse."""
    r = requests.get(f"{BASE}/ip/{target}/{name}", timeout=10)
    r.raise_for_status()
    return r.text.strip()


def asn(number: str, family: int | None = None, limit: int = 100) -> dict:
    params = {"limit": limit}
    if family:
        params["family"] = family
    r = requests.get(f"{BASE}/api/asn/{number}", params=params, timeout=10)
    r.raise_for_status()
    return r.json()


def main() -> None:
    target = sys.argv[1] if len(sys.argv) > 1 else ""

    info = lookup(target)
    print(json.dumps(info, indent=2, ensure_ascii=False))

    if info.get("ip"):
        print()
        print(f"country : {field(info['ip'], 'country')}")
        print(f"location: {field(info['ip'], 'location')}")
        print(f"coord   : {field(info['ip'], 'loc')}")

    if info.get("asn"):
        print()
        print(f"asn     : AS{info['asn']} {info.get('asn_organization', '')}")


if __name__ == "__main__":
    main()
