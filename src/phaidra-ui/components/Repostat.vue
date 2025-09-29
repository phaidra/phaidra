<template>
    <v-row justify="center">
        <v-col>
        <v-card tile>
            <v-card-title class="title font-weight-light white--text">{{
            $t("Repository statistics")
            }}</v-card-title>
            <v-card-text>
            <!-- Storage stat -->
            <v-row class="mb-4" align="center">
                <v-col cols="12" sm="6" md="4" offset-md="8" offset-sm="6">
                    <v-menu
                        v-model="monthMenu"
                        :close-on-content-click="false"
                        transition="scale-transition"
                        offset-y
                    >
                        <template v-slot:activator="{ on, attrs }">
                            <v-text-field
                                class="mt-4"
                                v-model="selectedMonth"
                                label="Select month (YYYY-MM)"
                                readonly
                                v-bind="attrs"
                                v-on="on"
                                dense
                                clearable
                                @click:clear="clearMonth"
                            ></v-text-field>
                        </template>
                        <v-date-picker
                            v-model="selectedMonth"
                            type="month"
                            @change="monthMenu = false; fetchStorageUsage()"
                        ></v-date-picker>
                    </v-menu>
                </v-col>
            </v-row>
            <v-data-table
                :headers="storageHeaders"
                :items="storageItems"
                :items-per-page="5"
                :loading="storageLoading"
                :no-data-text="$t('No data available')"
                class="elevation-1 my-4"
                :sort-by="['month','total_bytes']"
                :sort-desc="[true,true]"
            >
                <template v-slot:item.total_bytes="{ item }">
                    <span>{{ item.total_bytes | bytes }}</span>
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
    this.fetchStorageUsage();
  },
  data () {
    return {
      monthMenu: false,
      selectedMonth: new Date().toISOString().substring(0, 7), // 'YYYY-MM'
      storageLoading: false,
      storageHeaders: [
        { text: 'Month', value: 'month' },
        { text: 'MIME Type', value: 'mime_type' },
        { text: 'Total (bytes)', value: 'total_bytes' },
        { text: 'Files', value: 'file_count' }
      ],
      storageItems: []
    }
  },
  methods: {
    async fetchStorageUsage () {
      try {
        this.storageLoading = true;
        let url = '/api/utils/fedora_storage_usage';
        if (this.selectedMonth) {
          const params = new URLSearchParams({ from: this.selectedMonth, to: this.selectedMonth });
          url += `?${params.toString()}`;
        }
        const res = await fetch(url, { credentials: 'include' });
        const json = await res.json();
        if (json && json.usage) {
          this.storageItems = json.usage;
        } else {
          this.storageItems = [];
        }
      } catch (e) {
        this.storageItems = [];
      } finally {
        this.storageLoading = false;
      }
    },
    clearMonth () {
      this.selectedMonth = null;
      this.fetchStorageUsage();
    },
  }
};
</script>
