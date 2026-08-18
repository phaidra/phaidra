# OPA Authorization

PHAIDRA uses [Open Policy Agent (OPA)](https://www.openpolicyagent.org/) for authorization decisions. Authentication (who you are) remains in the API; authorization (what you may do) is evaluated by OPA policies.

## Architecture

- **PEP** (Policy Enforcement Point): `phaidra-api` Mojolicious bridges and controllers
- **PDP** (Policy Decision Point): OPA service
- **PAP** (Policy Administration Point): Git-managed Rego + institution data bundles

The API assembles a JSON **input document** (subject, resource, action, environment, config) and POSTs it to OPA at `/v1/data/phaidra/authz/allow`.

Routing uses authz bridges that share one `authorization#authorize` entrypoint:

| Bridge | Authn | Use |
|--------|-------|-----|
| `$authz_optional` | Optional | Object/datastream reads (anonymous allowed when policy permits) |
| `$authz` | Required | Object writes/creates, account/API actions, site-admin and IR-admin actions |
| `$authenticated` | Required | Authn only — `/authz/capabilities` and `/authz/check` |

The bridge requires each protected route to declare an **`action_id`**. Object actions (`read`, `write`, `delete`, …) need a Fedora `pid`. Account actions (`settings_read`, `group_write`, `list_read`, …) are evaluated without an object; default policy allows any authenticated user (parity with the former `$authenticated`-only routes). Site-admin actions (`admin_*`) require the configured PHAIDRA admin username; IR-admin actions (`ir_admin_*`) require the `ir_admin` role (public config `iraccount`). Tighten those rules later via Rego/data bundles. Role names are not encoded in the router.

`GET /object/{pid}/datastream/{dsid}` is the unified datastream read: optional credentials, `dsid` in the path. Policy marks some dsids as private (`RIGHTS`, `JSON-LD-PRIVATE`); anonymous requests are denied for those, while owners/admins (with credentials) are allowed.

## Default behaviour (parity with legacy)

| Role / rule | Effect |
|-------------|--------|
| Admin / superuser | Full read/write on all objects; site-admin actions (`admin_*`) require configured admin username |
| IR admin (`iraccount`) | IR workflow actions (`ir_admin_*`) |
| Fedora admin (`FEDORA_ADMIN_USER`) | Same as admin when authenticating (service operations) |
| Owner | Full read/write on owned objects |
| Anonymous | Read active objects without RIGHTS restrictions |
| RIGHTS datastream | Restricts read on content datastreams |
| Inactive objects | Visible only to owner, admin, superuser |

## New capabilities (institution-configurable)

Institution admins tune behaviour via data bundles in `policies/data/<institution>/config.json` without editing Rego:

- **Writer / uploader roles** — `writer` is granted to every authenticated user (create/edit still allowed). `uploader` is the **uncurated submit** privilege
- **Default role** — `PHAIDRA_DEFAULT_ROLE` (Directory fills it for every user). Default `uploader` = curation off
- **Privileged submit forms** — catalog-fetch upload, bulk upload
- **Metadata policies** (optional) — match JSON-LD on create/edit; default bundle has none enabled
- **Restricted rights management** — who may set access restrictions and max expiry
- **Per-user delete** — replaces repo-wide `enabledelete` when configured

### Curated submit

Create is always allowed for `writer`. Whether the object is activated depends on the `uploader` role and metadata policies:

| Setup | Effect |
|-------|--------|
| `PHAIDRA_DEFAULT_ROLE=uploader`, empty `metadata_policies` | **Curation off** (default). Every user can submit uncurated. |
| `PHAIDRA_DEFAULT_ROLE=uploader` + metadata policies | **Conditional.** Introducing a policy match queues the upload (`PendingApproval`); otherwise it activates. |
| `PHAIDRA_DEFAULT_ROLE` unset or empty | **Curation on.** Nobody gets `uploader`; every create stays pending. Site admin still skips the queue. |

OPA does not auto-grant `uploader` (`all_authenticated` is false). The API/Directory puts `default_role` on the subject; later user management can assign `uploader` per user the same way. Users without `uploader` can still edit (they have `writer`); they cannot skip curation on create.

Activation of queued objects is `POST /object/{pid}/approve` (`approver` or admin).

### Optional metadata policies

The PEP flattens submitted JSON-LD (`edm:hasType`, `edm:rights`) into `resource.metadata` and, on edit, the stored JSON-LD into `resource.existing_metadata`. It evaluates `metadata_policies` from the data bundle. **Default is an empty list** (no extra constraints).

A policy applies only when the **proposed** payload newly matches (`introducing`): stored metadata did not already match. A full JSON-LD POST that only changes title (and still carries the same object type / licence) is not introducing.

When a policy is introduced and the user is not in `exempt_roles`:

| Action / object state | Effect |
|-----------------------|--------|
| `create`, or `write` on Inactive | Allow; keep pending approval (do not activate) |
| `write` on Active | Deny — cannot change *to* those values |
| `write` on Active when values were already set | Allow |

Example (copy into an institution `config.json`; leave `enabled` out or `true` to turn on):

```json
"metadata_policies": [
  {
    "id": "thesis",
    "exempt_roles": ["librarian", "admin"],
    "match": {
      "all": [
        {
          "field": "object_type",
          "ids": [
            "https://pid.phaidra.org/vocabulary/62DN-RZ7V",
            "https://pid.phaidra.org/vocabulary/Z3K6-SWVD",
            "https://pid.phaidra.org/vocabulary/P2YP-BMND",
            "https://pid.phaidra.org/vocabulary/1PHE-7VMS"
          ]
        }
      ]
    }
  },
  {
    "id": "oer",
    "exempt_roles": ["approver", "admin"],
    "match": {
      "all": [
        { "field": "object_type", "ids": ["https://pid.phaidra.org/vocabulary/YA8R-1M0D"] },
        { "field": "object_type", "prefix": "https://w3id.org/kim/hcrt" },
        {
          "field": "license",
          "ids": [
            "http://creativecommons.org/licenses/by/4.0/",
            "http://creativecommons.org/licenses/by-sa/4.0/",
            "http://creativecommons.org/licenses/by-nc/4.0/",
            "http://creativecommons.org/licenses/by-nc-sa/4.0/"
          ]
        }
      ]
    }
  }
]
```

`match.all` clauses are ANDed. A clause matches if some value in that field is in `ids` and/or has `prefix`. Roles listed in `exempt_roles` skip the policy (librarian can submit/edit thesis without queue/deny).

## API endpoints

| Endpoint | Description |
|----------|-------------|
| `POST /authz/check` | Batch authorization checks (`action` ids, optional `pid`) |
| `GET /authz/capabilities` | Capabilities and submit-form visibility for current user |

Authorization input uses a single **`action.id`** (`read`, `write`, `create`, `delete`, `approve`, `restrict`, …). Policies derive read vs write from that id; there is no separate `operation` field.

## Configuration

Environment variables (see `PhaidraAPI.conf`):

| Variable | Default | Description |
|----------|---------|-------------|
| `OPA_ENABLED` | `false` | Enable OPA authorization |
| `OPA_URL` | `http://opa:8181` | OPA server URL |
| `OPA_POLICY_PATH` | `/v1/data/phaidra/authz/allow` | OPA decision document path |
| `OPA_FAIL_MODE` | `legacy` | `legacy` or `closed` on OPA errors |
| `OPA_DUAL_RUN` | `false` | Log mismatches vs legacy Perl logic |
| `OPA_INSTITUTION` | `default` | Institution id for data bundle |
| `PHAIDRA_DEFAULT_ROLE` | `uploader` | Directory role for every user. `uploader` = uncurated submit; empty = instance-wide curation |

## Audit

Authorization decisions are logged as structured JSON with prefix `authz=1` in **phaidra-api** logs (not OPA logs):

```bash
docker compose logs -f api | grep 'authz=1'
# or for local-dev:
docker compose logs -f api-local-dev | grep 'authz=1'
```

Notes:

- Look in the **API** container. OPA decision logs are separate (see below).
- API log level must be `info` or lower (private Mongo config `loglevel`). If set to `warn`/`error`, `authz=1` lines are hidden.
- Capability and form-check decisions from `/authz/capabilities` are audited (`capabilities` / `forms` included in the JSON).
- Dist API images must include `PhaidraAPI/Model/Policy/Audit.pm` (use a remounted/dev API or rebuild dist).

OPA decision logging is enabled via [`policies/opa-config.yaml`](../../policies/opa-config.yaml) (`decision_logs.console: true`). Those appear in the **opa** container:

```bash
docker compose logs -f opa
```

## Policy development

See [policies/README.md](../../policies/README.md) for Rego layout and testing.
