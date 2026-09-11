<template>
  <div>
    <h1 class="d-sr-only">{{$t('Home')}}</h1>
    <ExtHome></ExtHome>
  </div>
</template>

<script>
import { useTranslatedPageHead } from '../mixins/config'

export default {
  setup() {
    useTranslatedPageHead(null, 'meta_description_home')
  }
}
</script>
