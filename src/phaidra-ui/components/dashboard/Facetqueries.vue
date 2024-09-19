<template>
  <v-card class="mt-2 mx-auto" :elevation="0">
    <v-card-text>
      <ul class="main-ul">
        <li v-for="(q, i) in facetqueries" :key="i">
          <a :href="'/search?fq='+q.query.replace(':','_')"><span class="facet-label primary--text">{{ $t(q.label) }}</span><span class="facet-count grey--text" v-if="facet_queries[q.query] > 0">({{ facet_queries[q.query] }})</span></a>
        </li>
      </ul>
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
    facetqueries: Array
  },
  data: () => ({
    facet_queries: {}
  }),
  methods: {
    async fetchFacet(self) {
      let params = {
        q: "*:*",
        rows: 0,
        facet: true,
        fl: "pid,dc_title",
        fq: 'owner:* AND -hassuccessor:* AND -ismemberof:["" TO *]',
        sort: "tcreated desc",
        defType: "edismax",
        wt: "json",
        'facet.query': []
      };
      for (let q of this.facetqueries) {
        params['facet.query'].push(q.query)
      }
      let query = qs.stringify(params, {
        encodeValuesOnly: true,
        indices: false,
        arrayFormat: 'repeat'
      });
      try {
        let response = await self.$axios.get(
          "/search/select?" + query
        );
        if (response?.data?.facet_counts?.facet_queries) {
          this.facet_queries = response?.data?.facet_counts?.facet_queries
        }
      } catch (error) {
        console.log(error);
      }
    },
  },
  async mounted() {
    await this.fetchFacet(this);
  }
}
</script>

<style lang="stylus" scoped>
ul
  list-style: none
  padding-left: 1em

.facet-label
  cursor: pointer

.facet-count
  margin-left: 5px
</style>