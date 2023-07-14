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
              :sort-by="currentYear.toString()"
              :sort-desc="true"
              hide-default-footer
              class="elevation-1 my-8"
              :no-data-text="$t('No data available')"
            ></v-data-table>
            <v-data-table
              :headers="newTypeHeaders"
              :items="newTypeItems"
              :items-per-page="1000"
              :sort-by="currentYear.toString()"
              :sort-desc="true"
              hide-default-footer
              class="elevation-1 my-8"
              :no-data-text="$t('No data available')"
            ></v-data-table>
            <v-data-table
              :headers="cmodelHeaders"
              :items="cmodelItems"
              :items-per-page="1000"
              :sort-by="currentYear.toString()"
              :sort-desc="true"
              hide-default-footer
              class="elevation-1 my-8"
              :no-data-text="$t('No data available')"
            ></v-data-table>
            <v-data-table
              :headers="cmodelStorageHeaders"
              :items="cmodelStorageItems"
              :items-per-page="1000"
              :sort-by="currentYear.toString()"
              :sort-desc="true"
              hide-default-footer
              class="elevation-1 my-8"
              :no-data-text="$t('No data available')"
            ></v-data-table>
            <v-data-table
              :headers="ownerHeaders"
              :items="ownerItems"
              :items-per-page="1000"
              :sort-by="currentYear.toString()"
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

export default {
  mixins: [context, config],
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
        },
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
      ownerTypes: ["u*", "s*", "p*", "x*"],
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
      this.cmodelStorageHeaders.push({ text: "total", value: "total" });
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
            let stats = {};
            let hasValue = false;
            for (let j = 0; j < a.length; j = j + 2) {
              if (a[j + 1] > 0) {
                hasValue = true;
              }
              stats.objectType = this.$store.getters.getLocalizedTermLabel(
                "objecttypeuwm",
                term["@id"]
              );
              stats[a[j].substring(0, 4)] = a[j + 1];
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
            let stats = {};
            let hasValue = false;
            for (let j = 0; j < a.length; j = j + 2) {
              if (a[j + 1] > 0) {
                hasValue = true;
              }
              stats.objectType = this.$store.getters.getLocalizedTermLabel(
                "objecttypeuwm",
                term["@id"]
              );
              stats[a[j].substring(0, 4)] = a[j + 1];
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
            let stats = {};
            let hasValue = false;
            for (let j = 0; j < a.length; j = j + 2) {
              if (a[j + 1] > 0) {
                hasValue = true;
              }
              stats.cmodel = this.$store.getters.getLocalizedTermLabel("cmodels", term["@id"]);
              stats[a[j].substring(0, 4)] = a[j + 1];
            }
            if (hasValue) {
              this.cmodelItems.push(stats);
            }
          }
        } catch (error) {
          console.log(error);
        }
      }
      for (let type of this.ownerTypes) {
        let params = {
          q: "*:*",
          fq: "owner:" + type + "",
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
            let stats = {};
            for (let j = 0; j < a.length; j = j + 2) {
              stats.owner = type;
              stats[a[j].substring(0, 4)] = a[j + 1];
            }
            this.ownerItems.push(stats);
          }
        } catch (error) {
          console.log(error);
        }
      }
      try {
        let response = await this.$axios.get("/stats/aggregates?detail=cm&time_scale=year");
        if (response.data.alerts && response.data.alerts.length > 0) {
          this.$store.commit("setAlerts", response.data.alerts);
        }
        if (response.data.stats) {
          let stats = {
            total: {
              cmodel: "total",
              total: 0,
            },
          };
          for (let s of response.data.stats) {
            if (s.model !== "Container" && s.model !== "Collection") {
              if (s.size > 0) {
                if (!stats[s.model]) {
                  stats[s.model] = {
                    cmodel: s.model,
                    total: 0,
                  };
                }
                if (!stats["total"][s.upload_date]) {
                  stats["total"][s.upload_date] = 0;
                }
                stats[s.model][s.upload_date] = (
                  s.size / Math.pow(1024, Math.floor(3))
                ).toFixed(3);
                stats[s.model].total += s.size;
                stats["total"][s.upload_date] += s.size;
                stats["total"].total += s.size;
              }
            }
          }
          for (let i = fromYear; i <= toYear; i++) {
            stats.total[i] = (
              stats.total[i] / Math.pow(1024, Math.floor(3))
            ).toFixed(3);
          }
          for (let cmodel of Object.keys(stats)) {
            stats[cmodel].total = (
              stats[cmodel].total / Math.pow(1024, Math.floor(3))
            ).toFixed(3);
            this.cmodelStorageItems.push(stats[cmodel]);
          }
        }
      } catch (error) {
        console.log(error);
        this.$store.commit("setAlerts", [{ type: "error", msg: error }]);
      } finally {
        this.loading = false;
      }
    },
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
