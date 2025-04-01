export default function ({ app }) {
  return {
    theme: {
      themes: {
        light: {
          primary: app.$config.primaryColor,
          secondary: '#616161', // grey darken-2
          error: '#dd4814',          
        },
        dark: {
          primary: app.$config.primaryColor,
          secondary: '#e2e2e2',
          error: '#dd4814'
        }
      }
    }
  }
}