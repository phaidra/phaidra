<template>
  <v-container fluid class="pa-0">
    <v-row>
      <v-col cols="3">
        <v-list v-model:opened="openedCategories">
          <v-list-group
            v-for="(category, i) in categories"
            :key="'cat'+i"
            :value="'cat'+i"
            :expand-icon="false"
            :collapse-icon="false"
          >
            <template #activator="{ props }">
              <v-list-item class="text-primary" v-bind="props" :title="$t(category.title)" />
            </template>
            <v-list-item
              v-for="(field, j) in category.fields"
              :key="'field'+j"
              :title="$t(field.title)"
              :value="field.predicate"
              :active="selectedField && selectedField.predicate === field.predicate"
              @click="selectField(field)"
            />
          </v-list-group>
        </v-list>
      </v-col>
      <v-col cols="9" class="px-3">
        <template v-if="selectedField">
          <div class="text-display-small">
            <span class="font-weight-light mr-2">{{ $t(selectedField.title) }}</span> <v-chip class="ma-2 pointer-disabled" label >{{ selectedField.predicate }}</v-chip>
          </div>
          <div v-for="(section, i) in selectedField.sections" :key="i" :id="'sec' + i">
            <template v-if="(section.content !== '') && (section.id !== 'obligation') && !(section.id === 'vocabulary' && section.content === 'None')">
              <div cols="12" class="font-weight-light text-headline-medium mt-8 mb-4">{{ $t(section.title) }}</div>
              <template v-if="section.content.level1" class="mb-8">
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
              <template v-else class="mb-8">
                <div v-html="$t(section.content)"></div>
              </template>
            </template>
          </div>
        </template>
      </v-col>
    </v-row>
  </v-container>
</template>

<script>
import { vuetifyGoTo } from '../../utils/vuetifyGoToCompat'

export default {
  name: 'p-metadata-fields-help',
  computed: {
    categories: function () {
      return this.$store.state.info.metadataFieldsOverview
    }
  },
  methods: {
    selectField: function (field) {
      this.$store.commit('info/switchFieldsOverview', field.id)
      this.selectedField = field
      vuetifyGoTo(1)
    }
  },
  mounted: function () {
    this.selectedField = this.categories[0].fields[0]
    this.$store.commit('info/initFieldsOverview')
    this.$store.dispatch('info/sortFieldsOverview', {locale: this.$i18n.locale, i18nInstance: this.$i18n})
    this.openedCategories = this.categories
      .map((category, i) => (category.open ? 'cat' + i : null))
      .filter(Boolean)
  },
  data () {
    return {
      drawer: null,
      openedCategories: [],
      selectedField: null
    }
  }
}
</script>
