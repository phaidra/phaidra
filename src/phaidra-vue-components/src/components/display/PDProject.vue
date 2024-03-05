<template>
  <span>
    <v-row>
      <div v-if="o['skos:exactMatch'] || o['skos:prefLabel'] || o['frapo:hasFundingAgency']">
        <v-col :md="labelColMd" cols="12" class="pdlabel primary--text text-md-right" :key="'idl'"><span v-show="!hideLabel && !o['rdfs:comment'] && !o['foaf:homepage']">{{ $t(p) }}</span></v-col>
        <v-col :md="valueColMd" cols="12" :key="'idv'"><template v-if="projectLabel !== ''">{{ projectLabel }} – </template><template v-if="projectId !== ''"><template v-if="projectId.startsWith('http')"><a target="_blank" :href="projectId">{{ projectId }}</a></template><template v-else>{{ projectId }}</template></template><template v-if="fundersLabel !== ''"> – {{ fundersLabel }}</template></v-col>
      </div>
    </v-row>
    <v-row>
      <div v-for="(ac, i) in o['frapo:hasAcronym']" :key="'ac'+i">
        <v-col :md="labelColMd" cols="12" class="pdlabel primary--text text-md-right" >{{ $t('Acronym') }}</v-col>
        <v-col :md="valueColMd" cols="12">{{ ac }}</v-col>
      </div>
    </v-row>
    <v-row>
      <div v-for="(d, i) in o['rdfs:comment']" :key="'dl'+i">
        <v-col :md="labelColMd" cols="12" class="pdlabel primary--text text-md-right" >{{ $t('Project Description') }} ({{ d['@language'] }})</v-col>
        <v-col class="valuefield" :md="valueColMd" cols="12">{{ d['@value'] }}</v-col>
      </div>
    </v-row>
    <v-row>
      <div v-for="(sd, i) in o['frapo:hasStartDate']" :key="'dfl'+i">
        <v-col :md="labelColMd" cols="12" class="pdlabel primary--text text-md-right" >{{ $t('Start date') }}</v-col>
        <v-col class="valuefield" :md="valueColMd" cols="12">{{ sd }}</v-col>
      </div>
    </v-row>
    <v-row>
      <div v-for="(ed, i) in o['frapo:hasEndDate']" :key="'dtl'+i">
        <v-col :md="labelColMd" cols="12" class="pdlabel primary--text text-md-right" >{{ $t('End date') }}</v-col>
        <v-col class="valuefield" :md="valueColMd" cols="12">{{ ed }}</v-col>
      </div>
    </v-row>
    <v-row>
      <div v-for="(hp, i) in o['foaf:homepage']" :key="'hpl'+i">
        <v-col :md="labelColMd" cols="12" class="pdlabel primary--text text-md-right" >{{ $t('Project Homepage') }}</v-col>
        <v-col :md="valueColMd" cols="12">{{ hp }}</v-col>
      </div>
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
    }
  }
}
</script>
