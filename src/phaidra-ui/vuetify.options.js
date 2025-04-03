export default function ({ app }) {
  return {
    theme: {
      options: { customProperties: true },
      themes: {
        light: {
          primary: app.$config.primaryColor,
          secondary: '#616161', // grey darken-2
          error: '#dd4814',
          cardtitlebg: '#757575' // grey darken-1
        },
        dark: {
          primary: app.$config.primaryColor,
          secondary: '#e2e2e2',
          error: '#dd4814',
          cardtitlebg: '#000'
        }
      }
    }
  }
}