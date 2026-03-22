# For use in phaidraorg CI/CD pipelines
FROM alpine:3.23
RUN apk add --no-cache --quiet curl helm git yq jq perl-tidy perl-critic yamllint gawk &&\
    adduser -DH user
USER user
