<template>
  <v-card >
    <v-card-title class="text-title-large font-weight-light text-white">{{ $t('Collection members') }}</v-card-title>
    <v-divider></v-divider>
    <v-card-text class="mt-4">
      <div>{{ $t('Here you can add or remove some of the members this collection is composed of.') }}</div>
    </v-card-text>
  </v-card>
</template>

<script>
import { useHostRootStore as useRootStore } from '../../stores/host-root'

export default {
  name: 'p-m-collection-members',
  props: {
    pid: {
      type: String,
      required: true
    }
  },
  computed: {
    instance: function () {
      return useRootStore().instanceconfig
    }
  },
  data () {
    return {
      loading: false
    }
  }
}
</script>
