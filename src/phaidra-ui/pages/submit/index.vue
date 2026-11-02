<template>
<Submit></Submit>
</template>
<script setup>
import { usePageDocumentTitle } from '../../mixins/config'

definePageMeta({
  middleware: 'auth'
})
usePageDocumentTitle('Submit')
</script>

<script>
import { config } from "../../mixins/config";
import Submit from "../../components/Submit.vue";

export default {
  mixins: [config]
}
</script>