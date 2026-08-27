<template>
  <div class="pt-4 mx-auto">
    <v-data-table
      :headers="cmodelHeaders"
      :items="cmodelItems"
      :items-per-page="1000"
      :sort-by="[{ key: 'total', order: 'desc' }]"
      hide-default-footer
      class="elevation-1 my-8"
      :no-data-text="$t('No data available')"
    ></v-data-table>
  </div>
</template>

<script>
import { useRootStore } from '~/stores/root'
import { useVocabularyStore } from 'phaidra-vue-components/src/stores/vocabulary'
import qs from "qs";
import { context } from "../../mixins/context";
import { config } from "../../mixins/config";
import { vocabulary } from 'phaidra-vue-components/src/mixins/vocabulary'

export default {
  mixins: [context, config, vocabulary],
  computed: {
    routepid: function () {
      return this.$route.params.pid;
    },
    currentYear: function () {
      return new Date().getFullYear();
    },
  },
  data() {
    return {
      cmodelHeaders: [
        {
          title: "Content models",
          align: "start",
          sortable: false,
          key: "cmodel",
        },
      ],
      cmodelItems: [],
      yearsTotal: [],
      total: 0,
    };
  },
  methods: {
    async fetchStats(self) {
      self.cmodelItems = [];
      let fromYear = parseInt(new Date().getFullYear());
      if (self.instanceconfig.since) {
        fromYear = self.instanceconfig.since.substring(0, 4);
      }
      let toYear = new Date().getFullYear();
      for (let i = fromYear; i <= toYear; i++) {
        this.cmodelHeaders.push({ title: i.toString(), key: i.toString() });
      }
      this.cmodelHeaders.push({ title: "Total", key: "total" });
      const terms = useVocabularyStore()?.vocabularies?.cmodels?.terms
      if (!terms?.length) {
        return
      }
      for (let term of terms) {
        let params = {
          q: "*:*",
          fq: 'cmodel:"' + term["@id"] + '"',
          facet: "on",
          rows: 0,
          "facet.range": "tcreated",
          "f.tcreated.facet.range.start": fromYear + "-01-01T00:00:00Z",
          "f.tcreated.facet.range.end": "NOW",
          "f.tcreated.facet.range.gap": "+1YEAR",
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
          if (response.data.facet_counts.facet_ranges.tcreated.counts) {
            let a = response.data.facet_counts.facet_ranges.tcreated.counts;
            let stats = {total: 0};
            let hasValue = false;
            for (let j = 0; j < a.length; j = j + 2) {
              if (a[j + 1] > 0) {
                hasValue = true;
              }
              stats.cmodel = this.getLocalizedTermLabel("cmodels", term["@id"]);
              stats[a[j].substring(0, 4)] = a[j + 1];
              stats.total += a[j + 1]
            }
            if (hasValue) {
              this.cmodelItems.push(stats);
            }
          }
        } catch (error) {
          console.log(error);
        }
      }
    },
    tofixed(x) {
      return Number.parseFloat(x).toFixed(3);
    }
  },
  beforeRouteEnter: async function (to, from, next) {
    next(async function (vm) {
      useRootStore().setLoading(true);
      await vm.fetchStats(vm);
      useRootStore().setLoading(false);
    });
  },
  beforeRouteUpdate: async function (to, from, next) {
    useRootStore().setLoading(true);
    await this.fetchStats(this);
    useRootStore().setLoading(false);
    next();
  },
  async mounted() {
    await this.fetchStats(this);
  }
};
</script>