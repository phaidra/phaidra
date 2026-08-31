# Submit deep links

PHAIDRA supports opening the upload form via a URL with query parameters. This is used for integrations (e.g. OpenCast archiving) where an external system sends users to PHAIDRA with prefilled metadata.

The user must be logged in. If not, they are redirected to login and returned to the same URL afterwards (including query parameters). The same applies to the terms-of-use consent step for SSO users.

## Entry points

| URL | Use case |
|-----|----------|
| `/submit/opencast` | OpenCast / u:stream choice page (usual object vs OER); forwards deep-link params |
| `/submit/upload` | Default upload form |
| `/submit/oer` | Open Educational Resource (OER) upload form |
| `/submit/custom/{id}` | Upload form based on a saved template |

## Encoded bundles (`job` and `role`)

Structured values use the same encoding for `job` and `role`:

| Delimiter | Meaning |
|-----------|---------|
| `__` | Separates segments in one bundle |
| `_` | Separates **field name** from **value** inside a segment |

Each segment is `{field}_{value}`.

Underscores that belong **inside** a field name or value (not as delimiters) must be written as `%5F` in the URL.

Examples:

| Segment (logical) | In URL |
|-------------------|--------|
| `agent` = `opencast` | `agent_opencast` |
| `oc_mpid` = `{uuid}` | `oc%5Fmpid_{uuid}` |
| `role` = `spk` | `role_spk` |
| `firstname` = `Jane` | `firstname_Jane` |

### `job` — background job payload

**Each `job` query parameter creates one separate job document** after submit.

```
job=agent_opencast__oc%5Fmpid_efe7b339-1234-5678-9abc-def012345678
```

Repeat `job` to enqueue multiple jobs for the same object.

### `role` — contributor prefill

One bundle per contributor. Must include `role_{code}` (e.g. `role_spk` → `role:spk` in metadata). Further segments are entity fields.

```
role=role_spk__firstname_Jane__lastname_Doe
```

Repeat `role` for multiple contributors.

### `submitmode` — metadata-only submit

| Value | Behaviour |
|-------|-----------|
| `metadata_only` | No file upload; object stays **Inactive** |

```
submitmode=metadata_only
```

Jobs are independent: use `submitmode=metadata_only` without `job`, or combine both as needed.

## Plain query parameters

| Parameter | Required | Description |
|-----------|----------|-------------|
| `title` | no | Prefills the title field |
| `language` | no | Prefills language of object (e.g. `eng`, `deu`) |
| `dateCreated` | no | Prefills a creation date (`dcterms:created`, EDTF) |

## Example URLs

Contributor with first and last name:

```
/submit/upload?role=role_spk__firstname_John__lastname_Doe&title=My%20Lecture
```

OpenCast archiving (choice page):

```
/submit/opencast?submitmode=metadata_only&job=agent_opencast__oc%5Fmpid_efe7b339-1234-5678-9abc-def012345678&title=My%20Lecture&language=eng&role=role_spk__firstname_Jane__lastname_Doe&dateCreated=2024-01-15
```

### OpenCast choice page

The choice page uses the `auth` middleware and preserves query parameters through login (`returnto`).

Text on the page can be customized per instance via **i18n overrides** in the Datastructures admin section (e.g. replace “OpenCast” with a local product name like “u:stream”):

```json
{
  "deu": {
    "OpenCast submit title": "Archivierung aus u:stream",
    "OpenCast submit access rights notice": "Zugriffsrechte aus u:stream werden nicht nach PHAIDRA übernommen. …"
  }
}
```

## Authentication return URL

Login and SSO consent preserve the target path via `returnto` (path only, same site):

```
/login?returnto={encoded-path-and-query}
```
