<template>
  <v-row>
    <v-col class="primary--text" cols="3">{{ label }}</v-col>
    {{jsonld}}
  </v-row>
</template>

<script>
export default {
  name: 'p-d-unknown',
  props: {
    jsonld: {
      type: Object
    },
    label: {
      type: String,
      required: true
    }
  }
}
</script>
