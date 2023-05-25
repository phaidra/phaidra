<template>
  <v-row>
    <v-col>
      <p-d-list :list="list"></p-d-list>
    </v-col>
  </v-row>
</template>

<script>
import axios from "axios";
import { context } from "../../mixins/context";
import { config } from "../../mixins/config";

export default {
  mixins: [context, config],
  validate({ params }) {
    return /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/.test(
      params.token.toLowerCase()
    );
  },
  computed: {
    lid() {
      return this.$route.params.lid;
    },
  },
  data() {
    return {
      list: {},
    };
  },
  methods: {
    loadData: async function (self, token) {
      if (token) {
        this.$store.commit("setLoading", true);
        try {
          let response = await axios.request({
            method: "GET",
            url: this.instanceconfig.api + "/list/token/" + token,
            headers: {
              "X-XSRF-TOKEN": this.$store.state.user.token,
            },
          });
          this.list = response.data.list;
          if (response.data.alerts && response.data.alerts.length > 0) {
            this.$store.commit("setAlerts", response.data.alerts);
          }
        } catch (error) {
          console.log(error);
        } finally {
          this.$store.commit("setLoading", false);
        }
      }
    },
  },
  serverPrefetch() {
    return this.loadData(this, this.$route.params.token);
  },
  beforeRouteEnter: function (to, from, next) {
    next((vm) => {
      vm.loadData(vm, to.params.token).then(() => {
        next();
      });
    });
  },
  beforeRouteUpdate: function (to, from, next) {
    this.loadData(this, to.params.token).then(() => {
      next();
    });
  },
};
</script>
