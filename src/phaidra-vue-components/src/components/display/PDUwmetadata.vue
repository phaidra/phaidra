<template>
  <v-col v-if="this.indexdata">
    <v-col v-for="(title,i) in getTitles()" :key="'title'+i" class="mt-3">
      <v-container fluid>
        <v-row >
          <v-col class="caption grey--text" cols="2">{{ $t('Title') }} ({{ title.lang }})</v-col>
          <v-col cols="9">{{ title.value }}</v-col>
        </v-row>
      </v-container>
    </v-col>

    <v-col v-for="(role,i) in parsedRolesUwm()" :key="'role'+i" class="mt-3">
      <v-container fluid>
        <v-row >
          <v-col class="caption grey--text" cols="2">{{ role.label }}</v-col>
          <v-col cols="9">
            <v-row>
              <v-col v-for="(entity,j) in role.entities" :key="j">
                {{ entity.firstname }} {{ entity.lastname }} <span class="grey--text">{{ entity.institution }}</span>
              </v-col>
            </v-row>
          </v-col>
        </v-row>
      </v-container>
    </v-col>

    <v-col v-if="indexdata.bib_journal" class="mt-3">
      <v-container fluid>
        <v-row >
          <v-col class="caption grey--text" cols="2">{{ $t('Journal') }}</v-col>
          <v-col cols="9">
            <v-row>
              <v-col v-for="(v,i) in indexdata.bib_journal" :key="i">{{v}}</v-col>
            </v-row>
          </v-col>
        </v-row>
      </v-container>
    </v-col>

    <v-col v-if="indexdata.bib_volume" class="mt-3">
      <v-container fluid>
        <v-row >
          <v-col class="caption grey--text" cols="2">{{ $t('Volume') }}</v-col>
          <v-col cols="9">
            <v-row>
              <v-col v-for="(v,i) in indexdata.bib_volume" :key="i">{{v}}</v-col>
            </v-row>
          </v-col>
        </v-row>
      </v-container>
    </v-col>

    <v-col v-if="indexdata.bib_publisher" class="mt-3">
      <v-container fluid>
        <v-row >
          <v-col class="caption grey--text" cols="2">{{ $t('Publisher') }}</v-col>
          <v-col cols="9">
            <v-row>
              <v-col v-for="(v,i) in indexdata.bib_publisher" :key="i">{{v}}</v-col>
            </v-row>
          </v-col>
        </v-row>
      </v-container>
    </v-col>

    <v-col v-if="indexdata.bib_published" class="mt-3">
      <v-container fluid>
        <v-row >
          <v-col class="caption grey--text" cols="2">{{ $t('Published') }}</v-col>
          <v-col cols="9">
            <v-row>
              <v-col v-for="(v,i) in indexdata.bib_published" :key="i">{{v}}</v-col>
            </v-row>
          </v-col>
        </v-row>
      </v-container>
    </v-col>

    <v-col v-if="indexdata.bib_publisherlocation" class="mt-3">
      <v-container fluid>
        <v-row >
          <v-col class="caption grey--text" cols="2">{{ $t('Publisher location') }}</v-col>
          <v-col cols="9">
            <v-row>
              <v-col v-for="(v,i) in indexdata.bib_publisherlocation" :key="i">{{v}}</v-col>
            </v-row>
          </v-col>
        </v-row>
      </v-container>
    </v-col>

    <v-col v-for="(desc,i) in getDescriptions()" :key="'desc'+i" class="mt-3">
      <v-container fluid>
        <v-row >
          <v-col class="caption grey--text" cols="2">{{ $t('Description') }} ({{ desc.lang }})</v-col>
          <v-col cols="9">{{ desc.value }}</v-col>
        </v-row>
      </v-container>
    </v-col>

    <v-col class="mt-3" v-if="indexdata.dc_license">
      <v-container fluid>
        <v-row >
          <v-col class="caption grey--text" cols="2">{{ $t('License') }}</v-col>
          <v-col cols="9">
            <p-d-license v-if="indexdata.dc_license" :dclicense="indexdata.dc_license[0]"></p-d-license>
          </v-col>
        </v-row>
      </v-container>
    </v-col>
  </v-col>
</template>

<script>
import PDLicense from './PDLicense'
import { vocabulary } from '../../mixins/vocabulary'
import { displayproperties } from '../../mixins/displayproperties'

export default {
  name: 'p-d-uwmetadata',
  mixins: [vocabulary, displayproperties],
  props: {
    pid: {
      type: String
    },
    indexdata: {
      type: Object,
      default: null
    }
  },
  components: {
    PDLicense
  },
  methods: {
    getRoleLabel: function (role) {
      var id = role.substring(role.indexOf(':') + 1)
      var roleTerms = this.vocabularies['rolepredicate'].terms
      for (var i = 0; i < roleTerms.length; i++) {
        if (roleTerms[i]['@id'] === id) {
          return roleTerms[i]['skos:prefLabel'][0]['@value']
        }
      }
    },
    getTitles: function () {
      var titles = []
      var doc = this.indexdata
      Object.keys(doc).forEach(function (field) {
        if (field.startsWith('dc_title_')) {
          for (var i = 0; i < doc[field].length; i++) {
            titles.push({ value: doc[field][i], lang: field.substr(field.length - 3) })
          }
        }
      })
      return titles
    },
    getDescriptions: function () {
      var descriptions = []
      var doc = this.indexdata
      Object.keys(doc).forEach(function (field) {
        if (field.startsWith('dc_description_')) {
          for (var i = 0; i < doc[field].length; i++) {
            descriptions.push({ value: doc[field][i], lang: field.substr(field.length - 3) })
          }
        }
      })
      return descriptions
    },
    parsedRolesUwm: function () {
      var rolesHash = {}
      if (this.indexdata.uwm_roles_json) {
        var sortedContr = JSON.parse(this.indexdata.uwm_roles_json).sort(function (a, b) {
          return a.data_order - b.data_order
        })
        for (var i = 0; i < sortedContr.length; i++) {
          sortedContr[i].entities = sortedContr[i].entities.sort(function (a, b) {
            return a.data_order - b.data_order
          })
          // merge multiple entities and multiple contributions if they have the same role
          if (!rolesHash[sortedContr[i].role]) {
            rolesHash[sortedContr[i].role] = {
              role: sortedContr[i].role,
              label: this.getRoleLabel(sortedContr[i].role),
              entities: []
            }
          }
          for (var j = 0; j < sortedContr[i].entities.length; j++) {
            rolesHash[sortedContr[i].role]['entities'].push(sortedContr[i].entities[j])
          }
        }
      }
      var roles = []
      Object.keys(rolesHash).forEach(function (r) {
        roles.push(rolesHash[r])
      })
      return roles
    }
  }
}
</script>
