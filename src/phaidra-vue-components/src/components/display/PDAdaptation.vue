<template>
  <v-row>
    <v-col :md="labelColMd" cols="12" class="pdlabel text-secondary font-weight-bold text-md-right">{{ $t(p) }}</v-col>
    <v-col :md="valueColMd" cols="12">
      <v-card tile elevation="0" color="transparent">
        <v-card-text class="jsonld-border-left">
          <v-container fluid>
            <v-row>
              <template v-for="(title, j) in o['dce:title']" :key="'title' + j">
                <template v-for="(mt, i) in title['bf:mainTitle']" :key="'mt' + j + '-' + i">
                  <v-col md="2" cols="12" class="pdlabel text-secondary font-weight-bold">
                    {{ $t(title['@type']) }}<template v-if="showLang && mt['@language']"> ({{ mt['@language'] }})</template>
                  </v-col>
                  <v-col md="10" cols="12">
                    <v-row class="valuefield">{{ mt['@value'] }}</v-row>
                    <template v-for="(st, si) in title['bf:subtitle']" :key="'st' + j + '-' + i + '-' + si">
                      <v-row class="valuefield">{{ st['@value'] }}</v-row>
                    </template>
                  </v-col>
                </template>
              </template>
            </v-row>

            <v-row v-for="(obj, pred, i) in o" :key="'role' + i">
              <template v-if="pred.startsWith('role')">
                <v-col md="2" cols="12" class="pdlabel text-secondary font-weight-bold">{{ getLocalizedTermLabel('rolepredicate', pred) }}</v-col>
                <v-col md="10" cols="12">
                  <v-row v-for="(n, ri) in obj" :key="'adpname' + ri">
                    <template v-for="(gn, gni) in n['schema:givenName']" :key="'adgn-'+ri+'-'+gni" class="valuefield">{{ gn['@value'] }}</template>
                    <template v-for="(fn, fni) in n['schema:familyName']" :key="'adfn-'+ri+'-'+fni" class="valuefield"> {{ fn['@value'] }}</template>
                    <template v-for="(nm, nmi) in n['schema:name']" :key="'adnm-'+ri+'-'+nmi" class="valuefield"> {{ nm['@value'] }}</template>
                    <template v-if="n['schema:affiliation']" class="text-secondary">
                      <template v-for="(af, afi) in n['schema:affiliation']" :key="'adaff-'+ri+'-'+afi">
                        <template v-for="(afn, afnk) in af" :key="'adafn-'+ri+'-'+afi+'-'+afnk" class="valuefield"> {{ afn['@value'] }}</template>
                      </template>
                    </template>
                  </v-row>
                </v-col>
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
  }
}
</script>
