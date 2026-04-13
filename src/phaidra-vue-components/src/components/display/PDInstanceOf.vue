<template>
  <v-row>
    <v-col :md="labelColMd" cols="12" class="pdlabel secondary--text font-weight-bold text-md-right">{{ $t(p) }}</v-col>
    <v-col :md="valueColMd" cols="12">
      <v-card tile elevation="0" color="transparent">
        <v-card-text class="jsonld-border-left">
          <v-container fluid>
            <v-row>
              <template v-for="(title, j) in o['dce:title']" :key="'title' + j">
                <template v-for="(mt, i) in title['bf:mainTitle']" :key="'mt' + j + '-' + i">
                  <v-col md="2" cols="12" class="pdlabel secondary--text font-weight-bold">{{ $t(title['@type']) }}<template v-if="showLang && mt['@language']"> ({{ mt['@language'] }})</template></v-col>
                  <v-col md="10" cols="12" class="valuefield">
                    <div>{{ mt['@value'] }}</div>
                    <template v-for="(st, si) in title['bf:subtitle']" :key="'st' + j + '-' + i + '-' + si">
                      <div>{{ st['@value'] }}</div>
                    </template>
                  </v-col>
                </template>
              </template>
            </v-row>
            <v-row>
              <template v-for="(id, i) in o['skos:exactMatch']" :key="'ex' + i">
                <v-col :md="labelColMd" cols="12" class="pdlabel secondary--text font-weight-bold">{{ getLocalizedTermLabel('objectidentifiertype', id['@type']) }}</v-col>
                <v-col v-if="getIDResolverURL(id)" :md="valueColMd" cols="12"><a :href="getIDResolverURL(id)" target="_blank">{{ id['@value'] }}</a></v-col>
              </template>
            </v-row>
          </v-container>
        </v-card-text>
      </v-card>
    </v-col>
  </v-row>
</template>

<script>
import { vocabulary } from '../../mixins/vocabulary'
import { displayproperties } from '../../mixins/displayproperties'

export default {
  name: 'p-d-instance-of',
  mixins: [vocabulary, displayproperties],
  props: {
    o: {
      type: Object,
      required: true
    },
    p: {
      type: String
    }
  }
}
</script>
