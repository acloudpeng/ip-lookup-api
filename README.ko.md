# IP Lookup API

**무료 IP 지오로케이션 API. 국가, 도시, 위도·경도, 시간대, ISP, ASN을 한 번에 조회할 수 있습니다. IPv4 / IPv6 지원, 가입 불필요.**

[English](README.md) · [简体中文](README.zh-CN.md) · [繁體中文](README.zh-TW.md) · [日本語](README.ja.md) · [한국어](README.ko.md)

"회원가입하면 월 1만 건 무료" 같은 조건을 내거는 서비스가 많지만, 여기는 그럴 필요가 없습니다. **API 키 없이 바로 쓸 수 있고, 터미널에서 `curl` 한 번이면 결과가 나옵니다.**

```bash
$ curl https://bgp.cx                       # 내 공인 IP 확인
191.223.220.39

$ curl https://bgp.cx/ip/8.8.8.8            # 임의의 IP를 텍스트로
IP          : 8.8.8.8
Location    : 미국 캘리포니아주 마운틴뷰
Country     : 미국 (US / USA)
Region      : 캘리포니아주
City        : 마운틴뷰
Continent   : 북아메리카
ISP         : 谷歌公共DNS(GoogleDNS)
ASN         : AS15169 Google LLC
AS Domain   : google.com
Usage       : DNS
Network     : 8.8.8.8/32
Timezone    : America/Los_Angeles
Coordinates : 37.386051, -122.083847
Phone Code  : +1
Currency    : USD

$ curl https://bgp.cx/api/ip/8.8.8.8        # 같은 내용을 JSON으로
{
  "ip": "8.8.8.8",
  "version": 4,
  "country": "미국",
  "country_code": "US",
  "region": "캘리포니아주",
  "city": "마운틴뷰",
  "continent": "북아메리카",
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

## 특징

- **API 키가 필요 없습니다.** 비로그인 상태에서는 IP 기준으로 요청 수를 제한하며(IPv6는 /64 단위), 키를 쓰면 한도가 올라갑니다.
- **IPv4와 IPv6 모두 지원**하고, 도메인 이름을 넣으면 자동으로 조회합니다.
- **ASN 조회** —— AS 이름, 도메인, 국가, 네트워크 유형, 그리고 해당 AS가 광고하는 모든 프리픽스.
- **최대 27개 필드**: 위도·경도, 시간대, 대륙, ISO 코드, 통화, 국가번호, 국기 등 (영어 결과는 23개. `*_en` 영문 지명은 표시 언어가 영어가 아닐 때 반환됩니다).
- **다국어 결과** (`zh-CN`, `zh-TW`, `en`, `ja`, `ko` 등).
- **JSONP 지원, CORS 전체 허용** —— 프런트엔드에서 바로 호출할 수 있습니다.
- **오프라인 데이터베이스**: MaxMind `.mmdb`와 ip2region `.xdb` 두 가지 형식.

바로 시도해 보세요:

```bash
curl https://bgp.cx/ip/1.1.1.1
curl https://bgp.cx/ip/github.com
curl https://bgp.cx/asn/15169
```

## 예제 코드

각 언어별 **실행 가능한** 예제를 담았습니다. 모든 파일이 독립적으로 동작하므로 복사한 뒤 IP만 바꾸면 바로 실행됩니다.

| 언어 | 파일 | 의존성 |
|---|---|---|
| cURL / shell | [`examples/curl.sh`](examples/curl.sh) | 없음 |
| Python | [`examples/python.py`](examples/python.py) | `requests` (`urllib`로 대체 가능) |
| Go | [`examples/go.go`](examples/go.go) | 없음 (표준 라이브러리) |
| Node.js | [`examples/node.js`](examples/node.js) | Node 18+ (내장 `fetch`) |
| PHP | [`examples/php.php`](examples/php.php) | 없음 |
| Java | [`examples/Java.java`](examples/Java.java) | Java 11+ (표준 라이브러리) |
| C# / .NET | [`examples/csharp.cs`](examples/csharp.cs) | .NET 6+ (표준 라이브러리) |
| Ruby | [`examples/ruby.rb`](examples/ruby.rb) | 없음 (표준 라이브러리) |
| Rust | [`examples/rust.rs`](examples/rust.rs) | `reqwest`(rustls-tls), `serde_json` |
| PowerShell | [`examples/powershell.ps1`](examples/powershell.ps1) | 없음 |
| Bash 한 줄 명령 | [`examples/oneliners.sh`](examples/oneliners.sh) | `curl`, `jq` |

## API 레퍼런스

기본 URL: `https://bgp.cx`

### 텍스트 응답 (스크립트와 설정 파일에 적합)

| 요청 | 반환 |
|---|---|
| `GET /` | 내 공인 IP |
| `GET /ip`, `GET /jsonip` | 내 IP (텍스트 / `{"ip":"…"}`) |
| `GET /info` | 내 IP의 상세 정보 |
| `GET /ip/{IP\|도메인}` | 전체 항목을 사람이 읽기 쉬운 형식으로 |
| `GET /ip/{IP}/{필드}` | 단일 필드를 텍스트로 |
| `GET /asn/{ASN}` | AS 정보와 프리픽스 |

`{IP}`에 `me`를 넣으면 자기 자신을 조회합니다. `{필드}`에는 아래 필드명 중 아무거나 쓸 수 있고, 추가로 `location`(전체 위치 문자열)과 `loc`(`"위도,경도"`)도 지원합니다.

```bash
curl https://bgp.cx/ip/me/country                 # 국가만
curl https://bgp.cx/ip/8.8.8.8/latitude           # 특정 IP의 필드 하나
curl https://bgp.cx/ip/8.8.8.8/loc                # "위도,경도"
curl https://bgp.cx/ip/8.8.8.8?format=json        # 강제로 JSON
```

> `coordinates`는 사람이 읽는 출력의 표시 라벨일 뿐, **필드 이름이 아닙니다** —— 위도·경도는 `latitude`, `longitude` 또는 `loc`를 쓰세요.

### JSON

| 요청 | 반환 |
|---|---|
| `GET /api/ip` | 내 IP (JSON) |
| `GET /api/ip/{IP\|도메인}` | 전체 JSON 레코드 |
| `GET /api/lookup?q={IP\|도메인}` | `info`(조회 결과) + `resolved`(DNS 조회 결과) |
| `GET /api/asn/{ASN}` | AS 정보와 광고 프리픽스 |

모든 JSON 엔드포인트는 `Access-Control-Allow-Origin: *`를 반환하므로 브라우저에서 바로 호출할 수 있습니다.

### 공통 파라미터

| 파라미터 | 값 | 설명 |
|---|---|---|
| `lang` | `zh-CN` `zh-TW` `en` `ja` `ko` `de` `fr` `ru` `es` `pt-BR` | 결과 언어 |
| `format` | `json` \| `text` | 응답 형식 강제 |
| `pretty` | – | JSON 정렬 |
| `callback` | 함수 이름 | JSONP |
| `key` | `ipk_…` | API 키 (조회 엔드포인트) |

### 필드 목록

| 필드 | 설명 |
|---|---|
| `ip`, `version` | IP 주소, IP 버전 (4 / 6) |
| `country`, `country_code`, `country_alpha3` | 국가명, ISO-3166 2자리 / 3자리 코드 |
| `region`, `region_code`, `city`, `district` | 시·도 / 주, 도시, 구·군 |
| `continent`, `continent_code` | 대륙 |
| `latitude`, `longitude`, `timezone` | 위도·경도, IANA 시간대 |
| `isp`, `organization` | ISP / 조직 |
| `asn`, `asn_organization`, `asn_domain`, `usage_type` | AS 관련 |
| `network` | 해당 IP가 속한 광고 프리픽스 |
| `phone_code`, `currency`, `languages`, `flag` | 국가 메타데이터 |
| `*_en` | 영문 지명 (표시 언어가 영어가 아닐 때) |

값이 없는 필드는 `null`입니다. **필드 수는 요금제에 따라 다릅니다** —— 무료 버전은 일부만, 유료 요금제는 전체를 반환합니다.

### ASN 엔드포인트

```bash
curl "https://bgp.cx/api/asn/4134?family=4&limit=100&offset=0"
```

`family`에 `4` 또는 `6`을 넣으면 프리픽스를 필터링합니다. `limit`은 최대 10000, `offset`은 페이지 이동에 씁니다. `{ASN}`은 `4134`든 `AS4134`든 모두 허용됩니다.

### 요청 제한

| | 제한 |
|---|---|
| 비로그인 | IP 기준 (IPv6는 /64 단위), 분당 요청 수 |
| API 키 사용 | 계정 기준, 요금제에 따라 결정 |

초과하면 `429`를 반환하고 `Retry-After`에 대기해야 할 초가 담깁니다. 할당량 관련 응답에는 `X-RateLimit-Limit`, `X-Quota-Limit`, `X-Quota-Remaining`도 함께 옵니다.

더 높은 한도가 필요하면 무료 계정을 만들고 키를 요청 헤더로 보내세요:

```bash
curl -H "Authorization: Bearer ipk_xxx" https://bgp.cx/api/ip/1.1.1.1
```

> 키를 URL에 넣지 마세요 —— `?key=`는 예전 코드와의 호환용일 뿐 권장되지 않습니다.

### 상태 코드

| 코드 | 의미 |
|---|---|
| `400` | IP 또는 도메인이 잘못되었거나 도메인을 조회할 수 없음 |
| `401` | API 키가 유효하지 않거나 다운로드 시 자격 증명이 없음 |
| `403` | 해당 데이터베이스의 다운로드 권한이 없음 |
| `404` | 리소스가 존재하지 않음 |
| `429` | 요청이 너무 잦음 |

오류 형식: JSON은 `{"error":"…","code":400}`, 텍스트는 `error: …`.

## 오프라인 데이터베이스

API를 호출하고 싶지 않다면 동일한 데이터를 **다운로드 가능한 오프라인 데이터베이스**로도 제공합니다. 형식은 **MaxMind `.mmdb`**와 **ip2region `.xdb`** —— nginx의 `ngx_http_geoip2`, Clash / mihomo의 `GEOIP,CN`, 각종 MaxMind 공식 리더가 그대로 지원합니다.

```bash
curl https://bgp.cx/api/databases              # 에디션 목록과 각 필드
```

"국가 + 도시"만 담은 작은 버전부터 ASN, 위도·경도, 영문명을 포함한 전체 버전까지 있습니다. 스키마, 파일 형식, 읽기 예제는 [데이터베이스 문서](https://bgp.cx/docs/database)를 참고하세요.

## 명령줄 도구

[`bgptool`](https://github.com/acloudpeng/bgptool)도 있습니다 —— traceroute와 MTR의 모든 홉에 ASN, 위치, ISP를 표시합니다:

```bash
curl -fsSL https://bgp.cx/install.sh | sh
bgptool trace 8.8.8.8
```

## 라이선스

이 저장소의 예제 코드는 MIT 라이선스이며 자유롭게 사용할 수 있습니다. API 자체는 호스팅 서비스이므로 이용 조건은 [bgp.cx](https://bgp.cx)를 확인하세요.
