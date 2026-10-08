// IP geolocation from C# / .NET — standard library only (.NET 6+).
//
//   dotnet run                       (or: csc csharp.cs && ./csharp)
//
// Pass an IP or domain as the first argument; with no argument it reports the caller's own address.

using System;
using System.Net.Http;
using System.Text.Json;
using System.Text.Json.Nodes;
using System.Threading.Tasks;

class Program
{
    const string Base = "https://bgp.cx";
    static readonly HttpClient Client = new() { Timeout = TimeSpan.FromSeconds(10) };

    /// <summary>Look up an IP or domain; an empty target queries the caller's own address.</summary>
    static async Task<JsonNode?> Lookup(string target, string lang = "en")
    {
        var url = string.IsNullOrEmpty(target)
            ? $"{Base}/api/ip?lang={lang}"
            : $"{Base}/api/ip/{Uri.EscapeDataString(target)}?lang={lang}";

        using var req = new HttpRequestMessage(HttpMethod.Get, url);
        var key = Environment.GetEnvironmentVariable("IPLOOKUP_KEY");
        if (!string.IsNullOrEmpty(key))
            req.Headers.Add("Authorization", $"Bearer {key}");

        using var res = await Client.SendAsync(req);
        res.EnsureSuccessStatusCode();
        return JsonNode.Parse(await res.Content.ReadAsStringAsync());
    }

    /// <summary>Fetch a single field as plain text.</summary>
    static async Task<string> Field(string target, string name)
    {
        var url = $"{Base}/ip/{Uri.EscapeDataString(target)}/{Uri.EscapeDataString(name)}";
        var body = await Client.GetStringAsync(url);
        return body.Trim();
    }

    /// <summary>ASN details with announced prefixes.</summary>
    static async Task<JsonNode?> Asn(string number, int? family = null, int limit = 100)
    {
        var url = $"{Base}/api/asn/{Uri.EscapeDataString(number)}?limit={limit}";
        if (family is not null) url += $"&family={family}";
        return JsonNode.Parse(await Client.GetStringAsync(url));
    }

    static async Task Main(string[] args)
    {
        var target = args.Length > 0 ? args[0] : "";

        var info = await Lookup(target);
        Console.WriteLine(info?.ToJsonString(new JsonSerializerOptions { WriteIndented = true }));

        var ip = info?["ip"]?.GetValue<string>();
        if (!string.IsNullOrEmpty(ip))
        {
            Console.WriteLine();
            Console.WriteLine($"country : {await Field(ip, "country")}");
            Console.WriteLine($"location: {await Field(ip, "location")}");
            Console.WriteLine($"coords  : {await Field(ip, "loc")}");
        }

        var asn = info?["asn"]?.GetValue<int>();
        if (asn is > 0)
        {
            var detail = await Asn(asn.Value.ToString(), family: 4, limit: 5);
            Console.WriteLine();
            Console.WriteLine($"AS{detail?["asn"]} {detail?["name"]} — {detail?["ipv4_prefixes"]} IPv4 prefixes");
            if (detail?["prefixes"] is JsonArray prefixes)
                foreach (var p in prefixes)
                    Console.WriteLine($"  {p}");
        }
    }
}
