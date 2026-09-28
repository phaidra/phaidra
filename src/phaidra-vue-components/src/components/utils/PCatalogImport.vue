<template>
  <v-container>
    <v-row no-gutters>
      <h3 class="text-title-large font-weight-light mb-4">{{ $t('Catalog import') }}</h3>
    </v-row>
    <v-row no-gutters justify="center" class="mt-4">
      <v-col cols="12" md="4">
        <v-text-field
          v-model="acNumber"
          :error-messages="errors"
          :label="$t('AC number')"
          :placeholder="$t('please enter')"
          variant="filled"
          @keyup.enter="fetchMetadata"
        />
      </v-col>
      <v-col cols="12" md="3" class="ml-md-2">
        <v-btn
          class="mx-2"
          color="primary"
          :disabled="loading || !normalizedAcNumber"
          :loading="loading"
          @click="fetchMetadata"
        >
          {{ $t('Fetch metadata') }}
        </v-btn>
        <v-btn class="mx-2" color="btnred" theme="dark" :disabled="loading" @click="reset">
          {{ $t('Reset') }}
        </v-btn>
      </v-col>
    </v-row>

    <v-row v-if="jsonld" no-gutters justify="center">
      <v-col cols="12" md="9">
        <v-card>
          <v-card-title class="text-title-large font-weight-light text-white">
            {{ $t('Metadata preview') }}
          </v-card-title>
          <v-card-text>
            <v-container class="mt-4">
              <p-d-jsonld :key="JSON.stringify(jsonld)" :jsonld="jsonld" />
            </v-container>
          </v-card-text>
        </v-card>
        <div class="font-weight-bold text-right mt-4">
          <v-btn color="primary" @click="loadForm">{{ $t('Load Form') }}</v-btn>
        </div>
      </v-col>
    </v-row>
  </v-container>
</template>

<script>
import { vocabulary } from '../../mixins/vocabulary'
import jsonLd from '../../utils/json-ld'
import PDJsonld from '../display/PDJsonld.vue'

export default {
  name: 'p-catalog-import',
  components: { PDJsonld },
  mixins: [vocabulary],
  props: {
    externalForm: {
      type: Object,
      required: true
    }
  },
  emits: ['load-form'],
  data () {
    return {
      acNumber: '',
      errors: [],
      jsonld: null,
      loading: false
    }
  },
  computed: {
    normalizedAcNumber () {
      return this.acNumber.trim()
    }
  },
  methods: {
    clone (value) {
      return JSON.parse(JSON.stringify(value))
    },
    reset () {
      this.acNumber = ''
      this.errors = []
      this.jsonld = null
    },
    async fetchMetadata () {
      if (!this.normalizedAcNumber) return

      this.loading = true
      this.errors = []
      this.jsonld = null
      try {
        const response = await this.$axios.request({
          method: 'GET',
          url: `/alma/${encodeURIComponent(this.normalizedAcNumber)}/jsonld`
        })
        if (!response.data?.jsonld) {
          throw new Error(this.$t('No metadata found'))
        }
        this.jsonld = response.data.jsonld
      } catch (error) {
        const message = error.response?.data?.alerts?.[0]?.msg || error.response?.data?.message || error.message
        this.errors = [message || this.$t('Could not fetch metadata')]
      } finally {
        this.loading = false
      }
    },
    fieldKey (field) {
      return `${field.predicate || ''}|${field.type || ''}`
    },
    mergeFields (targetSection, importedFields) {
      if (!targetSection.fields) targetSection.fields = []
      const usedIndexes = new Set()
      let populated = false

      const objectTypeIndex = targetSection.fields.findIndex(field => field.component === 'p-object-type-checkboxes')
      if (objectTypeIndex !== -1) {
        const objectTypes = importedFields.filter(field => field.predicate === 'edm:hasType')
        if (objectTypes.length > 0) {
          targetSection.fields[objectTypeIndex].selectedTerms = objectTypes.map(field => ({
            value: field.value,
            'skos:prefLabel': field['skos:prefLabel'] || []
          }))
          importedFields = importedFields.filter(field => field.predicate !== 'edm:hasType')
          populated = true
        }
      }

      importedFields.forEach(importedField => {
        const key = this.fieldKey(importedField)
        let targetIndex = targetSection.fields.findIndex((field, index) => {
          return !usedIndexes.has(index) && this.fieldKey(field) === key
        })
        if (targetIndex === -1) {
          targetIndex = targetSection.fields.findIndex((field, index) => {
            return !usedIndexes.has(index) && field.predicate && field.predicate === importedField.predicate
          })
        }

        if (targetIndex === -1) {
          targetSection.fields.push(this.clone(importedField))
          usedIndexes.add(targetSection.fields.length - 1)
        } else {
          const targetField = targetSection.fields[targetIndex]
          targetSection.fields.splice(targetIndex, 1, {
            ...targetField,
            ...this.clone(importedField),
            id: targetField.id,
            component: targetField.component,
            label: targetField.label
          })
          usedIndexes.add(targetIndex)
        }
        populated = true
      })

      if (populated && Object.prototype.hasOwnProperty.call(targetSection, 'collapsed')) {
        targetSection.collapsed = false
      }
    },
    mergeIntoExternalForm (importedForm) {
      const form = this.clone(this.externalForm)
      const digitalSections = form.sections.filter(section => section.type !== 'phaidra:Subject')
      const subjectSections = form.sections.filter(section => section.type === 'phaidra:Subject')

      importedForm.sections.forEach(importedSection => {
        const candidates = importedSection.type === 'phaidra:Subject' ? subjectSections : digitalSections
        let targetSection = candidates.find(section => {
          return importedSection.fields.some(importedField => section.fields?.some(field => {
            return this.fieldKey(field) === this.fieldKey(importedField) ||
              (field.predicate && field.predicate === importedField.predicate)
          }))
        })

        if (!targetSection) {
          targetSection = candidates[0]
        }
        if (!targetSection) {
          targetSection = this.clone(importedSection)
          targetSection.collapsed = false
          form.sections.push(targetSection)
          return
        }

        const fieldsBySection = new Map()
        importedSection.fields.forEach(importedField => {
          const matchingSection = candidates.find(section => section.fields?.some(field => {
            return this.fieldKey(field) === this.fieldKey(importedField) ||
              (field.predicate && field.predicate === importedField.predicate)
          })) || targetSection
          if (!fieldsBySection.has(matchingSection)) fieldsBySection.set(matchingSection, [])
          fieldsBySection.get(matchingSection).push(importedField)
        })
        fieldsBySection.forEach((importedFields, section) => this.mergeFields(section, importedFields))
      })

      const resourceType = 'https://pid.phaidra.org/vocabulary/69ZZ-2KGX'
      form.sections.flatMap(section => section.fields || []).forEach(field => {
        if (field.predicate === 'dcterms:type') field.value = resourceType
        if (field.component === 'p-object-type-checkboxes') field.resourceType = resourceType
      })

      return form
    },
    loadForm () {
      if (!this.jsonld) return
      const importedForm = jsonLd.json2form(this.jsonld, null, this.vocabularies)
      this.$emit('load-form', this.mergeIntoExternalForm(importedForm))
    }
  }
}
</script>
