<template>
  <span v-if="hideLabel" :class="{ 'font-weight-regular': boldLabelFields.includes('edm:rights') }">
    <template v-if="o.startsWith('http')">{{ getLocalizedTermLabel('alllicenses', o) }}</template>
    <template v-else>{{ $t(o) }}</template>
  </span>
  <v-row v-else>
    <v-col :md="labelColMd" cols="12" class="pdlabel secondary--text font-weight-bold text-md-right">{{ $t(p) }}</v-col>
    <v-col :md="valueColMd" cols="12" :class="{ 'font-weight-regular': boldLabelFields.includes('edm:rights') }">
      <a :href="o" target="_blank">{{ getLocalizedTermLabel('alllicenses', o) }}</a>
      <!--
        <v-img :src="'../../assets/' + getTermProperty('licenses', o, 'img')" :alt="o" class="license-icon"/>
      -->
      <span class="ml-2" v-if="copyrightLink && (o === 'http://rightsstatements.org/vocab/InC/1.0/')">(<a :href="copyrightLink" target="_blank" :title="$t('Copyright')">{{$t('Copyright')}}</a>)</span>
    </v-col>
  </v-row>
</template>

<script>
import { vocabulary } from '../../mixins/vocabulary'
import { displayproperties } from '../../mixins/displayproperties'

export default {
  name: 'p-d-license',
  mixins: [vocabulary, displayproperties],
  props: {
    o: {
      type: String,
      required: true
    },
    p: {
      type: String
    },
    copyrightLink: {
      type: String
    },
    hideLabel: Boolean
  }
}
</script>

<style scoped>

.license-icon {
  height: 1.3em;
  vertical-align: text-bottom;
}

.license-label {
  vertical-align: middle;
}

</style>
