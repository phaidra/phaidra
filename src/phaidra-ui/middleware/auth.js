/**
 * Nuxt 3 route middleware: signature is (to, from), not Nuxt 2 context.
 * Login required only for editing / admin flows; /detail/:pid and search stay public.
 */
function pathRequiresAuth (path) {
  const p = (path || '').split('?')[0]
  const prefixes = [
    '/admin',
    '/bulk-upload',
    '/submit',
    '/submitrelated/',
    '/delete/',
    '/rights/',
    '/uwmetadata/',
    '/upload-webversion/',
    '/sort/',
    '/relationships/',
    '/stats/',
    '/sorttextinput/',
    '/list/'
  ]
  if (prefixes.some((pre) => p.startsWith(pre))) return true
  if (/^\/metadata\/o:/.test(p)) return true
  return false
}

export default defineNuxtRouteMiddleware((to) => {
  if (!pathRequiresAuth(to.path)) return

  const store = useNuxtApp().$store
  if (!store?.state?.user?.token) {
    if (import.meta.client) {
      try {
        localStorage.setItem('redirect', to.fullPath)
      } catch (_) {}
    }
    return navigateTo('/login')
  }
})
