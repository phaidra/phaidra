<template>
  <v-container fluid>
    <v-row>
      <v-col cols="3">
        <v-list>
          <v-list-group prepend-icon="" append-icon="" v-for="(category, i) in categories" :value="category.open" :key="'cat'+i">
            <template v-slot:activator>
              <v-list-item-title >{{ $t(category.title) }}</v-list-item-title>
            </template>
            <v-list-group prepend-icon="" v-for="(field, j) in category.fields" sub-group :key="'field'+j">
              <template v-slot:activator>
                <v-list-item :value="field.open">
                  <v-list-item-content @click="selectField(field)">
                    <v-list-item-title>{{ $t(field.title) }}</v-list-item-title>
                  </v-list-item-content>
                </v-list-item>
              </template>
            </v-list-group>
          </v-list-group>
        </v-list>
      </v-col>
      <v-col cols="9">
        <template v-if="selectedField">
          <div class="display-1 my-8">
            <span class="font-weight-light mr-2">{{ $t(selectedField.title) }}</span> <v-chip class="ma-2 pointer-disabled" label >{{ selectedField.predicate }}</v-chip>
          </div>
          <div v-for="(section, i) in selectedField.sections" :key="i" :id="'sec' + i">
            <template v-if="(section.content !== '') && (section.id !== 'obligation') && !(section.id === 'vocabulary' && section.content === 'None')">
              <div cols="12" class="font-weight-light headline mt-8 mb-4">{{ $t(section.title) }}</div>
              <template v-if="section.content.level1" class="mb-8">
                <div class="font-weight-light subtitle-1 mt-6 mb-2" v-if="section.content.level2">{{ $t('Basic usage notes') }}</div>
                <div v-html="$t(section.content.level1)"></div>
                <template v-if="section.content.level2">
                  <div class="font-weight-light subtitle-1 mt-6 mb-2">{{ $t('Improve your metadata quality') }}</div>
                  <div v-html="$t(section.content.level2)"></div>
                </template>
                <template v-if="section.content.level3">
                  <div class="font-weight-light subtitle-1 mt-6 mb-2">{{ $t('Fairify your data') }}</div>
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
      this.$vuetify.goTo(1)
    }
  },
  mounted: function () {
    this.selectedField = this.categories[0].fields[0]
    this.$store.commit('info/initFieldsOverview')
    this.$store.dispatch('info/sortFieldsOverview', this.$i18n.locale)
  },
  data () {
    return {
      drawer: null,
      selectedField: null
    }
  }
}
</script>
