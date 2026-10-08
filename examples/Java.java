import java.io.IOException;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.time.Duration;

/**
 * IP geolocation from Java — standard library only (Java 11+).
 *
 * <pre>
 *   java Java.java [ip-or-domain]
 * </pre>
 *
 * The JSON is printed as-is; add a library such as Jackson or Gson if you want typed access.
 */
public class Java {

    static final String BASE = "https://bgp.cx";
    static final HttpClient CLIENT = HttpClient.newBuilder()
            .connectTimeout(Duration.ofSeconds(10))
            .build();

    /** Look up an IP or domain; an empty target queries the caller's own address. */
    public static String lookup(String target, String lang) throws IOException, InterruptedException {
        String url = target.isEmpty()
                ? BASE + "/api/ip?lang=" + lang
                : BASE + "/api/ip/" + java.net.URLEncoder.encode(target, "UTF-8") + "?lang=" + lang;

        HttpRequest.Builder req = HttpRequest.newBuilder(URI.create(url)).GET();
        String key = System.getenv("IPLOOKUP_KEY");
        if (key != null && !key.isEmpty()) {
            req.header("Authorization", "Bearer " + key);
        }

        HttpResponse<String> res = CLIENT.send(req.build(), HttpResponse.BodyHandlers.ofString());
        if (res.statusCode() != 200) {
            throw new IOException("lookup failed: HTTP " + res.statusCode());
        }
        return res.body();
    }

    /** Fetch a single field as plain text — the smallest possible response. */
    public static String field(String target, String name) throws IOException, InterruptedException {
        String url = BASE + "/ip/" + java.net.URLEncoder.encode(target, "UTF-8")
                + "/" + java.net.URLEncoder.encode(name, "UTF-8");
        HttpResponse<String> res = CLIENT.send(
                HttpRequest.newBuilder(URI.create(url)).GET().build(),
                HttpResponse.BodyHandlers.ofString());
        if (res.statusCode() != 200) {
            throw new IOException("field lookup failed: HTTP " + res.statusCode());
        }
        return res.body().trim();
    }

    public static void main(String[] args) {
        String target = args.length > 0 ? args[0] : "8.8.8.8";
        try {
            // The API already returns indented JSON, so print it as-is.
            String json = lookup(target, "en");
            System.out.println(json);

            // A tiny amount of hand-rolled parsing keeps this dependency-free.
            String ip = stringValue(json, "ip");
            if (ip != null) {
                System.out.println();
                System.out.println("country : " + field(ip, "country"));
                System.out.println("location: " + field(ip, "location"));
                System.out.println("coords  : " + field(ip, "loc"));
            }
        } catch (Exception e) {
            System.err.println("error: " + e.getMessage());
            System.exit(1);
        }
    }

    /** Extracts a top-level string value without pulling in a JSON library. */
    static String stringValue(String json, String key) {
        String needle = "\"" + key + "\":\"";
        int i = json.indexOf(needle);
        if (i < 0) return null;
        int start = i + needle.length();
        int end = json.indexOf('"', start);
        return end < 0 ? null : json.substring(start, end);
    }
}
