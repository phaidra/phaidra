<template>
<client-only>
  <p-lists></p-lists>
</client-only>
</template>
<script setup>
import { usePageDocumentTitle } from '../mixins/config'

definePageMeta({
  middleware: 'auth'
})
usePageDocumentTitle('Manage object lists')
</script>

<script>
import { config } from "../mixins/config";
export default {
  mixins: [config]
}
</script>
