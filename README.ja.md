# IP Lookup API

**無料の IP ジオロケーション API。国・都市・緯度経度・タイムゾーン・ISP・ASN を一度に取得できます。IPv4 / IPv6 対応、登録不要。**

[English](README.md) · [简体中文](README.zh-CN.md) · [繁體中文](README.zh-TW.md) · [日本語](README.ja.md) · [한국어](README.ko.md)

「アカウント登録すると月 1 万リクエストまで無料」というサービスはよくありますが、これはその必要がありません。**API キーなしでそのまま使えて、ターミナルから `curl` するだけで結果が返ります。**

```bash
$ curl https://bgp.cx                       # 自分のグローバル IP を確認
191.223.220.39

$ curl https://bgp.cx/ip/8.8.8.8            # 任意の IP をプレーンテキストで
IP          : 8.8.8.8
Location    : アメリカ合衆国 カリフォルニア州 マウンテンビュー
Country     : アメリカ合衆国 (US / USA)
Region      : カリフォルニア州
City        : マウンテンビュー
Continent   : 北アメリカ
ISP         : 谷歌公共DNS(GoogleDNS)
ASN         : AS15169 Google LLC
AS Domain   : google.com
Usage       : DNS
Network     : 8.8.8.8/32
Timezone    : America/Los_Angeles
Coordinates : 37.386051, -122.083847
Phone Code  : +1
Currency    : USD

$ curl https://bgp.cx/api/ip/8.8.8.8        # 同じ内容を JSON で
{
  "ip": "8.8.8.8",
  "version": 4,
  "country": "アメリカ合衆国",
  "country_code": "US",
  "region": "カリフォルニア州",
  "city": "マウンテンビュー",
  "continent": "北アメリカ",
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

## 特徴

- **API キー不要。** 未ログイン時は IP 単位でレート制限（IPv6 は /64 単位）。キーを付ければ上限が上がります。
- **IPv4 / IPv6 の両方に対応**。ドメイン名を渡せば自動で名前解決します。
- **ASN 検索** —— AS 名、ドメイン、国、ネットワーク種別、およびその AS が広告している全プレフィックス。
- **最大 27 フィールド**：緯度経度、タイムゾーン、大陸、ISO コード、通貨、電話国番号、国旗など（英語結果では 23 フィールド。`*_en` の英語地名は表示言語が英語以外のときに返ります）。
- **多言語対応**（`zh-CN`、`zh-TW`、`en`、`ja`、`ko` など）。
- **JSONP 対応、CORS は全開放**。フロントエンドから直接呼べます。
- **オフラインデータベース**：MaxMind `.mmdb` と ip2region `.xdb` の 2 形式。

すぐ試せます:

```bash
curl https://bgp.cx/ip/1.1.1.1
curl https://bgp.cx/ip/github.com
curl https://bgp.cx/asn/15169
```

## サンプルコード

各言語の**実行可能な**サンプルを収録しています。どのファイルも単体で完結しているので、コピーして IP を書き換えればそのまま動きます。

| 言語 | ファイル | 依存関係 |
|---|---|---|
| cURL / shell | [`examples/curl.sh`](examples/curl.sh) | なし |
| Python | [`examples/python.py`](examples/python.py) | `requests`（`urllib` でも可） |
| Go | [`examples/go.go`](examples/go.go) | なし（標準ライブラリ） |
| Node.js | [`examples/node.js`](examples/node.js) | Node 18+（組み込み `fetch`） |
| PHP | [`examples/php.php`](examples/php.php) | なし |
| Java | [`examples/Java.java`](examples/Java.java) | Java 11+（標準ライブラリ） |
| C# / .NET | [`examples/csharp.cs`](examples/csharp.cs) | .NET 6+（標準ライブラリ） |
| Ruby | [`examples/ruby.rb`](examples/ruby.rb) | なし（標準ライブラリ） |
| Rust | [`examples/rust.rs`](examples/rust.rs) | `reqwest`（rustls-tls）、`serde_json` |
| PowerShell | [`examples/powershell.ps1`](examples/powershell.ps1) | なし |
| Bash ワンライナー | [`examples/oneliners.sh`](examples/oneliners.sh) | `curl`、`jq` |

## API リファレンス

ベース URL：`https://bgp.cx`

### プレーンテキスト（スクリプトや設定ファイル向け）

| リクエスト | 内容 |
|---|---|
| `GET /` | 自分のグローバル IP |
| `GET /ip`、`GET /jsonip` | 自分の IP（テキスト / `{"ip":"…"}`） |
| `GET /info` | 自分の IP の詳細 |
| `GET /ip/{IP\|ドメイン}` | 全項目を人が読みやすい形式で |
| `GET /ip/{IP}/{フィールド}` | 単一フィールドをプレーンテキストで |
| `GET /asn/{ASN}` | AS 情報とプレフィックス |

`{IP}` に `me` を指定すると自分自身を照会します。`{フィールド}` は下記の任意のフィールド名のほか、`location`（所在地の文字列）と `loc`（`"緯度,経度"`）が使えます。

```bash
curl https://bgp.cx/ip/me/country                 # 国だけ
curl https://bgp.cx/ip/8.8.8.8/latitude           # 特定 IP の 1 フィールド
curl https://bgp.cx/ip/8.8.8.8/loc                # "緯度,経度"
curl https://bgp.cx/ip/8.8.8.8?format=json        # 強制的に JSON で
```

> `coordinates` は人間向け出力の表示ラベルであり、**フィールド名ではありません** —— 緯度経度は `latitude`、`longitude`、または `loc` を使ってください。

### JSON

| リクエスト | 内容 |
|---|---|
| `GET /api/ip` | 自分の IP（JSON） |
| `GET /api/ip/{IP\|ドメイン}` | 全項目の JSON |
| `GET /api/lookup?q={IP\|ドメイン}` | `info`（照会結果）+ `resolved`（DNS 解決結果） |
| `GET /api/asn/{ASN}` | AS 情報と広告プレフィックス |

すべての JSON エンドポイントは `Access-Control-Allow-Origin: *` を返すので、ブラウザから直接呼べます。

### 共通パラメータ

| パラメータ | 値 | 説明 |
|---|---|---|
| `lang` | `zh-CN` `zh-TW` `en` `ja` `ko` `de` `fr` `ru` `es` `pt-BR` | 結果の言語 |
| `format` | `json` \| `text` | レスポンス形式の強制 |
| `pretty` | – | JSON を整形 |
| `callback` | 関数名 | JSONP |
| `key` | `ipk_…` | API キー（照会エンドポイント） |

### フィールド一覧

| フィールド | 内容 |
|---|---|
| `ip`、`version` | IP アドレス、IP バージョン（4 / 6） |
| `country`、`country_code`、`country_alpha3` | 国名、ISO-3166 2 文字 / 3 文字コード |
| `region`、`region_code`、`city`、`district` | 都道府県 / 州、市区町村、郡 |
| `continent`、`continent_code` | 大陸 |
| `latitude`、`longitude`、`timezone` | 緯度経度、IANA タイムゾーン |
| `isp`、`organization` | ISP / 組織 |
| `asn`、`asn_organization`、`asn_domain`、`usage_type` | AS 関連 |
| `network` | その IP が属する広告プレフィックス |
| `phone_code`、`currency`、`languages`、`flag` | 国のメタデータ |
| `*_en` | 英語の地名（表示言語が英語以外のとき） |

取得できないフィールドは `null` です。**フィールド数はプランによって異なります** —— 無料版は一部のみ、有料プランは全項目を返します。

### ASN エンドポイント

```bash
curl "https://bgp.cx/api/asn/4134?family=4&limit=100&offset=0"
```

`family` に `4` か `6` を指定するとプレフィックスを絞り込めます。`limit` の上限は 10000、`offset` でページングします。`{ASN}` は `4134` でも `AS4134` でも構いません。

### レート制限

| | 制限 |
|---|---|
| 未ログイン | IP 単位（IPv6 は /64 単位）、1 分あたりのリクエスト数 |
| API キーあり | アカウント単位、プランに依存 |

超過すると `429` を返し、`Retry-After` に待つべき秒数が入ります。クォータ関連のレスポンスには `X-RateLimit-Limit`、`X-Quota-Limit`、`X-Quota-Remaining` も付きます。

より高い上限が必要な場合は、無料アカウントを登録してキーをリクエストヘッダーで送ります:

```bash
curl -H "Authorization: Bearer ipk_xxx" https://bgp.cx/api/ip/1.1.1.1
```

> キーを URL に含めないでください —— `?key=` は古いコードとの互換用で、推奨されません。

### ステータスコード

| コード | 意味 |
|---|---|
| `400` | IP またはドメインが不正、もしくは名前解決できない |
| `401` | API キーが無効、またはダウンロード時に認証情報がない |
| `403` | そのデータベースのダウンロード権限がない |
| `404` | リソースが存在しない |
| `429` | リクエストが多すぎる |

エラー形式：JSON は `{"error":"…","code":400}`、プレーンテキストは `error: …`。

## オフラインデータベース

API を呼びたくない場合、同じデータを**ダウンロード可能なオフラインデータベース**としても提供しています。形式は **MaxMind `.mmdb`** と **ip2region `.xdb`** —— nginx の `ngx_http_geoip2`、Clash / mihomo の `GEOIP,CN`、各 MaxMind 公式リーダーがそのまま扱えます。

```bash
curl https://bgp.cx/api/databases              # エディション一覧と各フィールド
```

「国 + 都市」だけの小さなものから、ASN・緯度経度・英語名を含むフルセットまで揃っています。スキーマ、ファイル形式、読み込み例は[データベースドキュメント](https://bgp.cx/docs/database)をご覧ください。

## コマンドラインツール

[`bgptool`](https://github.com/acloudpeng/bgptool) もあります —— traceroute と MTR の各ホップに ASN・所在地・ISP を表示します:

```bash
curl -fsSL https://bgp.cx/install.sh | sh
bgptool trace 8.8.8.8
```

## ライセンス

本リポジトリのサンプルコードは MIT ライセンスです。自由にご利用ください。API 自体はホスト型サービスであり、利用条件は [bgp.cx](https://bgp.cx) をご確認ください。
