vcl 4.1;
import std;

# Backends
backend api {
  .host = "api";
  .port = "3000";
  .first_byte_timeout = 300s;
}

backend ui {
  .host = "ui";
  .port = "3001";
  .first_byte_timeout = 60s;
}

sub vcl_recv {
  # Route by path
  if (req.url ~ "^/api/") {
    set req.backend_hint = api;
  } else {
    set req.backend_hint = ui;
  }

  # WebSocket pass-through
  if (req.http.Upgrade ~ "(?i)websocket") {
    return (pipe);
  }

  # Only cache GET/HEAD
  if (req.method != "GET" && req.method != "HEAD") {
    return (pass);
  }

  # Don't cache Range requests
  if (req.http.Range) {
    return (pass);
  }

  # API rules
  if (req.backend_hint == api) {
    # Whitelisted API static directories (client-facing, with /api)
    if (req.url ~ "^/api/(?:3dhop|docs|iipmooviewer|images|ip2country|json-schema|languages|licenses|mirador|mods|pdfjs|replayweb|swagger-ui|threejs|video-js|vocabulary|xsd)(?:/|$)"
        || req.url ~ "^/api/object/o:[0-9]+/thumbnail"
        || req.url ~ "^/api/oai($|\\?)") {

      # Do NOT cache if the client sends XSRF-TOKEN cookie or Authorization
      if (req.http.Cookie ~ "XSRF-TOKEN=" || req.http.Authorization) {
        return (pass);
      }

      # Strip cookies so cache key doesn't vary on them
      if (req.http.Cookie) { unset req.http.Cookie; }

      return (hash);
    }

    # Everything else from API is passed/streamed
    return (pass);
  }

  # UI rules: cache static assets; pass HTML and dynamic endpoints
  if (req.backend_hint == ui) {
    if (req.url ~ "(?i)\\.(?:css|js|mjs|png|jpg|jpeg|gif|svg|webp|ico|woff2?|ttf|eot)(?:\\?.*)?$"
        || req.url ~ "^/(?:static|assets|_nuxt)/") {

      if (req.http.Cookie) { unset req.http.Cookie; }
      return (hash);
    }

    return (pass);
  }
}

sub vcl_backend_fetch {
  # Strip /api from the path before sending to the API backend
  if (bereq.backend == api && bereq.url ~ "^/api/") {
    set bereq.url = regsub(bereq.url, "^/api", "");
  }
}

sub vcl_backend_response {
  # Never cache if origin explicitly forbids it
  if (beresp.http.Cache-Control ~ "(?i)no-store|private") {
    set beresp.uncacheable = true;
    set beresp.ttl = 0s;
    set beresp.do_stream = true;
    set beresp.do_gzip = false;
    set beresp.do_gunzip = false;
    return (deliver);
  }

  # API backend behavior
  if (bereq.backend == api) {
    # After vcl_backend_fetch, bereq.url no longer has /api

    # If not a whitelisted cacheable API resource → stream/pass (uncacheable)
    if (bereq.url !~ "^/(?:3dhop|docs|iipmooviewer|images|ip2country|json-schema|languages|licenses|mirador|mods|pdfjs|replayweb|swagger-ui|threejs|video-js|vocabulary|xsd)(?:/|$)"
     && bereq.url !~ "^/object/o:[0-9]+/thumbnail"
     && bereq.url !~ "^/oai($|\\?)") {
      set beresp.uncacheable = true;
      set beresp.ttl = 0s;
      set beresp.do_stream = true;
      set beresp.do_gzip = false;
      set beresp.do_gunzip = false;
      return (deliver);
    }

    # Pass thumbnails if > 1 MiB (avoid caching huge thumbs)
    if (bereq.url ~ "^/object/o:[0-9]+/thumbnail"
        && beresp.http.Content-Length
        && std.integer(beresp.http.Content-Length, 0) > 1048576) {
      set beresp.uncacheable = true;
      set beresp.ttl = 0s;
      set beresp.do_stream = true;
      set beresp.do_gzip = false;
      set beresp.do_gunzip = false;
      return (deliver);
    }

    # Static API directories: safe to strip accidental cookies
    if (bereq.url ~ "^/(?:3dhop|docs|iipmooviewer|images|ip2country|json-schema|languages|licenses|mirador|mods|pdfjs|replayweb|swagger-ui|threejs|video-js|vocabulary|xsd)(?:/|$)") {
      unset beresp.http.Set-Cookie;
    } else {
      # For thumbnails/OAI, if Set-Cookie is present, avoid caching to be safe
      if (beresp.http.Set-Cookie) {
        set beresp.uncacheable = true;
        set beresp.ttl = 0s;
        set beresp.do_stream = true;
        set beresp.do_gzip = false;
        set beresp.do_gunzip = false;
        return (deliver);
      }
    }

    # Honor origin cache headers; otherwise set defaults
    if (!beresp.http.Cache-Control) {
      if (bereq.url !~ "^/oai($|\\?)") {
        set beresp.ttl = 30d;
        set beresp.grace = 7d;
      }else {
        # OAI get's re-generated every night
        set beresp.ttl = 6h;
        set beresp.grace = 2h;
      }
    }

    return (deliver);
  }

  # UI backend behavior
  if (bereq.backend == ui) {
    if (bereq.url ~ "(?i)\\.(?:css|js|mjs|png|jpg|jpeg|gif|svg|webp|ico|woff2?|ttf|eot)(?:\\?.*)?$"
        || bereq.url ~ "^/(?:static|assets|_nuxt)/") {

      if (!beresp.http.Cache-Control) {
        set beresp.ttl = 30d;
        set beresp.grace = 7d;
      }

      unset beresp.http.Set-Cookie;
      return (deliver);
    }

    # Dynamic UI: don't cache, stream
    set beresp.uncacheable = true;
    set beresp.ttl = 0s;
    set beresp.do_stream = true;
    set beresp.do_gzip = false;
    set beresp.do_gunzip = false;

    return (deliver);
  }
}

sub vcl_pipe {
  if (req.http.Upgrade) {
    set bereq.http.upgrade = req.http.upgrade;
    set bereq.http.connection = req.http.connection;
  }
}