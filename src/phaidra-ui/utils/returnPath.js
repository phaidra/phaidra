/**
 * Resolve returnto from route query or localStorage fallback.
 */
export function resolveReturnPath (routeQuery) {
  const returnto = routeQuery?.returnto
  if (typeof returnto === 'string' && returnto.startsWith('/')) {
    return returnto
  }
  if (import.meta.client) {
    try {
      const stored = localStorage.getItem('redirect')
      if (stored && stored.startsWith('/')) {
        return stored
      }
    } catch (_) {}
  }
  return '/'
}

/**
 * Split a same-site path + query (e.g. /submit/upload?title=…) for vue-router.
 */
export function parseReturnPath (fullPath) {
  if (typeof fullPath !== 'string' || !fullPath.startsWith('/')) {
    return { path: '/' }
  }
  const qIndex = fullPath.indexOf('?')
  if (qIndex === -1) {
    return { path: fullPath }
  }
  const path = fullPath.slice(0, qIndex)
  const query = {}
  const params = new URLSearchParams(fullPath.slice(qIndex + 1))
  for (const key of params.keys()) {
    const values = params.getAll(key)
    query[key] = values.length > 1 ? values : values[0]
  }
  return { path, query }
}

export function getReturnLocation (routeQuery) {
  return parseReturnPath(resolveReturnPath(routeQuery))
}
