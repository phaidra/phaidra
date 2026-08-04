<template>
 <v-row v-if="maxRowLen()">
  <v-col :md="labelColMd" cols="12" class="pdlabel text-secondary font-weight-bold text-md-right">{{$t('Accessibility')}}</v-col>
  <v-col class="valuefield" :md="valueColMd" cols="12">
    <table border="1">
        <thead>
          <tr>
            <template v-for="(value, key) in o" :key="key">
              <th v-if="value && value.length" class="text-secondary font-weight-bold">{{ $t(key) }}</th>
            </template>
          </tr>
        </thead>
        <tbody>
          <tr v-for="(row, index) in new Array(maxRowLen())" :key="index">
            <template v-for="(value, key) in o" :key="key">
              <td v-if="value && value.length">{{ getValue(value, index, $i18n.locale) }}</td>
            </template>
          </tr>
        </tbody>
      </table>
  </v-col>
 </v-row>
</template>

<script>
import { displayproperties } from '../../mixins/displayproperties'
import { vocabulary } from '../../mixins/vocabulary'

export default {
  name: 'p-d-accessibility',
  mixins: [displayproperties, vocabulary],
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
    maxRowLen() {
      return Math.max(this.o?.control?.length, this.o?.feature?.length, this.o?.hazard?.length, this.o?.mode?.length);
    },
    getValue(value, index, lang) {
      if(value &&
        value[index] &&
        value[index]['skos:prefLabel'] &&
        value[index]['skos:prefLabel']){
          let langIndex = value[index]['skos:prefLabel'].findIndex(x => x['@language'] === lang)
          return value[index]['skos:prefLabel'][langIndex >= 0 ? langIndex : 0]['@value'] || ''
      } else {
        return ''
      }
    }
  }
}
</script>
<style scoped>
table {
  width: 100%;
  border-collapse: collapse;
}
th, td {
  padding: 8px;
  text-align: left;
}
</style>
