<template>
  <span>
    <v-row v-for="(l, i) in o['skos:prefLabel']" v-if="l['@language'] === displaylang" :key="'prl'+i">
      <v-col :md="labelColMd" cols="12" v-if="p==='bf:note'" class="pdlabel primary--text text-md-right" >{{ $t(o['@type']) }}<template v-if="showLang && l['@language']"> ({{ l['@language'] }})</template></v-col>
      <v-col :md="labelColMd" cols="12" v-else class="pdlabel primary--text text-md-right">{{ $t(p) }}<template v-if="showLang && l['@language']"> ({{ l['@language'] }})</template></v-col>
      <v-col :md="valueColMd" cols="12" v-if="o['skos:exactMatch']">
        <span v-if="o['skos:exactMatch'][0].startsWith('oefos2012:')">ÖFOS 2012 -- {{ o['skos:notation'][0] }} -- {{ l['@value'] }}</span>
        <span v-else-if="o['skos:exactMatch'][0].startsWith('thema:')">{{ $t('Thema Subject Codes') }} -- {{ o['skos:notation'][0] }} -- {{ l['@value'] }}</span>
        <a v-else class="valuefield" :href="o['skos:exactMatch'][0]" target="_blank">{{ l['@value'] }}</a>
      </v-col>
      <v-col class="valuefield" :md="valueColMd" cols="12" v-else ref="desc">{{ l['@value'] }}</v-col>
    </v-row>
  </span>
</template>

<script>
import Autolinker from 'autolinker'
import { displayproperties } from '../../mixins/displayproperties'

export default {
  name: 'p-d-skos-preflabel',
  mixins: [displayproperties],
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
    }
  },
  methods: {
    link: function (v) {
      if (typeof v === 'string') {
        return Autolinker.link(v, {
          stripPrefix: false,
          stripTrailingSlash: false
        })
      } else {
        return v
      }
    }
  },
  mounted: function () {
    this.$nextTick(function () {
      if (this.$refs && this.$refs.desc && this.$refs.desc.length) {
        this.$refs.desc[0].innerHTML = Autolinker.link(this.$refs.desc[0].innerHTML, {
          stripPrefix: false,
          stripTrailingSlash: false
        })
      }
    })
  },
  updated: function () {
    this.$nextTick(function () {
      if (this.$refs && this.$refs.desc && this.$refs.desc.length) {
        this.$refs.desc[0].innerHTML = Autolinker.link(this.$refs.desc[0].innerHTML, {
          stripPrefix: false,
          stripTrailingSlash: false
        })
      }
    })
  }
}
</script>
