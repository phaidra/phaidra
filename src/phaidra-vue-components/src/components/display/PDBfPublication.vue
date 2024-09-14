<template>
  <v-row>
    <v-col :md="labelColMd" cols="12" class="pdlabel primary--text text-md-right">{{ $t('Publication') }}</v-col>
    <v-col :md="valueColMd" cols="12">
      <template v-for="(publisher, i) in o['bf:agent']">
        <template v-if="localizedOrgUnit(publisher)">
          <a :key="'publname'+i" class="valuefield" :href="localizedOrgUnit(publisher).id" target="_blank">{{ localizedOrgUnit(publisher).value }}</a>
        </template>
        <template v-else v-for="(publishername, i) in publisher['schema:name']">
          <span :key="'publname'+i" class="valuefield">{{ publishername['@value'] }}</span>
        </template>
      </template>
      <template v-for="(publishingplace, j) in o['bf:place']">
        <template v-for="(place, i) in publishingplace['skos:prefLabel']">
          <span class="valuefield" :key="'publplace'+j+i">, {{ place['@value'] }}</span>
        </template>
      </template>
      <template v-for="(publishingdate, j) in o['bf:date']">
          <span :key="'publdate'+j">, {{ publishingdate }}</span>
      </template>
    </v-col>
  </v-row>
</template>

<script>
import { displayproperties } from '../../mixins/displayproperties'

export default {
  name: 'p-d-bf-publication',
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
  methods: {
    localizedOrgUnit: function (orgUnit) {
      if (orgUnit['skos:exactMatch']) {
        if (orgUnit['skos:exactMatch'].length > 0) {
          for (let name of orgUnit['schema:name']) {
            if (name['@language'] === this.$i18n.locale) {
              return {
                value: name['@value'],
                language: name['@language'],
                id: orgUnit['skos:exactMatch']
              }
            }
          }
          if (orgUnit['schema:name'].length > 0) {
            return {
              name: orgUnit['schema:name'][0]['@value'],
              language: orgUnit['schema:name'][0]['@language'],
              id: orgUnit['skos:exactMatch'].length > 0 ? orgUnit['skos:exactMatch'][0] : null
            }
          }
        }
      }
      return null
    }
  }
}
</script>
