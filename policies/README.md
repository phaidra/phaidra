# PHAIDRA OPA Authorization Policies

Rego policies for PHAIDRA authorization decisions. Evaluated by Open Policy Agent (OPA).

## Layout

- `phaidra/authz/*.rego` — core policy packages (Git-managed)
- `data/phaidra/config.json` — default institution data bundle
- `data/<institution>/` — institution-specific overrides (optional)

## Local testing

```bash
docker run --rm -v "$PWD/policies:/policies" openpolicyagent/opa:latest test -v /policies
```

## Decision logs

[`opa-config.yaml`](opa-config.yaml) enables console decision logging. Restart the `opa` service after changing it:

```bash
docker compose up -d opa
docker compose logs -f opa
```

## Kubernetes

Create or update the policies ConfigMap from this directory:

```bash
kubectl create configmap opa-policies-configmap \
  --from-file=policies/ \
  --dry-run=client -o yaml | kubectl apply -f -
```
