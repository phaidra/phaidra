<template>

  <div v-if="instanceconfig.cms_home">
    <runtimetemplate :template="instanceconfig.cms_home" />
  </div>
  
  <div v-else>
    <v-row class="mx-4 mt-10">
      <v-col cols="12" md="10" offset-md="1">
        <v-row>
          <v-text-field class="searchBox" v-model="q" :placeholder="$t('Search...')" autocomplete="off" append-icon="mdi-magnify"
            v-on:keyup.enter="$router.push({ name: 'search', query: { q } })" clearable solo hide-details>
          </v-text-field>
        </v-row>
        <v-row class="text-subtitle-1 font-weight-light text-center my-6">
          <v-col>{{ $t('Phaidra is a repository for the permanent secure storage of digital assets') }}</v-col>
        </v-row>
      </v-col>
    </v-row>

    <v-divider class="mb-8"></v-divider>

    <v-row class="px-2">

      <v-col cols="12" lg="10">
        <v-row>
          <h2 class="md-headline title font-weight-light pa-2">{{ "Dashboard" }}</h2>
        </v-row>

        <v-row class="mt-6">
          <v-col lg="6">
            <DashboardUploads></DashboardUploads>
            <DashboardCmodels></DashboardCmodels>
          </v-col>
          <v-col>
            <DashboardLatestuploads :length="5"></DashboardLatestuploads>
          </v-col>
        </v-row>
      </v-col>

      <v-col cols="12" lg="2" class="border-left mt-2">
        <v-row class="px-2">
          <v-col cols="12">
            <v-row>
              <h2 class="md-headline title font-weight-light pa-2 mb-3">{{ "Manage Phaidra" }}</h2>
            </v-row>
            <v-row class="pl-2 mb-6 mt-4">
              <ul>
                <li><a href="/lam/">Manage Users</a></li>
                <li><a href="/api/openapi">Inspect API</a></li>
                <li><a href="/dbgate/">Inspect Databases</a></li>
                <li><a href="/fcrepo/rest/">Inspect Object Repository</a></li>
                <li><a href="/solr/">Inspect Search Engine</a></li>
                <li><a href="/grafana/">Inspect Running Services</a></li>
                <li><a href="https://phaidra.org/docs/overview/">Documentation</a></li>
              </ul>
            </v-row>
            <v-divider class="my-4"></v-divider>
            <v-row>
              <h2 class="md-headline title font-weight-light pa-2 mb-3">
                <icon width="27px" height="27px" name="univie-kartenkontakte" class="mr-2"></icon>{{  $t("Contact") }}
              </h2>
            </v-row>
            <v-divider class="my-4"></v-divider>
            <v-row class="pl-2 mb-6 mt-4">
              <span v-if="$i18n.locale === 'deu'">Bei allen Fragen zu PHAIDRA steht Ihnen unsere Support-Adresse zur
                Verfügung</span>
              <span v-else>If you have any questions about Phaidra, please contact support</span> <a
                href="mailto:support.phaidra@univie.ac.at">support.phaidra@univie.ac.at</a>
            </v-row>
            <v-row class="pl-2 mb-6 mt-4">
              <a v-if="$i18n.locale === 'deu'" href="https://phaidra.univie.ac.at/o:1430148" target="_self">Guidelines
                für barrierearme Inhalte in Repositorien</a>
              <a v-else href="https://phaidra.univie.ac.at/o:1430148" target="_self">Guidelines for barrier-free content
                in repositories</a>
            </v-row>
            <v-row class="pl-2 mb-6 mt-6">
              <nuxt-link :to="localePath('termsofuse')">{{ $t('Terms of Use')}}</nuxt-link>
            </v-row>
            <v-divider class="my-4"></v-divider>
            <v-row>
              <a href="https://www.facebook.com/" target="_blank" aria-label="Facebook">
                <icon class="mx-2" width="24px" height="18px" name="univie-facebook"></icon>
              </a>
              <a href="https://twitter.com/" target="_blank" aria-label="Twitter">
                <icon class="ml-2 mr-4" width="26px" height="18px" name="univie-twitter"></icon>
              </a>
              <a href="https://www.youtube.com/" target="_blank" aria-label="YouTube">
                <icon class="mx-2" width="24px" height="18px" name="univie-youtube"></icon>
              </a>
              <a href="https://www.instagram.com/" target="_blank" aria-label="Instagram">
                <icon class="mx-2" width="24px" height="18px" name="univie-instagram"></icon>
              </a>
              <a href="http://www.flickr.com/" target="_blank" aria-label="Flickr">
                <icon class="mx-2" width="24px" height="18px" name="univie-flickr"></icon>
              </a>
            </v-row>
          </v-col>
        </v-row>
      </v-col>

    </v-row>
  </div>

</template>

<script>
import { config } from "@/mixins/config";
import '@/compiled-icons/univie-kartenkontakte'
import '@/compiled-icons/univie-facebook'
import '@/compiled-icons/univie-youtube'
import '@/compiled-icons/univie-twitter'
import '@/compiled-icons/univie-instagram'
import '@/compiled-icons/univie-flickr'
import VueHorizontal from 'vue-horizontal'

export default {
  name: 'home',
  components: {
    VueHorizontal
  },
  mixins: [config],
  data() {
    return {
      q: ''
    }
  }
}
</script>

<style scoped>
.v-card img {
  max-width: 100%;
  height: auto;
}

h2.md-headline {
  font-size: 21pt !important;
  font-weight: 300 !important;
}

.v-sheet--offset {
  top: -24px;
  position: relative;
}

</style>
