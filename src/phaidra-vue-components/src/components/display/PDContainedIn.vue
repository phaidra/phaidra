<template>
  <v-row>
    <v-col :md="labelColMd" cols="12" class="pdlabel primary--text text-md-right">{{ $t(p) }}</v-col>
    <v-col :md="valueColMd" cols="12">
      <v-card tile elevation="0">
        <v-card-text class="jsonld-border-left">
          <v-container fluid>
            <v-row>
              <template v-for="(title, j) in o['dce:title']">
                <template v-for="(mt, i) in title['bf:mainTitle']">
                  <v-col md="3" cols="12" class="pdlabel primary--text" :key="'mt'+j+i">{{ $t(title['@type']) }}<template v-if="showLang && mt['@language']"> ({{ mt['@language'] }})</template></v-col>
                  <v-col md="9" cols="12" :key="'mtv'+j+i">
                    <v-row no-gutters class="valuefield">{{ mt['@value'] }}</v-row>
                    <v-row v-for="(st, k) in title['bf:subtitle']" no-gutters class="valuefield" :key="'stv'+k">{{ st['@value'] }}</v-row>
                  </v-col>
                </template>
              </template>
            </v-row>
            <template v-if="o.hasOwnProperty('ids:isbn')">
              <v-row v-for="(isbn, i) in o['ids:isbn']" :key="'isbn'+i">
                <v-col md="3" cols="12" class="pdlabel primary--text">{{ getLocalizedTermLabel('objectidentifiertype', 'ids:isbn') }}</v-col>
                <v-col md="9" cols="12" class="valuefield">{{ isbn }}</v-col>
              </v-row>
            </template>
            <v-row v-for="(id, i) in o['skos:exactMatch']" :key="'identifier'+i">
              <v-col md="3" cols="12" class="pdlabel primary--text">{{ getLocalizedTermLabel('objectidentifiertype', id['@type']) }}</v-col>
              <v-col md="9" cols="12" v-if="getIDResolverURL(id)"><a :href="getIDResolverURL(id)" target="_blank">{{ id['@value'] }}</a></v-col>
            </v-row>
            <v-row v-for="(obj, pred, i) in o" :key="'role' + i">
              <template v-if="pred.startsWith('role')">
                <v-col md="3" cols="12" class="pdlabel primary--text ">{{ getLocalizedTermLabel('rolepredicate', pred) }}</v-col>
                <v-col md="9" cols="12">
                  <v-row no-gutters v-for="(n, i) in obj" :key="'adpname' + i">
                    <template class="valuefield" v-for="(gn) in n['schema:givenName']">{{ gn['@value'] }}</template>
                    <template class="valuefield" v-for="(fn) in n['schema:familyName']"> {{ fn['@value'] }}</template>
                    <template class="valuefield" v-for="(fn) in n['schema:name']"> {{ fn['@value'] }}</template>
                    <template v-if="n['schema:affiliation']" class="grey--text">
                      <template v-for="(af) in n['schema:affiliation']">
                        <template class="valuefield" v-for="(afn) in af"> {{ afn['@value'] }}</template>
                      </template>
                    </template>
                  </v-row>
                </v-col>
              </template>
            </v-row>
            <v-row v-for="(series, k) in o['rdau:P60193']" :key="'series'+k">
              <v-col md="3" cols="12" class="pdlabel primary--text">{{ $t('rdau:P60101_rdau:P60193') }}</v-col>
              <v-col md="9" cols="12">
                <v-card tile elevation="0">
                  <v-card-text class="jsonld-border-left">
                    <v-container>
                      <v-row :key="'stit'+k">
                        <template v-for="(title, j) in series['dce:title']">
                          <template v-for="(mt, i) in title['bf:mainTitle']">
                            <v-col md="3" cols="12" class="pdlabel primary--text" :key="'mt'+j+i">{{ $t(title['@type']) }}<template v-if="showLang && mt['@language']"> ({{ mt['@language'] }})</template></v-col>
                            <v-col md="9" cols="12" :key="'mtv'+j+i" class="valuefield">{{ mt['@value'] }}</v-col>
                          </template>
                        </template>
                      </v-row>
                      <v-row :key="'svol'+k">
                        <template v-for="(volume, i) in series['bibo:volume']">
                          <v-col md="3" cols="12" class="pdlabel primary--text" :key="'vl'+i">{{ $t('Volume') }}</v-col>
                          <v-col md="9" cols="12" class="valuefield" :key="'v'+i">{{ volume }}</v-col>
                        </template>
                      </v-row>
                      <v-row :key="'sissue'+k">
                        <template v-for="(issue, i) in series['bibo:issue']">
                          <v-col md="3" cols="12"  class="pdlabel primary--text" :key="'il'+i">{{ $t('Issue') }}</v-col>
                          <v-col md="9" cols="12" class="valuefield" :key="'i'+i">{{ issue }}</v-col>
                        </template>
                      </v-row>
                      <v-row :key="'sissued'+k">
                        <template v-for="(issued, i) in series['dcterms:issued']">
                          <v-col md="3" cols="12" class="pdlabel primary--text" :key="'idatel'+i">{{ $t('Issued') }}</v-col>
                          <v-col md="9" cols="12" class="valuefield" :key="'idate'+i">{{ issued }}</v-col>
                        </template>
                      </v-row>
                      <v-row :key="'sissn'+k">
                        <template v-for="(issn, i) in series['ids:issn']">
                          <v-col md="3" cols="12" class="pdlabel primary--text" :key="'isl'+i">{{ $t('ISSN') }}</v-col>
                          <v-col md="9" cols="12" class="valuefield" :key="'is'+i">{{ issn }}</v-col>
                        </template>
                      </v-row>
                      <v-row v-for="(id, i) in series['skos:exactMatch']" :key="'sid'+i">
                        <v-col md="3" cols="12" class="pdlabel primary--text">{{ getLocalizedTermLabel('objectidentifiertype', id['@type']) }}</v-col>
                        <v-col md="9" cols="12" v-if="getIDResolverURL(id)"><a :href="getIDResolverURL(id)" target="_blank">{{ id['@value'] }}</a></v-col>
                      </v-row>
                    </v-container>
                  </v-card-text>
                </v-card>
              </v-col>
            </v-row>
            <v-row v-for="(pub, k) in o['bf:provisionActivity']" :key="'pub'+k">
              <v-col md="3" cols="12" class="pdlabel primary--text">{{ $t('rdau:P60101_bf:provisionActivity') }}</v-col>
              <v-col md="9" cols="12">
                <template v-for="(publisher, i) in pub['bf:agent']">
                  <template v-if="localizedOrgUnit(publisher)">
                    <a :key="'publname'+i" class="valuefield" :href="localizedOrgUnit(publisher).id" target="_blank">{{ localizedOrgUnit(publisher).value }}</a>
                  </template>
                  <template v-else v-for="(publishername, i) in publisher['schema:name']">
                    <span :key="'publname'+i" class="valuefield">{{ publishername['@value'] }}</span>
                  </template>
                </template>
                <template v-for="(publishingplace, j) in pub['bf:place']">
                  <template v-for="(place, i) in publishingplace['skos:prefLabel']">
                    <span class="valuefield" :key="'publplace'+j+i">, {{ place['@value'] }}</span>
                  </template>
                </template>
                <template v-for="(publishingdate, j) in pub['bf:date']">
                    <span :key="'publdate'+j">, {{ publishingdate }}</span>
                </template>
              </v-col>
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
  name: 'p-d-series',
  mixins: [vocabulary, displayproperties],
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
        for (let name of orgUnit['schema:name']) {
          if (name['@language'] === this.$i18n.locale) {
            return {
              value: name['@value'],
              language: name['@language'],
              id: orgUnit['skos:exactMatch']
            }
          }
        }
        return {
          name: orgUnit['schema:name'][0]['@value'],
          language: orgUnit['schema:name'][0]['@language'],
          id: orgUnit['schema:name'][0]['skos:exactMatch']
        }
      }
      return null
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