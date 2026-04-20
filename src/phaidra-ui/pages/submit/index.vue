<template>
<Submit></Submit>
</template>
<script>
import { config } from "../../mixins/config";
import Submit from "../../components/Submit.vue";

export default {
  middleware: "auth",
  mixins: [config],
  setup() {
    const nuxtApp = useNuxtApp()
    useHead(() => {
      const t = nuxtApp.$i18n?.t || ((v) => v)
      return {
        title: this.documentTitle(t('Submit'))
      }
    })
  }
}
</script>