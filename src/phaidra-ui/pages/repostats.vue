<template>
  <v-container>
    <v-row justify="center">
      <v-col>
        <v-card tile>
          <v-card-title class="title font-weight-light grey white--text">{{
            $t("Repository statistics")
          }}</v-card-title>
          <v-card-text>
            <v-data-table
              :headers="typeHeaders"
              :items="typeItems"
              :items-per-page="1000"
              :sort-by="'total'"
              :sort-desc="true"
              hide-default-footer
              class="elevation-1 my-8"
              :no-data-text="$t('No data available')"
            ></v-data-table>
            <v-data-table
              :headers="newTypeHeaders"
              :items="newTypeItems"
              :items-per-page="1000"
              :sort-by="'total'"
              :sort-desc="true"
              hide-default-footer
              class="elevation-1 my-8"
              :no-data-text="$t('No data available')"
            ></v-data-table>
            <v-data-table
              :headers="cmodelHeaders"
              :items="cmodelItems"
              :items-per-page="1000"
              :sort-by="'total'"
              :sort-desc="true"
              hide-default-footer
              class="elevation-1 my-8"
              :no-data-text="$t('No data available')"
            ></v-data-table>
            <v-data-table
              :headers="cmodelStorageHeaders"
              :items="cmodelStorageItems"
              :items-per-page="1000"
              :sort-by="'total'"
              :sort-desc="true"
              hide-default-footer
              class="elevation-1 my-8"
              :no-data-text="$t('No data available')"
            ></v-data-table>
          </v-card-text>
        </v-card>
      </v-col>
    </v-row>
  </v-container>
</template>

<script>
import qs from "qs";
import { context } from "../mixins/context";
import { config } from "../mixins/config";
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
      typeHeaders: [
        {
          text: "Object types",
          align: "start",
          sortable: false,
          value: "objectType",
        },
      ],
      newTypeHeaders: [
        {
          text: "New object types",
          align: "start",
          sortable: false,
          value: "objectType",
        },
      ],
      cmodelHeaders: [
        {
          text: "Content models",
          align: "start",
          sortable: false,
          value: "cmodel",
        },
      ],
      cmodelStorageHeaders: [
        {
          text: "Storage approx. (GB)",
          align: "start",
          sortable: false,
          value: "cmodel",
        }
      ],
      ownerHeaders: [
        {
          text: "Owner",
          align: "start",
          sortable: false,
          value: "owner",
        },
      ],
      typeItems: [],
      newTypeItems: [],
      cmodelItems: [],
      cmodelStorageItems: [],
      ownerItems: [],
      yearsTotal: [],
      newTypesFilter: {
        "https://pid.phaidra.org/vocabulary/9E94-E3F8": true,
        "https://pid.phaidra.org/vocabulary/P2YP-BMND": true,
        "https://pid.phaidra.org/vocabulary/1PHE-7VMS": true,
        "https://pid.phaidra.org/vocabulary/ST05-F6SP": true,
        "https://pid.phaidra.org/vocabulary/9ZSV-CVJH": true,
      },
      total: 0,
    };
  },
  methods: {


    async fetchStats(self) {
      self.typeItems = [];
      self.cmodelItems = [];
      self.cmodelStorageItems = [];
      let fromYear = parseInt(new Date().getFullYear());
      if (self.instanceconfig.since) {
        fromYear = self.instanceconfig.since.substring(0, 4);
      }
      let toYear = new Date().getFullYear();
      for (let i = fromYear; i <= toYear; i++) {
        this.typeHeaders.push({ text: i.toString(), value: i.toString() });
        this.newTypeHeaders.push({ text: i.toString(), value: i.toString() });
        this.cmodelHeaders.push({ text: i.toString(), value: i.toString() });
        this.cmodelStorageHeaders.push({
          text: i.toString(),
          value: i.toString(),
        });
        this.ownerHeaders.push({ text: i.toString(), value: i.toString() });
      }
      this.typeHeaders.push({ text: "Total", value: "total" });
      this.newTypeHeaders.push({ text: "Total", value: "total" });
      this.cmodelHeaders.push({ text: "Total", value: "total" });
      this.cmodelStorageHeaders.push({ text: "Total", value: "total" });
      for (let term of this.$store.state.vocabulary.vocabularies["objecttypeuwm"].terms) {
        let params = {
          q: "*:*",
          fq: 'object_type_id:"' + term["@id"] + '"',
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
            let stats = { total: 0 };
            let hasValue = false;
            for (let j = 0; j < a.length; j = j + 2) {
              if (a[j + 1] > 0) {
                hasValue = true;
              }
              stats.objectType = this.getLocalizedTermLabel(
                "objecttypeuwm",
                term["@id"]
              );
              stats[a[j].substring(0, 4)] = a[j + 1];
              stats.total += a[j + 1]
            }
            if (hasValue) {
              this.typeItems.push(stats);
            }
          }
        } catch (error) {
          console.log(error);
        }
      }
      for (let term of this.$store.state.vocabulary.vocabularies["objecttype"].terms) {
        let params = {
          q: "*:*",
          fq: 'object_type_id:"' + term["@id"] + '"',
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
              stats.objectType = this.getLocalizedTermLabel(
                "objecttype",
                term["@id"]
              );
              stats[a[j].substring(0, 4)] = a[j + 1];
              stats.total += a[j + 1]
            }
            if (hasValue) {
              this.newTypeItems.push(stats);
            }
          }
        } catch (error) {
          console.log(error);
        }
      }
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

      for (let term of this.$store.state.vocabulary.vocabularies["cmodels"].terms) {
            let cmodel = term["@id"]

        let stats = {
          cmodel,
          total: 0
        };

        for (let i = fromYear; i <= toYear; i++) {

          try {
            let year = i
          
            let params = {
              q: '*:*',
              stats: true,
              'stats.field': 'size',
              fq: 'cmodel:' + cmodel + ' AND tcreated:[' + year + '-01-01T00:00:00Z TO ' + year + '-12-31T23:59:59Z]',//AND -ismemberof:["" TO *]
              rows: 0
            }
            if (cmodel === 'Page') {
              params.core = 'phaidra_pages'
            }
            let query = qs.stringify(params, {
              encodeValuesOnly: true,
              indices: false,
            });
            let res = await self.$axios.get(
              "/search/select?" + query
            );        
            if (res.status == 200) {
              let gb = res.data.stats.stats_fields.size.sum/1000000000
              stats.total += res.data.stats.stats_fields.size.sum
              stats[year] = gb > 0 ? this.tofixed(gb) : 0
            }
          } catch (error) {
            console.log(error);
          }
            
        }
        stats.total = stats.total > 0 ? this.tofixed(stats.total/1000000000) : 0
        this.cmodelStorageItems.push(stats)
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
  mounted() {
    console.log('this.$store', this.$store)
  }
};
</script>
