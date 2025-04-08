<template>
  <div class="pt-4 mx-auto">
    <v-data-table
      :headers="cmodelHeaders"
      :items="cmodelItems"
      :items-per-page="1000"
      :sort-by="'total'"
      :sort-desc="true"
      hide-default-footer
      class="elevation-1 my-8"
      :no-data-text="$t('No data available')"
      hide-default-header
    >
    <template v-slot:header="{ props: { headers } }">
      <thead>
        <tr>
          <th v-for="h in headers">
            <span>{{h.text}}</span>
          </th>
        </tr>
      </thead>
  </template>
  </v-data-table>
  </div>
</template>

<script>
import qs from "qs";
import { context } from "../../mixins/context";
import { config } from "../../mixins/config";
import { vocabulary } from 'phaidra-vue-components/src/mixins/vocabulary'

export default {
  mixins: [context, config, vocabulary],
  computed: {
    routepid: function () {
      return this.$store.state.route.params.pid;
    },
    currentYear: function () {
      return new Date().getFullYear();
    },
  },
  data() {
    return {
      cmodelHeaders: [
        {
          text: "Content models",
          align: "start",
          sortable: false,
          value: "cmodel",
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
        this.cmodelHeaders.push({ text: i.toString(), value: i.toString() });
      }
      this.cmodelHeaders.push({ text: "Total", value: "total" });
      for (let term of this.$store.state.vocabulary.vocabularies["cmodels"].terms) {
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
      vm.$store.commit("setLoading", true);
      await vm.fetchStats(vm);
      vm.$store.commit("setLoading", false);
    });
  },
  beforeRouteUpdate: async function (to, from, next) {
    this.$store.commit("setLoading", true);
    await this.fetchStats(this);
    this.$store.commit("setLoading", false);
    next();
  },
  async mounted() {
    await this.fetchStats(this);
  }
};
</script>