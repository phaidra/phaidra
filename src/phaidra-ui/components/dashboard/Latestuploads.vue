<template>
  <v-card class="mt-2 mx-auto" max-width="700" :elevation="0">
    <v-card-title class="title font-weight-light primary--text">{{ $t('Latest uploads') }}</v-card-title>
    <v-card-text>
    <div v-for="(doc, i) in this.docs" :key="'doc'+i" class="pa-4">
      <v-row>
        <v-col :cols="12">
          <v-row :key="'prev'+doc.pid">
            <v-col cols="2" class="preview-maxwidth">
              <p-img :src="instanceconfig.api + '/object/' + doc.pid + '/thumbnail'" class="elevation-2 mt-2">
                <template v-slot:placeholder>
                  <div class="fill-height ma-0" align="center" justify="center" >
                    <v-progress-circular indeterminate color="grey lighten-5"></v-progress-circular>
                  </div>
                </template>
              </p-img>
            </v-col>
            <v-col cols="10">
              <v-row no-gutters class="mb-4">
                <v-col cols="10">
                  <h3 class="title font-weight-light primary--text" @click.stop v-if="doc.dc_title">
                    <router-link :to="{ path: `detail/${doc.pid}`, params: { pid: doc.pid } }">{{ doc.dc_title[0] }}</router-link>
                  </h3>
                </v-col>
                <v-spacer></v-spacer>
                <v-col cols="2" class="text-right"><span v-if="doc.created" class="grey--text">{{ doc.created | date }}</span></v-col>
              </v-row>
              <v-row no-gutters class="my-4 mr-2">
                <span class="grey--text text--darken-4">{{doc.owner}}</span>
                <v-spacer></v-spacer>
                <p-d-license v-if="doc.dc_rights" :hideLabel="true" :o="doc.dc_rights[0]"></p-d-license>
              </v-row>
            </v-col>
          </v-row>
        </v-col>
      </v-row>
      <v-divider :key="'div'+doc.pid" class="mt-6 mb-4 mr-2"></v-divider>
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
    length: Number,
  },
  data: () => ({
    docs: []
  }),
  methods: {
    async fetchDocs(self) {
      let params = {
        q: "*:*",
        rows: this.length,
        fl: "pid,dc_title,created,owner,isrestricted,dc_rights",
        sort: "tcreated desc",
        defType: "edismax",
        wt: "json",
      };
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