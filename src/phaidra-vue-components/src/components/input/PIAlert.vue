<template>
  <v-row class="mx-1 mt-4">
    <v-cols cols="10" class="pa-0">
      <v-alert text type="info" color="black" v-html="content" ></v-alert>
    </v-cols>
  </v-row>
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
