<template>
  <span>
    <v-row v-for="(l, i) in o['skos:prefLabel']" v-if="l['@language'] === displaylang" :key="'prl'+i">
      <v-col :md="labelColMd" cols="12" v-if="p==='bf:note'" class="pdlabel secondary--text font-weight-bold text-md-right" >{{ $t(o['@type']) }}<template v-if="showLang && l['@language']"> ({{ l['@language'] }})</template></v-col>
      <v-col :md="labelColMd" cols="12" v-else class="pdlabel secondary--text font-weight-bold text-md-right">{{ $t(p) }}<template v-if="showLang && l['@language']"> ({{ l['@language'] }})</template></v-col>
      <v-col :md="valueColMd" cols="12" v-if="o['skos:exactMatch']">
        <span v-if="o['skos:exactMatch'][0].startsWith('oefos2012:')">ÖFOS 2012 -- {{ o['skos:notation'][0] }} -- {{ l['@value'] }}</span>
        <span v-else-if="o['skos:exactMatch'][0].startsWith('thema:')">{{ $t('Thema Subject Codes') }} -- {{ o['skos:notation'][0] }} -- {{ l['@value'] }}</span>
        <span v-else-if="o['skos:exactMatch'][0].startsWith('bic:')">{{ l['@value'] }}</span>
        <span v-else-if="isA11y">{{ getLocalizedTermLabel(a11yVocab, o['skos:exactMatch'][0]) }}</span>
        <a v-else class="valuefield" :href="o['skos:exactMatch'][0]" target="_blank">{{ l['@value'] }}</a>
      </v-col>
      <!--<v-col :md="valueColMd" cols="12" v-else-if="usedMarkdown" class="valuefield" v-html="$md.disable(['image','emphasis']).render(l['@value'])"></v-col>-->
      <v-col class="valuefield" :md="valueColMd" cols="12" v-else ><span v-html="autolinkerCheck(l['@value'])"></span></v-col>
    </v-row>
  </span>
</template>

<script>
import Autolinker from 'autolinker';
import { displayproperties } from '../../mixins/displayproperties'
import { vocabulary } from '../../mixins/vocabulary'

export default {
  name: 'p-d-skos-preflabel',
  mixins: [displayproperties, vocabulary],
  props: {
    o: {
      type: Object,
      required: true
    },
    p: {
      type: String
    }
  },
  computed: {
    isA11y: function () {
      return ((this.p === 'schema:accessMode') ||
        (this.p === 'schema:accessibilityFeature') ||
        (this.p === 'schema:accessibilityControl') ||
        (this.p === 'schema:accessibilityHazard')
      )
    },
    a11yVocab: function () {
      switch (this.p) {
        case 'schema:accessMode':
          return 'accessMode'
        case 'schema:accessibilityFeature':
          return 'accessibilityFeature'
        case 'schema:accessibilityControl':
          return 'accessibilityControl'
        case 'schema:accessibilityHazard':
          return 'accessibilityHazard'
      }
    },
    displaylang: function () {
      let lang
      let somelang
      for (let label of this.o['skos:prefLabel']) {
        somelang = label['@language']
        if (label['@language'] === this.$i18n.locale) {
          lang = this.$i18n.locale
        }
      }
      return lang || somelang
    },
    usedMarkdown: function () {
      return (this.p === 'bf:TableOfContents') ||
      (this.p === 'bf:note') ||
      (this.p === 'dcterms:provenance')
    }
  },
  methods: {
    autolinkerCheck(val) {
      return Autolinker.link(val);

    }
  },
}
</script>
