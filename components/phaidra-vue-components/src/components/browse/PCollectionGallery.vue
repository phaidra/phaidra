<template>
  <v-container fluid>
    <v-row>
      <v-toolbar>
        <v-toolbar-title>Toolbar</v-toolbar-title>
        <v-spacer></v-spacer>
        <v-btn icon @click="mode = 'single'">
          <v-icon>mdi-image-outline</v-icon>
        </v-btn>
        <v-btn icon @click="mode = 'gallery'">
          <v-icon>mdi-grid</v-icon>
        </v-btn>
      </v-toolbar>
    </v-row>
    <v-row>
      <v-col md="auto">
        <v-treeview
          :items="collections"
          :load-children="getChildCollections"
          :active.sync="active"
          :open.sync="open"
          @update:active="getChildren"
          activatable
          transition
          color="primary"
        ></v-treeview>
      </v-col>
      <v-divider vertical></v-divider>
      <v-col v-if="mode === 'single'">
        <v-carousel hide-delimiters height="100%">
          <v-carousel-item v-for="(doc, i) in childrenOfActiveCollection" :key="'cha1'+i">
             <v-tooltip bottom>
              <template v-slot:activator="{ on }">
                <span v-on="on">
                   <v-img aspect-ratio="1" :src="'https://' + instanceconfig.baseurl + '/preview/' + doc.pid" @click="showDetailDialog(doc)"></v-img>
                </span>
              </template>
              <span>{{doc.dc_title[0]}}</span>
            </v-tooltip>
          </v-carousel-item>
        </v-carousel>
      </v-col>
      <v-col v-if="mode === 'gallery'">
        <v-container fluid>
          <v-row>
            <v-col class="d-flex child-flex" cols="4" v-for="(doc, i) in childrenOfActiveCollection" :key="'cha2'+i">
              <v-tooltip bottom>
                <template v-slot:activator="{ on }">
                  <span v-on="on">
                    <v-card tile elevation="0" class="d-flex">
                      <v-img class="grey lighten-2" aspect-ratio="1" :src="'https://' + instanceconfig.baseurl + '/preview/' + doc.pid"
                        @click="showDetailDialog(doc)">
                        <template v-slot:placeholder>
                          <v-row class="fill-height ma-0" align="center" justify="center">
                            <v-progress-circular indeterminate color="grey lighten-5"></v-progress-circular>
                          </v-row>
                        </template>
                      </v-img>
                    </v-card>
                  </span>
                </template>
                <span>{{doc.dc_title[0]}}</span>
              </v-tooltip>
            </v-col>
          </v-row>
        </v-container>
      </v-col>
    </v-row>
    <v-dialog v-model="detailDialog" max-width="500px" v-if="detailToShow">
      <v-card>
        <v-card-title class="title font-weight-light grey white--text">
          {{ detailToShow.dc_title[0] }}
        </v-card-title>
        <v-card-text>
          <v-img aspect-ratio="1" :src="'https://' + instanceconfig.baseurl + '/preview/' + detailToShow.pid"></v-img>
        </v-card-text>
        <v-card-actions>
          <v-spacer></v-spacer>
          <v-btn dark @click="detailDialog = false" color="grey">Abbrechen</v-btn>
          <v-btn @click="openDetails()" color="primary">Details</v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>

  </v-container>
</template>

<script>
import qs from 'qs'

export default {
  name: 'p-collection-gallery',
  props: {
    collection: {
      type: String,
      required: true
    }
  },
  computed: {
    instanceconfig: function () {
      return this.$root.$store.state.instanceconfig
    }
  },
  data () {
    return {
      active: [],
      open: [this.collection],
      collections: [
        {
          id: this.collection,
          name: 'Root',
          children: []
        }
      ],
      mode: 'gallery',
      selectedImage: {
        src: ''
      },
      childrenOfActiveCollection: [],
      detailDialog: true,
      detailToShow: null
    }
  },
  methods: {
    getChildCollections: async function (item) {
      try {
        let params = {
          q: '*:*',
          defType: 'edismax',
          wt: 'json',
          fq: 'ispartof:"' + item.id + '" AND cmodel:"Collection"',
          start: 0,
          rows: 5000
        }
        let response = await this.$http.request({
          method: 'POST',
          url: this.$store.state.instanceconfig.solr + '/select',
          data: qs.stringify(params, { arrayFormat: 'repeat' }),
          headers: {
            'content-type': 'application/x-www-form-urlencoded'
          }
        })
        let docs = response.data.response.docs
        let total = response.data.response.numFound
        if (total < 1) {
          console.log(item.id + ' has ' + total + ' members')
          return
        }
        for (let member of docs) {
          let node = {
            id: member.pid,
            name: member.dc_title,
            children: []
          }
          item.children.push(node)
        }
      } catch (error) {
        console.log(error)
        this.$store.commit('setAlerts', [{ type: 'danger', msg: error }])
      }
    },
    getChildren: async function (arr) {
      // alert('load children of: '+JSON.stringify(arr));
      // alert('load children2 of: '+arr[0]);
      try {
        let params = {
          q: '*:*',
          defType: 'edismax',
          wt: 'json',
          fq: 'ispartof:"' + arr[0] + '" AND -cmodel:"Collection"', // ReferenceError: item is not defined
          start: 0,
          rows: 5000
        }
        let response = await this.$http.request({
          method: 'POST',
          url: this.$store.state.instanceconfig.solr + '/select',
          data: qs.stringify(params, { arrayFormat: 'repeat' }),
          headers: {
            'content-type': 'application/x-www-form-urlencoded'
          }
        })

        let total = response.data.response.numFound
        if (total < 1) {
          console.log(arr[0] + ' has ' + total + ' members')
          return
        }

        this.childrenOfActiveCollection = response.data.response.docs

        // for (let doc of this.childrenOfActiveCollection) {
        //  alert('https://' + this.instanceconfig.baseurl + '/preview/' + doc.pid);
        // }
      } catch (error) {
        console.log(error)
        this.$store.commit('setAlerts', [{ type: 'danger', msg: error }])
      }
    },
    showDetailDialog: async function (doc) {
      try {
        this.detailToShow = doc
        this.detailDialog = true
      } catch (error) {
        console.log(error)
        this.$store.commit('setAlerts', [{ type: 'danger', msg: error }])
      }
    },
    openDetails: async function () {
      try {
        alert('open details for: ' + this.detailToShow.dc_title[0])
      } catch (error) {
        console.log(error)
        this.$store.commit('setAlerts', [{ type: 'danger', msg: error }])
      }
    }
  }

}
</script>
