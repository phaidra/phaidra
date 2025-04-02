<template>
  <v-row>
    <v-col :md="labelColMd" cols="12" class="pdlabel secondary--text font-weight-bold text-md-right">{{ $t(p) }}</v-col>
    <v-col :md="valueColMd" cols="12" >
      <v-card tile elevation="0" color="transparent">
        <v-card-text class="jsonld-border-left">
            <v-row>
              <template v-for="(title, j) in o['dce:title']">
                <template v-for="(mt, i) in title['bf:mainTitle']">
                  <v-col :md="labelColMd" cols="12" class="pdlabel secondary--text font-weight-bold" :key="'mt'+j+i">{{ $t(title['@type']) }}<template v-if="showLang && mt['@language']"> ({{ mt['@language'] }})</template></v-col>
                  <v-col :md="valueColMd" cols="12" :key="'mtv'+j+i" class="valuefield">{{ mt['@value'] }}</v-col>
                </template>
              </template>
            </v-row>
            <v-row v-for="(volume, i) in o['bibo:volume']" :key="'volume'+i">
              <v-col :md="labelColMd" cols="12" class="pdlabel secondary--text font-weight-bold">{{ $t('Volume') }}</v-col>
              <v-col :md="valueColMd" cols="12" class="valuefield">{{ volume }}</v-col>
            </v-row>
            <v-row v-for="(issue, i) in o['bibo:issue']" :key="'issue'+i">
              <v-col :md="labelColMd" cols="12" class="pdlabel secondary--text font-weight-bold">{{ $t('Issue') }}</v-col>
              <v-col :md="valueColMd" cols="12" class="valuefield">{{ issue }}</v-col>
            </v-row>
            <v-row v-for="(issn, i) in o['ids:issn']" :key="'issn'+i">
              <v-col :md="labelColMd" cols="12" class="pdlabel secondary--text font-weight-bold">{{ $t('ISSN') }}</v-col>
              <v-col :md="valueColMd" cols="12" class="valuefield">{{ issn }}</v-col>
            </v-row>
            <v-row v-for="(issued, i) in o['dcterms:issued']" :key="'issued'+i">
              <v-col :md="labelColMd" cols="12" class="pdlabel secondary--text font-weight-bold" >{{ $t('Issued') }}</v-col>
              <v-col :md="valueColMd" cols="12" class="valuefield">{{ checkAndUpdateField(issued) }}</v-col>
            </v-row>
            <v-row v-for="(id, i) in o['skos:exactMatch']" :key="'seriesexactMatch'+i">
              <v-col :md="labelColMd" cols="12" class="pdlabel secondary--text font-weight-bold">{{ getLocalizedTermLabel('objectidentifiertype', id['@type']) }}</v-col>
              <v-col :md="valueColMd" cols="12" v-if="getIDResolverURL(id)"><a :href="getIDResolverURL(id)" target="_blank">{{ id['@value'] }}</a></v-col>
            </v-row>
        </v-card-text>
      </v-card>
    </v-col>
    <v-spacer></v-spacer>
  </v-row>
</template>

<script>
import { vocabulary } from '../../mixins/vocabulary'
import { displayproperties } from '../../mixins/displayproperties'
import PDateModifier from '../../utils/PDateModifier'

export default {
  name: 'p-d-series',
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
  methods: {
    checkAndUpdateField(val) {
      return PDateModifier.dateModifierFn(val, this)
    },
  },
}
</script>
