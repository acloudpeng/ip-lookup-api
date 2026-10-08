#!/usr/bin/env node
// IP geolocation from Node.js — requires Node 18+ (global fetch), no dependencies.
//
//   node node.js [ip-or-domain]
'use strict';

const BASE = 'https://bgp.cx';
const API_KEY = process.env.IPLOOKUP_KEY || '';

/** Look up an IP or domain; an empty target queries the caller's own address. */
async function lookup(target = '', lang = 'en') {
  const url = target
    ? `${BASE}/api/ip/${encodeURIComponent(target)}?lang=${lang}`
    : `${BASE}/api/ip?lang=${lang}`;

  const headers = API_KEY ? { Authorization: `Bearer ${API_KEY}` } : {};
  const res = await fetch(url, { headers });
  if (!res.ok) throw new Error(`lookup failed: HTTP ${res.status}`);
  return res.json();
}

/** Fetch a single field as plain text. */
async function field(target, name) {
  const res = await fetch(`${BASE}/ip/${encodeURIComponent(target)}/${name}`);
  if (!res.ok) throw new Error(`field lookup failed: HTTP ${res.status}`);
  return (await res.text()).trim();
}

/** ASN details with announced prefixes. */
async function asn(number, { family, limit = 100 } = {}) {
  const params = new URLSearchParams({ limit });
  if (family) params.set('family', family);
  const res = await fetch(`${BASE}/api/asn/${number}?${params}`);
  if (!res.ok) throw new Error(`asn lookup failed: HTTP ${res.status}`);
  return res.json();
}

async function main() {
  const target = process.argv[2] || '';

  const info = await lookup(target);
  console.log(JSON.stringify(info, null, 2));

  if (info.ip) {
    console.log('\ncountry :', await field(info.ip, 'country'));
    console.log('location:', await field(info.ip, 'location'));
    console.log('coords  :', await field(info.ip, 'loc'));
  }

  if (info.asn) {
    const detail = await asn(info.asn, { family: 4, limit: 5 });
    console.log(`\nAS${detail.asn} ${detail.name} — ${detail.ipv4_prefixes} IPv4 prefixes`);
    for (const p of detail.prefixes || []) console.log(' ', p);
  }
}

main().catch((err) => {
  console.error('error:', err.message);
  process.exit(1);
});
