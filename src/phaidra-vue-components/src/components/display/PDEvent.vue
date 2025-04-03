<template>
  <v-row>
    <v-col :md="labelColMd" cols="12" class="pdlabel secondary--text font-weight-bold text-md-right">{{ $t(p) }}</v-col>
    <v-col :md="valueColMd" cols="12">
      <v-card tile elevation="0" color="transparent">
        <v-card-text class="jsonld-border-left">
          <v-container fluid>
            <v-row>
              <template v-for="(name, i) in o['skos:prefLabel']">
                <v-col :md="labelColMd" cols="12" class="pdlabel secondary--text font-weight-bold" :key="'vl'+i">{{ $t('Name') }}<template v-if="showLang && name['@language']"> ({{ name['@language'] }})</template></v-col>
                <v-col :md="valueColMd" cols="12" class="valuefield" :key="'v'+i">{{ name['@value'] }}</v-col>
              </template>
            </v-row>
            <v-row>
              <template v-for="(d, i) in o['rdfs:comment']">
                <v-col :md="labelColMd" cols="12" class="pdlabel secondary--text font-weight-bold" :key="'dl'+i">{{ $t('Event description') }} ({{ d['@language'] }})</v-col>
                <v-col class="valuefield" :md="valueColMd" cols="12" :key="'dv'+i">{{ d['@value'] }}</v-col>
              </template>
            </v-row>
            <v-row>
              <template v-for="(location, j) in o['ebucore:hasEventRelatedLocation']">
                <template v-for="(place, i) in location['skos:prefLabel']">
                  <v-col :md="labelColMd" cols="12" class="pdlabel secondary--text font-weight-bold" :key="'dl'+i+j">{{ $t('Location') }}</v-col>
                  <v-col class="valuefield" :md="valueColMd" cols="12" :key="'dv'+i+j">{{ place['@value'] }}</v-col>
                </template>
              </template>
            </v-row>
            <v-row>
              <template v-for="(d, i) in o['ebucore:eventStartDateTime']">
                <v-col :md="labelColMd" cols="12" class="pdlabel secondary--text font-weight-bold" :key="'dfl'+i">{{ $t('Start date') }}</v-col>
                <v-col class="valuefield" :md="valueColMd" cols="12" :key="'dfv'+i">{{ d }}</v-col>
              </template>
            </v-row>
            <v-row>
              <template v-for="(d, i) in o['ebucore:eventEndDateTime']">
                <v-col :md="labelColMd" cols="12" class="pdlabel secondary--text font-weight-bold" :key="'dtl'+i">{{ $t('End date') }}</v-col>
                <v-col class="valuefield" :md="valueColMd" cols="12" :key="'dtv'+i">{{ d }}</v-col>
              </template>
            </v-row>
            <v-row>
              <template v-for="(id, i) in o['skos:exactMatch']">
                <v-col :md="labelColMd" cols="12" class="pdlabel secondary--text font-weight-bold" :key="'evidl'+i">{{ getLocalizedTermLabel('entityidentifiertype', id['@type']) }}</v-col>
                <v-col v-if="getIDResolverURL(id)" :md="valueColMd" cols="12" :key="'evidv'+i"><a :href="getIDResolverURL(id)" target="_blank">{{ id['@value'] }}</a></v-col>
              </template>
            </v-row>
          </v-container>
        </v-card-text>
      </v-card>
    </v-col>
  </v-row>
</template>

<script>
import { displayproperties } from '../../mixins/displayproperties'
import { vocabulary } from '../../mixins/vocabulary'

export default {
  name: 'p-d-event',
  mixins: [ displayproperties, vocabulary ],
  props: {
    o: {
      type: Object,
      required: true
    },
    p: {
      type: String
    },
    hideLabel: {
      type: Boolean,
      defualt: false
    }
  }
}
</script>
