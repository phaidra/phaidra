FROM golang:1.25-alpine AS builder

RUN apk add --no-cache git

WORKDIR /app
RUN git clone https://github.com/otto-de/prometheus_varnish_exporter.git .
RUN go build -o prometheus_varnish_exporter .

FROM varnish:8

# Copy built exporter from builder
COPY --from=builder /app/prometheus_varnish_exporter /usr/local/bin/

ENTRYPOINT ["/bin/bash", "-c"]
CMD ["prometheus_varnish_exporter &  sleep 2 && varnishd -F -a :80 -f /etc/varnish/default.vcl -s Transient=malloc,1G -s malloc,2G -p transit_buffer=128K"]
