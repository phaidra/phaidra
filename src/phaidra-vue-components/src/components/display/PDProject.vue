<template>
  <span>
    <v-row>
      <template v-if="o['skos:exactMatch'] || o['skos:prefLabel'] || o['frapo:hasFundingAgency']">
        <v-col :md="labelColMd" cols="12" class="pdlabel primary--text text-md-right" :key="'idl'"><span v-show="!hideLabel && !o['rdfs:comment'] && !o['foaf:homepage']">{{ $t(p) }}</span></v-col>
        <v-col :md="valueColMd" cols="12" :key="'idv'">{{ id }}</v-col>
      </template>
    </v-row>
    <v-row>
      <template v-for="(ac, i) in o['frapo:hasAcronym']">
        <v-col :md="labelColMd" cols="12" class="pdlabel primary--text text-md-right" :key="'ac'+i">{{ $t('Acronym') }}</v-col>
        <v-col :md="valueColMd" cols="12" :key="'ac'+i">{{ ac }}</v-col>
      </template>
    </v-row>
    <v-row>
      <template v-for="(d, i) in o['rdfs:comment']">
        <v-col :md="labelColMd" cols="12" class="pdlabel primary--text text-md-right" :key="'dl'+i">{{ $t('Project Description') }} ({{ d['@language'] }})</v-col>
        <v-col class="valuefield" :md="valueColMd" cols="12" :key="'dv'+i">{{ d['@value'] }}</v-col>
      </template>
    </v-row>
    <v-row>
      <template v-for="(sd, i) in o['frapo:hasStartDate']">
        <v-col :md="labelColMd" cols="12" class="pdlabel primary--text text-md-right" :key="'dfl'+i">{{ $t('Start date') }}</v-col>
        <v-col class="valuefield" :md="valueColMd" cols="12" :key="'dfv'+i">{{ sd }}</v-col>
      </template>
    </v-row>
    <v-row>
      <template v-for="(ed, i) in o['frapo:hasEndDate']">
        <v-col :md="labelColMd" cols="12" class="pdlabel primary--text text-md-right" :key="'dtl'+i">{{ $t('End date') }}</v-col>
        <v-col class="valuefield" :md="valueColMd" cols="12" :key="'dtv'+i">{{ ed }}</v-col>
      </template>
    </v-row>
    <v-row>
      <template v-for="(hp, i) in o['foaf:homepage']">
        <v-col :md="labelColMd" cols="12" class="pdlabel primary--text text-md-right" :key="'hpl'+i">{{ $t('Project Homepage') }}</v-col>
        <v-col :md="valueColMd" cols="12" :key="'hpv'+i">{{ hp }}</v-col>
      </template>
    </v-row>
  </span>
</template>

<script>
import { displayproperties } from '../../mixins/displayproperties'
import { vocabulary } from '../../mixins/vocabulary'

export default {
  name: 'p-d-project',
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
  },
  computed: {
    fundersLabel: function () {
      let labels = []
      if (this.o['frapo:hasFundingAgency']) {
        for (let f of this.o['frapo:hasFundingAgency']) {
          let vocabValue = false
          if (f['skos:exactMatch']) {
            for (let id of f['skos:exactMatch']) {
              if (id.startsWith('https://pid.phaidra.org/')) {
                vocabValue = true
                labels.push(this.getLocalizedTermLabel('funders', id))
              }
            }
          }
          if (!vocabValue) {
            if (f['skos:prefLabel']) {
              for (let l of f['skos:prefLabel']) {
                labels.push(l['@value'])
              }
            }
          }
        }
      }
      return labels.join(', ')
    },
    projectLabel: function () {
      let labels = []
      if (this.o['skos:prefLabel']) {
        for (let l of this.o['skos:prefLabel']) {
          labels.push(l['@value'])
        }
      }
      return labels.join(', ')
    },
    projectId: function () {
      let ids = []
      if (this.o['skos:exactMatch']) {
        for (let id of this.o['skos:exactMatch']) {
          ids.push(id)
        }
      }
      return ids.join(', ')
    },
    id: function () {
      let id = []
      if (this.projectLabel !== '') {
        id.push(this.projectLabel)
      }
      if (this.projectId !== '') {
        id.push(this.projectId)
      }
      if (this.fundersLabel !== '') {
        id.push(this.fundersLabel)
      }
      return id.join(' – ')
    }
  }
}
</script>
