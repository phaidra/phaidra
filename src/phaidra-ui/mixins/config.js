import { useRootStore } from '~/stores/root'

export function buildDocumentTitle (pageTitle, instanceconfig = {}, t = (v) => v) {
  const title = instanceconfig.title ? t(instanceconfig.title) : ''
  const institution = instanceconfig.institution
    ? t(instanceconfig.institution)
    : ''
  const suffix = (!institution || institution === title)
    ? title
    : `${title} - ${institution}`

  if (pageTitle) {
    return suffix ? `${pageTitle} - ${suffix}` : pageTitle
  }
  return suffix
}

/** Composition-API helper for useHead() — mixin methods are not available via `this` in setup(). */
export function useDocumentTitle () {
  const nuxtApp = useNuxtApp()
  const root = useRootStore(nuxtApp.$pinia)

  return (pageTitle) => {
    const instanceconfig = root.instanceconfig || {}
    const t = nuxtApp.$i18n?.global?.t
      || nuxtApp.$i18n?.t
      || ((v) => v)
    return buildDocumentTitle(pageTitle, instanceconfig, t)
  }
}

export const config = {
  computed: {
    appconfig () {
      return useRootStore().config?.global || {}
    },
    instanceconfig () {
      return useRootStore().instanceconfig || {}
    },
    apiBaseUrl () {
      return this.instanceconfig?.api || this.$config?.apiBaseURL || this.$config?.public?.apiBaseURL || ''
    },
    documentTitleSuffix () {
      return buildDocumentTitle(null, this.instanceconfig, (key) => this.$t(key))
    }
  },
  methods: {
    documentTitle (pageTitle) {
      return buildDocumentTitle(pageTitle, this.instanceconfig, (key) => this.$t(key))
    }
  }
}
