<template>
  <div>
    <v-row no-gutters class="mb-6">
        <v-col cols="12" md="10" offset-md="1" class="header">
        <v-row no-gutters class="mt-2" style="min-height: 125px">
            <v-col class="text-left" cols="12" md="3">
            <a :href="instanceconfig.institutionurl" target="_blank">
                <img src="../../assets/ext/phaidralogo.png" class="logo mt-4" alt="logo" />
            </a>
            </v-col>

            <v-col cols="9">
            <v-row justify="start" justify-md="end" class="pl-3">
                <icon
                v-if="signedin"
                class="personicon mr-2 mt-1 univie-grey"
                name="material-social-person"
                width="24px"
                height="24px"
                ></icon>
                <span
                v-if="signedin"
                class="mr-2 mt-2 subheading displayname univie-grey"
                >{{ user.firstname }} {{ user.lastname }}</span
                >

                <v-menu offset-y>
                <template v-slot:activator="{ on }">
                    <v-btn text v-on="on" class="top-margin-lang">
                    <span class="grey--text text--darken-1">{{
                        localeLabel
                    }}</span>
                    <icon
                        name="univie-sprache"
                        class="lang-icon grey--text text--darken-1"
                    ></icon>
                    </v-btn>
                </template>
                <v-list>
                    <v-list-item
                    v-if="useLocale('eng')"
                    @click="changeLocale('eng')"
                    >
                    <v-list-item-title>English</v-list-item-title>
                    </v-list-item>
                    <v-list-item
                    v-if="useLocale('deu')"
                    @click="changeLocale('deu')"
                    >
                    <v-list-item-title>Deutsch</v-list-item-title>
                    </v-list-item>
                </v-list>
                </v-menu>
            </v-row>

            <v-row>
                <v-col
                v-if="appconfig.showinstanceswitch"
                cols="4"
                class="select-instance text-left"
                >
                <v-select
                    :items="instances"
                    @input="switchInstance"
                    :value="instanceconfig.baseurl"
                    item-text="baseurl"
                    single-line
                ></v-select>
                </v-col>
                <v-col
                class="text-left"
                cols="10"
                offset="1"
                v-else-if="instanceconfig.title"
                >
                <icon
                    left
                    dark
                    name="univie-right"
                    color="#a4a4a4"
                    width="14px"
                    height="14px"
                    class="mb-1"
                ></icon>
                <nuxt-link
                    class="subheading primary--text mx-3"
                    :to="localePath('/')"
                    >{{ instanceconfig.title }}</nuxt-link
                >
                </v-col>
            </v-row>

            <v-row>
                <v-toolbar flat color="white" dense>
                <client-only>
                    <v-app-bar-nav-icon class="hidden-md-and-up">
                    <v-menu offset-y>
                        <template v-slot:activator="{ on }">
                        <v-btn text icon color="grey lighten-1" v-on="on"
                            ><icon
                            name="material-navigation-menu"
                            width="24px"
                            height="24px"
                            ></icon
                        ></v-btn>
                        </template>
                        <v-list>
                        <v-list-item
                            @click="
                            $router.push(
                                localeLocation({
                                path: '/search',
                                query: { reset: 1 },
                                })
                            )
                            "
                            ><v-list-item-title>{{
                            $t("Search")
                            }}</v-list-item-title></v-list-item
                        >
                        <v-list-item
                            v-if="signedin"
                            @click="
                            $router.push(localeLocation({ path: '/submit' }))
                            "
                            ><v-list-item-title>{{
                            $t("Submit")
                            }}</v-list-item-title></v-list-item
                        >
                        <v-list-item
                            v-if="signedin"
                            @click="
                            $router.push(
                                localeLocation({
                                path: '/search',
                                query: { reset: 1, owner: user.username },
                                })
                            )
                            "
                            ><v-list-item-title>{{
                            $t("My objects")
                            }}</v-list-item-title></v-list-item
                        >
                        <v-list-item
                            v-if="signedin"
                            @click="
                            $router.push(localeLocation({ path: '/lists' }))
                            "
                            ><v-list-item-title>{{
                            $t("Object lists")
                            }}</v-list-item-title></v-list-item
                        >
                        <v-list-item
                            v-if="signedin & instanceconfig.groups"
                            @click="
                            $router.push(localeLocation({ path: '/groups' }))
                            "
                            ><v-list-item-title>{{
                            $t("Groups")
                            }}</v-list-item-title></v-list-item
                        >
                        <v-list-item
                            @click="
                            $router.push(localeLocation({ path: '/help' }))
                            "
                            ><v-list-item-title>{{
                            $t("Help")
                            }}</v-list-item-title></v-list-item
                        >
                        <v-list-item
                            v-if="!signedin && appconfig.enablelogin"
                            
                            >
<v-list-item-title><a :class="hover ? 'ph-button primary' : 'ph-button grey'" href="/login">{{ $t("Login")
                          }}</a></v-list-item-title></v-list-item
                        >
                        <v-list-item v-if="signedin" @click="logout"
                            ><v-list-item-title>{{
                            $t("Logout")
                            }}</v-list-item-title></v-list-item
                        >
                        </v-list>
                    </v-menu>
                    </v-app-bar-nav-icon>
                </client-only>
                <v-spacer></v-spacer>
                <v-toolbar-items class="hidden-sm-and-down no-height-inherit">
                    <v-hover v-slot:default="{ hover }">
                    <nuxt-link
                        :class="hover ? 'ph-button primary' : 'ph-button grey'"
                        :to="localePath(`/search?reset=1`)"
                        >{{ $t("Search") }}</nuxt-link
                    >
                    </v-hover>
                    <v-hover v-slot:default="{ hover }">
                    <nuxt-link
                        :class="hover ? 'ph-button primary' : 'ph-button grey'"
                        v-show="signedin"
                        :to="localePath('/submit')"
                        >{{ $t("Upload") }}</nuxt-link
                    >
                    </v-hover>
                    <v-hover v-slot:default="{ hover }">
                    <nuxt-link
                        :class="hover ? 'ph-button primary' : 'ph-button grey'"
                        v-show="signedin"
                        :to="
                        localePath({
                            path: '/search',
                            query: { reset: 1, owner: user.username },
                        })
                        "
                        >{{ $t("My objects") }}</nuxt-link
                    >
                    </v-hover>
                    <v-hover v-slot:default="{ hover }">
                    <nuxt-link
                        :class="hover ? 'ph-button primary' : 'ph-button grey'"
                        v-show="signedin"
                        :to="localePath('/lists')"
                        >{{ $t("Object lists") }}</nuxt-link
                    >
                    </v-hover>
                    <v-hover v-slot:default="{ hover }">
                    <nuxt-link
                        :class="hover ? 'ph-button primary' : 'ph-button grey'"
                        v-show="signedin && instanceconfig.groups"
                        :to="localePath('/groups')"
                        >{{ $t("Groups") }}</nuxt-link
                    >
                    </v-hover>
                    <v-hover v-slot:default="{ hover }">
                    <nuxt-link
                        :class="hover ? 'ph-button primary' : 'ph-button grey'"
                        :to="localePath('/help')"
                        >{{ $t("Help") }}</nuxt-link
                    >
                    </v-hover>
                    <v-hover v-slot:default="{ hover }">
                    <a
                        :class="hover ? 'ph-button primary' : 'ph-button grey'"
                        v-show="!signedin && appconfig.enablelogin"
                        :to="localePath('/login')"
                        >{{ $t("Login") }}</a
                    >
                    </v-hover>
                    <v-hover>
                    <a
                        class="flat dark ph-button grey"
                        v-show="signedin"
                        @click="logout"
                        >{{ $t("Logout") }}</a
                    >
                    </v-hover>
                </v-toolbar-items>
                </v-toolbar>
            </v-row>
            </v-col>
        </v-row>
        </v-col>
    </v-row>
  </div>
</template>

<script>
import { config } from "@/mixins/config";
import { context } from "@/mixins/context";

export default {
  mixins: [config, context],
  computed: {
    localeLabel: function () {
      if (this.instanceconfig.ui) {
        if (this.instanceconfig.ui.twoletterlang === 1) {
          switch (this.$i18n.locale) {
            case "eng":
              return "eng";
            case "deu":
              return "deu";
            default:
              return "";
          }
        }
      }
      return this.$i18n.locale;
    }
  },
  data() {
    return {
      quicklinksenabled: 0,
    };
  },
  methods: {
    logout: function () {
      this.$store.dispatch("logout");
      this.$store.commit("setLoading", false);
      this.$router.push(this.localeLocation({ path: `/` }));
    },
    useLocale: function (lang) {
      if (this.instanceconfig.ui) {
        if (this.instanceconfig.ui.languages) {
          return this.instanceconfig.ui.languages.includes(lang);
        }
      }
      return false;
    },
    changeLocale: function (lang) {
      this.$i18n.locale = lang;
      // this.$i18n.setLocaleCookie(lang);
      localStorage.setItem("locale", lang);
      this.$router.push(this.switchLocalePath(lang));
      this.$store.dispatch("vocabulary/sortRoles", this.$i18n.locale);
      this.$store.dispatch("vocabulary/sortFields", this.$i18n.locale);
      this.$store.dispatch("vocabulary/sortObjectTypes", this.$i18n.locale);
      this.$store.dispatch('info/sortFieldsOverview', this.$i18n.locale)
    }
  },
  mounted() {
    console.log('mounting header, signedin: ' + this.signedin)
    console.log('mounting header, token: ' + this.$store.state.user.token)
    if (localStorage.getItem("locale")) {
      this.$i18n.locale = localStorage.getItem("locale");
    } else {
      localStorage.setItem("locale", this.$i18n.locale);
    }
  }
};
</script>
