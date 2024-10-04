<template>
  <v-card class="mt-2 mx-auto" :elevation="0">
    <v-card-title class="title font-weight-light primary--text">{{ $t(label) }}</v-card-title>
    <v-card-text>
      <center>
        <v-img max-width="200" :src="src" class="elevation-2 mt-2" :alt="alt">
          <template v-slot:placeholder>
            <div class="fill-height ma-0" align="center" justify="center" >
              <v-progress-circular indeterminate color="grey lighten-5"></v-progress-circular>
            </div>
          </template>
        </v-img>
      </center>
      <p class="mt-4">{{ $t(text) }}</p>
      <div>
        <router-link :to="{ path: '/search?q='+fq }">{{ $t('More') }} ({{ total }})</router-link>
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
    label: String,
    text: String,
    fq: String,
  },
  computed: {
    src: function () {
      if (this.doc) {
        return this.instanceconfig.api + '/object/' + this.doc.pid + '/thumbnail'
      }
      return ''
    },
    alt: function () {
      if (this.doc) {
        return this.doc.dc_title[0]
      }
      return ''
    }
  },
  data: () => ({
    doc: null,
    total: 0
  }),
  methods: {
    async fetchDocs(self) {
      let params = {
        q: "*:*",
        rows: 1,
        fl: "pid,dc_title",
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
          this.doc = response?.data?.response?.docs[0]
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