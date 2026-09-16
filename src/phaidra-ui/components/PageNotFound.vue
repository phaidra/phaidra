<template>
  <v-row justify="center" class="mt-8">
    <v-col cols="12" md="8">
      <v-alert type="error" variant="outlined" class="not-found-alert">
        {{ $t('This page does not exist or the object cannot be found.') }}
        <p class="mt-4">{{ $t('We apologise for the inconvenience, the page you are trying to access does not exist at this address.') }}</p>
        <p v-if="instanceconfig.email">
          {{ $t('If you are sure you entered the correct address but still get an error, please contact') }}
          <a :href="'mailto:' + instanceconfig.email">{{ instanceconfig.email }}</a>.
        </p>
      </v-alert>
    </v-col>
  </v-row>
</template>

<script>
import { config } from '../mixins/config'

export default {
  mixins: [config]
}
</script>
