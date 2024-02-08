<template>
  <v-row>
    <v-col :md="labelColMd" cols="12" class="pdlabel primary--text text-md-right">{{ $t(p) }}</v-col>
    <v-col :md="valueColMd" cols="12" >
      <v-card tile elevation="0">
        <v-card-text class="jsonld-border-left">
            <v-row>
              <template v-for="(title, j) in o['dce:title']">
                <template v-for="(mt, i) in title['bf:mainTitle']">
                  <v-col :md="labelColMd" cols="12" class="pdlabel primary--text" :key="'mt'+j+i">{{ $t(title['@type']) }}<template v-if="showLang && mt['@language']"> ({{ mt['@language'] }})</template></v-col>
                  <v-col :md="valueColMd" cols="12" :key="'mtv'+j+i" class="valuefield">{{ mt['@value'] }}</v-col>
                </template>
              </template>
            </v-row>
            <v-row>
              <template v-for="(volume, i) in o['bibo:volume']">
                <v-col :md="labelColMd" cols="12" class="pdlabel primary--text" :key="'vl'+i">{{ $t('Volume') }}</v-col>
                <v-col :md="valueColMd" cols="12" class="valuefield" :key="'v'+i">{{ volume }}</v-col>
              </template>
            </v-row>
            <v-row>
              <template v-for="(issue, i) in o['bibo:issue']">
                <v-col :md="labelColMd" cols="12" class="pdlabel primary--text" :key="'il'+i">{{ $t('Issue') }}</v-col>
                <v-col :md="valueColMd" cols="12" class="valuefield" :key="'i'+i">{{ issue }}</v-col>
              </template>
            </v-row>
            <v-row>
              <template v-for="(issn, i) in o['ids:issn']">
                <v-col :md="labelColMd" cols="12" class="pdlabel primary--text" :key="'isl'+i">{{ $t('ISSN') }}</v-col>
                <v-col :md="valueColMd" cols="12" class="valuefield" :key="'is'+i">{{ issn }}</v-col>
              </template>
            </v-row>
            <v-row>
              <template v-for="(issued, i) in o['dcterms:issued']">
                <v-col :md="labelColMd" cols="12" class="pdlabel primary--text" :key="'idatel'+i">{{ $t('Issued') }}</v-col>
                <v-col :md="valueColMd" cols="12" class="valuefield" :key="'idate'+i">{{ checkAndUpdateField(issued) }}</v-col>
              </template>
            </v-row>
            <v-row>
              <template v-for="(id, i) in o['skos:exactMatch']">
                <v-col :md="labelColMd" cols="12" class="pdlabel primary--text" :key="'idserl'+i">{{ getLocalizedTermLabel('objectidentifiertype', id['@type']) }}</v-col>
                <v-col :md="valueColMd" cols="12" v-if="getIDResolverURL(id)" :key="'idser'+i"><a :href="getIDResolverURL(id)" target="_blank">{{ id['@value'] }}</a></v-col>
                <!-- <v-col :md="labelColMd" cols="12" class="pdlabel primary--text">{{ $t('Identifier') }}</v-col>
                <v-col :md="valueColMd" cols="12" ><a :href="getIDResolverURL(id)" target="_blank">{{ id['@value'] }}</a></v-col> -->
              </template>
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
