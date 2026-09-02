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
| `ocmpid` = `{uuid}` | `ocmpid_{uuid}` |
| `role` = `spk` | `role_spk` |
| `firstname` = `Jane` | `firstname_Jane` |

### `job` — background job payload

**Each `job` query parameter creates one separate job document** after submit.

```
job=agent_opencast__ocmpid_efe7b339-1234-5678-9abc-def012345678
```

Repeat `job` to enqueue multiple jobs for the same object.

### `role` — contributor prefill

One bundle per contributor. Must include `role_{code}` (e.g. `role_spk` → `role:spk` in metadata). Further segments are entity fields.

```
role=role_spk__firstname_Jane__lastname_Doe
```

Repeat `role` for multiple contributors.

### `submitmode` — deferred upload

| Value | Behaviour |
|-------|-----------|
| `deferred_upload` | No file upload; object stays **Inactive** until bitstream data arrive (e.g. via background job) |

```
submitmode=deferred_upload
```

Jobs are independent: use `submitmode=deferred_upload` without `job`, or combine both as needed.

## Plain query parameters

| Parameter | Required | Description |
|-----------|----------|-------------|
| `title` | no | Prefills the title field |
| `language` | no | Prefills language of object (e.g. `eng`, `deu`) |
| `datecreated` | no | Prefills a creation date (`dcterms:created`, EDTF); shown in the main form section just before **License** |
| `rt` | no | Resource type vocabulary URL (e.g. `https://pid.phaidra.org/vocabulary/B0Y6-GYT8` for video; URL-encode in query strings) |

The OpenCast choice page adds `rt` for video automatically when forwarding to `/submit/upload` or `/submit/oer` (unless `rt` is already set).

## Example URLs

Contributor with first and last name:

```
/submit/upload?role=role_spk__firstname_John__lastname_Doe&title=My%20Lecture
```

OpenCast archiving (choice page):

```
/submit/opencast?submitmode=deferred_upload&job=agent_opencast__ocmpid_efe7b339-1234-5678-9abc-def012345678&title=My%20Lecture&language=eng&role=role_spk__firstname_Jane__lastname_Doe&datecreated=2024-01-15&rt=https%3A%2F%2Fpid.phaidra.org%2Fvocabulary%2FB0Y6-GYT8
```

### OpenCast choice page

The choice page uses the `auth` middleware and preserves query parameters through login (`returnto`).

Between the access-rights notice and the upload options, the page shows a **prefilled metadata** summary parsed from the query string: media package ID (`ocmpid` from `job` bundles), title, language, creation date, and contributors.

After a deferred-upload submit the object is registered in **My inactive objects** and the user is redirected there (not to the detail page).

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
