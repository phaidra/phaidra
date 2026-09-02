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

export function queryScalar (query, key) {
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
 * Deep-link job bundles use ocmpid; MongoDB agents expect oc_mpid.
 */
export function normalizeSubmitJob (bundle) {
  const job = { ...bundle }
  if (job.ocmpid && !job.oc_mpid) {
    job.oc_mpid = job.ocmpid
    delete job.ocmpid
  }
  return job
}

function jobMpid (job) {
  return job.ocmpid || job.oc_mpid || ''
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
    jobs.push(normalizeSubmitJob(bundle))
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

export function isDeferredUploadSubmitMode (query) {
  const mode = query.submitmode
  const value = Array.isArray(mode) ? mode[0] : mode
  return value === 'deferred_upload'
}

export const VOCAB_NS = 'https://pid.phaidra.org/vocabulary/'

export const RESOURCE_TYPE_VIDEO = `${VOCAB_NS}B0Y6-GYT8`
export const DEFAULT_RESOURCE_TYPE_IMAGE = `${VOCAB_NS}44TN-P1S0`

const RESOURCE_TYPE_RE = /^https:\/\/pid\.phaidra\.org\/vocabulary\/[A-Z0-9]+-[A-Z0-9]+$/i

/**
 * Resource type from rt query param (full vocabulary URL).
 */
export function parseResourceTypeFromQuery (query) {
  const raw = queryScalar(query, 'rt')
  if (!raw) {
    return null
  }
  if (RESOURCE_TYPE_RE.test(raw)) {
    return raw
  }
  return null
}

export function resolveInitialResourceType (query) {
  return parseResourceTypeFromQuery(query) || DEFAULT_RESOURCE_TYPE_IMAGE
}

export function formatContributorName (fields) {
  const first = sanitizeDeepLinkText(fields.firstname || '')
  const last = sanitizeDeepLinkText(fields.lastname || '')
  const name = [first, last].filter(Boolean).join(' ')
  if (name) {
    return name
  }
  return sanitizeDeepLinkText(fields.institution || '')
}

/**
 * Bibliographical metadata and OpenCast mpid from deep-link query params.
 */
export function buildSubmitDeepLinkSummary (query) {
  const mpids = []
  for (const job of buildSubmitJobsFromQuery(query)) {
    const mpid = jobMpid(job)
    if (mpid && !mpids.includes(mpid)) {
      mpids.push(mpid)
    }
  }
  return {
    mpids,
    title: queryScalar(query, 'title'),
    language: queryScalar(query, 'language'),
    datecreated: queryScalar(query, 'datecreated'),
    contributors: parseRoleQueryParams(query)
  }
}

export function hasSubmitDeepLinkSummary (summary) {
  return summary.mpids.length > 0 ||
    !!summary.title ||
    !!summary.language ||
    !!summary.datecreated ||
    summary.contributors.length > 0
}
