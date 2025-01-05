<template>
  <v-card class="mt-2 mx-auto" :elevation="0">
    <v-card-title v-if="centertitle" class=" font-weight-light" :class="titlecolor + '--text'" style="word-break: break-word;"><div style="width:100%"><center>{{ $t(label) }}</center></div></v-card-title>
    <v-card-title v-else class=" font-weight-light" :class="titlecolor + '--text'" style="word-break: break-word;">{{ $t(label) }}</v-card-title>
    <v-card-text>
      <center>
        <router-link :to="{ path: `detail/${pid}`, params: { pid: pid } }">
          <v-img max-width="200" :src="src" class="elevation-2 mt-2" :alt="alt" :title="alt">
            <template v-slot:placeholder>
              <div class="fill-height ma-0" align="center" justify="center" >
                <v-progress-circular indeterminate color="grey lighten-5"></v-progress-circular>
              </div>
            </template>
          </v-img>
        </router-link>
      </center>
      <div class="my-6">
        <slot></slot>
      </div>
      <div>
        <router-link :to="{ path: '/search?q='+fq }">{{ $t(linklabel)  }} ({{ total }})</router-link>
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
    titlecolor: {
      type: String,
      default: 'primary'
    },
    linklabel: {
      type: String,
      default: 'More'
    },
    centertitle: {
      type: Boolean,
      default: false
    }
  },
  computed: {
    src: function () {
      if (this.doc) {
        return this.instanceconfig.api + '/object/' + this.doc.pid + '/thumbnail?w=200'
      }
      return ''
    },
    alt: function () {
      if (this.doc) {
        return this.doc.dc_title[0]
      }
      return ''
    },
    pid:  function () {
      if (this.doc) {
        return this.doc.pid
      }
      return ''
    },
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