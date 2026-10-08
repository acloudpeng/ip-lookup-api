// IP geolocation from Rust.
//
//   cargo add reqwest --no-default-features --features blocking,json,rustls-tls
//   cargo add serde_json
//   cargo run -- [ip-or-domain]
//
// rustls-tls avoids the system OpenSSL dependency (works on alpine/musl images as-is).

use serde_json::Value;
use std::env;
use std::time::Duration;

const BASE: &str = "https://bgp.cx";

fn client() -> Result<reqwest::blocking::Client, Box<dyn std::error::Error>> {
    Ok(reqwest::blocking::Client::builder()
        .timeout(Duration::from_secs(10))
        .build()?)
}

fn get(url: &str) -> Result<reqwest::blocking::Response, Box<dyn std::error::Error>> {
    let mut req = client()?.get(url);
    if let Ok(key) = env::var("IPLOOKUP_KEY") {
        if !key.is_empty() {
            req = req.header("Authorization", format!("Bearer {}", key));
        }
    }
    let res = req.send()?;
    if !res.status().is_success() {
        return Err(format!("request failed: HTTP {}", res.status()).into());
    }
    Ok(res)
}

/// Look up an IP or domain; an empty target queries the caller's own address.
fn lookup(target: &str, lang: &str) -> Result<Value, Box<dyn std::error::Error>> {
    let url = if target.is_empty() {
        format!("{}/api/ip?lang={}", BASE, lang)
    } else {
        format!("{}/api/ip/{}?lang={}", BASE, target, lang)
    };
    Ok(get(&url)?.json()?)
}

/// Fetch a single field as plain text — the smallest possible response.
fn field(target: &str, name: &str) -> Result<String, Box<dyn std::error::Error>> {
    let url = format!("{}/ip/{}/{}", BASE, target, name);
    Ok(get(&url)?.text()?.trim().to_string())
}

/// ASN details with announced prefixes.
fn asn(number: i64, family: Option<u8>, limit: u32) -> Result<Value, Box<dyn std::error::Error>> {
    let mut url = format!("{}/api/asn/{}?limit={}", BASE, number, limit);
    if let Some(f) = family {
        url.push_str(&format!("&family={}", f));
    }
    Ok(get(&url)?.json()?)
}

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let target = env::args().nth(1).unwrap_or_default();

    let info = lookup(&target, "en")?;
    println!("{}", serde_json::to_string_pretty(&info)?);

    if let Some(ip) = info["ip"].as_str() {
        println!();
        println!("country : {}", field(ip, "country")?);
        println!("location: {}", field(ip, "location")?);
        println!("coords  : {}", field(ip, "loc")?);
    }

    if let Some(number) = info["asn"].as_i64() {
        let detail = asn(number, Some(4), 5)?;
        println!(
            "\nAS{} {} — {} IPv4 prefixes",
            detail["asn"], detail["name"], detail["ipv4_prefixes"]
        );
        if let Some(prefixes) = detail["prefixes"].as_array() {
            for p in prefixes.iter().take(5) {
                println!("  {}", p.as_str().unwrap_or(""));
            }
        }
    }

    Ok(())
}
