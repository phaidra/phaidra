<template>
  <v-row v-if="entity">
    <v-col :md="labelColMd" cols="12" class="pdlabel text-secondary font-weight-bold text-md-right"><span v-show="!hideLabel">{{ getLocalizedTermLabel(this.role) }}</span></v-col>
    <v-col :md="valueColMd" cols="12">
      <template v-if="entity['@type'] === 'schema:Person'">
        <template v-if="entity['skos:exactMatch']">
          <template v-if="entity['skos:exactMatch'].length === 1">
            <a class="valuefield" :class="{ 'font-weight-regular': boldLabelFields.includes('role') }" :href="getIDResolverURL(entity['skos:exactMatch'][0])" target="_blank">
              <icon width="16px" height="16px" class="mr-1 mb-1" v-if="entity['skos:exactMatch'][0]['@type'] === 'ids:orcid'" name="orcid"></icon><template v-for="(gn, gni) in entity['schema:givenName']" :key="'gn-'+gni" class="valuefield">{{ gn['@value'] }}</template><template v-for="(fn, fni) in entity['schema:familyName']" :key="'fn-'+fni" class="valuefield"> {{ fn['@value'] }}</template><template v-for="(n, ni) in entity['schema:name']" :key="'nm-'+ni" class="valuefield">{{ n['@value'] }}</template>
            </a>
<template class="valuefield">{{ formatBirthDeathDate() }}</template>
          </template>
          <template v-else-if="entity['skos:exactMatch'].length > 1">
            <a class="valuefield" :class="{ 'font-weight-regular': boldLabelFields.includes('role') }" :href="getIDResolverURL(entity['skos:exactMatch'][0])" target="_blank">
              <template v-for="(gn, gni) in entity['schema:givenName']" :key="'gn2-'+gni" class="valuefield">{{ gn['@value'] }}</template><template v-for="(fn, fni) in entity['schema:familyName']" :key="'fn2-'+fni" class="valuefield"> {{ fn['@value'] }}</template><template v-for="(n, ni) in entity['schema:name']" :key="'nm2-'+ni" class="valuefield">{{ n['@value'] }}</template>
            </a>
            <template class="valuefield">{{ formatBirthDeathDate() }}</template>
          </template>
        </template>
        <template v-else>
          <template v-for="(gn, gni) in entity['schema:givenName']" :key="'gn3-'+gni"><span class="valuefield" :class="{ 'font-weight-regular': boldLabelFields.includes('role') }">{{ gn['@value'] }}</span></template><template v-for="(fn, fni) in entity['schema:familyName']" :key="'fn3-'+fni"><span class="valuefield" :class="{ 'font-weight-regular': boldLabelFields.includes('role') }"> {{ fn['@value'] }}</span></template><template v-for="(n, ni) in entity['schema:name']" :key="'nm3-'+ni"><span class="valuefield" :class="{ 'font-weight-regular': boldLabelFields.includes('role') }">{{ n['@value'] }}</span></template>
          <template class="valuefield">{{ formatBirthDeathDate() }}</template>
        </template>
        <template v-if="entity['schema:affiliation']" class="text-secondary">
          <br/>
          <div>
            <template v-for="(af, afi) in entity['schema:affiliation']" :key="'aff-'+afi">
              <template v-if="af['skos:exactMatch'] && univieAffiliation">
                {{ ' ' }}<a class="valuefield" :href="af['skos:exactMatch'][0]" target="_blank">{{ univieAffiliation }}</a>
              </template>
              <template v-else>
                <template v-if="af['skos:exactMatch']">
                  {{ ' ' }}<a class="valuefield" :href="af['skos:exactMatch'][0]" target="_blank">{{ af['schema:name'][0]['@value'] }}</a>
                </template>
                <template v-else>
                  {{ ' ' }}<template v-for="(afname, afni) in af['schema:name']" :key="'afn-'+afi+'-'+afni"><template v-if="afni>0"> / </template>{{ afname['@value'] }}</template>
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
          <template v-for="(corpname, ci) in entity['schema:name']" :key="'corp-'+ci">
            <template v-if="ci>0">, </template><span class="valuefield">{{ corpname['@value'] }}</span>
          </template>
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
    },
    organizationLanguage: function () {
      if (this.entity['@type'] === 'schema:Organization' && this.entity['schema:name']) {
        if (this.entity['schema:name'][0] && this.entity['schema:name'][0]['@language']) {
          return this.entity['schema:name'][0]['@language']
        }
      }
      return null
    }
  },
  methods: {
    getLocalizedTermLabel: function (role) {
      return this.$store.getters['vocabulary/getLocalizedTermLabel']('rolepredicate', role, this.$i18n.locale)
    },
    formatBirthDeathDate: function () {
      if (this.entity['@type'] !== 'schema:Person') {
        return ''
      }
      
      const birthDates = this.entity['schema:birthDate'] || []
      const deathDates = this.entity['schema:deathDate'] || []
      
      const birthDate = birthDates.length > 0 ? birthDates[0] : null
      const deathDate = deathDates.length > 0 ? deathDates[0] : null
      
      if (birthDate && deathDate) {
        return `(${birthDate} - ${deathDate})`
      } else if (birthDate) {
        return `(${birthDate} - )`
      } else if (deathDate) {
        return `( - ${deathDate})`
      }

      return ''
    }
  },
  mounted: function () {
    this.$nextTick(function () {
      this.$store.dispatch('vocabulary/loadOrgUnits', this.$i18n.locale)
    })
  }
}
</script>
