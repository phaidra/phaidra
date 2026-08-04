<template>
  <v-dialog width="600px" v-model="dialog">
    <v-card>
      <v-card-actions>
        <v-container fluid>
          <v-row justify="start">
            <v-col cols="3">{{ $t('Quick select') }}:</v-col>
            <v-col>
              <v-btn v-for="lang in this.$i18n.availableLocales" :key="lang" class="mx-1" color="primary" @click="selectLang(lang)">{{ getLocalizedTermLabel('lang', lang) }}</v-btn>
              <v-btn v-if="showReset" class="mx-1 text-white" color="btnred" @click="resetLang()">{{ $t('Reset') }}</v-btn>
            </v-col>
          </v-row>
        </v-container>
      </v-card-actions>
      <v-divider></v-divider>
      <v-card-text>
        <v-data-table
          :items="languagesTable"
          :headers="languagesHeaders"
          item-value="id"
          :search="langsearchinput"
          :items-per-page="5"
          :items-per-page-text="$t('Rows per page')"
          :items-per-page-options="languageItemsPerPageOptions"
        >
          <template v-slot:top>
            <v-text-field
              v-model="langsearchinput"
              :label="$t('Search...')"
              class="mx-4"
            ></v-text-field>
          </template>
          <template v-slot:item.actions="{ item }">
            <v-btn class="mx-1" variant='text' color="primary" @click="selectLang(item.id)">{{ $t('Select') }}</v-btn>
          </template>
        </v-data-table>
      </v-card-text>
      <v-divider></v-divider>
      <v-card-actions>
        <v-spacer></v-spacer>
        <v-btn variant="outlined" @click="dialog = false">{{ $t('Cancel') }}</v-btn>             
      </v-card-actions>
    </v-card>
  </v-dialog>
</template>

<script>
import { vocabulary } from '../../mixins/vocabulary'

export default {
  name: 'select-language',
  mixins: [vocabulary],
  props: {
    showReset: {
      type: Boolean,
      default: false
    }
  },
  computed: {
    languagesTable () {
      let tab = []
      for (let l of this.vocabularies['lang'].terms) {
        tab.push(
          {
            id: l['@id'],
            label: this.getLocalizedTermLabel('lang', l['@id'])
          }
        )
      }
      return tab
    },
    languagesHeaders () {
      return [
        { key: 'id', title: 'ID', align: 'start' },
        { key: 'label', title: this.$t('Name') },
        { key: 'actions', title: this.$t('Actions'), sortable: false }
      ]
    },
    languageItemsPerPageOptions () {
      return [
        { value: 5, title: '5' },
        { value: 10, title: '10' },
        { value: 25, title: '25' },
        { value: -1, title: this.$t('All') }
      ]
    }
  },
  data () {
    return {
      dialog: false,
      langsearchinput: ''
    }
  },
  methods: {
    open: async function () {
      this.dialog = true
    },
    resetLang: function () {
      this.$emit('language-selected', '')
      this.dialog = false
    },
    selectLang: function (id) {
      this.$emit('language-selected', this.getTerm('lang', id))
      this.dialog = false
    }
  }
}
</script>
