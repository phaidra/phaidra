<template>
  <v-card class="mt-2 mx-auto" :elevation="0">
    <div v-if="centertitle" class="font-weight-light text-h6" :class="titleClass" style="word-break: break-word;">{{ $t(label) }}</div>
    <div v-else class="font-weight-light text-h6" :class="titleClass" style="word-break: break-word;">{{ $t(label) }}</div>
    <v-card-text :class="textcenter ? 'text-center justify-center' : ''">
      <div>
        <nuxt-link :to="{ path: '/search?q='+fq }">{{ $t(linklabel)  }} ({{ total }})</nuxt-link>
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
    textcenter: {
      type: Boolean,
      default: false
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
    pid:  function () {
      if (this.doc) {
        return this.doc.pid
      }
      return ''
    },
    titleClass: function () {
      let c = ''
      if (this.titlecolor) {
        c += this.titlecolor + '--text'
      }
      if (this.textcenter) {
        c += ' text-center justify-center'
      }
      return c
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