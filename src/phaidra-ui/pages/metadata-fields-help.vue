<template>
<client-only>
  <p-metadata-fields-help></p-metadata-fields-help>
</client-only>
</template>
<script>
import { useTranslatedPageHead } from '../mixins/config'

export default {
  setup() {
    useTranslatedPageHead('Metadata fields overview', 'meta_description_metadata_fields')
  }
}
</script>
