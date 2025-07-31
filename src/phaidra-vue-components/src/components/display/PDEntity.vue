<template>
  <v-row v-if="entity">
    <v-col :md="labelColMd" cols="12" class="pdlabel secondary--text font-weight-bold text-md-right"><span v-show="!hideLabel">{{ getLocalizedTermLabel(this.role) }}</span></v-col>
    <v-col :md="valueColMd" cols="12">
      <template v-if="entity['@type'] === 'schema:Person'">
        <template v-if="entity['skos:exactMatch']">
          <template v-if="entity['skos:exactMatch'].length === 1">
            <a class="valuefield" :class="{ 'font-weight-regular': boldLabelFields.includes('role') }" :href="getIDResolverURL(entity['skos:exactMatch'][0])" target="_blank">
              <icon width="16px" height="16px" class="mr-1 mb-1" v-if="entity['skos:exactMatch'][0]['@type'] === 'ids:orcid'" name="orcid"></icon><template class="valuefield" v-for="(gn) in entity['schema:givenName']">{{ gn['@value'] }}</template><template class="valuefield" v-for="(fn) in entity['schema:familyName']"> {{ fn['@value'] }}</template><template class="valuefield" v-for="(n) in entity['schema:name']">{{ n['@value'] }}</template>
            </a>
          </template>
          <template v-else-if="entity['skos:exactMatch'].length > 1">
            <a class="valuefield" :class="{ 'font-weight-regular': boldLabelFields.includes('role') }" :href="getIDResolverURL(entity['skos:exactMatch'][0])" target="_blank">
              <template class="valuefield" v-for="(gn) in entity['schema:givenName']">{{ gn['@value'] }}</template><template class="valuefield" v-for="(fn) in entity['schema:familyName']"> {{ fn['@value'] }}</template><template class="valuefield" v-for="(n) in entity['schema:name']">{{ n['@value'] }}</template>
            </a>
          </template>
        </template>
        <template v-else>
          <template v-for="(gn) in entity['schema:givenName']"><span class="valuefield" :class="{ 'font-weight-regular': boldLabelFields.includes('role') }">{{ gn['@value'] }}</span></template><template v-for="(fn) in entity['schema:familyName']"><span class="valuefield" :class="{ 'font-weight-regular': boldLabelFields.includes('role') }"> {{ fn['@value'] }}</span></template><template v-for="(n) in entity['schema:name']"><span class="valuefield" :class="{ 'font-weight-regular': boldLabelFields.includes('role') }">{{ n['@value'] }}</span></template>
        </template>
        <template v-if="entity['schema:affiliation']" class="secondary--text">
          <br/>
          <div>
            <template v-for="(af, i) in entity['schema:affiliation']">
              <template v-if="af['skos:exactMatch'] && univieAffiliation">
                {{ ' ' }}<a :key="'afuw'+i" class="valuefield" :href="af['skos:exactMatch'][0]" target="_blank">{{ univieAffiliation }}</a>
              </template>
              <template v-else>
                <template v-if="af['skos:exactMatch']">
                  {{ ' ' }}<a :key="'af'+i" class="valuefield" :href="af['skos:exactMatch'][0]" target="_blank">{{ af['schema:name'][0]['@value'] }}</a>
                </template>
                <template v-else>
                  {{ ' ' }}<template v-for="(afname, i) in af['schema:name']"><template v-if="i>0"> / </template>{{ afname['@value'] }}</template>
                </template>
              </template>
            </template>
          </div>
        </template>
      </template>
      <template v-if="entity['@type'] === 'schema:Organization'">
        <template v-if="(typeof entity['skos:exactMatch'] === 'string') && entity['skos:exactMatch'][0].startsWith('https://pid.phaidra.org/univie-org')">
          {{ ' ' }}<a class="valuefield" :href="entity['skos:exactMatch'][0]" target="_blank">{{ getLocalizedValue(entity['schema:name']) }}</a>
        </template>
        <template v-else-if="entity['skos:exactMatch']">
          {{ ' ' }}<a class="valuefield" :href="typeof entity['skos:exactMatch'][0] === 'string' ? entity['skos:exactMatch'][0] : getIDResolverURL(entity['skos:exactMatch'][0])" target="_blank">{{ entity['schema:name'][0]['@value'] }}</a>
        </template>
        <template v-else>
          <template class="valuefield" v-for="(corpname) in entity['schema:name']">{{ corpname['@value'] }}</template>
        </template>
      </template>
    </v-col>
  </v-row>
</template>

<script>
import '@/compiled-icons/orcid'
import { vocabulary } from '../../mixins/vocabulary'
import { displayproperties } from '../../mixins/displayproperties'

export default {
  name: 'p-d-entity',
  mixins: [vocabulary, displayproperties],
  props: {
    entity: {
      type: Object,
      required: true
    },
    role: {
      type: String,
      required: true
    },
    hideLabel: {
      type: Boolean,
      defualt: false
    }
  },
  computed: {
    univieAffiliation: function () {
      if (this.entity['@type'] === 'schema:Person') {
        if (this.entity.hasOwnProperty('schema:affiliation')) {
          for (let af of this.entity['schema:affiliation']) {
            if (af.hasOwnProperty('skos:exactMatch')) {
              for (let id of af['skos:exactMatch']) {
                if (id.startsWith('https://pid.phaidra.org/univie-org')) {
                  let affiliationPath = []
                  if (this.$store.state.vocabulary) { // does not work in old phaidra
                    this.getOrgPath(this.getTerm('orgunits', id), this.vocabularies['orgunits'].tree, affiliationPath)
                  }
                  let pathLabels = []
                  for (let u of affiliationPath) {
                    // skip division "Faculties and Centers"
                    if (u['@id'] !== 'https://pid.phaidra.org/univie-org/1DVY-S9TG') {
                      pathLabels.push(u['skos:prefLabel'][this.$i18n.locale])
                    }
                  }
                  return pathLabels.join(', ')
                }
              }
            }
          }
        }
      }
      return ''
    }
  },
  methods: {
    getLocalizedTermLabel: function (role) {
      return this.$store.getters['vocabulary/getLocalizedTermLabel']('rolepredicate', role, this.$i18n.locale)
    }
  },
  mounted: function () {
    this.$nextTick(function () {
      this.$store.dispatch('vocabulary/loadOrgUnits', this.$i18n.locale)
    })
  }
}
</script>
