<template>
  
    <v-row>
      <template v-if="funderAndProjIdOnly">
        <v-col :md="labelColMd" cols="12" class="pdlabel primary--text text-md-right"><span v-if="!hideLabel">{{ $t('Funder') }}</span></v-col>
        <v-col :md="valueColMd" cols="12">
          <v-row v-for="(funder, i) in o['frapo:hasFundingAgency']">
            <span v-for="(ft, j) in funder['skos:prefLabel']" :key="'ft'+i+j">
              <template v-if="funder['skos:exactMatch']">
                <template v-for="(fid, k) in funder['skos:exactMatch']">
                  <template v-if="fid['@value']">
                    <span :key="'idzf'+i+j+k"><a :href="getIDResolverURL(fid)" target="_blank">{{ ft['@value'] }}</a></span>
                  </template>
                  <template v-else>
                    <span :key="'idzx'+i+j+k"><a :href="fid" target="_blank">{{ ft['@value'] }}</a></span>
                  </template>
                </template>
              </template>
              <span v-else class="valuefield">{{ ft['@value'] }}</span>
            </span>
            <span v-for="(id, i) in o['skos:exactMatch']" :key="'idprojxv'+i">
              <span class="mx-4">—</span>
              <span v-if="id['@value']"><a :href="getIDResolverURL(id)" target="_blank">{{ id['@value'] }}</a></span>
              <span v-else >{{ id }}</span>
            </span>
          </v-row>
        </v-col>
      </template>
      <template v-else>
        <v-col :md="labelColMd" cols="12" class="pdlabel primary--text text-md-right">{{ $t('Project') }}</v-col>
        <v-col :md="valueColMd" cols="12">
          <v-card tile elevation="0">
            <v-card-text class="jsonld-border-left">
              <v-row v-for="(t, i) in o['skos:prefLabel']"  :key="'projpreflab'+i">
                <v-col :md="3" cols="12" class="pdlabel primary--text">{{ $t('Titel') }}<template v-if="t['@language']"> ({{ t['@language'] }})</template></v-col>
                <v-col :md="9" cols="12" class="valuefield">{{ t['@value'] }}</v-col>
              </v-row>
              <v-row v-for="(d, i) in o['frapo:hasProjectIdentifier']" :key="'ddsl'+i">
                <v-col :md="3" cols="12" class="pdlabel primary--text" >{{ $t('Code / Identifier') }}</v-col>
                <v-col :md="9" cols="12" class="valuefield">{{ d }}</v-col>
              </v-row>
              <v-row v-for="(ac, i) in o['frapo:hasAcronym']" :key="'ac'+i">
                <v-col :md="3" cols="12" class="pdlabel primary--text" >{{ $t('Acronym') }}</v-col>
                <v-col :md="9" cols="12">{{ ac }}</v-col>
              </v-row>
              <v-row>
                <template v-for="(id, i) in o['skos:exactMatch']">
                  <template v-if="id['@value']">
                    <v-col :md="3" cols="12" class="pdlabel primary--text" :key="'idproj'+i">{{ $t('Project') }} {{ getLocalizedTermLabel('objectidentifiertype', id['@type']) }}</v-col>
                    <v-col :md="9" cols="12" :key="'idproj'+i"><a :href="getIDResolverURL(id)" target="_blank">{{ id['@value'] }}</a></v-col>
                  </template>
                  <template v-else>
                    <v-col :md="3" cols="12" class="pdlabel primary--text" :key="'idprojxl'+i">{{ $t('Project identifier') }}</v-col>
                    <v-col :md="9" cols="12" :key="'idprojxv'+i">{{ id }}</v-col>
                  </template>
                </template>
              </v-row>
              <template v-for="(funder, i) in o['frapo:hasFundingAgency']">
                <v-row v-for="(ft, j) in funder['skos:prefLabel']":key="'ft'+i+j">
                  <v-col :md="3" cols="12" class="pdlabel primary--text">{{ $t('Funder') }}<template v-if="ft['@language']"> ({{ ft['@language'] }})</template></v-col>
                  <template v-if="funder['skos:exactMatch']">
                    <template v-for="(fid, k) in funder['skos:exactMatch']">
                      <template v-if="fid['@value']">
                        <v-col :md="9" cols="12" :key="'idzf'+i+j+k"><a :href="getIDResolverURL(fid)" target="_blank">{{ ft['@value'] }}</a></v-col>
                      </template>
                      <template v-else>
                        <v-col :md="9" cols="12" :key="'idzx'+i+j+k"><a :href="fid" target="_blank">{{ ft['@value'] }}</a></v-col>
                      </template>
                    </template>
                  </template>
                  <v-col v-else :md="9" cols="12" class="valuefield">{{ ft['@value'] }}</v-col>
                </v-row>
              </template>
              <v-row v-for="(d, i) in o['rdfs:comment']" :key="'dl'+i">
                <v-col :md="3" cols="12" class="pdlabel primary--text" >{{ $t('Project Description') }}<template v-if="d['@language']"> ({{ d['@language'] }})</template></v-col>
                <v-col class="valuefield" :md="9" cols="12">{{ d['@value'] }}</v-col>
              </v-row>
              <v-row v-for="(sd, i) in o['frapo:hasStartDate']" :key="'dfl'+i">
                <v-col :md="3" cols="12" class="pdlabel primary--text" >{{ $t('Start date') }}</v-col>
                <v-col class="valuefield" :md="9" cols="12">{{ sd }}</v-col>
              </v-row>
              <v-row v-for="(ed, i) in o['frapo:hasEndDate']" :key="'dtl'+i">
                <v-col :md="3" cols="12" class="pdlabel primary--text" >{{ $t('End date') }}</v-col>
                <v-col class="valuefield" :md="9" cols="12">{{ ed }}</v-col>
              </v-row>
              <v-row v-for="(hp, i) in o['foaf:homepage']" :key="'hpl'+i">
                <v-col :md="3" cols="12" class="pdlabel primary--text" >{{ $t('Project Homepage') }}</v-col>
                <v-col :md="9" cols="12"><a :href="hp">{{ hp }}</a></v-col>
              </v-row>
            </v-card-text>
          </v-card>
        </v-col>
      </template>
    </v-row>
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
    funderAndProjIdOnly: function () {
      Object.keys(this.o).forEach(name => {   
        if ((name !== 'frapo:hasFundingAgency') && (name !== 'skos:exactMatch')) {
          return false
        }
      })
      return true
    }
  }
}
</script>

<style>
.jsonld-border-left {
  border-left: 1px solid;
  border-color: rgba(0, 0, 0, 0.12);
}
</style>