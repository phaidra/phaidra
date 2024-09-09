<template>
  <v-dialog width="600px" v-model="dialog">
    <v-card height="520px">
      <v-card-actions>
        <v-container fluid>
          <v-row justify="start">
            <v-col cols="3">{{ $t('Quick select') }}:</v-col>
            <v-col><v-btn v-for="lang in this.$i18n.localeCodes" :key="lang" class="mx-1" color="grey" dark @click="selectLang(lang)">{{ getLocalizedTermLabel('lang', lang) }}</v-btn></v-col>
          </v-row>
        </v-container>
      </v-card-actions>
      <v-divider></v-divider>
      <v-card-text>
        <v-data-table
          :items="languagesTable"
          :headers="languagesHeaders"
          item-key="id"
          :search="langsearchinput"
          :items-per-page="5"
        >
          <template v-slot:top>
            <v-text-field
              v-model="langsearchinput"
              :label="$t('Search...')"
              class="mx-4"
            ></v-text-field>
          </template>
          <template v-slot:item.actions="{ item }">
            <v-btn class="mx-1" color="grey" dark @click="selectLang(item.id)">{{ $t('Select') }}</v-btn>
          </template>
        </v-data-table>
      </v-card-text>
    </v-card>
  </v-dialog>
</template>

<script>
import { vocabulary } from '../../mixins/vocabulary'

export default {
  name: 'select-language',
  mixins: [vocabulary],
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
    }
  },
  data () {
    return {
      dialog: false,
      langsearchinput: '',
      languagesHeaders: [
        {
          text: 'ID',
          align: 'start',
          value: 'id'
        },
        {
          text: 'Name',
          value: 'label'
        },
        {
          text: 'Actions',
          value: 'actions', 
          sortable: false
        }
      ]
    }
  },
  methods: {
    open: async function () {
      this.dialog = true
    },
    selectLang: function (id) {
      this.$emit('language-selected', this.getTerm('lang', id))
      this.dialog = false
    }
  }
}
</script>
