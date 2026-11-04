<template>
  <v-col cols="12" class="px-1 mt-4">
    <v-alert variant="text" type="info" color="black">
      <div v-html="content"></div>
    </v-alert>
  </v-col>
</template>

<script>
export default {
  name: 'p-i-alert',
  props: {
    contentperlocale: {
      type: Object
    }
  },
  computed: {
    content: function () {
      return this.contentperlocale[this.$i18n.locale]
    }
  }
}
</script>
