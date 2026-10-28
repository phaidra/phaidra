<template>
<client-only>
  <div>
    <h1 class="d-sr-only">{{$t('Groups')}}</h1>
    <p-groups></p-groups>
  </div>
</client-only>
</template>
<script setup>
import { usePageDocumentTitle } from '../mixins/config'

definePageMeta({
  middleware: 'auth'
})
usePageDocumentTitle('Groups')
</script>

<script>
import { config } from "../mixins/config";
export default {
  mixins: [config]
}
</script>
