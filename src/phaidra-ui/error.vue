<template>
  <NuxtLayout>
    <div class="pt-4">
      <div v-if="is404">
        <h2 class="font-weight-light">{{ $t('This page does not exist or the object cannot be found.') }}</h2>
        <p class="mt-4">{{ $t('We apologise for the inconvenience, the page you are trying to access does not exist at this address.') }}</p>
        <p v-if="instanceconfig.email">
          {{ $t('If you are sure you entered the correct address but still get an error, please contact') }}
          <a :href="'mailto:' + instanceconfig.email">{{ instanceconfig.email }}</a>.
        </p>
      </div>
      <template v-else>
        <h2 class="font-weight-light">{{ $t('An error occurred.') }}</h2>
      </template>
      <p>
        {{ $t('Return to') }}
        <NuxtLink to="/" @click.prevent="clearError({ redirect: '/' })">home page</NuxtLink>.
      </p>
    </div>
  </NuxtLayout>
</template>

<script setup>
import { useRootStore } from '~/stores/root'
const props = defineProps({
  error: {
    type: Object,
    required: true
  }
})

const nuxtApp = useNuxtApp()
const instanceconfig = computed(() => useRootStore()?.instanceconfig ?? {})

const is404 = computed(() => {
  const code = props.error?.statusCode ?? props.error?.status
  return Number(code) === 404
})
</script>
