const COOKIE_OPTS = {
  path: '/',
  maxAge: 60 * 60 * 24 * 365 // 1 year
}

export default ({ app, $cookies }) => {
  const defaultLocale = app.$config.defaultLocale || 'eng'
  const availableLocales = (app.i18n.locales || []).map(l =>
    typeof l === 'string' ? l : l.code
  )

  const resolveLocale = (candidate) => {
    if (candidate && availableLocales.includes(candidate)) {
      return candidate
    }
    return defaultLocale
  }

  if (process.server) {
    app.i18n.locale = resolveLocale($cookies?.get('locale'))
    return
  }

  const locale = resolveLocale(
    localStorage.getItem('locale') || $cookies?.get('locale')
  )
  app.i18n.locale = locale
  localStorage.setItem('locale', locale)
  $cookies.set('locale', locale, COOKIE_OPTS)
}
