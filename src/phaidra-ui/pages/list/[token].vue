<template>
  <v-row>
    <v-col>
      <p-d-list :list="list"></p-d-list>
    </v-col>
  </v-row>
</template>

<script>
import { useAsyncData, useNuxtApp, useRoute } from "#app";
import { context } from "../../mixins/context";
import { config } from "../../mixins/config";

export default {
  mixins: [context, config],
  setup() {
    const route = useRoute();
    const nuxtApp = useNuxtApp();

    const { data: list } = useAsyncData(
      "list-token",
      async () => {
        const token = route.params.token;
        if (!token) return {};
        try {
          const response = await nuxtApp.$axios.request({
            method: "GET",
            url: "/list/token/" + token,
            headers: {
              "X-XSRF-TOKEN": nuxtApp.$store.state.user.token,
            },
          });
          const loaded = response.data.list || {};
          if (loaded && loaded.name) {
            nuxtApp.$store.commit("addBreadcrumb", {
              text: loaded.name,
              to: route.path,
              disabled: true,
            });
          }
          if (response.data.alerts && response.data.alerts.length > 0) {
            nuxtApp.$store.commit("setAlerts", response.data.alerts);
          }
          return loaded;
        } catch (error) {
          console.log(error);
          return {};
        }
      },
      {
        default: () => ({}),
        watch: [() => route.params.token],
      }
    );

    return { list };
  },
  validate({ params }) {
    return /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/.test(
      params.token.toLowerCase()
    );
  },
};
</script>
