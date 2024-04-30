export default function ({ app }) {
  return {
    theme: {
      themes: {
        light: {
          primary: app.$config.primaryColor,
          error: '#dd4814'
        },
        dark: {
          primary: app.$config.primaryColor,
          error: '#dd4814'
        }
      }
    }
  }
}