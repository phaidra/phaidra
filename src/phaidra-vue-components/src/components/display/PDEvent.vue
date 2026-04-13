<template>
  <v-row>
    <v-col :md="labelColMd" cols="12" class="pdlabel secondary--text font-weight-bold text-md-right">{{ $t(p) }}</v-col>
    <v-col :md="valueColMd" cols="12">
      <v-card tile elevation="0" color="transparent">
        <v-card-text class="jsonld-border-left">
          <v-container fluid>
            <v-row>
              <template v-for="(name, i) in o['skos:prefLabel']" :key="'name' + i">
                <v-col :md="labelColMd" cols="12" class="pdlabel secondary--text font-weight-bold">{{ $t('Name') }}<template v-if="showLang && name['@language']"> ({{ name['@language'] }})</template></v-col>
                <v-col :md="valueColMd" cols="12" class="valuefield">{{ name['@value'] }}</v-col>
              </template>
            </v-row>
            <v-row>
              <template v-for="(d, i) in o['rdfs:comment']" :key="'comment' + i">
                <v-col :md="labelColMd" cols="12" class="pdlabel secondary--text font-weight-bold">{{ $t('Event description') }} ({{ d['@language'] }})</v-col>
                <v-col class="valuefield" :md="valueColMd" cols="12">{{ d['@value'] }}</v-col>
              </template>
            </v-row>
            <v-row>
              <template v-for="(location, j) in o['ebucore:hasEventRelatedLocation']" :key="'loc' + j">
                <template v-for="(place, i) in location['skos:prefLabel']" :key="'place' + j + '-' + i">
                  <v-col :md="labelColMd" cols="12" class="pdlabel secondary--text font-weight-bold">{{ $t('Location') }}</v-col>
                  <v-col class="valuefield" :md="valueColMd" cols="12">{{ place['@value'] }}</v-col>
                </template>
              </template>
            </v-row>
            <v-row>
              <template v-for="(d, i) in o['ebucore:eventStartDateTime']" :key="'start' + i">
                <v-col :md="labelColMd" cols="12" class="pdlabel secondary--text font-weight-bold">{{ $t('Start date') }}</v-col>
                <v-col class="valuefield" :md="valueColMd" cols="12">{{ d }}</v-col>
              </template>
            </v-row>
            <v-row>
              <template v-for="(d, i) in o['ebucore:eventEndDateTime']" :key="'end' + i">
                <v-col :md="labelColMd" cols="12" class="pdlabel secondary--text font-weight-bold">{{ $t('End date') }}</v-col>
                <v-col class="valuefield" :md="valueColMd" cols="12">{{ d }}</v-col>
              </template>
            </v-row>
            <v-row>
              <template v-for="(id, i) in o['skos:exactMatch']" :key="'id' + i">
                <v-col :md="labelColMd" cols="12" class="pdlabel secondary--text font-weight-bold">{{ getLocalizedTermLabel('entityidentifiertype', id['@type']) }}</v-col>
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
