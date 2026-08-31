const FIELD_NAME_RE = /^[a-zA-Z][a-zA-Z0-9_]*$/
const AGENT_NAME_RE = /^[a-zA-Z][a-zA-Z0-9_-]*$/
const MAX_TEXT_LENGTH = 10000

/**
 * Field names in bundles (job, role entity fields).
 */
export function sanitizeDeepLinkFieldName (name) {
  if (typeof name !== 'string' || !FIELD_NAME_RE.test(name)) {
    return null
  }
  return name
}

/**
 * Plain text from deep-link query values (metadata prefill, bundle values).
 */
export function sanitizeDeepLinkText (value, { maxLength = MAX_TEXT_LENGTH } = {}) {
  if (value === undefined || value === null) {
    return ''
  }
  let s = String(value).trim()
  if (s.length > maxLength) {
    s = s.slice(0, maxLength)
  }
  s = s.replace(/<[^>]*>/g, '')
  s = s.replace(/\0/g, '')
  s = s.replace(/javascript:/gi, '')
  s = s.replace(/data:text\/html/gi, '')
  return s
}

function queryScalar (query, key) {
  const raw = query[key]
  if (raw === undefined || raw === null || raw === '') {
    return ''
  }
  return sanitizeDeepLinkText(Array.isArray(raw) ? raw[0] : raw)
}

/**
 * One bundle segment: {field}_{value}
 * Underscores inside field or value are written as %5F in the URL.
 */
function splitFieldValue (segment) {
  if (typeof segment !== 'string') {
    return null
  }
  const match = segment.match(/^((?:[^_]|%5F)+)_([\s\S]+)$/i)
  if (!match) {
    return null
  }
  const decodePart = (part) => part.replace(/%5F/gi, '_')
  return {
    field: decodePart(match[1]),
    value: decodePart(match[2])
  }
}

/**
 * Bundle: {field}_{value}__{field}_{value}…
 */
export function parseBundle (encoded) {
  if (typeof encoded !== 'string' || !encoded) {
    return {}
  }
  const out = {}
  for (const segment of encoded.split('__')) {
    const parsed = splitFieldValue(segment)
    if (!parsed) {
      continue
    }
    const field = sanitizeDeepLinkFieldName(parsed.field)
    if (!field) {
      continue
    }
    const value = sanitizeDeepLinkText(parsed.value)
    if (field === 'agent' && value && !AGENT_NAME_RE.test(value)) {
      continue
    }
    out[field] = value
  }
  return out
}

function bundleQueryParam (query, paramName) {
  const raw = query[paramName]
  if (!raw) {
    return []
  }
  return Array.isArray(raw) ? raw : [raw]
}

/**
 * Each job=… query parameter creates one job document.
 */
export function buildSubmitJobsFromQuery (query) {
  const jobs = []
  for (const item of bundleQueryParam(query, 'job')) {
    const bundle = parseBundle(item)
    if (!bundle.agent || !AGENT_NAME_RE.test(bundle.agent)) {
      continue
    }
    jobs.push(bundle)
  }
  return jobs
}

/**
 * role=role_spk__firstname_Jane__lastname_Doe — one contributor per param.
 */
export function parseRoleQueryParams (query) {
  const specs = []
  for (const item of bundleQueryParam(query, 'role')) {
    const bundle = parseBundle(item)
    if (!bundle.role) {
      continue
    }
    const roleCode = sanitizeDeepLinkText(bundle.role)
    if (!roleCode) {
      continue
    }
    const { role: _role, ...entityFields } = bundle
    specs.push({
      role: `role:${roleCode}`,
      fields: entityFields
    })
  }
  return specs
}

export function isMetadataOnlySubmitMode (query) {
  const mode = query.submitmode
  const value = Array.isArray(mode) ? mode[0] : mode
  return value === 'metadata_only'
}
