<template>

  <v-data-table
    v-model:sort-by="tableSortBy"
    :headers="headers"
    :search="templateSearch"
    :items="templates"
    :loading="loading"
    :items-per-page="itemsPerPage"
    :class="{'elevation-1': type !== 'navtemplate'}"
    :no-data-text="$t('No data available')"
    :page-text="$t('Page')"
    :items-per-page-text="$t('Rows per page')"
    :items-per-page-options="itemsPerPageOptions"
    :no-results-text="$t('There were no search results')"
  >
    <template v-slot:top>
      <v-toolbar flat color="transparent">
        <v-text-field
          v-model="templateSearch"
          append-inner-icon="mdi-magnify"
          :label="$t('Search...')"
          single-line
          hide-details
        ></v-text-field>
      </v-toolbar>
    </template>
    <template v-slot:item.name="{ item }">
      <v-tooltip location="bottom">
        <template v-slot:activator="{ props: activatorProps }">
          <span v-bind="activatorProps">{{ item.name }}</span>
        </template>
        <span>{{ item.tid }}</span>
      </v-tooltip>
      <v-chip
        class="ma-2 pointer-disabled"
        color="primary"
        v-if="item.tid === selectedTemplateId"
      >
      {{ $t('Selected') }}
      </v-chip>
    </template>    
    <template v-if="type === 'navtemplate' && useRootStore().user.isadmin" v-slot:item.public="{ item }">
      <v-checkbox v-model="item.public" @change="onPublicValChange(item)"></v-checkbox>
    </template>
    <template v-if="type === 'navtemplate'" v-slot:item.validationfnc="{ item }">
      {{ item.validationfnc || '' }}
    </template>
    <template v-slot:item.created="{ item }">
      {{ $unixtime(item.created) }}
    </template>
    <template v-slot:item.load="{ item }">
      <v-btn variant="text" color="primary" @click="editValidation(item)" v-if="type === 'navtemplate' && useRootStore().user.isadmin">
        <span>{{ $t('Edit Validation') }}</span>
      </v-btn>
      <v-btn variant="text" color="primary" @click="loadTemplate('')" v-if="isDefaultSelect && item.tid === selectedTemplateId">
        <span v-if="isDefaultSelect">{{ $t('Remove') }}</span>
      </v-btn>
      <v-btn variant="text" color="primary" @click="loadTemplate(item.tid)" v-else>
        <span v-if="isDefaultSelect">{{ $t('Select') }}</span>
        <span v-else-if="item.tid !== selectedTemplateId">{{ $t('Load') }}</span>
      </v-btn>
      <v-btn v-if="!isDefaultSelect" variant="text" color="btnred" @click="deleteTemplate(item.tid)">{{ $t('Delete') }}</v-btn>
    </template>
  </v-data-table>

</template>

<script>
import { useHostRootStore as useRootStore } from '../../stores/host-root'

export default {
  name: 'p-templates',
  props: {
    tag: {
      type: String
    },
    type: {
      type: String,
      default: 'popup'
    },
    itemsPerPage: {
      type: Number,
      default: 10
    },
    idOnly: {
      type: Boolean,
      default: false
    },
    selectedTemplateId: {
      type: String,
      default: ""
    },
    isDefaultSelect: {
      type: Boolean,
      default: false
    }
  },
  data () {
    return {
      /** Vuetify 3 data table requires sort-by to stay an array (see sortBy.value.find in headers). */
      tableSortBy: [],
      headers: [],
      templates: [],
      deletetempconfirm: false,
      loading: false,
      templateSearch: '',
    }
  },
  computed: {
    itemsPerPageOptions () {
      return [
        { value: 5, title: '5' },
        { value: 10, title: '10' },
        { value: 25, title: '25' },
        { value: 50, title: '50' },
        { value: 100, title: '100' },
        { value: -1, title: this.$t('All') }
      ]
    }
  },
  watch: {
     '$i18n.locale': {
        immediate: true, // Ensure it's set on load
        handler() {
          this.headers = [
            { title: this.$t('Name'), align: 'start', key: 'name' },
            { title: this.$t('Created'), align: 'end', key: 'created' },
          ];
          if(this.type === 'navtemplate' && useRootStore().user.isadmin) {
            this.headers.unshift({ title: this.$t('Public'), align: 'start', key: 'public' })
          }
          if(useRootStore().user.isadmin) {
            this.headers.push({ title: this.$t('Validation'), align: 'start', key: 'validationfnc' })
          }
          this.headers.push({ title: this.$t('Actions'), align: 'end', key: 'load', sortable: false })
        }
     }
  },
  methods: {
     async onPublicValChange(item) {
       this.$emit('public-toggle', item)
    },
    editValidation: async function (item) {
       this.$emit('edit-validation', item)
    },
    loadTemplate: async function (tid) {
      if (this.idOnly) {
        this.$emit('load-template', tid)
        return
      }
      this.loading = true
      try {
        let response = await this.$axios.request({
          method: 'GET',
          url: '/jsonld/template/' + tid,
          headers: {
            'X-XSRF-TOKEN': useRootStore().user.token
          }
        })
        if (response.data.alerts && response.data.alerts.length > 0) {
          useRootStore().setAlerts(response.data.alerts)
        }
        this.$emit('load-template', response.data.template)
      } catch (error) {
        console.log(error)
        useRootStore().setAlerts([{ type: 'danger', msg: error }])
      } finally {
        this.loading = false
      }
    },
    deleteTemplate: async function (tid) {
      if (confirm(this.$t('Are you sure you want to delete this template?'))) {
        this.loading = true
        try {
          let response = await this.$axios.request({
            method: 'POST',
            url: '/jsonld/template/' + (useRootStore().user.isadmin ? 'admin/' : '')  + tid + '/remove',
            headers: {
              'X-XSRF-TOKEN': useRootStore().user.token
            }
          })
          if (response.data.alerts && response.data.alerts.length > 0) {
            useRootStore().setAlerts(response.data.alerts)
          }
          this.deletetempconfirm = false
          this.loadTemplates()
        } catch (error) {
          console.log(error)
          useRootStore().setAlerts([{ type: 'danger', msg: error }])
        } finally {
          this.loading = false
        }
      }
    },
    loadTemplates: async function () {
      this.loading = true
      try {
        let response = await this.$axios.request({
          method: 'GET',
          url: '/jsonld/templates' + (useRootStore().user.isadmin ? '/admin' : '')  + ((this.tag && this.tag.length > 1) ? '?tag=' + this.tag : ''),
          headers: {
            'X-XSRF-TOKEN': useRootStore().user.token
          }
        })
        if (response.data.alerts && response.data.alerts.length > 0) {
          useRootStore().setAlerts(response.data.alerts)
        }
        this.templates = response.data.templates
        this.loading = false
      } catch (error) {
        console.log(error)
        useRootStore().setAlerts([{ type: 'danger', msg: error }])
      } finally {
        this.loading = false
      }
    }
  },
  mounted: function () {
    if (useRootStore().user.token) {
      this.loadTemplates()
    }
  }
}
</script>
