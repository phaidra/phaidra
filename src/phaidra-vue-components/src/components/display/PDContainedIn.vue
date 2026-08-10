<template>
  <v-row>
    <v-col :md="labelColMd" cols="12" class="pdlabel text-secondary font-weight-bold text-md-right">{{ $t(p) }}</v-col>
    <v-col :md="valueColMd" cols="12">
      <v-card tile elevation="0" color="transparent">
        <v-card-text class="jsonld-border-left">
          <v-container fluid>
            <v-row>
              <template v-for="(title, j) in o['dce:title']" :key="'ctitle' + j">
                <template v-for="(mt, i) in title['bf:mainTitle']" :key="'cmt' + j + '-' + i">
                  <v-col md="3" cols="12" class="pdlabel text-secondary font-weight-bold">
                    {{ $t(title['@type']) }}<template v-if="showLang && mt['@language']"> ({{ mt['@language'] }})</template>
                  </v-col>
                  <v-col md="9" cols="12">
                    <v-row no-gutters class="valuefield">{{ mt['@value'] }}</v-row>
                    <v-row v-for="(st, k) in title['bf:subtitle']" no-gutters class="valuefield" :key="'stv'+j+'-'+i+'-'+k">{{ st['@value'] }}</v-row>
                  </v-col>
                </template>
              </template>
            </v-row>

            <template v-if="o.hasOwnProperty('ids:isbn')">
              <v-row v-for="(isbn, i) in o['ids:isbn']" :key="'isbn'+i">
                <v-col md="3" cols="12" class="pdlabel text-secondary font-weight-bold">{{ getLocalizedTermLabel('objectidentifiertype', 'ids:isbn') }}</v-col>
                <v-col md="9" cols="12" class="valuefield">{{ isbn }}</v-col>
              </v-row>
            </template>

            <template v-if="o.hasOwnProperty('skos:exactMatch')">
              <v-row v-for="(id, i) in o['skos:exactMatch']" :key="'identifier'+i">
                <v-col md="3" cols="12" class="pdlabel text-secondary font-weight-bold">{{ getLocalizedTermLabel('objectidentifiertype', id['@type']) }}</v-col>
                <v-col md="9" cols="12" v-if="getIDResolverURL(id)">
                  <a :href="getIDResolverURL(id)" target="_blank">{{ id['@value'] }}</a>
                </v-col>
              </v-row>
            </template>

            <v-row v-for="(obj, pred, i) in o" :key="'role' + i">
              <template v-if="pred.startsWith('role')">
                <v-col md="3" cols="12" class="pdlabel text-secondary font-weight-bold">{{ getLocalizedTermLabel('rolepredicate', pred) }}</v-col>
                <v-col md="9" cols="12">
                  <v-row no-gutters v-for="(n, ri) in obj" :key="'adpname' + ri">
                    <template v-for="(gn, gni) in n['schema:givenName']" :key="'cgn-'+ri+'-'+gni" class="valuefield">{{ gn['@value'] }}</template>
                    <template v-if="n['schema:givenName']?.length && n['schema:familyName']?.length">{{ ' ' }}</template>
                    <template v-for="(fn, fni) in n['schema:familyName']" :key="'cfn-'+ri+'-'+fni" class="valuefield">{{ fn['@value'] }}</template>
                    <template v-for="(nm, nmi) in n['schema:name']" :key="'cnm-'+ri+'-'+nmi" class="valuefield"> {{ nm['@value'] }}</template>
                    <template v-if="n['schema:affiliation']" class="text-secondary">
                      <template v-for="(af, afi) in n['schema:affiliation']" :key="'caff-'+ri+'-'+afi">
                        <template v-for="(afn, afnk) in af" :key="'cafn-'+ri+'-'+afi+'-'+afnk" class="valuefield"> {{ afn['@value'] }}</template>
                      </template>
                    </template>
                  </v-row>
                </v-col>
              </template>
            </v-row>

            <v-row v-for="(series, k) in o['rdau:P60193']" :key="'series'+k">
              <v-col md="3" cols="12" class="pdlabel text-secondary font-weight-bold">{{ $t('rdau:P60101_rdau:P60193') }}</v-col>
              <v-col md="9" cols="12">
                <v-card tile elevation="0">
                  <v-card-text class="jsonld-border-left">
                    <v-container>
                      <v-row>
                        <template v-for="(title, j) in series['dce:title']" :key="'stitle' + k + '-' + j">
                          <template v-for="(mt, i) in title['bf:mainTitle']" :key="'smt' + k + '-' + j + '-' + i">
                            <v-col md="3" cols="12" class="pdlabel text-secondary font-weight-bold">{{ $t(title['@type']) }}<template v-if="showLang && mt['@language']"> ({{ mt['@language'] }})</template></v-col>
                            <v-col md="9" cols="12" class="valuefield">{{ mt['@value'] }}</v-col>
                          </template>
                        </template>
                      </v-row>
                      <v-row>
                        <template v-for="(volume, i) in series['bibo:volume']" :key="'svol' + k + '-' + i">
                          <v-col md="3" cols="12" class="pdlabel text-secondary font-weight-bold">{{ $t('Volume') }}</v-col>
                          <v-col md="9" cols="12" class="valuefield">{{ volume['@value'] || volume }}</v-col>
                        </template>
                      </v-row>
                      <v-row>
                        <template v-for="(issue, i) in series['bibo:issue']" :key="'sissue' + k + '-' + i">
                          <v-col md="3" cols="12" class="pdlabel text-secondary font-weight-bold">{{ $t('Issue') }}</v-col>
                          <v-col md="9" cols="12" class="valuefield">{{ issue['@value'] || issue }}</v-col>
                        </template>
                      </v-row>
                      <v-row>
                        <template v-for="(issued, i) in series['dcterms:issued']" :key="'sissued' + k + '-' + i">
                          <v-col md="3" cols="12" class="pdlabel text-secondary font-weight-bold">{{ $t('Issued') }}</v-col>
                          <v-col md="9" cols="12" class="valuefield">{{ issued }}</v-col>
                        </template>
                      </v-row>
                      <v-row>
                        <template v-for="(issn, i) in series['ids:issn']" :key="'sissn' + k + '-' + i">
                          <v-col md="3" cols="12" class="pdlabel text-secondary font-weight-bold">{{ $t('ISSN') }}</v-col>
                          <v-col md="9" cols="12" class="valuefield">{{ issn }}</v-col>
                        </template>
                      </v-row>
                      <v-row v-for="(id, i) in series['skos:exactMatch']" :key="'sid'+k+'-'+i">
                        <v-col md="3" cols="12" class="pdlabel text-secondary font-weight-bold">{{ getLocalizedTermLabel('objectidentifiertype', id['@type']) }}</v-col>
                        <v-col md="9" cols="12" v-if="getIDResolverURL(id)"><a :href="getIDResolverURL(id)" target="_blank">{{ id['@value'] }}</a></v-col>
                      </v-row>
                    </v-container>
                  </v-card-text>
                </v-card>
              </v-col>
            </v-row>

            <v-row v-for="(pub, k) in o['bf:provisionActivity']" :key="'pub'+k">
              <v-col md="3" cols="12" class="pdlabel text-secondary font-weight-bold">{{ $t('rdau:P60101_bf:provisionActivity') }}</v-col>
              <v-col md="9" cols="12">
                <template v-for="(publisher, i) in pub['bf:agent']" :key="'agent' + k + '-' + i">
                  <template v-if="localizedOrgUnit(publisher)">
                    <a class="valuefield" :href="localizedOrgUnit(publisher).id" target="_blank">{{ localizedOrgUnit(publisher).value }}</a>
                  </template>
                  <template v-else>
                    <template v-for="(publishername, ni) in publisher['schema:name']" :key="'pname' + k + '-' + i + '-' + ni">
                      <span class="valuefield">{{ publishername['@value'] }}</span>
                    </template>
                  </template>
                </template>
                <template v-for="(publishingplace, j) in pub['bf:place']" :key="'pplace' + k + '-' + j">
                  <template v-for="(place, i) in publishingplace['skos:prefLabel']" :key="'pl' + k + '-' + j + '-' + i">
                    <span class="valuefield">, {{ place['@value'] }}</span>
                  </template>
                </template>
                <template v-for="(publishingdate, j) in pub['bf:date']" :key="'pdate' + k + '-' + j">
                  <span>, {{ publishingdate }}</span>
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