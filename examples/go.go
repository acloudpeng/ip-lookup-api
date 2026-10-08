// IP geolocation from Go — standard library only.
//
//	go run go.go [ip-or-domain]
package main

import (
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"net/url"
	"os"
	"time"
)

const base = "https://bgp.cx"

var client = &http.Client{Timeout: 10 * time.Second}

// Info is the JSON returned by /api/ip/{ip}. Fields the plan does not include are null.
type Info struct {
	IP          string   `json:"ip"`
	Version     int      `json:"version"`
	Country     string   `json:"country"`
	CountryCode string   `json:"country_code"`
	Region      string   `json:"region"`
	City        string   `json:"city"`
	District    string   `json:"district"`
	Continent   string   `json:"continent"`
	Latitude    *float64 `json:"latitude"`
	Longitude   *float64 `json:"longitude"`
	Timezone    string   `json:"timezone"`
	ISP         string   `json:"isp"`
	ASN         int      `json:"asn"`
	ASNOrg      string   `json:"asn_organization"`
	ASNDomain   string   `json:"asn_domain"`
	UsageType   string   `json:"usage_type"`
	Network     string   `json:"network"`
}

// Lookup returns the record for target, or the caller's own address when target is empty.
func Lookup(target, lang, apiKey string) (*Info, error) {
	u := base + "/api/ip"
	if target != "" {
		u += "/" + url.PathEscape(target)
	}
	if lang != "" {
		u += "?lang=" + url.QueryEscape(lang)
	}

	req, err := http.NewRequest(http.MethodGet, u, nil)
	if err != nil {
		return nil, err
	}
	if apiKey != "" {
		req.Header.Set("Authorization", "Bearer "+apiKey)
	}

	resp, err := client.Do(req)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()
	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("lookup failed: HTTP %d", resp.StatusCode)
	}

	var out Info
	if err := json.NewDecoder(resp.Body).Decode(&out); err != nil {
		return nil, err
	}
	return &out, nil
}

// Field fetches a single field as plain text — the smallest possible response.
func Field(target, name string) (string, error) {
	resp, err := client.Get(fmt.Sprintf("%s/ip/%s/%s", base, url.PathEscape(target), url.PathEscape(name)))
	if err != nil {
		return "", err
	}
	defer resp.Body.Close()
	if resp.StatusCode != http.StatusOK {
		return "", fmt.Errorf("field lookup failed: HTTP %d", resp.StatusCode)
	}
	b, err := io.ReadAll(resp.Body)
	return string(b), err
}

func main() {
	target := ""
	if len(os.Args) > 1 {
		target = os.Args[1]
	}

	info, err := Lookup(target, "en", os.Getenv("IPLOOKUP_KEY"))
	if err != nil {
		fmt.Fprintln(os.Stderr, "error:", err)
		os.Exit(1)
	}

	out, _ := json.MarshalIndent(info, "", "  ")
	fmt.Println(string(out))

	if info.Latitude != nil && info.Longitude != nil {
		fmt.Printf("\ncoordinates: %.6f, %.6f\n", *info.Latitude, *info.Longitude)
	}
	if info.ASN != 0 {
		fmt.Printf("AS%d %s (%s) — %s\n", info.ASN, info.ASNOrg, info.ASNDomain, info.UsageType)
	}
}
