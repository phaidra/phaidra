export default ({ app }) => {
    const defaultLocale = app.$config.defaultLocale || 'eng'
  
    if (process.server) {
      app.i18n.locale = defaultLocale
      return
    }
  
    const storedLocale = localStorage.getItem('locale')
    if (storedLocale) {
      app.i18n.locale = storedLocale
      return
    }
  
    app.i18n.locale = defaultLocale
    localStorage.setItem('locale', defaultLocale)
  }