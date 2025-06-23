vcl 4.1;
import std;

backend default {
    .host = "api";
    .port = "3000";
    .first_byte_timeout = 300s;
}
sub vcl_recv {
    // only cache thumbnails
    // add here the paths of API calls varnish should cache
    // note: varnish by default won't cache requests containg a cookie or http basic auth headers
    if (
        req.url !~ "^/object/o:[0-9]+/thumbnail"
    ) {
        return (pass);
    }
}
