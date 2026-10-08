<?php
// IP geolocation from PHP — no dependencies (cURL extension or allow_url_fopen).
//
//   php php.php [ip-or-domain]

const BASE = 'https://bgp.cx';

/** Look up an IP or domain; an empty target queries the caller's own address. */
function lookup(string $target = '', string $lang = 'en'): array
{
    $url = $target ? BASE . '/api/ip/' . rawurlencode($target) : BASE . '/api/ip';
    $url .= '?lang=' . rawurlencode($lang);
    return json_decode(http_get($url), true, 512, JSON_THROW_ON_ERROR);
}

/** Fetch a single field as plain text. */
function field(string $target, string $name): string
{
    return trim(http_get(BASE . '/ip/' . rawurlencode($target) . '/' . rawurlencode($name)));
}

/** ASN details with announced prefixes. */
function asn(string $number, ?int $family = null, int $limit = 100): array
{
    $query = ['limit' => $limit];
    if ($family !== null) {
        $query['family'] = $family;
    }
    $url = BASE . '/api/asn/' . rawurlencode($number) . '?' . http_build_query($query);
    return json_decode(http_get($url), true, 512, JSON_THROW_ON_ERROR);
}

function http_get(string $url): string
{
    $headers = [];
    $key = getenv('IPLOOKUP_KEY');
    if ($key) {
        $headers[] = 'Authorization: Bearer ' . $key;
    }

    if (function_exists('curl_init')) {
        $ch = curl_init($url);
        curl_setopt_array($ch, [
            CURLOPT_RETURNTRANSFER => true,
            CURLOPT_TIMEOUT        => 10,
            CURLOPT_HTTPHEADER     => $headers,
        ]);
        $body = curl_exec($ch);
        $code = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        $err  = curl_error($ch);
        // No curl_close() needed: it has had no effect since PHP 8.0 and is deprecated in 8.5.

        if ($body === false) {
            throw new RuntimeException("request failed: $err");
        }
        if ($code !== 200) {
            throw new RuntimeException("request failed: HTTP $code");
        }
        return $body;
    }

    // Fallback when cURL is unavailable.
    $ctx = stream_context_create(['http' => ['header' => implode("\r\n", $headers), 'timeout' => 10]]);
    $body = @file_get_contents($url, false, $ctx);
    if ($body === false) {
        throw new RuntimeException("request failed: $url");
    }
    return $body;
}

$target = $argv[1] ?? '';

$info = lookup($target);
echo json_encode($info, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES), PHP_EOL;

if (!empty($info['ip'])) {
    echo PHP_EOL;
    echo 'country : ', field($info['ip'], 'country'), PHP_EOL;
    echo 'location: ', field($info['ip'], 'location'), PHP_EOL;
    echo 'coords  : ', field($info['ip'], 'loc'), PHP_EOL;
}

if (!empty($info['asn'])) {
    $detail = asn((string) $info['asn'], 4, 5);
    echo PHP_EOL, 'AS', $detail['asn'], ' ', $detail['name'], ' — ', $detail['ipv4_prefixes'], ' IPv4 prefixes', PHP_EOL;
    foreach (array_slice($detail['prefixes'] ?? [], 0, 5) as $prefix) {
        echo '  ', $prefix, PHP_EOL;
    }
}
