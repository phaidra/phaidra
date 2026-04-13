<template>
  <v-row>
    <v-col :md="labelColMd" cols="12" class="pdlabel secondary--text font-weight-bold text-md-right">{{ $t('Publication') }}</v-col>
    <v-col :md="valueColMd" cols="12">
      <template v-for="(publisher, i) in o['bf:agent']" :key="'pub' + i">
        <template v-if="localizedOrgUnit(publisher)">
          <a class="valuefield" :href="localizedOrgUnit(publisher).id" target="_blank">{{ localizedOrgUnit(publisher).value || localizedOrgUnit(publisher).name }}</a>
        </template>
        <template v-else>
          <template v-for="(publishername, ni) in publisher['schema:name']" :key="'pn' + i + '-' + ni">
            <span class="valuefield">{{ publishername['@value'] }}</span>
          </template>
        </template>
        <span v-if="i < o['bf:agent'].length - 1">, </span>
      </template>
      <template v-if="o['bf:place'] && o['bf:place'].length > 0">
        <span v-if="o['bf:agent'] && o['bf:agent'].length > 0">, </span>
        <template v-for="(publishingplace, j) in o['bf:place']" :key="'pp' + j">
          <template v-for="(place, i) in publishingplace['skos:prefLabel']" :key="'pl' + j + '-' + i">
            <span class="valuefield">{{ place['@value'] }}</span>
          </template>
          <span v-if="j < o['bf:place'].length - 1">, </span>
        </template>
      </template>
      <template v-if="o['bf:date'] && o['bf:date'].length > 0">
        <span v-if="(o['bf:agent'] && o['bf:agent'].length > 0) || (o['bf:place'] && o['bf:place'].length > 0)">, </span>
        <template v-for="(publishingdate, j) in o['bf:date']" :key="'pdate' + j">
          <span>{{ publishingdate }}</span>
          <span v-if="j < o['bf:date'].length - 1">, </span>
        </template>
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
