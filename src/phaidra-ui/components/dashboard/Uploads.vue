<template>
  <v-card class="mt-2 mx-auto" flat>
    <v-card-title class="title font-weight-light primary--text">{{ $t('Objects uploaded last year') }}</v-card-title>
    <v-card-text>
      <v-sheet class="mx-auto mt-6" color="grey" elevation="12" max-width="calc(100% - 32px)">
        <v-sparkline :labels="labels" :value="value" color="white" line-width="2" padding="16"></v-sparkline>
      </v-sheet>
      <v-row class="title font-weight-light grey--text mt-8 ml-4">
        <span>Total objects {{total}}</span>
        <v-spacer></v-spacer>
        <v-icon class="mr-2">
          mdi-clock
        </v-icon>
        <span class="grey--text font-weight-light mr-6" v-show="lastUpload">last upload {{ lastUpload }} ago</span>
      </v-row>
    </v-card-text>
  </v-card>
</template>

<script>
import qs from "qs";
import { context } from "../../mixins/context";
import { config } from "../../mixins/config";

export default {
  mixins: [context, config],
  computed: {
    currentYear: function () {
      return new Date().getFullYear();
    }
  },
  data: () => ({
    total: 0,
    labels: [],
    value: [],
    lastUpload: ''
  }),
  methods: {
    async fetchStats(self) {
      let params = {
        q: "*:*",
        facet: "on",
        rows: 1,
        fl: "tcreated",
        sort: "tcreated desc",
        "facet.range": "tcreated",
        "f.tcreated.facet.range.start": "NOW-1YEAR",
        "f.tcreated.facet.range.end": "NOW",
        "f.tcreated.facet.range.gap": "+1MONTH",
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
        this.total = response?.data?.response?.numFound;
        let shortMonthName = new Intl.DateTimeFormat("en-US", { month: "short" }).format
        if (response?.data?.facet_counts?.facet_ranges?.tcreated?.counts) {
          let a = response.data.facet_counts.facet_ranges.tcreated.counts;
          for (let j = 0; j < a.length; j = j + 2) {
            let date = new Date(a[j])
            self.labels.push(shortMonthName(date.setMonth(date.getMonth() + 1)))
            self.value.push(a[j + 1])
          }
        }
        if (response.data.response.docs) {
          let lastUploadDate = new Date(response.data.response.docs[0].tcreated)
          this.lastUpload = this.timeSince(lastUploadDate)
        }
      } catch (error) {
        console.log(error);
      }
    },
    timeSince(date) {
      var seconds = Math.floor((new Date() - date) / 1000);

      var interval = seconds / 31536000;

      if (interval > 1) {
        return Math.floor(interval) + " years";
      }
      interval = seconds / 2592000;
      if (interval > 1) {
        return Math.floor(interval) + " months";
      }
      interval = seconds / 86400;
      if (interval > 1) {
        return Math.floor(interval) + " days";
      }
      interval = seconds / 3600;
      if (interval > 1) {
        return Math.floor(interval) + " hours";
      }
      interval = seconds / 60;
      if (interval > 1) {
        return Math.floor(interval) + " minutes";
      }
      return Math.floor(seconds) + " seconds";
    }
  },
  async mounted() {
    await this.fetchStats(this);
  }
}
</script>

<style>
.v-sheet--offset {
  top: -24px;
  position: relative;
}
</style>