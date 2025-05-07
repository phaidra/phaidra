export default function ({ app }) {
  let theme = app.$config.defaultThemeColor === 'dark' ? 'dark' : 'light';
  if (process.server) {
    let ssrCookie = app?.context?.ssrContext?.req?.headers?.cookie
    let cookieTheme = ssrCookie && ssrCookie.split('; ').find(row => row.startsWith('theme='))?.split('=')[1]
    theme = cookieTheme || theme
  }
  if(process.client) {
    let cookieTheme = localStorage.getItem('theme')
    theme = cookieTheme || theme
  }
  return {
    theme: {
      dark: theme === 'dark',
      options: { customProperties: true },
      themes: {
        light: {
          primary: app.$config.primaryColor,
          secondary: '#616161', // grey darken-2
          error: '#dd4814',
          cardtitlebg: '#757575', // grey darken-1
          btnred: '#E91916'
        },
        dark: {
          primary: app.$config.darkPrimaryColor || app.$config.primaryColor,
          secondary: '#e2e2e2',
          error: '#dd4814',
          cardtitlebg: '#000',
          btnred: '#E91916'
        }
      }
    }
  }
}