<template>

  <v-data-table
    :headers="headers"
    :items="templates"
    :loading="loading"
    :items-per-page="itemsPerPage"
    class="elevation-1"
    :no-data-text="$t('No data available')"
    :footer-props="{
      pageText: $t('Page'),
      itemsPerPageText: $t('Rows per page'),
      itemsPerPageAllText: $t('All')
    }"
    :no-results-text="$t('There were no search results')"
  >
    <template v-slot:item.name="{ item }">
      <v-tooltip bottom>
        <template v-slot:activator="{ on }">
          <span v-on="on">{{ item.name }}</span>
        </template>
        <span>{{ item.tid }}</span>
      </v-tooltip>
      <v-chip
        class="ma-2"
        color="primary"
        v-if="item.tid === selectedTemplateId"
      >
      Selected
      </v-chip>
    </template>
    <template v-slot:item.created="{ item }">
      {{ item.created | unixtime }}
    </template>
    <template v-slot:item.load="{ item }">
      <v-btn text color="primary" @click="loadTemplate('')" v-if="isDefaultSelect && item.tid === selectedTemplateId">
        <span v-if="isDefaultSelect">{{ $t('Remove') }}</span>
      </v-btn>
      <v-btn text color="primary" @click="loadTemplate(item.tid)" v-else>
        <span v-if="isDefaultSelect">{{ $t('Select') }}</span>
        <span v-else-if="item.tid !== selectedTemplateId">{{ $t('Load') }}</span>
      </v-btn>
      <v-btn v-if="!isDefaultSelect" text color="red lighten-1" @click="deleteTemplate(item.tid)">{{ $t('Delete') }}</v-btn>
    </template>
  </v-data-table>

</template>

<script>

export default {
  name: 'p-templates',
  props: {
    tag: {
      type: String
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
      headers: [],
      templates: [],
      deletetempconfirm: false,
      loading: false
    }
  },
  watch: {
     '$i18n.locale': {
        immediate: true, // Ensure it's set on load
        handler() {
          this.headers = [
            { text: this.$t('Name'), align: 'left', value: 'name' },
            { text: this.$t('Created'), align: 'right', value: 'created' },
            { text: this.$t('Actions'), align: 'right', value: 'load', sortable: false }
          ];
        }
     }
  },
  methods: {
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
            'X-XSRF-TOKEN': this.$store.state.user.token
          }
        })
        if (response.data.alerts && response.data.alerts.length > 0) {
          this.$store.commit('setAlerts', response.data.alerts)
        }
        this.$emit('load-template', response.data.template)
      } catch (error) {
        console.log(error)
        this.$store.commit('setAlerts', [{ type: 'danger', msg: error }])
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
            url: '/jsonld/template/' + tid + '/remove',
            headers: {
              'X-XSRF-TOKEN': this.$store.state.user.token
            }
          })
          if (response.data.alerts && response.data.alerts.length > 0) {
            this.$store.commit('setAlerts', response.data.alerts)
          }
          this.deletetempconfirm = false
          this.loadTemplates()
        } catch (error) {
          console.log(error)
          this.$store.commit('setAlerts', [{ type: 'danger', msg: error }])
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
          url: '/jsonld/templates' + ((this.tag && this.tag.length > 1) ? '?tag=' + this.tag : ''),
          headers: {
            'X-XSRF-TOKEN': this.$store.state.user.token
          }
        })
        if (response.data.alerts && response.data.alerts.length > 0) {
          this.$store.commit('setAlerts', response.data.alerts)
        }
        this.templates = response.data.templates
        this.loading = false
      } catch (error) {
        console.log(error)
        this.$store.commit('setAlerts', [{ type: 'danger', msg: error }])
      } finally {
        this.loading = false
      }
    }
  },
  mounted: function () {
    if (this.$store.state.user.token) {
      this.loadTemplates()
    }
  }
}
</script>
