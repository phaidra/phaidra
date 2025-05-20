<template>
  <v-container fluid>
    <v-btn color="primary" class="my-4" :to="{ path: `/detail/${routepid}`, params: { pid: routepid } }">
      <v-icon left>mdi-arrow-left</v-icon>{{ $t('Back to detail page') }}
    </v-btn>
    <v-card class="mt-8" v-if="objectInfo && objectInfo.metadata['JSON-LD']">
      <v-card-title class="title font-weight-light white--text">{{ routepid }} JSON-LD</v-card-title>
      <v-card-text>
        <vue-json-pretty :data="objectInfo.metadata['JSON-LD']"></vue-json-pretty>
      </v-card-text>
    </v-card>
  </v-container>
</template>

<script>
import VueJsonPretty from "vue-json-pretty";
import "vue-json-pretty/lib/styles.css";
import configjs from "../../../config/phaidra-ui";
import { context } from "../../../mixins/context";
import { config } from "../../../mixins/config";

export default {
  mixins: [context, config],
  components: {
    VueJsonPretty,
  },
  computed: {
    routepid: function () {
      return this.$route.params.pid;
    },
    objectInfo: function () {
      return this.$store.state.objectInfo;
    },
  },
  data() {
    return {
      active: null,
    };
  },
  methods: {
    async fetchAsyncData(self, pid) {
      await self.$store.dispatch("fetchObjectInfo", pid);
    },
  },
  serverPrefetch() {
    console.log("[" + this.$route.params.pid + "] prefetch");
    return this.fetchAsyncData(this, this.$route.params.pid);
  },
  beforeRouteEnter: async function (to, from, next) {
    next( async function (vm) {
      await vm.fetchAsyncData(vm, to.params.pid);
    });
  },
  beforeRouteUpdate: async function (to, from, next) {
    await this.fetchAsyncData(this, to.params.pid);
    next();
  },
  mounted() {
    console.log("this.$route.params.pid", this.$route);
  },
};
</script>
