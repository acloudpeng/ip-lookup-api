# IP Lookup API

**免费 IP 归属地查询 API：国家、城市、经纬度、时区、运营商、ASN 一次返回。支持 IPv4 / IPv6，无需注册。**

[English](README.md) · [简体中文](README.zh-CN.md) · [繁體中文](README.zh-TW.md) · [日本語](README.ja.md) · [한국어](README.ko.md)

别的服务动不动就是「注册后每月送你一万次免费额度」，这个不用：**不带 Key 也能直接查，命令行里 curl 一下就有结果。**

```bash
$ curl https://bgp.cx                       # 查自己的公网 IP
191.223.220.39

$ curl https://bgp.cx/ip/8.8.8.8            # 查任意 IP，纯文本
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

$ curl https://bgp.cx/api/ip/8.8.8.8        # 同样的数据，JSON
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

## 特点

- **不用申请 Key。** 免登录按 IP 限流（IPv6 按 /64 计），带 Key 则额度更高。
- **IPv4 和 IPv6 都支持**，也能直接传域名 —— 自动帮你解析。
- **ASN 查询** —— 名称、域名、所属国家、网络类型，以及该 ASN 宣告的全部网段。
- **最多 27 个字段**：经纬度、时区、大洲、ISO 代码、货币、电话区号、国旗等（英文结果为 23 个，带 `*_en` 的英文字段只在非英文界面语言下返回）。
- **多语言结果**（`zh-CN`、`zh-TW`、`en`、`ja`、`ko` 等）。
- **支持 JSONP，CORS 全开**，前端可以直接调用。
- **离线数据库**：MaxMind `.mmdb` 和 ip2region `.xdb` 两种格式。

马上试一下：

```bash
curl https://bgp.cx/ip/1.1.1.1
curl https://bgp.cx/ip/github.com
curl https://bgp.cx/asn/15169
```

## 示例代码

仓库里是各语言的**可直接运行**示例，每个文件都自成一体 —— 复制走改个 IP 就能跑。

| 语言 | 文件 | 依赖 |
|---|---|---|
| cURL / shell | [`examples/curl.sh`](examples/curl.sh) | 无 |
| Python | [`examples/python.py`](examples/python.py) | `requests`（也可以换成 `urllib`） |
| Go | [`examples/go.go`](examples/go.go) | 无（标准库） |
| Node.js | [`examples/node.js`](examples/node.js) | Node 18+（自带 `fetch`） |
| PHP | [`examples/php.php`](examples/php.php) | 无 |
| Java | [`examples/Java.java`](examples/Java.java) | Java 11+（标准库） |
| C# / .NET | [`examples/csharp.cs`](examples/csharp.cs) | .NET 6+（标准库） |
| Ruby | [`examples/ruby.rb`](examples/ruby.rb) | 无（标准库） |
| Rust | [`examples/rust.rs`](examples/rust.rs) | `reqwest`（rustls-tls）、`serde_json` |
| PowerShell | [`examples/powershell.ps1`](examples/powershell.ps1) | 无 |
| Bash 一行流 | [`examples/oneliners.sh`](examples/oneliners.sh) | `curl`、`jq` |

## 接口说明

基础地址：`https://bgp.cx`

### 纯文本（适合写脚本、填配置）

| 请求 | 返回 |
|---|---|
| `GET /` | 你自己的公网 IP |
| `GET /ip`、`GET /jsonip` | 你的 IP（纯文本 / `{"ip":"…"}`） |
| `GET /info` | 你自己 IP 的详细信息 |
| `GET /ip/{ip\|域名}` | 完整记录，人眼可读 |
| `GET /ip/{ip}/{字段}` | 单个字段，纯文本 |
| `GET /asn/{asn}` | ASN 信息及其网段 |

`{ip}` 写 `me` 表示查自己。`{字段}` 可以是下面任意字段名，另外支持 `location`（完整归属地字符串）和 `loc`（`"纬度,经度"`）。

```bash
curl https://bgp.cx/ip/me/country                 # 只要国家
curl https://bgp.cx/ip/8.8.8.8/latitude           # 指定 IP 的某个字段
curl https://bgp.cx/ip/8.8.8.8/loc                # "纬度,经度"
curl https://bgp.cx/ip/8.8.8.8?format=json        # 强制要 JSON
```

> `coordinates` 只是文本输出里的显示标签，**不是字段名** —— 取经纬度请用 `latitude`、`longitude` 或 `loc`。

### JSON

| 请求 | 返回 |
|---|---|
| `GET /api/ip` | 自己的 IP（JSON） |
| `GET /api/ip/{ip\|域名}` | 完整 JSON 记录 |
| `GET /api/lookup?q={ip\|域名}` | `info`（查询结果）+ `resolved`（DNS 解析结果） |
| `GET /api/asn/{asn}` | ASN 及其宣告的网段 |

所有 JSON 接口都带 `Access-Control-Allow-Origin: *`，浏览器里可以直接调。

### 通用参数

| 参数 | 取值 | 说明 |
|---|---|---|
| `lang` | `zh-CN` `zh-TW` `en` `ja` `ko` `de` `fr` `ru` `es` `pt-BR` | 结果语言 |
| `format` | `json` \| `text` | 强制指定返回格式 |
| `pretty` | – | 格式化 JSON |
| `callback` | 函数名 | JSONP |
| `key` | `ipk_…` | API Key（查询接口） |

### 返回字段

| 字段 | 含义 |
|---|---|
| `ip`、`version` | IP 地址、IP 版本（4 / 6） |
| `country`、`country_code`、`country_alpha3` | 国家名称、ISO-3166 二位 / 三位代码 |
| `region`、`region_code`、`city`、`district` | 省 / 州、城市、区县 |
| `continent`、`continent_code` | 大洲 |
| `latitude`、`longitude`、`timezone` | 经纬度、IANA 时区 |
| `isp`、`organization` | 运营商 / 组织 |
| `asn`、`asn_organization`、`asn_domain`、`usage_type` | ASN 相关 |
| `network` | 该 IP 所属的宣告网段 |
| `phone_code`、`currency`、`languages`、`flag` | 国家元数据 |
| `*_en` | 英文地名（界面语言非英文时返回） |

取不到的字段为 `null`。**字段多少取决于套餐** —— 免费版返回其中一部分，付费套餐返回全部。

### ASN 接口

```bash
curl "https://bgp.cx/api/asn/4134?family=4&limit=100&offset=0"
```

`family` 传 `4` 或 `6` 可筛选协议，`limit` 上限 10000，`offset` 用于翻页。`{asn}` 写 `4134` 或 `AS4134` 都行。

### 频率限制

| | 限制 |
|---|---|
| 免登录 | 按 IP 计（IPv6 按 /64），每分钟请求数 |
| 带 API Key | 按账号计，具体看套餐 |

超限返回 `429`，`Retry-After` 告诉你还要等多少秒。配额相关的响应还会带 `X-RateLimit-Limit`、`X-Quota-Limit`、`X-Quota-Remaining`。

想要更高额度，注册个免费账号，把 Key 放在请求头里：

```bash
curl -H "Authorization: Bearer ipk_xxx" https://bgp.cx/api/ip/1.1.1.1
```

> Key 别放 URL 里 —— `?key=` 只是为了兼容老代码，不推荐。

### 状态码

| 状态码 | 含义 |
|---|---|
| `400` | IP 或域名无效，或域名解析不了 |
| `401` | API Key 无效，或下载时没带凭证 |
| `403` | 没有该数据库的下载权限 |
| `404` | 资源不存在 |
| `429` | 请求太频繁 |

错误格式：JSON 是 `{"error":"…","code":400}`，纯文本是 `error: …`。

## 离线数据库

不想调 API 的话，同一份数据也提供**可下载的离线库**，格式是 **MaxMind `.mmdb`** 和 **ip2region `.xdb`** —— nginx 的 `ngx_http_geoip2`、Clash / mihomo 的 `GEOIP,CN`、以及各家 MaxMind 官方读取库都直接支持。

```bash
curl https://bgp.cx/api/databases              # 版本清单及各自字段
```

从「国家 + 城市」的精简版，到含 ASN、经纬度、英文名的完整版都有。字段结构、文件格式和读取示例见[数据库文档](https://bgp.cx/docs/database)。

## 命令行工具

还有个 [`bgptool`](https://github.com/acloudpeng/bgptool) —— traceroute 和 MTR 的每一跳都标出 ASN、归属地和运营商：

```bash
curl -fsSL https://bgp.cx/install.sh | sh
bgptool trace 8.8.8.8
```

## 许可

本仓库的示例代码采用 MIT 许可，随便用。API 本身是托管服务，条款见 [bgp.cx](https://bgp.cx)。
