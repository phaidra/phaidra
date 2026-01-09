vcl 4.1;
import std;

backend default {
  .host = "api";
  .port = "3000";
  .first_byte_timeout = 300s;
}

sub vcl_recv {
  if (req.method != "GET" && req.method != "HEAD") { return (pass); }

  // don't cache range requests
  if (req.http.Range) { return (pass); }

  if (req.url ~ "^/object/o:[0-9]+/thumbnail"
   || req.url ~ "^/oai($|\\?)") {

    // do NOT cache if the client sends XSRF-TOKEN cookie or basic auth
    if (req.http.Cookie ~ "XSRF-TOKEN=" || req.http.Authorization) {
      return (pass);
    }

    // strip other cookies so cache key doesn't vary on them
    unset req.http.Cookie;

    return (hash);
  }

  return (pass);
}

sub vcl_backend_response {
  // stream if not thumbnail
  if (bereq.url !~ "^/object/o:[0-9]+/thumbnail" && bereq.url !~ "^/oai($|\\?)") {
    set beresp.uncacheable = true;
    set beresp.ttl = 0s;
    set beresp.do_stream = true;
    # avoid extra buffers
    set beresp.do_gzip = false;
    return (deliver);
  }

  // pass thumbnails if > 1 MiB
  if (bereq.url ~ "^/object/o:[0-9]+/thumbnail" && beresp.http.Content-Length && std.integer(beresp.http.Content-Length, 0) > 1048576) {
    set beresp.uncacheable = true;
    set beresp.ttl = 0s;
    return (deliver);
  }
}