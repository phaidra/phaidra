<template>
  <v-container fluid class="pa-0">
    <v-row>
      <v-col cols="12" md="3">
        <v-select
          v-model="mobileNavigationValue"
          :items="mobileNavigationItems"
          class="d-md-none mb-4"
          :label="$t('Metadata help')"
          density="compact"
          hide-details
        />
        <v-list v-model:opened="openedCategories" class="d-none d-md-block">
          <v-list-group
            v-for="(category, i) in categories"
            :key="'cat'+i"
            :value="'cat'+i"
          >
            <template #activator="{ props }">
              <v-list-item class="text-primary" v-bind="props" :title="$t(category.title)" />
            </template>
            <v-list-item
              v-for="field in category.fields"
              :key="field.title + ':' + field.predicate"
              :title="$t(field.title)"
              :value="fieldAnchor(field)"
              :href="'#' + fieldAnchor(field)"
              :active="selectedView === 'field' && selectedField === field"
              @click.prevent="selectField(field, true)"
            />
          </v-list-group>
          <v-list-item
            class="text-primary"
            :title="$t('Namespaces')"
            value="namespaces"
            href="#namespaces"
            :active="selectedView === 'namespaces'"
            @click.prevent="selectView('namespaces', true)"
          />
          <v-list-item
            class="text-primary"
            :title="$t('Resources')"
            value="resources"
            href="#resources"
            :active="selectedView === 'resources'"
            @click.prevent="selectView('resources', true)"
          />
        </v-list>
      </v-col>
      <v-col cols="12" md="9" class="px-3">
        <template v-if="selectedView === 'field' && selectedField">
          <div :id="fieldAnchor(selectedField)" class="text-display-small">
            <span class="font-weight-light mr-2">{{ $t(selectedField.title) }}</span> <v-chip class="ma-2 pointer-disabled" label >{{ selectedField.predicate }}</v-chip>
          </div>
          <v-alert v-if="selectedParentField" type="info" variant="tonal" class="mt-4">
            {{ $t('This field is a type of') }}
            <a :href="'#' + fieldAnchor(selectedParentField)" @click.prevent="selectField(selectedParentField, true)">{{ selectedParentField.title }}</a>.
          </v-alert>
          <div v-for="(section, i) in selectedField.sections" :key="i" :id="'sec' + i">
            <template v-if="hasSectionContent(section)">
              <div cols="12" class="font-weight-light text-headline-medium mt-8 mb-4">{{ $t(section.title) }}</div>
              <template v-if="typeof section.content === 'object'">
                <div class="font-weight-light text-title-medium mt-6 mb-2" v-if="section.content.level2">{{ $t('Basic usage notes') }}</div>
                <div v-html="$t(section.content.level1)"></div>
                <template v-if="section.content.level2">
                  <div class="font-weight-light text-title-medium mt-6 mb-2">{{ $t('Improve your metadata quality') }}</div>
                  <div v-html="$t(section.content.level2)"></div>
                </template>
                <template v-if="section.content.level3">
                  <div class="font-weight-light text-title-medium mt-6 mb-2">{{ $t('Fairify your data') }}</div>
                  <div v-html="$t(section.content.level3)"></div>
                </template>
              </template>
              <template v-else>
                <div v-html="$t(section.content)"></div>
              </template>
            </template>
          </div>
          <template v-if="selectedVocabulary">
            <div class="font-weight-light text-headline-medium mt-8 mb-4">Vocabulary</div>
            <v-data-table
              :headers="vocabularyHeaders"
              :items="selectedVocabularyTerms"
              density="compact"
              hide-default-footer
              :items-per-page="-1"
            >
              <template v-slot:[`item.label`]="{ item }">
                {{ item.label }}
              </template>
              <template v-slot:[`item.definition`]="{ item }">
                <span v-html="item.definition" />
              </template>
            </v-data-table>
            <div v-if="selectedField.vocabularyNote" class="text-medium-emphasis mt-2">{{ selectedField.vocabularyNote }}</div>
          </template>
          <template v-if="selectedFieldReference">
            <div v-for="list in referenceLists" :key="list.name" class="mt-8">
              <div class="font-weight-light text-headline-medium mb-4">{{ list.name }}</div>
              <v-table density="compact">
                <tbody>
                  <tr v-for="(entry, index) in list.entries" :key="index">
                    <td v-for="(value, cell) in entry" :key="cell">{{ value }}</td>
                  </tr>
                </tbody>
              </v-table>
            </div>
            <v-expansion-panels v-if="selectedFieldReference.jsonLdExample" class="mt-6">
              <v-expansion-panel title="JSON-LD example">
                <v-expansion-panel-text>
                  <pre class="metadata-example"><code>{{ selectedFieldReference.jsonLdExample }}</code></pre>
                </v-expansion-panel-text>
              </v-expansion-panel>
            </v-expansion-panels>
          </template>
        </template>

        <template v-else-if="selectedView === 'namespaces'">
          <div id="namespaces" class="text-display-small font-weight-light mb-6">Namespaces</div>
          <v-table density="compact">
            <thead><tr><th>Vocabulary</th><th>Prefix</th><th>URL</th></tr></thead>
            <tbody>
              <tr v-for="namespace in namespaces" :key="namespace.prefix">
                <td>{{ namespace.name }}</td>
                <td><code>{{ namespace.prefix }}</code></td>
                <td><a :href="namespace.url" target="_blank" rel="noopener">{{ namespace.url }}</a></td>
              </tr>
            </tbody>
          </v-table>
        </template>

        <template v-else-if="selectedView === 'resources'">
          <div id="resources" class="text-display-small font-weight-light mb-6">Resources</div>
          <v-list>
            <v-list-item v-for="resource in resources" :key="resource.url" :href="resource.url" target="_blank" rel="noopener">
              <v-list-item-title>{{ resource.label }}</v-list-item-title>
            </v-list-item>
          </v-list>
        </template>
      </v-col>
    </v-row>
  </v-container>
</template>

<script>
import { useInfoStore } from '../../stores/info'
import { useVocabularyStore } from '../../stores/vocabulary'
import languages from '../../utils/lang'
import { vuetifyGoTo } from '../../utils/vuetifyGoToCompat'

export default {
  name: 'p-metadata-fields-help',
  computed: {
    metadataOverview: function () {
      return useInfoStore().metadataFieldsOverview
    },
    categories: function () {
      return this.metadataOverview.filter(category => category.fields.length)
    },
    namespaces: function () {
      return this.metadataOverview.find(category => category.title === 'Namespaces')?.items || []
    },
    resources: function () {
      return this.metadataOverview.find(category => category.title === 'Resources')?.items || []
    },
    mobileNavigationItems: function () {
      return [
        ...this.categories.flatMap(category => category.fields).map(field => ({
          title: this.$t(field.title),
          value: this.fieldAnchor(field)
        })),
        { title: 'Namespaces', value: 'namespaces' },
        { title: 'Resources', value: 'resources' }
      ]
    },
    mobileNavigationValue: {
      get: function () {
        return this.selectedView === 'field' && this.selectedField
          ? this.fieldAnchor(this.selectedField)
          : this.selectedView
      },
      set: function (value) {
        window.location.hash = value
      }
    },
    selectedFieldReference: function () {
      return this.selectedField
    },
    selectedParentField: function () {
      if (!this.selectedField?.parentTitle) return null
      return this.categories.flatMap(category => category.fields)
        .find(field => field.title === this.selectedField.parentTitle) || null
    },
    selectedVocabulary: function () {
      const vocabularyId = this.selectedField?.vocabularyId
      if (vocabularyId === 'lang') return { terms: languages.get_lang() }
      const vocabulary = vocabularyId ? useVocabularyStore().vocabularies[vocabularyId] : null
      return Array.isArray(vocabulary?.terms) && vocabulary.terms.length ? vocabulary : null
    },
    selectedVocabularyTerms: function () {
      if (!this.selectedVocabulary || !Array.isArray(this.selectedVocabulary.terms)) return []
      return this.selectedVocabulary.terms.map(term => ({
        label: this.localizedVocabularyValue(term['skos:prefLabel']),
        code: term['@id'],
        definition: this.localizedVocabularyValue(term['skos:definition']),
        id: term['@id']
      }))
    },
    vocabularyHeaders: function () {
      const headers = [
        { title: 'Term', key: 'label' },
        { title: 'Code', key: 'code' }
      ]
      if (this.selectedVocabularyTerms.some(term => term.definition)) {
        headers.push({ title: 'Help', key: 'definition' })
      }
      return headers
    },
    referenceLists: function () {
      if (!this.selectedFieldReference) return []
      return this.selectedVocabulary
        ? this.selectedFieldReference.lists.filter(list => !/vocabulary/i.test(list.name))
        : this.selectedFieldReference.lists
    }
  },
  methods: {
    localizedVocabularyValue: function (value) {
      if (!value) return ''
      if (typeof value === 'string') return value
      const locale = this.$i18n.locale
      return value[locale] || value[locale.slice(0, 2)] || value.eng || Object.values(value).find(Boolean) || ''
    },
    hasSectionContent: function (section) {
      if (section.id === 'obligation' || section.content == null) return false
      if (section.id === 'vocabulary' && (section.content === 'None' || this.selectedVocabulary)) return false
      if (typeof section.content === 'object') {
        return Object.values(section.content).some(Boolean)
      }
      return section.content !== ''
    },
    fieldAnchor: function (field) {
      return field.title.toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/(^-|-$)/g, '')
    },
    pushHash: function (hash) {
      if (window.location.hash !== '#' + hash) {
        window.history.pushState(null, '', '#' + hash)
      }
    },
    selectField: function (field, addHistory = false) {
      this.selectedField = field
      this.selectedView = 'field'
      if (addHistory) this.pushHash(this.fieldAnchor(field))
      vuetifyGoTo(1)
    },
    selectView: function (view, addHistory = false) {
      this.selectedView = view
      if (addHistory) this.pushHash(view)
      vuetifyGoTo(1)
    },
    selectFromHash: function () {
      const hash = window.location.hash.slice(1)
      const linkedField = this.categories.flatMap(category => category.fields)
        .find(field => this.fieldAnchor(field) === hash)
      if (linkedField) {
        this.selectedField = linkedField
        this.selectedView = 'field'
      } else if (hash === 'namespaces' || hash === 'resources') {
        this.selectedView = hash
      } else if (!hash) {
        this.selectedField = this.categories[0].fields[0]
        this.selectedView = 'field'
      }
    }
  },
  mounted: function () {
    useInfoStore().initFieldsOverview()
    useInfoStore().sortFieldsOverview({locale: this.$i18n.locale, i18nInstance: this.$i18n})
    this.selectFromHash()
    if (!this.selectedField && this.selectedView === 'field') this.selectedField = this.categories[0].fields[0]
    window.addEventListener('hashchange', this.selectFromHash)
    window.addEventListener('popstate', this.selectFromHash)
    this.openedCategories = this.categories
      .map((category, i) => (category.open ? 'cat' + i : null))
      .filter(Boolean)
  },
  beforeUnmount: function () {
    window.removeEventListener('hashchange', this.selectFromHash)
    window.removeEventListener('popstate', this.selectFromHash)
  },
  data () {
    return {
      drawer: null,
      openedCategories: [],
      selectedField: null,
      selectedView: 'field'
    }
  }
}
</script>

<style scoped>
.metadata-example {
  max-width: 100%;
  overflow-x: auto;
}
</style>
