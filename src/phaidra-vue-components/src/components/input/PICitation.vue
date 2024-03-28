<template>
  <v-row v-if="!hidden">
    <v-col cols="2">
      <v-autocomplete
        v-on:input="$emit('input-citation-type', $event)"
        :label="$t('Citation type')"
        :items="vocabularies['citationpredicate'].terms"
        :item-value="'@id'"
        :value="getTerm('citationpredicate', type)"
        :filter="autocompleteFilter"
        :disabled="disabletype"
        :filled="inputStyle==='filled'"
        :outlined="inputStyle==='outlined'"
        return-object
        clearable
      >
        <template slot="item" slot-scope="{ item }">
          <v-list-item-content two-line>
            <v-list-item-title  v-html="`${getLocalizedTermLabel('citationpredicate', item['@id'])}`"></v-list-item-title>
            <v-list-item-subtitle v-if="showIds" v-html="`${item['@id']}`"></v-list-item-subtitle>
          </v-list-item-content>
        </template>
        <template slot="selection" slot-scope="{ item }">
          <v-list-item-content>
            <v-list-item-title v-html="`${getLocalizedTermLabel('citationpredicate', item['@id'])}`"></v-list-item-title>
          </v-list-item-content>
        </template>
      </v-autocomplete>
    </v-col>
    <v-col cols="4">
      <v-text-field
        :value="citation"
        v-on:input="$emit('input-citation', $event)"
        :label="$t(citationLabel)"
        :required="required"
        :rules="required ? [ v => !!v || 'Required'] : []"
        :filled="inputStyle==='filled'"
        :outlined="inputStyle==='outlined'"      
        append-outer-icon="mdi-magnify"
        @click:append-outer="onYarmClick"
      ></v-text-field><!--append-outer-icon="mdi-magnify"
        @click:append-outer="onYarmClick"-->
    </v-col>
    <v-col cols="2">
      <v-autocomplete
        :value="getTerm('lang', citationLanguage)"
        v-on:input="$emit('input-citation-language', $event)"
        :items="vocabularies['lang'].terms"
        :item-value="'@id'"
        :filter="autocompleteFilter"
        hide-no-data
        :label="$t('Language')"
        :filled="inputStyle==='filled'"
        :outlined="inputStyle==='outlined'"
        return-object
        clearable
      >
        <template slot="item" slot-scope="{ item }">
          <v-list-item-content two-line>
            <v-list-item-title  v-html="`${getLocalizedTermLabel('lang', item['@id'])}`"></v-list-item-title>
            <v-list-item-subtitle v-if="showIds" v-html="`${item['@id']}`"></v-list-item-subtitle>
          </v-list-item-content>
        </template>
        <template slot="selection" slot-scope="{ item }">
          <v-list-item-content>
            <v-list-item-title v-html="`${getLocalizedTermLabel('lang', item['@id'])}`"></v-list-item-title>
          </v-list-item-content>
        </template>
      </v-autocomplete>
    </v-col>
    <v-col cols="3">
      <v-text-field
        :value="identifier"
        v-on:input="$emit('input-identifier', $event)"
        :label="$t(identifierLabel)"
        :required="required"
        :rules="required ? [ v => !!v || 'Required'] : []"
        :filled="inputStyle==='filled'"
        :outlined="inputStyle==='outlined'"
      ></v-text-field>
    </v-col>
    <v-col cols="1" v-if="actions.length">
      <v-menu open-on-hover bottom offset-y>
        <template v-slot:activator="{ on }">
          <v-btn v-on="on" icon>
            <v-icon>mdi-dots-vertical</v-icon>
          </v-btn>
        </template>
        <v-list>
          <v-list-item v-for="(action, i) in actions" :key="i" @click="$emit(action.event, $event)">
            <v-list-item-title>{{ action.title }}</v-list-item-title>
          </v-list-item>
        </v-list>
      </v-menu>
    </v-col>
    <v-dialog class="pb-4" v-model="showYarmDialog" scrollable width="1000px">
      <v-card>
        <v-card-title class="grey white--text"><span v-t="'YARM'"></span><v-spacer></v-spacer><v-btn
              @click="yarmLogout()"
              color="primary"
              dark
              v-if="yarmToken"
            >
            {{ $t('Logout') }} (YARM)
            </v-btn></v-card-title>
        <v-card-text v-if="yarmToken">
          <v-text-field clearable :label="$t('Search...')" append-icon="mdi-magnify" v-model="searchInput"></v-text-field>
          <v-data-table
            :headers="headers"
            :items="yarmData"
            :items-per-page="10"
            class="elevation-1"
            :options.sync="options"
            :server-items-length="totalData"
            :loading="yarmDataLoading"
          >
          <template v-slot:item.action="{ item }">
            <v-btn
              @click="onYarmConfirm(item)"
              color="primary"
            >
            {{ $t('Select') }}
            </v-btn>
          </template>
        </v-data-table>
        </v-card-text>
        <v-card-text v-else>
          <div class="login-btn-container">
            <v-btn
              @click="yarmLoginDialog = true"
              color="primary"
              dark
              v-on="on"
            >
            {{ $t('Login') }} (YARM)
            </v-btn>
          </div>
          <v-dialog
            v-model="yarmLoginDialog"
            persistent
            max-width="600px"
          >
            <v-card>
              <v-card-title>
                <span class="text-h5">{{ $t('Login') }} (YARM)</span>
              </v-card-title>
              <v-card-text>
                <v-container>
                  <v-row>
                    <v-col cols="12">
                      <v-text-field
                        label="Email*"
                        v-model="yarmEmail"
                        required
                      ></v-text-field>
                    </v-col>
                    <v-col cols="12">
                      <v-text-field
                        label="Password*"
                        type="password"
                        v-model="yarmPassword"
                        required
                      ></v-text-field>
                    </v-col>
                  </v-row>
                </v-container>
                <small>* {{ $t('Please fill in the required fields')}}</small>
              </v-card-text>
              <v-card-actions>
                <v-spacer></v-spacer>
                <v-btn
                  color="blue darken-1"
                  text
                  @click="yarmLoginDialog = false"
                >
                  {{ $t('Cancel') }}
                </v-btn>
                <v-btn
                  color="blue darken-1"
                  text
                  @click="yarmLogin()"
                >
                {{ $t('Login') }}
                </v-btn>
              </v-card-actions>
            </v-card>
          </v-dialog>
        </v-card-text>

        <v-divider></v-divider>
        <v-card-actions>
          <v-container fluid>
            <v-row justify="end">
              <v-btn class="mx-1" color="grey" dark @click="closeYarmSelect()"><span v-t="'Cancel'"></span></v-btn>
            </v-row>
          </v-container>
        </v-card-actions>
      </v-card>

    </v-dialog>
  </v-row>
</template>

<script>
import { vocabulary } from '../../mixins/vocabulary'
import { fieldproperties } from '../../mixins/fieldproperties'

export default {
  name: 'p-i-citation',
  data() {
    return {
      searchInput: '',
      yarmLoginDialog: false,
      showYarmDialog: false,
      yarmEmail: '',
      yarmPassword: '',
      yarmToken: null,
      headers: [
        { text: 'Title', value: 'title' },
        { text: 'Identifier', value: 'identifier' },
        { text: 'Action', value: 'action' },
      ],
      yarmData: [],
      totalData: 0,
      yarmDataLoading: false,
      options: {},
    }
  },
  watch: {
    searchInput(val) {
      this.options = {
        ...this.options,
        page: 1
      }
    },
    options: {
      handler () {
        this.searchForRecordInYarm()
      },
      deep: true,
    },
  },
  mixins: [vocabulary, fieldproperties],
  props: {
    citation: {
      type: String
    },
    citationLanguage: {
      type: String
    },
    identifier: {
      type: String
    },
    type: {
      type: String
    },
    citationLabel: {
      type: String,
      required: true
    },
    identifierLabel: {
      type: String,
      required: true
    },
    required: {
      type: Boolean
    },
    disabletype: {
      type: Boolean
    },
    showIds: {
      type: Boolean,
      default: false
    }
  },
  methods: {
    searchForRecordInYarm: async function() {
      const { sortBy, sortDesc, page, itemsPerPage } = this.options
      this.yarmDataLoading = true
      try {
        let response = await this.$axios.request({
          method: 'GET',
          url: `https://${this.$store.state.appconfig.apis.yarm.baseurl}/api/search?search[0][field]=title&search[0][criterium]=like&search[0][term]=${this.searchInput}&offset=${0}&limit=${itemsPerPage}&pagination=${true}&page=${page}`,
          headers: {
            'Authorization': `Bearer ${this.yarmToken}`
          }
        })
        this.yarmDataLoading = false
        if(response && response.data && response.data.data){
          this.totalData = response.data.message.dataTotal
          this.yarmData = response.data.data
          this.yarmData.forEach(data => {
            if(data.relIdentifiers && data.relIdentifiers.length) {
              data.identifier = data.relIdentifiers[0].value
            }
          })
        }
      } catch (error) {
        console.error(error)
      } finally {
        this.yarmDataLoading = false
      }

    },
    onYarmConfirm: async function (item) {
      try {
        this.yarmDataLoading = true
        let citationText = ''
        let response = await this.$axios.request({
          method: 'GET',
          url: `https://${this.$store.state.appconfig.apis.yarm.baseurl}/api/buildCustomExport?export_as=json&field=id&criterium=equal&search=${item.id}&style=mla`,
          headers: {
            'Authorization': `Bearer ${this.yarmToken}`
          }
        })
        if(response && response.data && response.data.length > 0){
          citationText = response.data[0].HTMLCIT.replace('<p>','').replace('</p>','').replace('<e>','').replace('</e>','').replace('<i>','').replace('</i>','')
        }

        this.$emit('input-citation', citationText)
        this.$emit('input-identifier', `https://${this.$store.state.appconfig.apis.yarm.baseurl}/yarm/refs/${item.id}`)
        // keep this to make sure the predicate is set
        this.$emit('input-citation-type', this.getTerm('citationpredicate', this.type))
      } catch (error) {
        console.error(error)
      } finally {
        this.yarmDataLoading = false
      }
      
      this.closeYarmSelect()
    },
    closeYarmSelect: function () {
      this.showYarmDialog = false
    },
    onYarmClick: function () {
      this.showYarmDialog = true
      this.checkYarmAccess()
    },
    checkYarmAccess: async function() {
      const yarmTokenExpirationTime = localStorage.getItem('yarmTokenExpirationTime')
      const yarmSavedToken = localStorage.getItem('yarmSavedToken')
      if(yarmTokenExpirationTime && yarmTokenExpirationTime > new Date().getTime() && yarmSavedToken){
        this.yarmToken = yarmSavedToken
      } else {
        this.yarmToken = null
      }
    },
    yarmLogin: async function() {
      try {
        let basicToken = btoa(this.yarmEmail + ":" + this.yarmPassword)
        let response = await this.$axios.request({
          method: 'post',
          url: `https://${this.$store.state.appconfig.apis.yarm.baseurl}/api/createToken`,
          headers: {
            'Authorization': `Basic ${basicToken}`
          }
        })
        if(response.data){
          const yarmTokenExpirationTime = new Date(response.data['expiration date'] + 'z').getTime()
          const yarmSavedToken = response.data.token
          this.yarmToken = yarmSavedToken          
          localStorage.setItem('yarmTokenExpirationTime', yarmTokenExpirationTime)
          localStorage.setItem('yarmSavedToken', yarmSavedToken)
        }
      } catch (error) {
        console.log('error', error)
      } finally {
        this.yarmLoginDialog = false
      }
    },
    yarmLogout: async function () {
      localStorage.setItem('yarmTokenExpirationTime', null)
      localStorage.setItem('yarmSavedToken', null)
      this.yarmToken = null
      this.yarmLoginDialog = false
    }
  },
  mounted: function () {
    this.checkYarmAccess()
    this.$nextTick(function () {
      this.loading = !this.vocabularies['citationpredicate'].loaded
      // emit input to set skos:prefLabel in parent
      if (this.type) {
        this.$emit('input-citation-type', this.getTerm('citationpredicate', this.type))
      }
    })
  }
}
</script>

<style scoped>
.v-btn {
  margin: 0;
}
.login-btn-container {
  display: flex;
  justify-content: center;
  margin-top: 10px;
}
</style>