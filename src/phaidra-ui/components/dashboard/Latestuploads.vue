<template>
  <v-card class="mt-2 mx-auto" :elevation="0" color="transparent">
    <div class="title font-weight-light transparent text-h6" :class="titlecolor ? titlecolor + '--text' : ''">{{ $t(label) }}</div>
    <v-card-text>
      <div v-for="(doc, i) in this.docs" :key="'doc'+i" class="pa-4">
        <v-row>
          <v-col :cols="12">
            <v-row :key="'prev'+doc.pid">
              <v-col cols="2" class="preview-maxwidth">
                <nuxt-link :to="{ path: `detail/${doc.pid}`, params: { pid: doc.pid } }">
                  <p-img :src="instanceconfig.api + '/object/' + doc.pid + '/thumbnail'" class="elevation-2 mt-2" :alt="doc.dc_title ? doc.dc_title[0] : doc.pid">
                    <template v-slot:placeholder>
                      <div class="fill-height ma-0" align="center" justify="center" >
                        <v-progress-circular indeterminate color="grey lighten-5"></v-progress-circular>
                      </div>
                    </template>
                  </p-img>
                </nuxt-link>
              </v-col>
              <v-col cols="10">
                <v-row no-gutters class="mb-4">
                  <v-col cols="10">
                    <span class="primary--text" @click.stop v-if="doc.dc_title">
                      <nuxt-link :to="{ path: `detail/${doc.pid}`, params: { pid: doc.pid } }">{{ doc.dc_title[0] }}</nuxt-link>
                    </span>
                  </v-col>
                  <v-spacer></v-spacer>
                </v-row>
                <v-row no-gutters class="my-2 mr-2">
                  <span v-for="(aut,i) in doc.bib_roles_pers_aut" :key="'pers'+i">
                    {{aut}}<span v-if="(i+1) < doc.bib_roles_pers_aut.length">; </span>
                  </span>
                  <v-spacer></v-spacer>
                </v-row>
              </v-col>
            </v-row>
          </v-col>
        </v-row>
        <v-divider :key="'div'+doc.pid" class="mt-4 mb-2 mr-2"></v-divider>
      </div>
      <div>
        <nuxt-link :to="{ path: '/search?q='+fq }">{{ $t(linklabel) }} ({{ total }})</nuxt-link>
      </div>
    </v-card-text>
  </v-card>
</template>

<script>
import qs from "qs";
import { context } from "../../mixins/context";
import { config } from "../../mixins/config";

export default {
  mixins: [context, config],
  props: {
    label: {
      type: String,
      default: 'Latest uploads'
    },
    fq: {
      type: String,
      default: '*:*'
    },
    length: Number,
    titlecolor: {
      type: String,
      default: ''
    },
    linklabel: {
      type: String,
      default: 'More'
    }
  },
  data: () => ({
    docs: [],
    total: 0
  }),
  methods: {
    async fetchDocs(self) {
      let params = {
        q: "*:*",
        rows: this.length,
        fl: "pid,dc_title,created,owner,isrestricted,dc_rights,bib_roles_pers_aut",
        sort: "tcreated desc",
        defType: "edismax",
        wt: "json",
      };
      if (self.fq) {
        params.fq = self.fq
      }
      let query = qs.stringify(params, {
        encodeValuesOnly: true,
        indices: false,
      });
      try {
        let response = await self.$axios.get(
          "/search/select?" + query
        );
        if (response?.data?.response?.docs) {
          this.docs = response?.data?.response?.docs
          this.total = response?.data?.response?.numFound
        }
      } catch (error) {
        console.log(error);
      }
    },
  },
  async mounted() {
    await this.fetchDocs(this);
  }
}
</script>

<style>
.v-sheet--offset {
  top: -24px;
  position: relative;
}
</style>