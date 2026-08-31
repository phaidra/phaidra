# Submit deep links

PHAIDRA supports opening the upload form via a URL with query parameters. This is used for integrations (e.g. OpenCast archiving) where an external system sends users to PHAIDRA with prefilled metadata.

The user must be logged in. If not, they are redirected to login and returned to the same URL afterwards (including query parameters). The same applies to the terms-of-use consent step for SSO users.

## Entry points

| URL | Use case |
|-----|----------|
| `/submit/upload` | Default upload form |
| `/submit/upload?template={id}` | Upload form based on a saved template |
| `/submit/custom/{id}` | Same as above, template id in the path |

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

### Input sanitization

Deep-link values are treated as plain text. Before prefill (and when creating jobs server-side):

- HTML tags are stripped
- Field names must match `[a-zA-Z][a-zA-Z0-9_]*`
- Agent names must match `[a-zA-Z][a-zA-Z0-9_-]*`
- Obvious script payloads (`javascript:`, etc.) are removed
- Length is capped (10 000 characters per value)

Invalid bundle segments or field names are skipped silently.

## Plain query parameters

| Parameter | Required | Description |
|-----------|----------|-------------|
| `template` | no | UUID of a saved upload template |
| `title` | no | Prefills the title field |
| `language` | no | Prefills language of object (e.g. `eng`, `deu`) |
| `dateCreated` | no | Prefills a creation date (`dcterms:created`, EDTF) |

Templates can include an **Alert** field (`p-alert` component) for informational banners.

## Example URLs

Contributor with first and last name:

```
/submit/upload?role=role_spk__firstname_John__lastname_Doe&title=My%20Lecture
```

OpenCast archiving (template + metadata-only + one job):

```
/submit/upload?template=2A177BD4-A5BE-11EF-8DEA-A7715D1595E0&submitmode=metadata_only&job=agent_opencast__oc%5Fmpid_efe7b339-1234-5678-9abc-def012345678&title=My%20Lecture&language=eng&role=role_spk__firstname_Jane__lastname_Doe&dateCreated=2024-01-15
```

## Creating an integration template

1. Open **Submit → Create new object** and configure fields for the integration.
2. Add an **Alert** field at the top with instructions for users.
3. Save as template and note the template id.
4. Use that id in the `template` query parameter.

## Authentication return URL

Login and SSO consent preserve the target path via `returnto` (path only, same site):

```
/login?returnto={encoded-path-and-query}
```
