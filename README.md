# IP Lookup API

**Free IP geolocation API — country, region, city, coordinates, timezone, ISP and ASN. IPv4 + IPv6.
No signup required.**

[English](README.md) · [简体中文](README.zh-CN.md) · [繁體中文](README.zh-TW.md) · [日本語](README.ja.md) · [한국어](README.ko.md)

A no-nonsense alternative to the usual "10,000 free requests/month after you create an account"
services: this one answers without an API key, and answers from the command line by default.

```bash
$ curl https://bgp.cx                       # your own public IP
191.223.220.39

$ curl https://bgp.cx/ip/8.8.8.8            # any IP, plain text
IP          : 8.8.8.8
Location    : 美国 加利福尼亚州 山景城
Country     : 美国 (US / USA)
Region      : 加利福尼亚州
City        : 山景城
Continent   : 北美洲
ISP         : 谷歌公共DNS(GoogleDNS)
ASN         : AS15169 Google LLC
AS Domain   : google.com
Usage       : DNS
Network     : 8.8.8.8/32
Timezone    : America/Los_Angeles
Coordinates : 37.386051, -122.083847
Phone Code  : +1
Currency    : USD

$ curl "https://bgp.cx/ip/8.8.8.8?lang=en"  # or ask for English
Location    : United States California Mountain View
Country     : United States (US / USA)

$ curl https://bgp.cx/api/ip/8.8.8.8        # JSON, 25 fields
{
  "ip": "8.8.8.8",
  "version": 4,
  "country": "美国",
  "country_code": "US",
  "region": "加利福尼亚州",
  "city": "山景城",
  "continent": "北美洲",
  "latitude": 37.386051,
  "longitude": -122.083847,
  "timezone": "America/Los_Angeles",
  "isp": "谷歌公共DNS(GoogleDNS)",
  "asn": 15169,
  "asn_organization": "Google LLC",
  "asn_domain": "google.com",
  "usage_type": "DNS",
  "network": "8.8.8.8/32",
  ...
}
```

- **No API key needed.** Anonymous use is rate limited per IP (IPv6 per /64); an API key raises the
  quota.
- **IPv4 and IPv6**, plus **domain names** — they are resolved for you.
- **ASN lookups** — name, domain, country, usage type and every announced prefix.
- **Up to 27 fields** including coordinates, timezone, continent, ISO codes, currency, phone code
  and flag (23 in English; the `*_en` variants come with a non-English result language).
- **Multi-language** results (`zh-CN`, `zh-TW`, `en`, `ja`, `ko`, …).
- **JSONP and permissive CORS** for browser use.
- **Offline databases** in MaxMind `.mmdb` and ip2region `.xdb` formats.

Try it right now:

```bash
curl https://bgp.cx/ip/1.1.1.1
curl https://bgp.cx/ip/github.com
curl https://bgp.cx/asn/15169
```

## Examples in this repo

Runnable examples for the languages people actually call IP geolocation from. Every file is
self-contained — copy it, run it, edit the IP.

| Language | File | Dependency |
|---|---|---|
| cURL / shell | [`examples/curl.sh`](examples/curl.sh) | none |
| Python | [`examples/python.py`](examples/python.py) | `requests` (or swap for `urllib`) |
| Go | [`examples/go.go`](examples/go.go) | none (stdlib) |
| Node.js | [`examples/node.js`](examples/node.js) | Node 18+ (global `fetch`) |
| PHP | [`examples/php.php`](examples/php.php) | none |
| Java | [`examples/Java.java`](examples/Java.java) | Java 11+ (stdlib) |
| C# / .NET | [`examples/csharp.cs`](examples/csharp.cs) | .NET 6+ (stdlib) |
| Ruby | [`examples/ruby.rb`](examples/ruby.rb) | none (stdlib) |
| Rust | [`examples/rust.rs`](examples/rust.rs) | `reqwest` (rustls-tls), `serde_json` |
| PowerShell | [`examples/powershell.ps1`](examples/powershell.ps1) | none |
| Bash one-liners | [`examples/oneliners.sh`](examples/oneliners.sh) | `curl`, `jq` |

## API reference

Base URL: `https://bgp.cx`

### Plain text (good for shell and configs)

| Request | Returns |
|---|---|
| `GET /` | Your own public IP |
| `GET /ip` , `GET /jsonip` | Your IP (text / `{"ip":"…"}`) |
| `GET /info` | Details for your own IP |
| `GET /ip/{ip\|domain}` | Full record, human readable |
| `GET /ip/{ip}/{field}` | A single field, plain text |
| `GET /asn/{asn}` | ASN info and prefixes |

`{ip}` accepts `me` for the caller's own address. `{field}` takes any field name below, plus
`location` (full location string) and `loc` (`"lat,lon"`).

```bash
curl https://bgp.cx/ip/me/country                 # just your country
curl https://bgp.cx/ip/8.8.8.8/latitude           # one field from a specific IP
curl https://bgp.cx/ip/8.8.8.8/loc                # "lat,lon" pair
curl https://bgp.cx/ip/8.8.8.8?format=json        # force JSON from the text endpoint
```

> `coordinates` is a label in the human-readable output, not a field name — use `latitude`,
> `longitude`, or `loc` for the pair.

### JSON

| Request | Returns |
|---|---|
| `GET /api/ip` | Caller's own IP as JSON |
| `GET /api/ip/{ip\|domain}` | Full JSON record |
| `GET /api/lookup?q={ip\|domain}` | `info` (result) + `resolved` (DNS answer) |
| `GET /api/asn/{asn}` | ASN with announced prefixes |

All JSON endpoints send `Access-Control-Allow-Origin: *`, so you can call them straight from a
browser.

### Parameters

| Parameter | Values | Meaning |
|---|---|---|
| `lang` | `zh-CN` `zh-TW` `en` `ja` `ko` `de` `fr` `ru` `es` `pt-BR` | result language |
| `format` | `json` \| `text` | force the response format |
| `pretty` | – | pretty-print JSON |
| `callback` | function name | JSONP |
| `key` | `ipk_…` | API key (query endpoints) |

### Fields

| Field | Meaning |
|---|---|
| `ip`, `version` | address and IP version (4 / 6) |
| `country`, `country_code`, `country_alpha3` | country name, ISO-3166 alpha-2 / alpha-3 |
| `region`, `region_code`, `city`, `district` | administrative divisions |
| `continent`, `continent_code` | continent |
| `latitude`, `longitude`, `timezone` | coordinates and IANA timezone |
| `isp`, `organization` | carrier / organization |
| `asn`, `asn_organization`, `asn_domain`, `usage_type` | autonomous system details |
| `network` | the announced CIDR the IP belongs to |
| `phone_code`, `currency`, `languages`, `flag` | country metadata |
| `*_en` variants | English place names (when the UI language is not English) |

Unavailable fields are `null`. The exact field set depends on the plan — the free tier returns a
subset, paid plans return everything.

### ASN endpoints

```bash
curl "https://bgp.cx/api/asn/4134?family=4&limit=100&offset=0"
```

`family` is `4` or `6` to filter prefixes, `limit` is capped at 10000, `offset` paginates.
`{asn}` may be written `4134` or `AS4134`.

### Rate limits

| | Limit |
|---|---|
| Anonymous | per IP (IPv6 per /64), per minute |
| With API key | per account, set by your plan |

Exceeding a limit returns `429` with `Retry-After` telling you how many seconds to wait. Quota
responses also carry `X-RateLimit-Limit`, `X-Quota-Limit` and `X-Quota-Remaining`.

For higher limits, sign up for a free account and send the key as a bearer token:

```bash
curl -H "Authorization: Bearer ipk_xxx" https://bgp.cx/api/ip/1.1.1.1
```

> Keep keys out of URLs — the `?key=` form exists for compatibility but is discouraged.

### Status codes

| Code | Meaning |
|---|---|
| `400` | invalid IP or domain, or the domain does not resolve |
| `401` | missing or invalid API key |
| `403` | no download permission for that database |
| `404` | not found |
| `429` | rate limited |

Errors look like `{"error":"…","code":400}` in JSON, `error: …` in plain text.

## Offline databases

If you would rather not call an API at all, the same data is available as downloadable databases in
**MaxMind `.mmdb`** and **ip2region `.xdb`** format — the formats already supported by nginx
`ngx_http_geoip2`, Clash / mihomo `GEOIP,CN`, and the standard MaxMind readers.

```bash
curl https://bgp.cx/api/databases              # the edition list and their fields
```

Editions range from a small country/city set to a full record with ASN, coordinates and English
names. See the [database documentation](https://bgp.cx/docs/database) for the schema and reader
examples.

## Command line tool

There is also [`bgptool`](https://github.com/acloudpeng/bgptool) — traceroute and MTR that annotate
every hop with its ASN, location and ISP:

```bash
curl -fsSL https://bgp.cx/install.sh | sh
bgptool trace 8.8.8.8
```

## License

The examples in this repository are MIT licensed — use them however you like. The API itself is a
hosted service; see [bgp.cx](https://bgp.cx) for its terms.
