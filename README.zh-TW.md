# IP Lookup API

**免費 IP 地理位置查詢 API：國家、城市、經緯度、時區、ISP、ASN 一次取得。支援 IPv4 / IPv6，不需註冊。**

[English](README.md) · [简体中文](README.zh-CN.md) · [繁體中文](README.zh-TW.md) · [日本語](README.ja.md) · [한국어](README.ko.md)

其他服務動不動就要你先註冊，再送你「每月一萬次免費額度」。這個不用：**不帶 Key 就能查，在終端機裡 curl 一下就得到結果。**

```bash
$ curl https://bgp.cx                       # 查自己的公網 IP
191.223.220.39

$ curl https://bgp.cx/ip/8.8.8.8            # 查任意 IP，純文字
IP          : 8.8.8.8
Location    : 美國 加利福尼亞州 山景城
Country     : 美國 (US / USA)
Region      : 加利福尼亞州
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

$ curl https://bgp.cx/api/ip/8.8.8.8        # 同一份資料，JSON 格式
{
  "ip": "8.8.8.8",
  "version": 4,
  "country": "美國",
  "country_code": "US",
  "region": "加利福尼亞州",
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

## 特色

- **不需申請金鑰。** 未登入時依 IP 限流（IPv6 以 /64 計算），帶 Key 則有更高額度。
- **同時支援 IPv4 與 IPv6**，也可以直接查網域名稱 —— 會自動幫你解析。
- **ASN 查詢** —— 名稱、網域、所屬國家、網路類型，以及該 ASN 宣告的所有網段。
- **最多 27 個欄位**：經緯度、時區、洲別、ISO 代碼、貨幣、電話國碼、國旗等（英文結果為 23 個；`*_en` 英文字地名只在非英文介面語言下回傳）。
- **多語言結果**（`zh-CN`、`zh-TW`、`en`、`ja`、`ko` 等）。
- **支援 JSONP，CORS 全開**，前端可直接呼叫。
- **離線資料庫**：MaxMind `.mmdb` 與 ip2region `.xdb` 兩種格式。

馬上試試：

```bash
curl https://bgp.cx/ip/1.1.1.1
curl https://bgp.cx/ip/github.com
curl https://bgp.cx/asn/15169
```

## 範例程式碼

收錄各語言的**可直接執行**範例，每個檔案都自成一體 —— 複製後改個 IP 就能跑。

| 語言 | 檔案 | 相依套件 |
|---|---|---|
| cURL / shell | [`examples/curl.sh`](examples/curl.sh) | 無 |
| Python | [`examples/python.py`](examples/python.py) | `requests`（也可改用 `urllib`） |
| Go | [`examples/go.go`](examples/go.go) | 無（標準函式庫） |
| Node.js | [`examples/node.js`](examples/node.js) | Node 18+（內建 `fetch`） |
| PHP | [`examples/php.php`](examples/php.php) | 無 |
| Java | [`examples/Java.java`](examples/Java.java) | Java 11+（標準函式庫） |
| C# / .NET | [`examples/csharp.cs`](examples/csharp.cs) | .NET 6+（標準函式庫） |
| Ruby | [`examples/ruby.rb`](examples/ruby.rb) | 無（標準函式庫） |
| Rust | [`examples/rust.rs`](examples/rust.rs) | `reqwest`（rustls-tls）、`serde_json` |
| PowerShell | [`examples/powershell.ps1`](examples/powershell.ps1) | 無 |
| Bash 一行指令 | [`examples/oneliners.sh`](examples/oneliners.sh) | `curl`、`jq` |

## API 說明

基底網址：`https://bgp.cx`

### 純文字（適合寫腳本、填設定檔）

| 請求 | 回傳 |
|---|---|
| `GET /` | 你自己的公網 IP |
| `GET /ip`、`GET /jsonip` | 你的 IP（純文字 / `{"ip":"…"}`） |
| `GET /info` | 你自己 IP 的詳細資訊 |
| `GET /ip/{ip\|網域}` | 完整記錄，方便人眼閱讀 |
| `GET /ip/{ip}/{欄位}` | 單一欄位，純文字 |
| `GET /asn/{asn}` | ASN 資訊與其網段 |

`{ip}` 填 `me` 代表查自己。`{欄位}` 可用下方任一欄位名稱，另支援 `location`（完整地理位置字串）與 `loc`（`"緯度,經度"`）。

```bash
curl https://bgp.cx/ip/me/country                 # 只要國家
curl https://bgp.cx/ip/8.8.8.8/latitude           # 指定 IP 的某個欄位
curl https://bgp.cx/ip/8.8.8.8/loc                # "緯度,經度"
curl https://bgp.cx/ip/8.8.8.8?format=json        # 強制回傳 JSON
```

> `coordinates` 只是純文字輸出裡的顯示標籤，**不是欄位名稱** —— 取經緯度請用 `latitude`、`longitude` 或 `loc`。

### JSON

| 請求 | 回傳 |
|---|---|
| `GET /api/ip` | 自己的 IP（JSON） |
| `GET /api/ip/{ip\|網域}` | 完整 JSON 記錄 |
| `GET /api/lookup?q={ip\|網域}` | `info`（查詢結果）+ `resolved`（DNS 解析結果） |
| `GET /api/asn/{asn}` | ASN 與其宣告的網段 |

所有 JSON 端點都帶 `Access-Control-Allow-Origin: *`，瀏覽器可直接呼叫。

### 通用參數

| 參數 | 值 | 說明 |
|---|---|---|
| `lang` | `zh-CN` `zh-TW` `en` `ja` `ko` `de` `fr` `ru` `es` `pt-BR` | 結果語言 |
| `format` | `json` \| `text` | 強制指定回傳格式 |
| `pretty` | – | 格式化 JSON |
| `callback` | 函式名稱 | JSONP |
| `key` | `ipk_…` | API Key（查詢端點） |

### 回傳欄位

| 欄位 | 說明 |
|---|---|
| `ip`、`version` | IP 位址、IP 版本（4 / 6） |
| `country`、`country_code`、`country_alpha3` | 國家名稱、ISO-3166 二位 / 三位代碼 |
| `region`、`region_code`、`city`、`district` | 省 / 州、城市、區縣 |
| `continent`、`continent_code` | 洲別 |
| `latitude`、`longitude`、`timezone` | 經緯度、IANA 時區 |
| `isp`、`organization` | ISP / 組織 |
| `asn`、`asn_organization`、`asn_domain`、`usage_type` | ASN 相關 |
| `network` | 該 IP 所屬的宣告網段 |
| `phone_code`、`currency`、`languages`、`flag` | 國家中介資料 |
| `*_en` | 英文地名（介面語言非英文時回傳） |

取不到的欄位為 `null`。**欄位多寡取決於方案** —— 免費版回傳其中一部分，付費方案回傳全部。

### ASN 端點

```bash
curl "https://bgp.cx/api/asn/4134?family=4&limit=100&offset=0"
```

`family` 填 `4` 或 `6` 可篩選協定，`limit` 上限 10000，`offset` 用於分頁。`{asn}` 寫 `4134` 或 `AS4134` 都可以。

### 頻率限制

| | 限制 |
|---|---|
| 未登入 | 依 IP 計算（IPv6 以 /64 計），每分鐘請求數 |
| 帶 API Key | 依帳號計算，依方案而定 |

超過限制會回傳 `429`，`Retry-After` 會告訴你還需等待幾秒。配額相關的回應另帶 `X-RateLimit-Limit`、`X-Quota-Limit`、`X-Quota-Remaining`。

想要更高額度，可註冊免費帳號，把 Key 放在請求標頭：

```bash
curl -H "Authorization: Bearer ipk_xxx" https://bgp.cx/api/ip/1.1.1.1
```

> Key 別放在網址裡 —— `?key=` 只是為了相容舊程式碼，不建議使用。

### 狀態碼

| 狀態碼 | 意義 |
|---|---|
| `400` | IP 或網域無效，或網域無法解析 |
| `401` | API Key 無效，或下載時未提供憑證 |
| `403` | 沒有該資料庫的下載權限 |
| `404` | 資源不存在 |
| `429` | 請求過於頻繁 |

錯誤格式：JSON 為 `{"error":"…","code":400}`，純文字為 `error: …`。

## 離線資料庫

不想呼叫 API 的話，同一份資料也提供**可下載的離線資料庫**，格式為 **MaxMind `.mmdb`** 與 **ip2region `.xdb`** —— nginx 的 `ngx_http_geoip2`、Clash / mihomo 的 `GEOIP,CN`，以及各家 MaxMind 官方讀取函式庫都直接支援。

```bash
curl https://bgp.cx/api/databases              # 版本清單與各自欄位
```

從「國家 + 城市」的精簡版，到含 ASN、經緯度、英文名的完整版都有。欄位結構、檔案格式與讀取範例見[資料庫文件](https://bgp.cx/docs/database)。

## 命令列工具

另有 [`bgptool`](https://github.com/acloudpeng/bgptool) —— traceroute 與 MTR 的每個節點都會標出 ASN、地理位置與電信業者：

```bash
curl -fsSL https://bgp.cx/install.sh | sh
bgptool trace 8.8.8.8
```

## 授權

本倉庫的範例程式碼採用 MIT 授權，歡迎自由使用。API 本身為託管服務，條款請見 [bgp.cx](https://bgp.cx)。
