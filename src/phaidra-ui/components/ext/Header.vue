<template>
    <div v-if="instanceconfig.cms_header">
      <runtimetemplate :template="instanceconfig.cms_header" />
    </div>
    
    <div v-else>
      <v-row no-gutters class="mb-6">
          <v-col cols="12" md="10" offset-md="1" class="header pb-4">
            <v-row no-gutters class="mt-2">
              <v-col class="text-left" cols="12" md="3" align-self="center">
                <a :href="instanceconfig.institutionurl" target="_blank" aria-label="PHAIDRA - to the homepage">
                    <svg version="1.1" id="PHAIDRA_Logo_copy_xA0_Image_1_"
                      xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px" viewBox="0 0 348.55 83.1"
                      style="enable-background:new 0 0 348.55 83.1; max-height: 70px;" xml:space="preserve">
                      <style v-if="isDarkTheme" type="text/css">
                        .st0{fill:#dedede;}
                        .st1{fill:none;stroke:#dedede;stroke-width:35;stroke-miterlimit:10;}
                      </style>
                      <style v-else type="text/css">
                        .st0{fill:#212121;}
                        .st1{fill:none;stroke:#212121;stroke-width:35;stroke-miterlimit:10;}
                      </style>
                    <g>
                      <g>
                        <g>
                          <g>
                            <path class="st0" d="M41.6,18c-3,0-5.4-2.4-5.4-5.4s2.4-5.4,5.4-5.4S47,9.6,47,12.6S44.5,18,41.6,18z M41.6,10.8
                              c-1,0-1.9,0.8-1.9,1.9s0.8,1.9,1.9,1.9s1.9-0.8,1.9-1.9S42.6,10.8,41.6,10.8z"/>
                          </g>
                        </g>
                      </g>
                      <g>
                        <g>
                          <g>
                            <path class="st0" d="M12.7,46.9c-3,0-5.4-2.4-5.4-5.4s2.4-5.4,5.4-5.4s5.4,2.4,5.4,5.4C18,44.5,15.6,46.9,12.7,46.9z M12.7,39.7
                              c-1,0-1.9,0.8-1.9,1.9s0.8,1.9,1.9,1.9s1.9-0.8,1.9-1.9S13.7,39.7,12.7,39.7z"/>
                          </g>
                        </g>
                      </g>
                      <g>
                        <g>
                          <g>
                            <path class="st0" d="M70.5,46.9c-3,0-5.4-2.4-5.4-5.4s2.4-5.4,5.4-5.4s5.4,2.4,5.4,5.4C75.9,44.5,73.4,46.9,70.5,46.9z
                              M70.5,39.7c-1,0-1.9,0.8-1.9,1.9s0.8,1.9,1.9,1.9c1.1,0,1.9-0.8,1.9-1.9S71.5,39.7,70.5,39.7z"/>
                          </g>
                        </g>
                      </g>
                      <g>
                        <g>
                          <g>
                            <path class="st0" d="M16.3,32.5c-3,0-5.4-2.4-5.4-5.4s2.4-5.4,5.4-5.4s5.4,2.4,5.4,5.4S19.2,32.5,16.3,32.5z M16.3,25.3
                              c-1,0-1.9,0.8-1.9,1.9s0.8,1.9,1.9,1.9s1.9-0.8,1.9-1.9S17.3,25.3,16.3,25.3z"/>
                          </g>
                        </g>
                      </g>
                      <g>
                        <g>
                          <g>
                            <path class="st0" d="M66.9,32.5c-3,0-5.4-2.4-5.4-5.4s2.4-5.4,5.4-5.4c3,0,5.4,2.4,5.4,5.4S69.8,32.5,66.9,32.5z M66.9,25.3
                              c-1,0-1.9,0.8-1.9,1.9s0.8,1.9,1.9,1.9c1.1,0,1.9-0.8,1.9-1.9S67.9,25.3,66.9,25.3z"/>
                          </g>
                        </g>
                      </g>
                      <g>
                        <g>
                          <g>
                            <path class="st0" d="M27.1,21.7c-3,0-5.4-2.4-5.4-5.4s2.4-5.4,5.4-5.4s5.4,2.4,5.4,5.4S30.1,21.7,27.1,21.7z M27.1,14.4
                              c-1,0-1.9,0.8-1.9,1.9s0.8,1.9,1.9,1.9s1.9-0.8,1.9-1.9S28.1,14.4,27.1,14.4z"/>
                          </g>
                        </g>
                      </g>
                      <g>
                        <g>
                          <g>
                            <path class="st0" d="M56,21.7c-3,0-5.4-2.4-5.4-5.4s2.4-5.4,5.4-5.4s5.4,2.4,5.4,5.4S59,21.7,56,21.7z M56,14.4
                              c-1,0-1.9,0.8-1.9,1.9s0.8,1.9,1.9,1.9s1.9-0.8,1.9-1.9S57,14.4,56,14.4z"/>
                          </g>
                        </g>
                      </g>
                      <g>
                        <g>
                          <g>
                            <rect x="16.3" y="39.8" class="st0" width="50.6" height="3.5"/>
                          </g>
                        </g>
                      </g>
                      <g>
                        <g>
                          <g>
                            <path style="fill:none;stroke:#212121;stroke-width:35;stroke-miterlimit:10;" d="M16.3,30.7"/>
                          </g>
                        </g>
                      </g>
                      <g>
                        <g>
                          <g>
                            <rect x="39.8" y="16.3" class="st0" width="3.5" height="66.8"/>
                          </g>
                        </g>
                      </g>
                      <g>
                        <g>
                          <g>
                            <polygon class="st0" points="49.7,28.9 33.4,28.9 27.5,20 30.4,18 35.3,25.4 47.9,25.4 52.8,18 55.7,20 				"/>
                          </g>
                        </g>
                      </g>
                      <g>
                        <g>
                          <g>
                            <polygon class="st0" points="28.9,41.6 25.4,41.6 25.4,35.3 18,30.4 20,27.5 28.9,33.4 				"/>
                          </g>
                        </g>
                      </g>
                      <g>
                        <g>
                          <g>
                            <polygon class="st0" points="57.8,41.6 54.3,41.6 54.3,33.4 63.2,27.5 65.1,30.4 57.8,35.3 				"/>
                          </g>
                        </g>
                      </g>
                      <g>
                        <g>
                          <g>
                            <path class="st0" d="M36.1,82.8L34,82.4c-6.3-1.2-12.3-3.8-17.4-7.6c-5-3.8-9.2-8.7-12-14.3l-1.3-2.6h23.8c5,0,9,4,9,9V82.8z
                              M9.2,61.4c5.2,8.5,13.7,14.7,23.4,17.1V66.9c0-3-2.5-5.5-5.5-5.5H9.2z"/>
                          </g>
                        </g>
                      </g>
                      <g>
                        <g>
                          <g>
                            <path class="st0" d="M47,82.8V66.9c0-4.9,4-9,9-9h23.8l-1.3,2.6c-2.9,5.6-7,10.5-12.1,14.3c-5.1,3.8-11.1,6.5-17.4,7.6L47,82.8z
                              M56,61.4c-3,0-5.5,2.4-5.5,5.5v11.6c9.7-2.4,18.2-8.6,23.4-17.1H56z"/>
                          </g>
                        </g>
                      </g>
                      <g>
                        <g>
                          <g>
                            <path class="st0" d="M43.3,66.9h-3.5c0-7-5.7-12.7-12.7-12.7H2l-0.4-1.3C0.6,49.2,0,45.4,0,41.6c0-5.6,1.1-11,3.3-16.2
                              c2.1-4.9,5.1-9.4,8.9-13.2c3.8-3.8,8.2-6.8,13.2-8.9C30.5,1.1,35.9,0,41.6,0s11,1.1,16.2,3.3c4.9,2.1,9.4,5.1,13.2,8.9
                              c3.8,3.8,6.8,8.2,8.9,13.2c2.2,5.1,3.3,10.5,3.3,16.2c0,3.8-0.5,7.7-1.6,11.3l-0.4,1.3H56C49,54.2,43.3,59.9,43.3,66.9z
                              M4.7,50.7h22.4c6.3,0,11.8,3.6,14.5,8.9c2.7-5.3,8.2-8.9,14.4-8.9h22.4c0.7-3,1.1-6,1.1-9.1c0-21-17-38-38-38s-38,17-38,38
                              C3.6,44.7,3.9,47.7,4.7,50.7z"/>
                          </g>
                        </g>
                      </g>
                    </g>
                    <g>
                      <g>
                        <path class="st0" d="M107.51,19.49h12.37c9.7,0,16.25,3.27,16.25,12.75c0,9.12-6.51,13.38-15.99,13.38h-7.12V62.8h-5.51V19.49z
                          M119.45,41.15c7.57,0,11.19-2.74,11.19-8.91c0-6.25-3.84-8.28-11.45-8.28h-6.16v17.19H119.45z"/>
                        <path class="st0" d="M144.86,19.49h5.51v18.14h20.14V19.49h5.51V62.8h-5.51V42.44h-20.14V62.8h-5.51V19.49z"/>
                        <path class="st0" d="M196.8,19.49h6.22l14.65,43.31h-5.84l-7.55-24.19c-1.56-4.84-2.95-9.6-4.33-14.6h-0.26
                          c-1.34,5.02-2.73,9.75-4.29,14.6l-7.64,24.19h-5.61L196.8,19.49z M189.85,45.21h19.94v4.4h-19.94V45.21z"/>
                        <path class="st0" d="M223.8,19.49h5.51V62.8h-5.51V19.49z"/>
                        <path class="st0" d="M241.16,19.49h10.84c13.32,0,20.46,7.74,20.46,21.5c0,13.76-7.14,21.81-20.21,21.81h-11.08V19.49z
                          M251.58,58.28c10.12,0,15.17-6.35,15.17-17.29s-5.05-16.98-15.17-16.98h-4.91v34.28H251.58z"/>
                        <path class="st0" d="M281.75,19.49h13.56c8.82,0,15.16,3.17,15.16,12.19c0,8.65-6.33,12.82-15.16,12.82h-8.05V62.8h-5.51V19.49z
                          M294.52,40.02c6.74,0,10.45-2.73,10.45-8.35c0-5.7-3.71-7.72-10.45-7.72h-7.26v16.06H294.52z M294.22,42.98l4.32-2.85
                          l13.22,22.67h-6.25L294.22,42.98z"/>
                        <path class="st0" d="M328.2,19.49h6.22l14.65,43.31h-5.84l-7.55-24.19c-1.56-4.84-2.95-9.6-4.33-14.6h-0.26
                          c-1.34,5.02-2.73,9.75-4.29,14.6l-7.64,24.19h-5.61L328.2,19.49z M321.26,45.21h19.94v4.4h-19.94V45.21z"/>
                      </g>
                    </g>
                    </svg>
                </a>
              </v-col>

              <v-col md="9" >
                <v-row justify-md="end" class="pr-4 py-2">
                  <div class="d-flex align-center me-2" v-if="signedin">
                    <v-icon
                      class="mr-1"
                      aria-hidden="true"
                    >mdi-account
                    </v-icon>
                    <span
                      class="subtitle-1"
                      >{{ user.firstname }} {{ user.lastname }}
                    </span>
                  </div>

                  <v-menu offset-y>
                    <template v-slot:activator="{ on, attrs }">
                      <v-btn class="px-12" icon tile v-on="on" v-bind="attrs" aria-controls="locale-menu">                        
                        <span class="subtitle-1 text-capitalize font-weight-medium"
                          >{{ localeLabel }}</span>
                        <v-icon
                          class="ml-1"  
                          aria-hidden="true"
                        >mdi-flag-variant
                        </v-icon>
                      </v-btn>
                    </template>
                    <v-list id="locale-menu">
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
                      <v-list-item
                        v-if="useLocale('ita')"
                        @click="changeLocale('ita')"
                        >
                        <v-list-item-title>Italiano</v-list-item-title>
                      </v-list-item>
                    </v-list>
                  </v-menu>

                  <v-tooltip v-if="!$vuetify.theme.dark" bottom>
                    <template v-slot:activator="{ on, attrs }">
                      <v-btn v-on="on" v-bind="attrs" icon @click="darkMode" :aria-label="$t('Dark Mode On')">
                        <v-icon>mdi-moon-waxing-crescent</v-icon>
                      </v-btn>
                    </template>
                    <span>{{ $t("Dark Mode On") }}</span>
                  </v-tooltip>

                  <v-tooltip v-else bottom>
                    <template v-slot:activator="{ on, attrs }">
                      <v-btn v-on="on" v-bind="attrs" icon @click="darkMode" :aria-label="$t('Dark Mode Off')">
                        <v-icon>mdi-white-balance-sunny</v-icon>
                      </v-btn>
                    </template>
                    <span>{{ $t("Dark Mode Off") }}</span>
                  </v-tooltip>
                </v-row>

                <v-row justify="center">
                  <v-col 
                  v-if="appconfig.showinstanceswitch"                  
                  md="4"
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

                  md="11"
                  offset-md="1"
                  v-else-if="instanceconfig.title"
                  >
                    <icon
                        aria-hidden="true"
                        left
                        dark
                        name="univie-right"
                        color="#a4a4a4"
                        width="14px"
                        height="14px"
                        class="mb-1"
                    ></icon>
                    <nuxt-link
                        class="subtitle-1"
                        :to="localePath('/')"
                        >{{ instanceconfig.title }}</nuxt-link
                    >
                  </v-col>
                </v-row>

                <v-row>
                  <v-toolbar flat dense color="transparent" class="my-md-1">
                    <client-only>
                      <v-row class="hidden-md-and-up">
                        <v-menu attach="#mobile-menu-btn" offset-y :disable-keys="true" min-width="150px">
                          <template v-slot:activator="{ on, attrs }">
                            <v-btn id="mobile-menu-btn" text x-large aria-controls="mobile-menu" aria-label="Main navigation menu"
                            v-bind="attrs" v-on="on" class="pa-2"><v-icon x-large class="mr-2">mdi-menu</v-icon>{{ $t('Menu') }}</v-btn>
                          </template>
                          <v-list id="mobile-menu">
                            <v-list-item
                                nuxt
                                :to="localePath({
                                    path: '/search',
                                    query: { reset: 1 },
                                    })"
                                ><v-list-item-title>{{
                                $t("Search")
                                }}</v-list-item-title></v-list-item
                            >
                            <v-list-item
                                v-if="signedin"
                                nuxt
                                :to="localePath('/submit')"
                                ><v-list-item-title>{{
                                $t("Upload")
                                }}</v-list-item-title></v-list-item
                            >
                            <v-list-item
                                v-if="signedin"
                                nuxt
                                :to="localePath({
                                    path: '/search',
                                    query: { reset: 1, owner: user.username },
                                    })"
                                ><v-list-item-title>{{
                                $t("My objects")
                                }}</v-list-item-title></v-list-item
                            >
                            <v-list-item
                                v-if="signedin"
                                nuxt
                                :to="localePath('/lists')"
                                ><v-list-item-title>{{
                                $t("Object lists")
                                }}</v-list-item-title></v-list-item
                            >
                            <v-list-item
                                v-if="signedin && instanceconfig.groups"
                                nuxt
                                :to="localePath('/groups')"
                                ><v-list-item-title>{{
                                $t("Groups")
                                }}</v-list-item-title></v-list-item
                            >
                            <v-list-item
                                v-if="signedin"
                                nuxt
                                :to="localePath('/templates')"
                                ><v-list-item-title>{{
                                $t("Templates")
                                }}</v-list-item-title></v-list-item
                            >
                            <v-list-item
                                nuxt
                                :to="localePath('/help')"
                                ><v-list-item-title>{{
                                $t("Help")
                                }}</v-list-item-title></v-list-item
                            >
                            <v-list-item
                                v-if="!signedin && appconfig.enablelogin"
                                ><v-list-item-title><a :href="localePath('/login') + '?returnto=' + encodeURIComponent($route.fullPath)">{{ $t("Login") }}</a></v-list-item-title></v-list-item
                            >
                            <v-list-item
                                v-if="user.isadmin"
                                nuxt
                                :to="localePath('/admin')"                              
                                ><v-list-item-title>{{
                                $t("Admin")
                                }}</v-list-item-title></v-list-item
                            >
                            <v-list-item v-if="signedin" @click="logout"
                                ><v-list-item-title>{{
                                $t("Logout")
                                }}</v-list-item-title></v-list-item
                            >
                          </v-list>
                        </v-menu>                                        
                      </v-row>
                    </client-only>
                    <v-spacer></v-spacer>
                    <v-toolbar-items class="hidden-sm-and-down no-height-inherit py-2">
                      <v-hover v-slot:default="{ hover }">
                        <v-btn
                          dark
                          tile
                          depressed
                          nuxt
                          active-class="ph-button-bg-active"
                          :color="hover ? 'primary' : isDarkTheme ? 'ph-button-bg-dark' : 'ph-button-bg'"
                          :to="localePath({
                              path: '/search',
                              query: { reset: 1 },
                          })"
                          class="font-weight-regular white--text"                          
                        >                    
                          {{ $t("Search") }}
                        </v-btn>
                      </v-hover>
                      <v-hover v-slot:default="{ hover }">
                        <v-btn
                          v-show="signedin"
                          dark
                          tile
                          depressed
                          nuxt
                          active-class="ph-button-bg-active"
                          :color="hover ? 'primary' : isDarkTheme ? 'ph-button-bg-dark' : 'ph-button-bg'"
                          :to="localePath('/submit')"
                          class="font-weight-regular white--text"
                        >
                          {{ $t("Upload") }}
                        </v-btn>
                      </v-hover>
                      <v-hover v-slot:default="{ hover }">
                        <v-btn
                          v-show="signedin"
                          dark
                          tile
                          depressed
                          nuxt
                          active-class="ph-button-bg-active"
                          :color="hover ? 'primary' : isDarkTheme ? 'ph-button-bg-dark' : 'ph-button-bg'"
                          :to="localePath({
                              path: '/search',
                              query: { reset: 1, owner: user.username },
                          })"
                          class="font-weight-regular white--text"
                        >                    
                          {{ $t("My objects") }}
                        </v-btn>
                      </v-hover>
                      <v-hover v-slot:default="{ hover }">
                        <v-btn
                          v-show="signedin"
                          dark
                          tile
                          depressed
                          nuxt
                          active-class="ph-button-bg-active"
                          :color="hover ? 'primary' : isDarkTheme ? 'ph-button-bg-dark' : 'ph-button-bg'"
                          :to="localePath('/lists')"
                          class="font-weight-regular white--text"
                        >                    
                          {{ $t("Object lists") }}
                        </v-btn>
                      </v-hover>
                      <v-hover v-slot:default="{ hover }">
                        <v-btn
                          v-show="signedin && instanceconfig.groups"
                          dark
                          tile
                          depressed
                          nuxt
                          active-class="ph-button-bg-active"
                          :color="hover ? 'primary' : isDarkTheme ? 'ph-button-bg-dark' : 'ph-button-bg'"
                          :to="localePath('/groups')"
                          class="font-weight-regular white--text"
                        >                    
                          {{ $t("Groups") }}
                        </v-btn>
                      </v-hover>
                      <v-hover v-slot:default="{ hover }">
                        <v-btn
                          v-show="signedin"
                          dark
                          tile
                          depressed
                          nuxt
                          active-class="ph-button-bg-active"
                          :color="hover ? 'primary' : isDarkTheme ? 'ph-button-bg-dark' : 'ph-button-bg'"
                          :to="localePath('/templates')"
                          class="font-weight-regular white--text"
                        >                    
                          {{ $t("Templates") }}
                        </v-btn>
                      </v-hover>
                      <v-hover v-slot:default="{ hover }">
                        <v-btn                          
                          dark
                          tile
                          depressed
                          nuxt
                          active-class="ph-button-bg-active"
                          :color="hover ? 'primary' : isDarkTheme ? 'ph-button-bg-dark' : 'ph-button-bg'"
                          :to="localePath('/help')"
                          class="font-weight-regular white--text"
                        >                    
                          {{ $t("Help") }}
                        </v-btn>
                      </v-hover>
                      <v-hover v-slot:default="{ hover }">
                        <v-btn
                          v-show="!signedin && appconfig.enablelogin"
                          dark
                          tile
                          depressed                          
                          :href="localePath('/login') + '?returnto=' + encodeURIComponent($route.fullPath)"
                          :color="hover ? 'primary' : isDarkTheme ? 'ph-button-bg-dark' : 'ph-button-bg'"
                          class="font-weight-regular white--text"
                          >
                            {{ $t("Login") }}                        
                        </v-btn>
                      </v-hover>
                      <v-hover v-slot:default="{ hover }">
                        <v-btn
                          v-show="user.isadmin"
                          dark
                          tile
                          depressed
                          nuxt
                          active-class="ph-button-bg-active"
                          :color="hover ? 'primary' : isDarkTheme ? 'ph-button-bg-dark' : 'ph-button-bg'"
                          :to="localePath('/admin')"
                          class="font-weight-regular white--text"
                          >
                            {{ $t("Admin") }}
                        </v-btn>
                      </v-hover>
                      <v-hover v-slot:default="{ hover }">
                        <v-btn
                          v-show="signedin"
                          dark
                          tile
                          depressed
                          active-class="ph-button-bg-active"
                          :color="hover ? 'primary' : isDarkTheme ? 'ph-button-bg-dark' : 'ph-button-bg'"
                          @click="logout"
                          class="font-weight-regular white--text"
                        >                    
                          {{ $t("Logout") }}
                        </v-btn>
                      </v-hover>
                    </v-toolbar-items>
                  </v-toolbar>
                </v-row>
              </v-col>
            </v-row>
          </v-col>
      </v-row>
      <a ref="logoutlink" href="/Shibboleth.sso/Logout" aria-hidden="true" role="presentation" tabindex="-1"></a>
    </div>
  </template>
  
  <script>
  import { config } from "@/mixins/config";
  import { context } from "@/mixins/context";
  
  export default {
    mixins: [config, context],
    computed: {
      localeLabel: function () {
        return this.$i18n.locale;
      },
      isDarkTheme: function () {
        return this.$vuetify.theme.dark;
      }
    },
    methods: {
      darkMode() {
        this.$vuetify.theme.dark = !this.$vuetify.theme.dark;
        localStorage.setItem("theme", this.$vuetify.theme.dark ? "dark" : "light");
        this.$cookies.set('theme', this.$vuetify.theme.dark ? "dark" : "light", {
          path: '/',
          maxAge: 60 * 60 * 24 * 365 // 1 year
        });
      },
      logout: function () {
        console.log("local logout")
        this.$store.dispatch("logout");
        this.$store.commit("setLoading", false);
        this.$router.push(this.localeLocation({ path: `/` }));
      },
      ssologoutlink: async function () {
        console.log("local logout")
        try {
          await this.$store.dispatch("logout");
        } catch (error) {
          console.log(error)
        }
        console.log("sso logout link")
        this.$store.commit("setLoading", false);
        this.$refs.logoutlink.click();
      },
      ssologout: async function () {
        console.log("local logout")
        try {
          await this.$store.dispatch("logout");
        } catch (error) {
          console.log(error)
        }
        console.log("sso logout location.href")
        this.$store.commit("setLoading", false);
        window.location.href = '/Shibboleth.sso/Logout'
      },
      useLocale: function (lang) {
        if (this.instanceconfig) {
          if (this.instanceconfig.languages) {
            return this.instanceconfig.languages.split(',').includes(lang);
          }
        }
        return false;
      },
      changeLocale: function (lang) {
        this.$i18n.locale = lang;
        // this.$i18n.setLocaleCookie(lang);
        localStorage.setItem("locale", lang);
        this.$cookies.set("locale", lang);
        this.$router.push(this.switchLocalePath(lang));
        this.$store.dispatch("vocabulary/sortRoles", this.$i18n.locale);
        this.$store.dispatch("vocabulary/sortFields", {locale: this.$i18n.locale, i18nInstance: this.$i18n});
        this.$store.dispatch("vocabulary/sortObjectTypes", this.$i18n.locale);
        this.$store.dispatch('info/sortFieldsOverview', {locale: this.$i18n.locale, i18nInstance: this.$i18n})
      }
    },
    mounted() {
      if (localStorage.getItem("locale")) {
        this.$i18n.locale = localStorage.getItem("locale");
      } else {
        console.log('default locale: ' + this.$config.defaultLocale)
        if (this.$config.defaultLocale) {
          this.$i18n.locale = this.$config.defaultLocale
        }
        localStorage.setItem("locale", this.$i18n.locale);
        this.$cookies.set("locale", this.$i18n.locale);
      }
    }
  };
  </script>  

<style scoped>
</style>
