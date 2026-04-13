/**
 * Node resolves `#internal/nuxt/paths` from the app package.json `imports` field.
 * Nuxt injects this during dev/build in some paths; when running the SSR chunk under
 * plain Node, this shim supplies the same export surface (currently `baseURL` only).
 */
export function baseURL () {
  return process.env.NUXT_APP_BASE_URL || ''
}
