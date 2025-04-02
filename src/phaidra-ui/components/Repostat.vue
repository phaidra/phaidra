<template>
    <v-row justify="center">
        <v-col>
        <v-card tile>
            <v-card-title class="title font-weight-light white--text">{{
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
  }
};
</script>
