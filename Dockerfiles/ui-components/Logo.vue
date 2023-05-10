<template>
  <a :href="instanceconfig.institutionweb" target="_blank">
    <img src="../../assets/ext/Uni_Logo_2016.png" class="logo" alt="logo" />
  </a>
</template>

<script>
import { config } from '@/mixins/config'

export default {
  name: 'logo',
  mixins: [ config ]
}
</script>
