<template>
  <client-only>
    <div>
      <v-btn class="mt-4" :to="{ path: `/detail/${pid}`, params: { pid: pid } }">
        <v-icon left>mdi-arrow-left</v-icon>{{ $t('Back to detail page') }}
      </v-btn>
      <p-i-form :form="form" :targetpid="pid" :enablerights="false" :enablerelationships="false" :templating="false"
        :importing="false" :addbutton="true" :help="false" :debug="false" :feedback="false" :validate="validationMethod"
        v-on:object-saved="objectSaved($event)" class="mt-4"></p-i-form>
    </div>
  </client-only>
</template>

<script>
import jsonLd from "phaidra-vue-components/src/utils/json-ld";
import { formvalidation } from '../../../mixins/formvalidation'
import { context } from "../../../mixins/context";
import { config } from "../../../mixins/config";

export default {
  mixins: [context, config, formvalidation],
  data() {
    return {
      loading: false,
      form: {},
      parentpid: "",
    };
  },
  computed: {
    pid: function () {
      return this.$route.params.pid;
    },
  },
  methods: {
    validationMethod: function () {
      if (this.instanceconfig.submit?.validationmethod) {
        return this[this.instanceconfig.submit?.validationmethod]()
      }
      return this.validate()
    },
    objectSaved: async function (pid) {
      this.$store.commit("setAlerts", [
        { type: "success", msg: "Metadata for object " + pid + " saved" },
      ]);
      // to save unnecessary loadings, fetchObjectInfo is skipped in Detail.vue if we return to the same pid
      // but it must be done after metadata edit, so re-load it here
      await this.$store.dispatch("fetchObjectInfo", pid);
      this.$router.push(this.localeLocation({ path: `/detail/${pid}` }));
      this.$vuetify.goTo(0);
    },
    postMetadataLoad: function (self, form) {
      for (let s of form.sections) {
        for (let f of s.fields) {
          if (f.predicate === "edm:rights") {
            if (f.value !== "http://rightsstatements.org/vocab/InC/1.0/") {
              f.disabled = true;
            }
          }
          f.removable = true
        }
        s.removable = true
      }
      self.form = form;
    },
    loadJsonld: async function (self, pid) {
      self.loading = true;
      try {
        let response = await self.$axios.request({
          method: "GET",
          url: "/object/" +
            pid +
            "/metadata",
          params: {
            mode: "resolved",
          },
        });
        if (response.data.alerts && response.data.alerts.length > 0) {
          self.$store.commit("setAlerts", response.data.alerts);
        }
        if (response.data.metadata["JSON-LD"]) {
          self.postMetadataLoad(
            self,
            this.json2form(response.data.metadata["JSON-LD"])
          );
        }
      } catch (error) {
        console.log(error);
      } finally {
        self.loading = false;
      }
    },
    json2form: function (jsonld) {
      return jsonLd.json2form(jsonld);
    },
  },
  beforeRouteEnter: function (to, from, next) {
    next((vm) => {
      vm.$store.commit("setLoading", true);
      vm.parentpid = from.params.pid;
      vm.loadJsonld(vm, to.params.pid).then(() => {
        vm.$store.commit("setLoading", false);
        next();
      });
    });
  },
  beforeRouteUpdate: function (to, from, next) {
    this.parentpid = from.params.pid;
    this.$store.commit("setLoading", true);
    this.loadJsonld(this, to.params.pid).then(() => {
      this.$store.commit("setLoading", false);
      next();
    });
  },
};
</script>
