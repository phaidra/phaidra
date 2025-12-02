<template>
    <v-row justify="center">
        <v-col>
        <v-card tile>
            <v-card-title class="title font-weight-light white--text">{{
            $t("Repository statistics")
            }}</v-card-title>
            <v-card-text>
            <div class="subtitle-1 mb-1">{{ selectedYear }} Fedora</div>
            <v-data-table
                :headers="avgHeaders"
                :items="avgItems"
                :items-per-page="1"
                :loading="storageLoading"
                :no-data-text="$t('No data available')"
                class="elevation-1 my-4"
                disable-sort
                hide-default-footer
            >
                <template v-for="col in avgCols" v-slot:[`item.${col.value}`]="{ item }">
                    <span v-if="item[col.value]">{{ item[col.value] | gigabytes }}</span>
                    <span v-else>-</span>
                </template>
            </v-data-table>

            <div class="subtitle-1 mb-1">{{ selectedYearImg }} Imageserver</div>
            <v-data-table
                :headers="imgAvgHeaders"
                :items="imgAvgItems"
                :items-per-page="1"
                :loading="imgLoading"
                :no-data-text="$t('No data available')"
                class="elevation-1 my-4"
                disable-sort
                hide-default-footer
            >
                <template v-for="col in imgAvgCols" v-slot:[`item.${col.value}`]="{ item }">
                    <span v-if="item[col.value]">{{ item[col.value] | gigabytes }}</span>
                    <span v-else>-</span>
                </template>
            </v-data-table>
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
</template>

<script>

import repostatMixin from '../mixins/repostatMixin';
import { context } from "../mixins/context";
import { config } from "../mixins/config";
import { vocabulary } from 'phaidra-vue-components/src/mixins/vocabulary'

export default {
  name: 'PRepostat',
  mixins: [context, config, vocabulary, repostatMixin],
  computed: {
    routepid: function () {
      return this.$store.state.route.params.pid;
    },
    currentYear: function () {
      return new Date().getFullYear();
    },
  },
  mounted() {
    this.fetchStats();
    this.fetchStorageAvgYear();
    this.fetchImageserverAvgYear();
  },
  data () {
    return {
      selectedYear: new Date().getFullYear(),
      selectedYearImg: new Date().getFullYear(),
      storageLoading: false,
      imgLoading: false,
      avgCols: [],
      avgHeaders: [],
      avgItems: []
      ,imgAvgCols: [],
      imgAvgHeaders: [],
      imgAvgItems: []
    }
  },
  methods: {
    async fetchStorageAvgYear () {
      try {
        let response = null;
        this.storageLoading = true;

        try {
          response = await this.$axios.get(`/utils/fedora_storage_avg_year?year=${this.selectedYear}`, {
            headers: {
              "X-XSRF-TOKEN": this.$store.state.user.token,
            },
          });
        } catch (error) {
          console.error(error)
        }
        const months = response?.data?.months;

        // Build columns up to current month for current year; all 12 for past; none for future
        const now = new Date();
        const currentYear = now.getFullYear();
        const currentMonth = now.getMonth() + 1; // 1..12
        let maxMonth = 12;
        if (Number(this.selectedYear) === currentYear) {
          maxMonth = currentMonth;
        } else if (Number(this.selectedYear) > currentYear) {
          maxMonth = 0;
        }

        const monthNames = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
        const valKeys = ['jan','feb','mar','apr','may','jun','jul','aug','sep','oct','nov','dec'];
        this.avgCols = monthNames.slice(0, maxMonth).map((label, idx) => ({ text: `${label} Avg`, value: valKeys[idx] }));
        this.avgHeaders = this.avgCols;

        if (maxMonth === 0) {
          this.avgItems = [];
        } else {
          const toVal = (n) => {
            const v = months[n];
            return v ? Number.isFinite(Number(v)) ? Number(v) : 0 : 0;
          };
          const row = {};
          for (let i = 1; i <= maxMonth; i++) {
            row[valKeys[i-1]] = toVal(i);
          }
          this.avgItems = [row];
        }
      } catch (e) {
        this.avgCols = [];
        this.avgHeaders = [];
        this.avgItems = [];
      } finally {
        this.storageLoading = false;
      }
    },
    async fetchImageserverAvgYear () {
      try {
        let response = null;
        this.imgLoading = true;
        try {
          response = await this.$axios.get(`/utils/imageserver_storage_avg_year?year=${this.selectedYearImg}`, {
            headers: {
              "X-XSRF-TOKEN": this.$store.state.user.token,
            },
          });
        } catch (error) {
          console.error(error)
        }
        const months = response?.data?.months;

        const now = new Date();
        const currentYear = now.getFullYear();
        const currentMonth = now.getMonth() + 1;
        let maxMonth = 12;
        if (Number(this.selectedYearImg) === currentYear) {
          maxMonth = currentMonth;
        } else if (Number(this.selectedYearImg) > currentYear) {
          maxMonth = 0;
        }

        const monthNames = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
        const valKeys = ['jan','feb','mar','apr','may','jun','jul','aug','sep','oct','nov','dec'];
        this.imgAvgCols = monthNames.slice(0, maxMonth).map((label, idx) => ({ text: `${label} Avg`, value: valKeys[idx] }));
        this.imgAvgHeaders = this.imgAvgCols;

        if (maxMonth === 0) {
          this.imgAvgItems = [];
        } else {
          const toVal = (n) => {
            const v = months[n];
            return v ? Number.isFinite(Number(v)) ? Number(v) : 0 : 0;
          };
          const row = {};
          for (let i = 1; i <= maxMonth; i++) {
            row[valKeys[i-1]] = toVal(i);
          }
          this.imgAvgItems = [row];
        }
      } catch (e) {
        this.imgAvgCols = [];
        this.imgAvgHeaders = [];
        this.imgAvgItems = [];
      } finally {
        this.imgLoading = false;
      }
    }
  }
};
</script>
