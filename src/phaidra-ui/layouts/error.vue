<template>
   <div class="pt-4">
      <div v-if="error.statusCode === 404">
        <h2 class="font-weight-light">{{$t('This page does not exist...')}}</h2>
        <p class="mt-4">{{$t('We apologise for the inconvenience, the page you are trying to access does not exist at this address.')}}</p>
        <p v-if="instanceconfig.email">{{$t('If you are sure you entered the correct address but still get an error, please contact')}} <a :href="'mailto:' + instanceconfig.email">{{ instanceconfig.email }}</a>.</p>
      </div>
      <h2 v-else class="font-weight-light">{{ $t('An error occurred.') }}</h2>
      <p>{{$t('Return to')}} <NuxtLink to="/">home page</NuxtLink>.</p>
  </div>
</template>

<script>
import { config } from "@/mixins/config";
export default {
  props: ['error'],
  layout: 'error',
  mixins: [config]
  // beforeMount() {
  //   this.$router.push(this.localeLocation('/notfound'))
  // }
};
</script>
