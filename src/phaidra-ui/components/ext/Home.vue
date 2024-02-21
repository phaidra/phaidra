<template>
  <div>

    <v-row class="mx-4 mt-10">
      <v-col cols="12" md="10" offset-md="1">
        <v-row>
          <v-text-field
            v-model="q"
            :placeholder="$t('Search...')"
            autocomplete="off"
            append-icon="mdi-magnify"
            v-on:keyup.enter="$router.push({ name: 'search', query: { q } })"
            clearable
            solo
            hide-details
          >
          </v-text-field>
        </v-row>
        <v-row class="text-subtitle-1 font-weight-light text-center my-6">
          <v-col>{{ $t('Phaidra is a repository for the permanent secure storage of digital assets') }}</v-col>
        </v-row>
      </v-col>
    </v-row>

    <v-divider class="mb-4"></v-divider>

    <v-row class="px-2">

      <v-col cols="12" lg="10">
        <v-row>
          <h2 class="md-headline title font-weight-light primary--text pa-2" >{{ "Featured collections" }}</h2>
        </v-row>

        <v-row justify="center">

          <v-col cols="12" md="4" sm="12">
            <v-card flat>
              <div class="text-center">
                <img class="mb-4" src="../../assets/ext/open-access.jpg" alt="picture" title="CC0"/>
              </div>
              <v-card-text class="pa-0">
                <h3 class="title font-weight-light primary--text pb-2">Example content</h3>
                <div>Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean nunc arcu, maximus id dignissim vel, posuere at velit. In tincidunt bibendum nisl, id placerat ipsum efficitur eget.</div>
              </v-card-text>
              <v-card-actions class="pl-0">
                <span class="mr-3">[<a color="primary" text href="/ext/featured-collection" target="_blank">{{ $t('More') }}</a>]</span>
                <span>[<a color="primary" text href="https://phaidra.univie.ac.at/search" target="_blank">{{ $t('Search') }}</a>]</span>
              </v-card-actions>
            </v-card>
          </v-col>

        </v-row>

      </v-col>

      <v-col cols="12" lg="2" class="border-left mt-2">
        <v-row>
            <v-col cols="12">
                <v-row>
                    <h2 class="md-headline title font-weight-light primary--text pa-2 mb-3" >{{ "Manage Phaidra" }}</h2>
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
              <h2 class="md-headline title font-weight-light primary--text pa-2 mb-3" ><icon width="27px" height="27px" name="univie-kartenkontakte" class="mr-2"></icon>{{ "Contact" }}</h2>
            </v-row>
            <v-divider class="my-4"></v-divider>
            <v-row class="pl-2 mb-6 mt-4">
              <span v-if="$i18n.locale === 'deu'">Bei allen Fragen zu PHAIDRA steht Ihnen unsere Support-Adresse zur Verfügung</span>
              <span v-else>If you have any questions about Phaidra, please contact support</span> <a href="mailto:support.phaidra@univie.ac.at">support.phaidra@univie.ac.at</a>
            </v-row>
            <div class="gray-bg">
              <div class="content-box">
                <span v-if="$i18n.locale === 'deu'">Neu</span>
                <span v-else>New</span>
              </div>
                <a v-if="$i18n.locale === 'deu'" href="https://phaidra.univie.ac.at/o:1430148" target="_self">Guidelines für barrierearme Inhalte in Repositorien</a>
                <a v-else href="https://phaidra.univie.ac.at/o:1430148" target="_self">Guidelines for barrier-free content in repositories</a>
            </div>
            <v-row class="pl-2 mb-6 mt-6">
              <router-link :to="localePath('termsofuse')">{{ $t('Terms of Use')}}</router-link>
            </v-row>
            <v-divider class="my-4"></v-divider>
            <v-row>
              <a href="https://www.facebook.com/" target="_blank"><icon class="mx-2" width="24px" height="18px" name="univie-facebook"></icon></a>
              <a href="https://twitter.com/" target="_blank"><icon class="ml-2 mr-4" width="26px" height="18px" name="univie-twitter"></icon></a>
              <a href="https://www.youtube.com/" target="_blank"><icon class="mx-2" width="24px" height="18px" name="univie-youtube"></icon></a>
              <a href="https://www.instagram.com/" target="_blank"><icon class="mx-2" width="24px" height="18px" name="univie-instagram"></icon></a>
              <a href="http://www.flickr.com/" target="_blank"><icon class="mx-2" width="24px" height="18px" name="univie-flickr"></icon></a>
            </v-row>
          </v-col>
        </v-row>
      </v-col>

    </v-row>
  </div>

</template>

<script>
import { context } from '../../mixins/context'
import '@/compiled-icons/univie-kartenkontakte'
import '@/compiled-icons/univie-facebook'
import '@/compiled-icons/univie-youtube'
import '@/compiled-icons/univie-twitter'
import '@/compiled-icons/univie-instagram'
import '@/compiled-icons/univie-flickr'

export default {
  name: 'home',
  mixins: [ context ],
  data () {
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
.gray-bg {
    background-color: #f2f2f2;
    padding: 9px;
}
.content-box {
    background-color: #008080;
    font-size: 10.8pt;
    color: white;
    display: table;
    line-height: 14pt;
    margin: 0 0 20px -8px !important;
    padding: 5px 10px;
}
h2.md-headline {
  font-size: 21pt!important;
  font-weight: 300!important;
}
</style>
