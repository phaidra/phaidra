<template>
  <div id="app">
    <v-app>
      <v-container fluid>
        <v-row justify="center" v-for="(alert, i) in alerts" :key="i">
          <v-col cols="10">
            <v-alert
              prominent
              dense
              :type="alert.type === 'danger' ? 'error' : alert.type"
              :value="true"
              transition="slide-y-transition"
            >
              <v-row align="center">
                <v-col class="grow">{{ alert.msg }}</v-col>
                <v-col class="shrink">
                  <v-btn icon @click.native="dismiss(alert)"
                    ><v-icon>mdi-close</v-icon></v-btn
                  >
                </v-col>
              </v-row>
            </v-alert>
          </v-col>
        </v-row>

        <v-row align="center">
          <v-col cols="2">
            <v-text-field v-model="solrbaseurl" :label="'solr'"></v-text-field>
          </v-col>
          <v-col cols="2">
            <v-text-field
              v-model="phaidrabaseurl"
              :label="'phaidra'"
            ></v-text-field>
          </v-col>
          <v-col cols="2">
            <v-text-field
              v-model="apibaseurl"
              :label="'phaidra-api'"
            ></v-text-field>
          </v-col>
          <template v-if="token">
            <v-col cols="4" class="body-2">{{ token }}</v-col>
            <v-col cols="1">
              <v-btn
                dark
                raised
                single-line
                color="grey darken-3"
                @click="logout()"
                >Logout</v-btn
              >
            </v-col>
          </template>
          <template v-else>
            <v-col cols="2">
              <v-text-field
                v-model="credentials.username"
                :label="'username'"
              ></v-text-field>
            </v-col>
            <v-col cols="2">
              <v-text-field
                v-model="credentials.password"
                :label="'password'"
                :append-icon="psvis ? 'mdi-eye' : 'mdi-eye-off'"
                @click:append="toggleVisibility"
                :type="psvis ? 'password' : 'text'"
              ></v-text-field>
            </v-col>
            <v-col cols="1">
              <v-btn
                dark
                raised
                single-line
                color="grey darken-3"
                @click="login()"
                >Login</v-btn
              >
            </v-col>
          </template>
        </v-row>

        <v-row>
          <v-col cols="2">
            <v-navigation-drawer permanent>
              <v-toolbar flat>
                <v-list>
                  <v-list-item>
                    <v-list-item-title class="title">{{
                      $t("Examples")
                    }}</v-list-item-title>
                  </v-list-item>
                </v-list>
              </v-toolbar>
              <v-divider></v-divider>
              <v-list>
                <v-item-group
                  v-model="window"
                  class="shrink mr-4"
                  mandatory
                  tag="v-flex"
                >
                  <v-item>
                    <div slot-scope="{ active, toggle }">
                      <v-list-item @click="toggle">
                        <v-list-item-content>
                          <v-list-item-title>{{
                            $t("Display")
                          }}</v-list-item-title>
                        </v-list-item-content>
                      </v-list-item>
                    </div>
                  </v-item>
                  <v-item>
                    <div slot-scope="{ active, toggle }">
                      <v-list-item @click="toggle">
                        <v-list-item-content>
                          <v-list-item-title>{{
                            $t("Edit")
                          }}</v-list-item-title>
                        </v-list-item-content>
                      </v-list-item>
                    </div>
                  </v-item>
                  <v-item>
                    <div slot-scope="{ active, toggle }">
                      <v-list-item @click="toggle">
                        <v-list-item-content>
                          <v-list-item-title>{{
                            $t("Submit")
                          }}</v-list-item-title>
                        </v-list-item-content>
                      </v-list-item>
                    </div>
                  </v-item>
                  <v-item>
                    <div slot-scope="{ active, toggle }">
                      <v-list-item @click="toggle">
                        <v-list-item-content>
                          <v-list-item-title>{{
                            $t("Search")
                          }}</v-list-item-title>
                        </v-list-item-content>
                      </v-list-item>
                    </div>
                  </v-item>
                  <v-item>
                    <div slot-scope="{ active, toggle }">
                      <v-list-item @click="toggle">
                        <v-list-item-content>
                          <v-list-item-title>{{
                            $t("Manage")
                          }}</v-list-item-title>
                        </v-list-item-content>
                      </v-list-item>
                    </div>
                  </v-item>
                  <v-item>
                    <div slot-scope="{ active, toggle }">
                      <v-list-item @click="toggle">
                        <v-list-item-content>
                          <v-list-item-title>{{
                            $t("Browse")
                          }}</v-list-item-title>
                        </v-list-item-content>
                      </v-list-item>
                    </div>
                  </v-item>
                  <v-item>
                    <div slot-scope="{ active, toggle }">
                      <v-list-item @click="toggle">
                        <v-list-item-content>
                          <v-list-item-title>{{
                            $t("Uwm editor")
                          }}</v-list-item-title>
                        </v-list-item-content>
                      </v-list-item>
                    </div>
                  </v-item>
                  <v-item>
                    <div slot-scope="{ active, toggle }">
                      <v-list-item @click="toggle">
                        <v-list-item-content>
                          <v-list-item-title>{{
                            $t("Uwm display")
                          }}</v-list-item-title>
                        </v-list-item-content>
                      </v-list-item>
                    </div>
                  </v-item>
                  <v-item>
                    <div slot-scope="{ active, toggle }">
                      <v-list-item @click="toggle">
                        <v-list-item-content>
                          <v-list-item-title>{{
                            $t("Mods display")
                          }}</v-list-item-title>
                        </v-list-item-content>
                      </v-list-item>
                    </div>
                  </v-item>
                </v-item-group>
              </v-list>
            </v-navigation-drawer>
          </v-col>

          <v-col cols="10">
            <v-window v-model="window">
              <v-window-item>
                <v-card>
                  <v-toolbar dark color="grey">
                    <v-toolbar-title>{{ $t("Display") }}</v-toolbar-title>
                    <v-text-field
                      class="mx-4"
                      flat
                      solo
                      hide-details
                      single-line
                      v-model="pid"
                      :placeholder="'o:123456789'"
                    ></v-text-field>
                    <v-spacer></v-spacer>
                    <v-btn
                      raised
                      single-line
                      class="float-right"
                      color="grey darken-3"
                      @click="loadDisplay()"
                      >Load</v-btn
                    >
                  </v-toolbar>
                  <v-card-text>
                    <p-d-jsonld
                      :jsonld="displayjsonld"
                      :pid="pid"
                      :labelColMd="'2'"
                      :valueColMd="'10'"
                      :copyrightLink="'https://www.ris.bka.gv.at/GeltendeFassung.wxe?Abfrage=Bundesnormen&Gesetzesnummer=10001848'"
                    ></p-d-jsonld>
                  </v-card-text>
                </v-card>
              </v-window-item>
              <v-window-item>
                <v-card>
                  <v-toolbar dark color="grey">
                    <v-toolbar-title>{{ $t("Edit") }}</v-toolbar-title>
                    <v-text-field
                      class="mx-4"
                      flat
                      solo
                      hide-details
                      single-line
                      v-model="pid"
                      :placeholder="'o:123456789'"
                    ></v-text-field>
                    <v-spacer></v-spacer>
                    <v-btn
                      raised
                      single-line
                      class="float-right"
                      color="grey darken-3"
                      @click="loadEdit()"
                      >Load</v-btn
                    >
                  </v-toolbar>
                  <v-card-text>
                    <p-i-form
                      :form="editform"
                      :targetpid="this.pid"
                      :validate="validate"
                      v-on:object-saved="objectSaved($event)"
                      v-on:load-form="form = $event"
                    ></p-i-form>
                  </v-card-text>
                </v-card>
              </v-window-item>
              <v-window-item>
                <v-card>
                  <v-toolbar class="grey" dark>
                    <v-toolbar-title>{{ $t("Submit") }}</v-toolbar-title>
                    <v-select
                      class="mx-4"
                      :items="contentmodels"
                      v-model="contentmodel"
                      label="Object type"
                      flat
                      solo
                      hide-details
                      single-line
                      v-on:change="resetForm($event)"
                    ></v-select>
                    <v-spacer></v-spacer>
                  </v-toolbar>
                  <v-card-text>
                    <p-i-form
                      :form="form"
                      :debug="true"
                      :rights="submitRights"
                      :enablerights="true"
                      :validate="validate"
                      v-on:object-created="objectCreated($event)"
                      v-on:load-form="form = $event"
                      v-on:form-input-p-select="handleSelect($event)"
                      v-on:add-phaidrasubject-section="
                        addPhaidrasubjectSection($event)
                      "
                      v-on:input-rights="submitRights = $event"
                    ></p-i-form>
                  </v-card-text>
                </v-card>
              </v-window-item>
              <v-window-item>
                <v-card>
                  <v-toolbar dark color="grey">
                    <v-toolbar-title>{{ $t("Search") }}</v-toolbar-title>
                    <v-text-field
                      class="mx-4"
                      flat
                      solo
                      hide-details
                      single-line
                      :placeholder="'Collection, e.g. ' + sampleCollection"
                      v-model="collection"
                    ></v-text-field>
                    <v-spacer></v-spacer>
                  </v-toolbar>
                  <v-card-text>
                    <p-search :collection="collection"></p-search>
                  </v-card-text>
                </v-card>
              </v-window-item>
              <v-window-item>
                <v-card>
                  <v-toolbar class="grey" dark>
                    <v-toolbar-title>{{ $t("Manage") }}</v-toolbar-title>
                    <v-text-field
                      class="mx-4"
                      flat
                      solo
                      hide-details
                      single-line
                      :placeholder="'o:123456789'"
                      v-model="pid"
                    ></v-text-field>
                    <v-spacer></v-spacer>
                    <v-btn
                      raised
                      single-line
                      class="float-right"
                      color="grey darken-3"
                      @click="loadManagement(pid)"
                      >Load</v-btn
                    >
                  </v-toolbar>
                  <v-card-text>
                    <v-col
                      >{{ $t("Manage") }} {{ piddoc.cmodel }} {{ pid }}</v-col
                    >
                    <p-m-sort
                      :pid="pid"
                      :cmodel="loadedcmodel"
                      :members="members"
                      @input="members = $event"
                      @order-saved="orderSaved($event)"
                    ></p-m-sort>
                    <p-m-rights :pid="pid"></p-m-rights>
                    <p-m-relationships :pid="pid"></p-m-relationships>
                    <p-m-delete
                      :pid="pid"
                      :cmodel="loadedcmodel"
                      :members="members"
                    ></p-m-delete>
                  </v-card-text>
                </v-card>
              </v-window-item>
              <v-window-item>
                <v-card>
                  <v-toolbar class="grey" dark>
                    <v-toolbar-title>{{
                      $t("Collection gallery")
                    }}</v-toolbar-title>
                    <v-text-field
                      class="mx-4"
                      flat
                      solo
                      hide-details
                      single-line
                      :placeholder="'Collection, e.g. ' + sampleCollection"
                      v-model="collection"
                    ></v-text-field>
                    <v-spacer></v-spacer>
                  </v-toolbar>
                  <v-card-text>
                    <p-collection-gallery
                      :collection="collection"
                    ></p-collection-gallery>
                  </v-card-text>
                </v-card>
              </v-window-item>
              <v-window-item>
                <v-card>
                  <v-toolbar class="grey" dark>
                    <v-toolbar-title>{{
                      $t("Uwmetadata Editor")
                    }}</v-toolbar-title>
                    <v-text-field
                      class="mx-4"
                      flat
                      solo
                      hide-details
                      single-line
                      :placeholder="'o:123456789'"
                      v-model="pid"
                    ></v-text-field>
                    <v-spacer></v-spacer>
                    <v-btn
                      raised
                      single-line
                      class="float-right"
                      color="grey darken-3"
                      @click="loadUwmetadataEdit()"
                      >Load</v-btn
                    >
                  </v-toolbar>
                  <v-card-text>
                    <p-i-form-uwm
                      :form="uwmetadataeditform"
                      :targetpid="this.pid"
                      v-on:object-saved="objectSaved($event)"
                      v-on:load-form="uwmetadataeditform = $event"
                    ></p-i-form-uwm>
                  </v-card-text>
                </v-card>
              </v-window-item>
              <v-window-item>
                <v-card>
                  <v-toolbar class="grey" dark>
                    <v-toolbar-title>{{
                      $t("Uwmetadata Display")
                    }}</v-toolbar-title>
                    <v-text-field
                      class="mx-4"
                      flat
                      solo
                      hide-details
                      single-line
                      :placeholder="'o:123456789'"
                      v-model="pid"
                    ></v-text-field>
                    <v-spacer></v-spacer>
                    <v-btn
                      raised
                      single-line
                      class="float-right"
                      color="grey darken-3"
                      @click="loadUwmetadataDisplay()"
                      >Load</v-btn
                    >
                  </v-toolbar>
                  <v-card-text>
                    <p-d-uwm-rec :children="uwmetadatadisplay"></p-d-uwm-rec>
                  </v-card-text>
                </v-card>
              </v-window-item>
              <v-window-item>
                <v-card>
                  <v-toolbar class="grey" dark>
                    <v-toolbar-title>{{ $t("Mods Display") }}</v-toolbar-title>
                    <v-text-field
                      class="mx-4"
                      flat
                      solo
                      hide-details
                      single-line
                      :placeholder="'o:123456789'"
                      v-model="pid"
                    ></v-text-field>
                    <v-spacer></v-spacer>
                    <v-btn
                      raised
                      single-line
                      class="float-right"
                      color="grey darken-3"
                      @click="loadModsDisplay()"
                      >Load</v-btn
                    >
                  </v-toolbar>
                  <v-card-text>
                    <p-d-mods-rec :children="modsdisplay"></p-d-mods-rec>
                  </v-card-text>
                </v-card>
              </v-window-item>
            </v-window>
          </v-col>
        </v-row>
        <v-row justify="center">
          <v-spacer></v-spacer>
          <v-col offset="9" cols="2">
            <v-select
              v-model="lang"
              :items="languages"
              :label="$t('Language')"
              @change="$i18n.locale = $event"
              prepend-icon="mdi-translate"
              single-line
            ></v-select>
          </v-col>
          <v-col cols="1" class="mt-4">v {{ version }}</v-col>
        </v-row>
      </v-container>
    </v-app>
  </div>
</template>

<script>
import qs from 'qs'
import PIForm from '@/components/input/PIForm'
import PDJsonld from '@/components/display/PDJsonld'
import PMDelete from '@/components/management/PMDelete'
import PMSort from '@/components/management/PMSort'
import PMRights from '@/components/management/PMRights'
import PMRelationships from '@/components/management/PMRelationships'
import PSearch from '@/components/search/PSearch'
import PIFormUwm from '@/components/legacy/PIFormUwm'
import PDUwmRec from '@/components/legacy/PDUwmRec'
import PDModsRec from '@/components/legacy/PDModsRec'
import PCollectionGallery from '@/components/browse/PCollectionGallery'
import { version } from '../package.json'
import fields from '@/utils/fields'
import jsonLd from '@/utils/json-ld'

export default {
  name: 'app',
  components: {
    PIForm,
    PDJsonld,
    PSearch,
    PMDelete,
    PMSort,
    PMRights,
    PMRelationships,
    PCollectionGallery,
    PIFormUwm,
    PDUwmRec,
    PDModsRec
  },
  computed: {
    loadedcmodel: function () {
      return 'cmodel' in this.piddoc ? this.piddoc.cmodel : 'unknown'
    },
    token: function () {
      return this.$store.state.user.token
    },
    alerts: function () {
      return this.$store.state.alerts
    },
    vocabularies: function () {
      return this.$store.state.vocabulary.vocabularies
    },
    instance: function () {
      return this.$store.state.instanceconfig
    }
  },
  data () {
    return {
      window: 2,
      lang: 'deu',
      languages: [
        { text: 'english', value: 'eng' },
        { text: 'deutsch', value: 'deu' }
      ],
      displayjsonld: {},
      editform: {},
      uwmetadataeditform: [],
      uwmetadatadisplay: [
        // {
        //   'children': [
        //     {
        //       'datatype': 'CharacterString',
        //       'input_type': 'input_text',
        //       'ui_value': 'o:588288',
        //       'xmlname': 'identifier',
        //       'xmlns': 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0'
        //     },
        //     {
        //       'attributes': [
        //         {
        //           'input_type': 'select',
        //           'ui_value': 'en',
        //           'xmlname': 'lang'
        //         }
        //       ],
        //       'datatype': 'LangString',
        //       'input_type': 'input_text',
        //       'ui_value': 'The Rubicon of Art',
        //       'xmlname': 'title',
        //       'xmlns': 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0'
        //     },
        //     {
        //       'attributes': [
        //         {
        //           'input_type': 'select',
        //           'ui_value': 'en',
        //           'xmlname': 'lang'
        //         }
        //       ],
        //       'datatype': 'LangString',
        //       'input_type': 'input_text',
        //       'ui_value': 'Precultural rationalism in the works of Stone',
        //       'xmlname': 'subtitle',
        //       'xmlns': 'http://phaidra.univie.ac.at/XML/metadata/extended/V1.0'
        //     },
        //     {
        //       'attributes': [
        //         {
        //           'input_type': 'select',
        //           'ui_value': 'en',
        //           'xmlname': 'lang'
        //         }
        //       ],
        //       'datatype': 'LangString',
        //       'input_type': 'input_text',
        //       'ui_value': 'Capitalist discourse and subtextual objectivism',
        //       'xmlname': 'alt_title',
        //       'xmlns': 'http://phaidra.univie.ac.at/XML/metadata/extended/V1.0'
        //     },
        //     {
        //       'datatype': 'Language',
        //       'input_type': 'select',
        //       'ui_value': 'en',
        //       'xmlname': 'language',
        //       'xmlns': 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0'
        //     },
        //     {
        //       'attributes': [
        //         {
        //           'input_type': 'select',
        //           'ui_value': 'en',
        //           'xmlname': 'lang'
        //         }
        //       ],
        //       'datatype': 'LangString',
        //       'input_type': 'input_text',
        //       'ui_value': 'In the works of Joyce, a predominant concept is the concept of dialectic\nculture. Therefore, Prinn[1] suggests that we have to choose\nbetween dialectic situationism and pretextual modern theory. Any number of\nnarratives concerning the collapse, and hence the economy, of neotextual class\nmay be revealed. \n\nThe primary theme of the works of Tarantino is not, in fact, construction,\nbut postconstruction. Thus, the subject is contextualised into a subtextual\nobjectivism that includes sexuality as a paradox. The premise of precultural\nrationalism states that society, somewhat surprisingly, has intrinsic meaning.',
        //       'xmlname': 'description',
        //       'xmlns': 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0'
        //     },
        //     {
        //       'attributes': [
        //         {
        //           'input_type': 'select',
        //           'ui_value': 'en',
        //           'xmlname': 'lang'
        //         }
        //       ],
        //       'datatype': 'LangString',
        //       'input_type': 'input_text',
        //       'ui_value': 'capitalism, Joyce, pomo',
        //       'xmlname': 'keyword',
        //       'xmlns': 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0'
        //     },
        //     {
        //       'attributes': [
        //         {
        //           'input_type': 'select',
        //           'ui_value': 'en',
        //           'xmlname': 'lang'
        //         }
        //       ],
        //       'datatype': 'LangString',
        //       'input_type': 'input_text',
        //       'ui_value': 'nonsense',
        //       'xmlname': 'coverage',
        //       'xmlns': 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0'
        //     },
        //     {
        //       'children': [
        //         {
        //           'datatype': 'Vocabulary',
        //           'input_type': 'select',
        //           'labels': {
        //             'de': 'HTTP/WWW',
        //             'en': 'HTTP/WWW',
        //             'it': 'HTTP/WWW',
        //             'sr': 'HTTP/WWW'
        //           },
        //           'ui_value': 'http://phaidra.univie.ac.at/XML/metadata/extended/V1.0/voc_31/1552102',
        //           'xmlname': 'resource',
        //           'xmlns': 'http://phaidra.univie.ac.at/XML/metadata/extended/V1.0'
        //         },
        //         {
        //           'datatype': 'CharacterString',
        //           'input_type': 'input_text',
        //           'ui_value': 'http://www.elsewhere.org/pomo/',
        //           'xmlname': 'identifier',
        //           'xmlns': 'http://phaidra.univie.ac.at/XML/metadata/extended/V1.0'
        //         }
        //       ],
        //       'datatype': 'Node',
        //       'input_type': 'node',
        //       'xmlname': 'identifiers',
        //       'xmlns': 'http://phaidra.univie.ac.at/XML/metadata/extended/V1.0'
        //     }
        //   ],
        //   'datatype': 'Node',
        //   'input_type': 'node',
        //   'xmlname': 'general',
        //   'xmlns': 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0'
        // },
        // {
        //   'children': [
        //     {
        //       'datatype': 'DateTime',
        //       'input_type': 'input_text',
        //       'ui_value': '2020-03-27T08:35:21.643Z',
        //       'xmlname': 'upload_date',
        //       'xmlns': 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0'
        //     },
        //     {
        //       'datatype': 'Vocabulary',
        //       'input_type': 'select',
        //       'labels': {
        //         'de': 'Fertig',
        //         'en': 'Complete',
        //         'it': 'Completo',
        //         'sr': 'kompletno'
        //       },
        //       'ui_value': 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_2/44',
        //       'xmlname': 'status',
        //       'xmlns': 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0'
        //     },
        //     {
        //       'datatype': 'Boolean',
        //       'input_type': 'select',
        //       'labels': {
        //         'de': 'Nein',
        //         'en': 'No',
        //         'it': 'No'
        //       },
        //       'ui_value': 'no',
        //       'xmlname': 'peer_reviewed',
        //       'xmlns': 'http://phaidra.univie.ac.at/XML/metadata/extended/V1.0'
        //     },
        //     {
        //       'attributes': [
        //         {
        //           'input_type': 'input_text',
        //           'ui_value': '0',
        //           'xmlname': 'data_order'
        //         }
        //       ],
        //       'children': [
        //         {
        //           'datatype': 'Vocabulary',
        //           'input_type': 'select',
        //           'labels': {
        //             'de': 'AutorIn des digitalen Objekts',
        //             'en': 'Author of the digital object',
        //             'it': "Autore dell'oggetto digitale",
        //             'sr': 'autor digitalnog objekta'
        //           },
        //           'ui_value': 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/46',
        //           'xmlname': 'role',
        //           'xmlns': 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0'
        //         },
        //         {
        //           'attributes': [
        //             {
        //               'input_type': 'input_text',
        //               'ui_value': '0',
        //               'xmlname': 'data_order'
        //             }
        //           ],
        //           'children': [
        //             {
        //               'datatype': 'CharacterString',
        //               'input_type': 'input_text',
        //               'ui_value': 'Agnes',
        //               'xmlname': 'firstname',
        //               'xmlns': 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/entity'
        //             },
        //             {
        //               'datatype': 'CharacterString',
        //               'input_type': 'input_text',
        //               'ui_value': 'V. L. McElwaine',
        //               'xmlname': 'lastname',
        //               'xmlns': 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/entity'
        //             },
        //             {
        //               'datatype': 'CharacterString',
        //               'input_type': 'input_text',
        //               'ui_value': 'Department of English, University of Illinois',
        //               'xmlname': 'institution',
        //               'xmlns': 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/entity'
        //             }
        //           ],
        //           'datatype': 'Node',
        //           'input_type': 'node',
        //           'xmlname': 'entity',
        //           'xmlns': 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0'
        //         },
        //         {
        //           'attributes': [
        //             {
        //               'input_type': 'input_text',
        //               'ui_value': '1',
        //               'xmlname': 'data_order'
        //             }
        //           ],
        //           'children': [
        //             {
        //               'datatype': 'CharacterString',
        //               'input_type': 'input_text',
        //               'ui_value': 'Engelbert',
        //               'xmlname': 'firstname',
        //               'xmlns': 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/entity'
        //             },
        //             {
        //               'datatype': 'CharacterString',
        //               'input_type': 'input_text',
        //               'ui_value': 'Humperdinck',
        //               'xmlname': 'lastname',
        //               'xmlns': 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/entity'
        //             },
        //             {
        //               'datatype': 'CharacterString',
        //               'input_type': 'input_text',
        //               'ui_value': 'person',
        //               'xmlname': 'type',
        //               'xmlns': 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/entity'
        //             }
        //           ],
        //           'datatype': 'Node',
        //           'input_type': 'node',
        //           'xmlname': 'entity',
        //           'xmlns': 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0'
        //         }
        //       ],
        //       'datatype': 'Node',
        //       'input_type': 'node',
        //       'xmlname': 'contribute',
        //       'xmlns': 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0'
        //     },
        //     {
        //       'attributes': [
        //         {
        //           'input_type': 'input_text',
        //           'ui_value': '1',
        //           'xmlname': 'data_order'
        //         }
        //       ],
        //       'children': [
        //         {
        //           'datatype': 'Vocabulary',
        //           'input_type': 'select',
        //           'labels': {
        //             'de': 'EditorIn',
        //             'en': 'Editor',
        //             'it': 'Curatore',
        //             'sr': 'urednik'
        //           },
        //           'ui_value': 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/52',
        //           'xmlname': 'role',
        //           'xmlns': 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0'
        //         },
        //         {
        //           'attributes': [
        //             {
        //               'input_type': 'input_text',
        //               'ui_value': '0',
        //               'xmlname': 'data_order'
        //             }
        //           ],
        //           'children': [
        //             {
        //               'datatype': 'CharacterString',
        //               'input_type': 'input_text',
        //               'ui_value': 'Rastislav',
        //               'xmlname': 'firstname',
        //               'xmlns': 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/entity'
        //             },
        //             {
        //               'datatype': 'CharacterString',
        //               'input_type': 'input_text',
        //               'ui_value': 'Hudak',
        //               'xmlname': 'lastname',
        //               'xmlns': 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/entity'
        //             },
        //             {
        //               'datatype': 'CharacterString',
        //               'input_type': 'input_text',
        //               'ui_value': 'Zentraler Informatikdienst, Universität Wien',
        //               'xmlname': 'institution',
        //               'xmlns': 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/entity'
        //             },
        //             {
        //               'datatype': 'CharacterString',
        //               'input_type': 'input_text',
        //               'ui_value': 'Mgr.',
        //               'xmlname': 'title1',
        //               'xmlns': 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/entity'
        //             },
        //             {
        //               'datatype': 'CharacterString',
        //               'input_type': 'input_text',
        //               'ui_value': 'Csc.',
        //               'xmlname': 'title2',
        //               'xmlns': 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/entity'
        //             },
        //             {
        //               'datatype': 'CharacterString',
        //               'input_type': 'input_text',
        //               'ui_value': '118517376',
        //               'xmlname': 'gnd',
        //               'xmlns': 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/entity'
        //             },
        //             {
        //               'datatype': 'CharacterString',
        //               'input_type': 'input_text',
        //               'ui_value': 'n79056735',
        //               'xmlname': 'lcnaf',
        //               'xmlns': 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/entity'
        //             }
        //           ],
        //           'datatype': 'Node',
        //           'input_type': 'node',
        //           'xmlname': 'entity',
        //           'xmlns': 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0'
        //         },
        //         {
        //           'datatype': 'DateTime',
        //           'input_type': 'input_text',
        //           'ui_value': '2020-03-12',
        //           'xmlname': 'date',
        //           'xmlns': 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0'
        //         }
        //       ],
        //       'datatype': 'Node',
        //       'input_type': 'node',
        //       'xmlname': 'contribute',
        //       'xmlns': 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0'
        //     },
        //     {
        //       'datatype': 'Vocabulary',
        //       'input_type': 'select',
        //       'labels': {
        //         'de': 'acceptedVersion',
        //         'en': 'acceptedVersion',
        //         'it': 'acceptedVersion',
        //         'sr': 'acceptedVersion'
        //       },
        //       'ui_value': 'http://phaidra.univie.ac.at/XML/metadata/extended/V1.0/voc_38/1556249',
        //       'xmlname': 'infoeurepoversion',
        //       'xmlns': 'http://phaidra.univie.ac.at/XML/metadata/extended/V1.0'
        //     }
        //   ],
        //   'datatype': 'Node',
        //   'input_type': 'node',
        //   'xmlname': 'lifecycle',
        //   'xmlns': 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0'
        // },
        // {
        //   'children': [
        //     {
        //       'datatype': 'CharacterString',
        //       'input_type': 'input_text',
        //       'ui_value': 'application/pdf',
        //       'xmlname': 'format',
        //       'xmlns': 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0'
        //     },
        //     {
        //       'datatype': 'FileSize',
        //       'input_type': 'input_text',
        //       'ui_value': '1115',
        //       'xmlname': 'size',
        //       'xmlns': 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0'
        //     },
        //     {
        //       'datatype': 'CharacterString',
        //       'input_type': 'input_text',
        //       'ui_value': 'http://phaidra-sandbox.univie.ac.at/o:588288',
        //       'xmlname': 'location',
        //       'xmlns': 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0'
        //     },
        //     {
        //       'attributes': [
        //         {
        //           'input_type': 'select',
        //           'ui_value': 'en',
        //           'xmlname': 'lang'
        //         }
        //       ],
        //       'datatype': 'LangString',
        //       'input_type': 'input_text',
        //       'ui_value': 'But the main theme of la Tournier’s[2] critique of\nprecultural rationalism is the dialectic of constructivist sexual identity. The\nmeaninglessness, and subsequent futility, of dialectic situationism which is a\ncentral theme of Tarantino’s Pulp Fiction emerges again in Reservoir\nDogs, although in a more mythopoetical sense.',
        //       'xmlname': 'installremarks',
        //       'xmlns': 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0'
        //     },
        //     {
        //       'attributes': [
        //         {
        //           'input_type': 'select',
        //           'ui_value': 'en',
        //           'xmlname': 'lang'
        //         }
        //       ],
        //       'datatype': 'LangString',
        //       'input_type': 'input_text',
        //       'ui_value': 'Thus, Sontag uses the term ‘precultural rationalism’ to denote the common\nground between reality and class. The premise of neotextual deconstructive\ntheory states that consciousness is capable of intent, but only if reality is\nequal to narrativity; if that is not the case, we can assume that the purpose\nof the reader is social comment.\n{link}google.com{/link}',
        //       'xmlname': 'otherrequirements',
        //       'xmlns': 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0'
        //     },
        //     {
        //       'datatype': 'Duration',
        //       'input_type': 'input_text',
        //       'ui_value': 'PT32H45M22S',
        //       'xmlname': 'duration',
        //       'xmlns': 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0'
        //     }
        //   ],
        //   'datatype': 'Node',
        //   'input_type': 'node',
        //   'xmlname': 'technical',
        //   'xmlns': 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0'
        // },
        // {
        //   'children': [
        //     {
        //       'children': [
        //         {
        //           'attributes': [
        //             {
        //               'input_type': 'input_text',
        //               'ui_value': '0',
        //               'xmlname': 'data_order'
        //             }
        //           ],
        //           'datatype': 'Vocabulary',
        //           'input_type': 'select',
        //           'labels': {
        //             'de': 'Experiment',
        //             'en': 'Experiment',
        //             'it': 'Esperimento',
        //             'sr': 'eksperiment'
        //           },
        //           'ui_value': 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/educational/voc_11/1699',
        //           'xmlname': 'learningresourcetype',
        //           'xmlns': 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/educational'
        //         },
        //         {
        //           'datatype': 'Vocabulary',
        //           'input_type': 'select',
        //           'labels': {
        //             'de': 'Erklärend',
        //             'en': 'Expositive',
        //             'it': 'Descrittiva',
        //             'sr': 'opisna'
        //           },
        //           'ui_value': 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/educational/voc_10/1686',
        //           'xmlname': 'interactivitytype',
        //           'xmlns': 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/educational'
        //         },
        //         {
        //           'datatype': 'Vocabulary',
        //           'input_type': 'select',
        //           'labels': {
        //             'de': 'Mittel',
        //             'en': 'Medium',
        //             'it': 'Medio',
        //             'sr': 'srednji'
        //           },
        //           'ui_value': 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/educational/voc_12/1705',
        //           'xmlname': 'interactivitylevel',
        //           'xmlns': 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/educational'
        //         },
        //         {
        //           'datatype': 'Vocabulary',
        //           'input_type': 'select',
        //           'labels': {
        //             'de': 'Studierende',
        //             'en': 'Learner',
        //             'it': 'Allievo',
        //             'sr': 'u?enik'
        //           },
        //           'ui_value': 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/educational/voc_14/1715',
        //           'xmlname': 'enduserrole',
        //           'xmlns': 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/educational'
        //         },
        //         {
        //           'datatype': 'Vocabulary',
        //           'input_type': 'select',
        //           'labels': {
        //             'de': 'Hochschule',
        //             'en': 'Higher Education',
        //             'it': 'Istruzione universitaria',
        //             'sr': 'visoko obrazovanje'
        //           },
        //           'ui_value': 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/educational/voc_15/1718',
        //           'xmlname': 'context',
        //           'xmlns': 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/educational'
        //         },
        //         {
        //           'attributes': [
        //             {
        //               'input_type': 'select',
        //               'ui_value': 'en',
        //               'xmlname': 'lang'
        //             }
        //           ],
        //           'datatype': 'LangString',
        //           'input_type': 'input_text',
        //           'ui_value': '32',
        //           'xmlname': 'agerange',
        //           'xmlns': 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/educational'
        //         },
        //         {
        //           'datatype': 'Vocabulary',
        //           'input_type': 'select',
        //           'labels': {
        //             'de': 'Sehr schwer',
        //             'en': 'Very difficult',
        //             'it': 'Molto difficile',
        //             'sr': 'veoma te ko'
        //           },
        //           'ui_value': 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/educational/voc_16/1725',
        //           'xmlname': 'difficulty',
        //           'xmlns': 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/educational'
        //         },
        //         {
        //           'datatype': 'Duration',
        //           'input_type': 'input_text',
        //           'ui_value': 'PT12H54M43S',
        //           'xmlname': 'learningtime',
        //           'xmlns': 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/educational'
        //         },
        //         {
        //           'attributes': [
        //             {
        //               'input_type': 'select',
        //               'ui_value': 'en',
        //               'xmlname': 'lang'
        //             }
        //           ],
        //           'datatype': 'LangString',
        //           'input_type': 'input_text',
        //           'ui_value': 'If one examines precultural rationalism, one is faced with a choice: either\nreject the materialist paradigm of narrative or conclude that the media is\ncapable of deconstruction, given that Derrida’s model of dialectic situationism\nis valid. Thus, the premise of precultural rationalism suggests that the raison\nd’etre of the participant is significant form. Lyotard promotes the use of\nDerridaist reading to deconstruct hierarchy.',
        //           'xmlname': 'description',
        //           'xmlns': 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/educational'
        //         },
        //         {
        //           'datatype': 'Language',
        //           'input_type': 'select',
        //           'ui_value': 'ba',
        //           'xmlname': 'language',
        //           'xmlns': 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/educational'
        //         }
        //       ],
        //       'datatype': 'Node',
        //       'input_type': 'node',
        //       'xmlname': 'educationals',
        //       'xmlns': 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0'
        //     },
        //     {
        //       'children': [
        //         {
        //           'attributes': [
        //             {
        //               'input_type': 'input_text',
        //               'ui_value': '0',
        //               'xmlname': 'data_order'
        //             }
        //           ],
        //           'datatype': 'Vocabulary',
        //           'input_type': 'select',
        //           'labels': {
        //             'de': 'Übung',
        //             'en': 'Exercise',
        //             'it': 'Esercizio',
        //             'sr': 've ba'
        //           },
        //           'ui_value': 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/educational/voc_11/1688',
        //           'xmlname': 'learningresourcetype',
        //           'xmlns': 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/educational'
        //         },
        //         {
        //           'datatype': 'Vocabulary',
        //           'input_type': 'select',
        //           'labels': {
        //             'de': 'Aktiv',
        //             'en': 'Active',
        //             'it': 'Dinamica',
        //             'sr': 'aktivna'
        //           },
        //           'ui_value': 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/educational/voc_10/1685',
        //           'xmlname': 'interactivitytype',
        //           'xmlns': 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/educational'
        //         },
        //         {
        //           'datatype': 'Vocabulary',
        //           'input_type': 'select',
        //           'labels': {
        //             'de': 'Niedrig',
        //             'en': 'Low',
        //             'it': 'Basso',
        //             'sr': 'nizak'
        //           },
        //           'ui_value': 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/educational/voc_12/1704',
        //           'xmlname': 'interactivitylevel',
        //           'xmlns': 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/educational'
        //         },
        //         {
        //           'datatype': 'Vocabulary',
        //           'input_type': 'select',
        //           'labels': {
        //             'de': 'StudienprogrammleiterIn',
        //             'en': 'Manager',
        //             'it': 'Gestore',
        //             'sr': 'rukovodilac'
        //           },
        //           'ui_value': 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/educational/voc_14/1716',
        //           'xmlname': 'enduserrole',
        //           'xmlns': 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/educational'
        //         },
        //         {
        //           'datatype': 'Vocabulary',
        //           'input_type': 'select',
        //           'labels': {
        //             'de': 'Schule',
        //             'en': 'School',
        //             'it': 'Scuola',
        //             'sr': ' kola'
        //           },
        //           'ui_value': 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/educational/voc_15/1717',
        //           'xmlname': 'context',
        //           'xmlns': 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/educational'
        //         },
        //         {
        //           'attributes': [
        //             {
        //               'input_type': 'select',
        //               'ui_value': 'en',
        //               'xmlname': 'lang'
        //             }
        //           ],
        //           'datatype': 'LangString',
        //           'input_type': 'input_text',
        //           'ui_value': '54',
        //           'xmlname': 'agerange',
        //           'xmlns': 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/educational'
        //         },
        //         {
        //           'datatype': 'Vocabulary',
        //           'input_type': 'select',
        //           'labels': {
        //             'de': 'Leicht',
        //             'en': 'Easy',
        //             'it': 'Facile',
        //             'sr': 'lako'
        //           },
        //           'ui_value': 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/educational/voc_16/1722',
        //           'xmlname': 'difficulty',
        //           'xmlns': 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/educational'
        //         },
        //         {
        //           'datatype': 'Duration',
        //           'input_type': 'input_text',
        //           'ui_value': 'PT16H55M23S',
        //           'xmlname': 'learningtime',
        //           'xmlns': 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/educational'
        //         },
        //         {
        //           'attributes': [
        //             {
        //               'input_type': 'select',
        //               'ui_value': 'en',
        //               'xmlname': 'lang'
        //             }
        //           ],
        //           'datatype': 'LangString',
        //           'input_type': 'input_text',
        //           'ui_value': 'The main theme of Geoffrey’s[3] analysis of subtextual\nobjectivism is the bridge between society and consciousness. However, Lacan\nuses the term ‘precultural rationalism’ to denote the role of the poet as\nartist. In Satanic Verses, Rushdie examines precultural capitalism; in\nMidnight’s Children, although, he deconstructs precultural rationalism.',
        //           'xmlname': 'description',
        //           'xmlns': 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/educational'
        //         },
        //         {
        //           'datatype': 'Language',
        //           'input_type': 'select',
        //           'ui_value': 'bm',
        //           'xmlname': 'language',
        //           'xmlns': 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/educational'
        //         }
        //       ],
        //       'datatype': 'Node',
        //       'input_type': 'node',
        //       'xmlname': 'educationals',
        //       'xmlns': 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0'
        //     }
        //   ],
        //   'datatype': 'Node',
        //   'input_type': 'node',
        //   'xmlname': 'educational',
        //   'xmlns': 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0'
        // },
        // {
        //   'children': [
        //     {
        //       'datatype': 'Boolean',
        //       'input_type': 'select',
        //       'labels': {
        //         'de': 'Nein',
        //         'en': 'No',
        //         'it': 'No'
        //       },
        //       'ui_value': 'no',
        //       'xmlname': 'cost',
        //       'xmlns': 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0'
        //     },
        //     {
        //       'datatype': 'Boolean',
        //       'input_type': 'select',
        //       'labels': {
        //         'de': 'Ja',
        //         'en': 'Yes',
        //         'it': 'SÃ¬'
        //       },
        //       'ui_value': 'yes',
        //       'xmlname': 'copyright',
        //       'xmlns': 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0'
        //     },
        //     {
        //       'datatype': 'License',
        //       'input_type': 'select',
        //       'labels': {
        //         'de': 'CC BY 4.0 International',
        //         'en': 'CC BY 4.0 International'
        //       },
        //       'ui_value': 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_21/16',
        //       'xmlname': 'license',
        //       'xmlns': 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0'
        //     },
        //     {
        //       'attributes': [
        //         {
        //           'input_type': 'select',
        //           'ui_value': 'en',
        //           'xmlname': 'lang'
        //         }
        //       ],
        //       'datatype': 'LangString',
        //       'input_type': 'input_text',
        //       'ui_value': 'If you license your content under the terms of this license, you allow every licensee to copy and to redistribute the material in any medium or format, to remix, to transform, and build upon the material for any purpose, even commercially.\n\nYou cannot revoke these freedoms as long as the licensee follows the license terms.\n',
        //       'xmlname': 'description',
        //       'xmlns': 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0'
        //     },
        //     {
        //       'datatype': 'Vocabulary',
        //       'input_type': 'select',
        //       'labels': {
        //         'de': 'openAccess',
        //         'en': 'openAccess',
        //         'it': 'openAccess',
        //         'sr': 'openAccess'
        //       },
        //       'ui_value': 'http://phaidra.univie.ac.at/XML/metadata/extended/V1.0/voc_36/1556227',
        //       'xmlname': 'infoeurepoaccess',
        //       'xmlns': 'http://phaidra.univie.ac.at/XML/metadata/extended/V1.0'
        //     },
        //     {
        //       'datatype': 'DateTime',
        //       'input_type': 'input_text',
        //       'ui_value': '2030-10-12',
        //       'xmlname': 'infoeurepoembargo',
        //       'xmlns': 'http://phaidra.univie.ac.at/XML/metadata/extended/V1.0'
        //     }
        //   ],
        //   'datatype': 'Node',
        //   'input_type': 'node',
        //   'xmlname': 'rights',
        //   'xmlns': 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0'
        // },
        // {
        //   'children': [
        //     {
        //       'datatype': 'Vocabulary',
        //       'input_type': 'select',
        //       'labels': {
        //         'de': 'Disziplin',
        //         'en': 'Discipline',
        //         'it': 'Materia',
        //         'sr': 'disciplina'
        //       },
        //       'ui_value': 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_6/70',
        //       'xmlname': 'purpose',
        //       'xmlns': 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0'
        //     },
        //     {
        //       'children': [
        //         {
        //           'datatype': 'ClassificationSource',
        //           'input_type': 'select',
        //           'labels': {
        //             'de': 'ÖFOS 2012',
        //             'en': 'ÖFOS 2012',
        //             'it': null,
        //             'nl': null,
        //             'ru': null,
        //             'sr': null
        //           },
        //           'ui_value': 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/classification/cls_16',
        //           'xmlname': 'source',
        //           'xmlns': 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/classification'
        //         },
        //         {
        //           'attributes': [
        //             {
        //               'input_type': 'input_text',
        //               'ui_value': '0',
        //               'xmlname': 'data_order'
        //             }
        //           ],
        //           'datatype': 'Taxon',
        //           'input_type': 'select',
        //           'labels': {
        //             'de': 'AGRARWISSENSCHAFTEN, VETERINÄRMEDIZIN',
        //             'en': 'AGRICULTURAL SCIENCES, VETERINARY MEDICINE'
        //           },
        //           'ui_value': 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/classification/cls_16/1072421',
        //           'xmlname': 'taxon',
        //           'xmlns': 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/classification'
        //         },
        //         {
        //           'attributes': [
        //             {
        //               'input_type': 'input_text',
        //               'ui_value': '1',
        //               'xmlname': 'data_order'
        //             }
        //           ],
        //           'datatype': 'Taxon',
        //           'input_type': 'select',
        //           'labels': {
        //             'de': 'Agrarbiotechnologie, Lebensmittelbiotechnologie',
        //             'en': 'Agricultural Biotechnology, Food Biotechnology'
        //           },
        //           'ui_value': 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/classification/cls_16/1072512',
        //           'xmlname': 'taxon',
        //           'xmlns': 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/classification'
        //         },
        //         {
        //           'attributes': [
        //             {
        //               'input_type': 'input_text',
        //               'ui_value': '2',
        //               'xmlname': 'data_order'
        //             }
        //           ],
        //           'datatype': 'Taxon',
        //           'input_type': 'select',
        //           'labels': {
        //             'de': 'Agrarbiotechnologie, Lebensmittelbiotechnologie',
        //             'en': 'Agricultural Biotechnology, Food Biotechnology'
        //           },
        //           'ui_value': 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/classification/cls_16/1073606',
        //           'xmlname': 'taxon',
        //           'xmlns': 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/classification'
        //         },
        //         {
        //           'attributes': [
        //             {
        //               'input_type': 'input_text',
        //               'ui_value': '3',
        //               'xmlname': 'data_order'
        //             }
        //           ],
        //           'datatype': 'Taxon',
        //           'input_type': 'select',
        //           'labels': {
        //             'de': 'Biopharming',
        //             'en': 'Biopharming'
        //           },
        //           'ui_value': 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/classification/cls_16/1072513',
        //           'xmlname': 'taxon',
        //           'xmlns': 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/classification'
        //         }
        //       ],
        //       'datatype': 'Node',
        //       'input_type': 'node',
        //       'xmlname': 'taxonpath',
        //       'xmlns': 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/classification'
        //     },
        //     {
        //       'children': [
        //         {
        //           'datatype': 'ClassificationSource',
        //           'input_type': 'select',
        //           'labels': {
        //             'de': 'Getty Art & Architecture Thesaurus',
        //             'en': 'Getty Art & Architecture Thesaurus',
        //             'it': null,
        //             'nl': null,
        //             'ru': null,
        //             'sr': null
        //           },
        //           'ui_value': 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/classification/cls_5',
        //           'xmlname': 'source',
        //           'xmlns': 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/classification'
        //         },
        //         {
        //           'attributes': [
        //             {
        //               'input_type': 'input_text',
        //               'ui_value': '0',
        //               'xmlname': 'data_order'
        //             }
        //           ],
        //           'datatype': 'Taxon',
        //           'input_type': 'select',
        //           'labels': {
        //             'de': 'Physical Attributes Facet',
        //             'en': 'Physical Attributes Facet'
        //           },
        //           'ui_value': 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/classification/cls_5/17180',
        //           'xmlname': 'taxon',
        //           'xmlns': 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/classification'
        //         },
        //         {
        //           'attributes': [
        //             {
        //               'input_type': 'input_text',
        //               'ui_value': '1',
        //               'xmlname': 'data_order'
        //             }
        //           ],
        //           'datatype': 'Taxon',
        //           'input_type': 'select',
        //           'labels': {
        //             'de': 'Color',
        //             'en': 'Color'
        //           },
        //           'ui_value': 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/classification/cls_5/17954',
        //           'xmlname': 'taxon',
        //           'xmlns': 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/classification'
        //         },
        //         {
        //           'attributes': [
        //             {
        //               'input_type': 'input_text',
        //               'ui_value': '2',
        //               'xmlname': 'data_order'
        //             }
        //           ],
        //           'datatype': 'Taxon',
        //           'input_type': 'select',
        //           'labels': {
        //             'de': 'color and color-related phenomena',
        //             'en': 'color and color-related phenomena'
        //           },
        //           'ui_value': 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/classification/cls_5/18298',
        //           'xmlname': 'taxon',
        //           'xmlns': 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/classification'
        //         },
        //         {
        //           'attributes': [
        //             {
        //               'input_type': 'input_text',
        //               'ui_value': '3',
        //               'xmlname': 'data_order'
        //             }
        //           ],
        //           'datatype': 'Taxon',
        //           'input_type': 'select',
        //           'labels': {
        //             'de': 'color',
        //             'en': 'color'
        //           },
        //           'ui_value': 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/classification/cls_5/18299',
        //           'xmlname': 'taxon',
        //           'xmlns': 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/classification'
        //         },
        //         {
        //           'attributes': [
        //             {
        //               'input_type': 'input_text',
        //               'ui_value': '4',
        //               'xmlname': 'data_order'
        //             }
        //           ],
        //           'datatype': 'Taxon',
        //           'input_type': 'select',
        //           'labels': {
        //             'de': 'luminous color',
        //             'en': 'luminous color'
        //           },
        //           'ui_value': 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/classification/cls_5/18302',
        //           'xmlname': 'taxon',
        //           'xmlns': 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/classification'
        //         }
        //       ],
        //       'datatype': 'Node',
        //       'input_type': 'node',
        //       'xmlname': 'taxonpath',
        //       'xmlns': 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/classification'
        //     }
        //   ],
        //   'datatype': 'Node',
        //   'input_type': 'node',
        //   'xmlname': 'classification',
        //   'xmlns': 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0'
        // },
        // {
        //   'children': [
        //     {
        //       'datatype': 'Vocabulary',
        //       'input_type': 'select',
        //       'labels': {
        //         'de': 'Artikel in Zeitschrift',
        //         'en': 'Article',
        //         'it': 'Articolo'
        //       },
        //       'ui_value': 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization/voc_17/1552253',
        //       'xmlname': 'hoschtyp',
        //       'xmlns': 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization'
        //     },
        //     {
        //       'datatype': 'DateTime',
        //       'input_type': 'input_text',
        //       'ui_value': '2010-01-23',
        //       'xmlname': 'approbation_period',
        //       'xmlns': 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization'
        //     },
        //     {
        //       'children': [
        //         {
        //           'datatype': 'Faculty',
        //           'input_type': 'select',
        //           'labels': {
        //             'de': 'Support facilities',
        //             'en': 'Support facilities'
        //           },
        //           'ui_value': 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization/voc_faculty/A0',
        //           'xmlname': 'faculty',
        //           'xmlns': 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization'
        //         },
        //         {
        //           'datatype': 'Department',
        //           'input_type': 'select',
        //           'labels': {
        //             'de': 'Zentraler Informatikdienst',
        //             'en': 'Vienna University Computer Center'
        //           },
        //           'ui_value': 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization/voc_department/A140',
        //           'xmlname': 'department',
        //           'xmlns': 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization'
        //         }
        //       ],
        //       'datatype': 'Node',
        //       'input_type': 'node',
        //       'xmlname': 'orgassignment',
        //       'xmlns': 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization'
        //     },
        //     {
        //       'children': [
        //         {
        //           'datatype': 'SPL',
        //           'input_type': 'select',
        //           'labels': {
        //             'de': 'SPL 24: Kultur- und Sozialanthropologie'
        //           },
        //           'ui_value': 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization/voc_spl/24',
        //           'xmlname': 'spl',
        //           'xmlns': 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization'
        //         },
        //         {
        //           'attributes': [
        //             {
        //               'input_type': 'input_text',
        //               'ui_value': '0',
        //               'xmlname': 'data_order'
        //             }
        //           ],
        //           'datatype': 'Curriculum',
        //           'input_type': 'select',
        //           'ui_value': '218',
        //           'xmlname': 'kennzahl',
        //           'xmlns': 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization'
        //         },
        //         {
        //           'attributes': [
        //             {
        //               'input_type': 'input_text',
        //               'ui_value': '1',
        //               'xmlname': 'data_order'
        //             }
        //           ],
        //           'datatype': 'Curriculum',
        //           'input_type': 'select',
        //           'ui_value': '216',
        //           'xmlname': 'kennzahl',
        //           'xmlns': 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization'
        //         }
        //       ],
        //       'datatype': 'Node',
        //       'input_type': 'node',
        //       'xmlname': 'curriculum',
        //       'xmlns': 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization'
        //     },
        //     {
        //       'datatype': 'CharacterString',
        //       'input_type': 'input_text',
        //       'ui_value': 'Eisenstadt-Umgebung',
        //       'xmlname': 'further_allocation',
        //       'xmlns': 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization'
        //     }
        //   ],
        //   'datatype': 'Node',
        //   'input_type': 'node',
        //   'xmlname': 'organization',
        //   'xmlns': 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0'
        // },
        // {
        //   'children': [
        //     {
        //       'attributes': [
        //         {
        //           'input_type': 'select',
        //           'ui_value': 'en',
        //           'xmlname': 'lang'
        //         }
        //       ],
        //       'datatype': 'LangString',
        //       'input_type': 'input_text',
        //       'ui_value': 'In a sense, the characteristic theme of the works of Rushdie is the economy of modernist sexual identity. Sargeant[4] implies that we have to choose between dialectic situationism and posttextual narrative.',
        //       'xmlname': 'inscription',
        //       'xmlns': 'http://phaidra.univie.ac.at/XML/metadata/histkult/V1.0'
        //     },
        //     {
        //       'attributes': [
        //         {
        //           'input_type': 'input_text',
        //           'ui_value': '0',
        //           'xmlname': 'data_order'
        //         }
        //       ],
        //       'children': [
        //         {
        //           'datatype': 'Vocabulary',
        //           'input_type': 'select',
        //           'labels': {
        //             'de': 'Analoger Film',
        //             'en': 'Analog Film',
        //             'it': 'Pellicola analogica',
        //             'sr': 'analogni film'
        //           },
        //           'ui_value': 'http://phaidra.univie.ac.at/XML/metadata/histkult/V1.0/voc_24/1552150',
        //           'xmlname': 'resource',
        //           'xmlns': 'http://phaidra.univie.ac.at/XML/metadata/histkult/V1.0'
        //         },
        //         {
        //           'datatype': 'Vocabulary',
        //           'input_type': 'select',
        //           'labels': {
        //             'de': 'cm',
        //             'en': 'cm',
        //             'it': 'cm',
        //             'sr': 'cm'
        //           },
        //           'ui_value': 'http://phaidra.univie.ac.at/XML/metadata/histkult/V1.0/voc_22/10880',
        //           'xmlname': 'dimension_unit',
        //           'xmlns': 'http://phaidra.univie.ac.at/XML/metadata/histkult/V1.0'
        //         },
        //         {
        //           'datatype': 'CharacterString',
        //           'input_type': 'input_text',
        //           'ui_value': '15',
        //           'xmlname': 'length',
        //           'xmlns': 'http://phaidra.univie.ac.at/XML/metadata/histkult/V1.0'
        //         },
        //         {
        //           'datatype': 'CharacterString',
        //           'input_type': 'input_text',
        //           'ui_value': '54',
        //           'xmlname': 'width',
        //           'xmlns': 'http://phaidra.univie.ac.at/XML/metadata/histkult/V1.0'
        //         },
        //         {
        //           'datatype': 'CharacterString',
        //           'input_type': 'input_text',
        //           'ui_value': '33',
        //           'xmlname': 'height',
        //           'xmlns': 'http://phaidra.univie.ac.at/XML/metadata/histkult/V1.0'
        //         },
        //         {
        //           'datatype': 'CharacterString',
        //           'input_type': 'input_text',
        //           'ui_value': '54',
        //           'xmlname': 'diameter',
        //           'xmlns': 'http://phaidra.univie.ac.at/XML/metadata/histkult/V1.0'
        //         }
        //       ],
        //       'datatype': 'Node',
        //       'input_type': 'node',
        //       'xmlname': 'dimensions',
        //       'xmlns': 'http://phaidra.univie.ac.at/XML/metadata/histkult/V1.0'
        //     },
        //     {
        //       'attributes': [
        //         {
        //           'input_type': 'input_text',
        //           'ui_value': '1',
        //           'xmlname': 'data_order'
        //         }
        //       ],
        //       'children': [
        //         {
        //           'datatype': 'Vocabulary',
        //           'input_type': 'select',
        //           'labels': {
        //             'de': 'Glasplattendia',
        //             'en': 'Glass Plate Dia',
        //             'it': 'Diapositiva su lastra di vetro',
        //             'sr': 'Staklene plo?e Dia'
        //           },
        //           'ui_value': 'http://phaidra.univie.ac.at/XML/metadata/histkult/V1.0/voc_24/1552077',
        //           'xmlname': 'resource',
        //           'xmlns': 'http://phaidra.univie.ac.at/XML/metadata/histkult/V1.0'
        //         },
        //         {
        //           'datatype': 'Vocabulary',
        //           'input_type': 'select',
        //           'labels': {
        //             'de': 'ft.',
        //             'en': 'ft.',
        //             'it': 'ft'
        //           },
        //           'ui_value': 'http://phaidra.univie.ac.at/XML/metadata/histkult/V1.0/voc_22/10884',
        //           'xmlname': 'dimension_unit',
        //           'xmlns': 'http://phaidra.univie.ac.at/XML/metadata/histkult/V1.0'
        //         },
        //         {
        //           'datatype': 'CharacterString',
        //           'input_type': 'input_text',
        //           'ui_value': '2',
        //           'xmlname': 'length',
        //           'xmlns': 'http://phaidra.univie.ac.at/XML/metadata/histkult/V1.0'
        //         },
        //         {
        //           'datatype': 'CharacterString',
        //           'input_type': 'input_text',
        //           'ui_value': '14',
        //           'xmlname': 'width',
        //           'xmlns': 'http://phaidra.univie.ac.at/XML/metadata/histkult/V1.0'
        //         },
        //         {
        //           'datatype': 'CharacterString',
        //           'input_type': 'input_text',
        //           'ui_value': '2',
        //           'xmlname': 'height',
        //           'xmlns': 'http://phaidra.univie.ac.at/XML/metadata/histkult/V1.0'
        //         },
        //         {
        //           'datatype': 'CharacterString',
        //           'input_type': 'input_text',
        //           'ui_value': '5',
        //           'xmlname': 'diameter',
        //           'xmlns': 'http://phaidra.univie.ac.at/XML/metadata/histkult/V1.0'
        //         }
        //       ],
        //       'datatype': 'Node',
        //       'input_type': 'node',
        //       'xmlname': 'dimensions',
        //       'xmlns': 'http://phaidra.univie.ac.at/XML/metadata/histkult/V1.0'
        //     },
        //     {
        //       'children': [
        //         {
        //           'datatype': 'Vocabulary',
        //           'input_type': 'select',
        //           'labels': {
        //             'de': 'GND subject',
        //             'en': 'GND subject',
        //             'it': 'GND subject'
        //           },
        //           'ui_value': 'http://phaidra.univie.ac.at/XML/metadata/histkult/V1.0/voc_25/1562802',
        //           'xmlname': 'reference',
        //           'xmlns': 'http://phaidra.univie.ac.at/XML/metadata/histkult/V1.0'
        //         },
        //         {
        //           'datatype': 'CharacterString',
        //           'input_type': 'input_text',
        //           'ui_value': '118517376',
        //           'xmlname': 'number',
        //           'xmlns': 'http://phaidra.univie.ac.at/XML/metadata/histkult/V1.0'
        //         }
        //       ],
        //       'datatype': 'Node',
        //       'input_type': 'node',
        //       'xmlname': 'reference_number',
        //       'xmlns': 'http://phaidra.univie.ac.at/XML/metadata/histkult/V1.0'
        //     },
        //     {
        //       'children': [
        //         {
        //           'datatype': 'Vocabulary',
        //           'input_type': 'select',
        //           'labels': {
        //             'de': 'Förderungsnummer: Universität Wien',
        //             'en': 'Grant Number: University of Vienna',
        //             'it': 'Grant Number: University of Vienna',
        //             'sr': 'Grant Number: University of Vienna'
        //           },
        //           'ui_value': 'http://phaidra.univie.ac.at/XML/metadata/histkult/V1.0/voc_25/1562640',
        //           'xmlname': 'reference',
        //           'xmlns': 'http://phaidra.univie.ac.at/XML/metadata/histkult/V1.0'
        //         },
        //         {
        //           'datatype': 'CharacterString',
        //           'input_type': 'input_text',
        //           'ui_value': '11112-32',
        //           'xmlname': 'number',
        //           'xmlns': 'http://phaidra.univie.ac.at/XML/metadata/histkult/V1.0'
        //         }
        //       ],
        //       'datatype': 'Node',
        //       'input_type': 'node',
        //       'xmlname': 'reference_number',
        //       'xmlns': 'http://phaidra.univie.ac.at/XML/metadata/histkult/V1.0'
        //     },
        //     {
        //       'datatype': 'Vocabulary',
        //       'input_type': 'select',
        //       'labels': {
        //         'de': 'Rundstempel - mit Adler (Fraktur), Variante 1',
        //         'en': 'Rundstempel - mit Adler (Fraktur), Variante 1',
        //         'it': 'Rundstempel - mit Adler (Fraktur), Variante 1',
        //         'sr': ''
        //       },
        //       'ui_value': 'http://phaidra.univie.ac.at/XML/metadata/histkult/V1.0/voc_23/10900',
        //       'xmlname': 'stamp',
        //       'xmlns': 'http://phaidra.univie.ac.at/XML/metadata/histkult/V1.0'
        //     },
        //     {
        //       'attributes': [
        //         {
        //           'input_type': 'select',
        //           'ui_value': 'en',
        //           'xmlname': 'lang'
        //         }
        //       ],
        //       'datatype': 'LangString',
        //       'input_type': 'input_text',
        //       'ui_value': 'However, Marx uses the term ‘precultural rationalism’ to denote a\nself-fulfilling paradox. If dialectic situationism holds, the works of Rushdie\nare an example of mythopoetical rationalism.',
        //       'xmlname': 'note',
        //       'xmlns': 'http://phaidra.univie.ac.at/XML/metadata/histkult/V1.0'
        //     }
        //   ],
        //   'datatype': 'Node',
        //   'input_type': 'node',
        //   'xmlname': 'histkult',
        //   'xmlns': 'http://phaidra.univie.ac.at/XML/metadata/histkult/V1.0'
        // },
        // {
        //   'children': [
        //     {
        //       'children': [
        //         {
        //           'datatype': 'Vocabulary',
        //           'input_type': 'select',
        //           'labels': {
        //             'de': 'Analoger Film',
        //             'en': 'Analog Film',
        //             'it': 'Pellicola analogica',
        //             'sr': 'analogni film'
        //           },
        //           'ui_value': 'http://phaidra.univie.ac.at/XML/metadata/provenience/V1.0/voc_24/1552150',
        //           'xmlname': 'resource',
        //           'xmlns': 'http://phaidra.univie.ac.at/XML/metadata/provenience/V1.0'
        //         },
        //         {
        //           'attributes': [
        //             {
        //               'input_type': 'select',
        //               'ui_value': 'en',
        //               'xmlname': 'lang'
        //             }
        //           ],
        //           'datatype': 'LangString',
        //           'input_type': 'input_text',
        //           'ui_value': 'But the subject is contextualised into a cultural desublimation that\nincludes reality as a totality. Debord suggests the use of dialectic\nsituationism to challenge and read culture.',
        //           'xmlname': 'comment',
        //           'xmlns': 'http://phaidra.univie.ac.at/XML/metadata/provenience/V1.0'
        //         },
        //         {
        //           'datatype': 'Vocabulary',
        //           'input_type': 'select',
        //           'labels': {
        //             'de': 'BearbeiterIn',
        //             'en': 'Adapter',
        //             'it': 'Adattatore'
        //           },
        //           'ui_value': 'http://phaidra.univie.ac.at/XML/metadata/provenience/V1.0/voc_3/1557099',
        //           'xmlname': 'role',
        //           'xmlns': 'http://phaidra.univie.ac.at/XML/metadata/provenience/V1.0'
        //         },
        //         {
        //           'attributes': [
        //             {
        //               'input_type': 'input_text',
        //               'ui_value': '0',
        //               'xmlname': 'data_order'
        //             }
        //           ],
        //           'children': [
        //             {
        //               'datatype': 'CharacterString',
        //               'input_type': 'input_text',
        //               'ui_value': 'Rasta',
        //               'xmlname': 'firstname',
        //               'xmlns': 'http://phaidra.univie.ac.at/XML/metadata/provenience/V1.0/entity'
        //             },
        //             {
        //               'datatype': 'CharacterString',
        //               'input_type': 'input_text',
        //               'ui_value': 'Blasta',
        //               'xmlname': 'lastname',
        //               'xmlns': 'http://phaidra.univie.ac.at/XML/metadata/provenience/V1.0/entity'
        //             },
        //             {
        //               'datatype': 'CharacterString',
        //               'input_type': 'input_text',
        //               'ui_value': 'ZID, Univie',
        //               'xmlname': 'institution',
        //               'xmlns': 'http://phaidra.univie.ac.at/XML/metadata/provenience/V1.0/entity'
        //             }
        //           ],
        //           'datatype': 'Node',
        //           'input_type': 'node',
        //           'xmlname': 'entity',
        //           'xmlns': 'http://phaidra.univie.ac.at/XML/metadata/provenience/V1.0'
        //         },
        //         {
        //           'datatype': 'DateTime',
        //           'input_type': 'input_text',
        //           'ui_value': '2000-01-11',
        //           'xmlname': 'date_from',
        //           'xmlns': 'http://phaidra.univie.ac.at/XML/metadata/provenience/V1.0'
        //         },
        //         {
        //           'datatype': 'DateTime',
        //           'input_type': 'input_text',
        //           'ui_value': '2030-10-23',
        //           'xmlname': 'date_to',
        //           'xmlns': 'http://phaidra.univie.ac.at/XML/metadata/provenience/V1.0'
        //         },
        //         {
        //           'attributes': [
        //             {
        //               'input_type': 'select',
        //               'ui_value': 'en',
        //               'xmlname': 'lang'
        //             }
        //           ],
        //           'datatype': 'LangString',
        //           'input_type': 'input_text',
        //           'ui_value': 'Postmodernism',
        //           'xmlname': 'chronological',
        //           'xmlns': 'http://phaidra.univie.ac.at/XML/metadata/provenience/V1.0'
        //         },
        //         {
        //           'attributes': [
        //             {
        //               'input_type': 'select',
        //               'ui_value': 'en',
        //               'xmlname': 'lang'
        //             }
        //           ],
        //           'datatype': 'LangString',
        //           'input_type': 'input_text',
        //           'ui_value': 'Elswhere',
        //           'xmlname': 'location',
        //           'xmlns': 'http://phaidra.univie.ac.at/XML/metadata/provenience/V1.0'
        //         }
        //       ],
        //       'datatype': 'Node',
        //       'input_type': 'node',
        //       'xmlname': 'contribute',
        //       'xmlns': 'http://phaidra.univie.ac.at/XML/metadata/provenience/V1.0'
        //     },
        //     {
        //       'children': [
        //         {
        //           'datatype': 'Vocabulary',
        //           'input_type': 'select',
        //           'labels': {
        //             'de': 'Glasplattendia',
        //             'en': 'Glass Plate Dia',
        //             'it': 'Diapositiva su lastra di vetro',
        //             'sr': 'Staklene plo?e Dia'
        //           },
        //           'ui_value': 'http://phaidra.univie.ac.at/XML/metadata/provenience/V1.0/voc_24/1552077',
        //           'xmlname': 'resource',
        //           'xmlns': 'http://phaidra.univie.ac.at/XML/metadata/provenience/V1.0'
        //         },
        //         {
        //           'attributes': [
        //             {
        //               'input_type': 'select',
        //               'ui_value': 'en',
        //               'xmlname': 'lang'
        //             }
        //           ],
        //           'datatype': 'LangString',
        //           'input_type': 'input_text',
        //           'ui_value': 'But the subject is contextualised into a cultural desublimation that\nincludes reality as a totality. \n\nDebord suggests the use of dialectic\nsituationism to challenge and read culture.',
        //           'xmlname': 'comment',
        //           'xmlns': 'http://phaidra.univie.ac.at/XML/metadata/provenience/V1.0'
        //         },
        //         {
        //           'datatype': 'Vocabulary',
        //           'input_type': 'select',
        //           'labels': {
        //             'de': 'zugeschriebene/r AutorIn',
        //             'en': 'Attributed name',
        //             'it': 'Nome attribuito'
        //           },
        //           'ui_value': 'http://phaidra.univie.ac.at/XML/metadata/provenience/V1.0/voc_3/1557128',
        //           'xmlname': 'role',
        //           'xmlns': 'http://phaidra.univie.ac.at/XML/metadata/provenience/V1.0'
        //         },
        //         {
        //           'attributes': [
        //             {
        //               'input_type': 'input_text',
        //               'ui_value': '0',
        //               'xmlname': 'data_order'
        //             }
        //           ],
        //           'children': [
        //             {
        //               'datatype': 'CharacterString',
        //               'input_type': 'input_text',
        //               'ui_value': 'Rasta',
        //               'xmlname': 'firstname',
        //               'xmlns': 'http://phaidra.univie.ac.at/XML/metadata/provenience/V1.0/entity'
        //             },
        //             {
        //               'datatype': 'CharacterString',
        //               'input_type': 'input_text',
        //               'ui_value': 'Pasta',
        //               'xmlname': 'lastname',
        //               'xmlns': 'http://phaidra.univie.ac.at/XML/metadata/provenience/V1.0/entity'
        //             }
        //           ],
        //           'datatype': 'Node',
        //           'input_type': 'node',
        //           'xmlname': 'entity',
        //           'xmlns': 'http://phaidra.univie.ac.at/XML/metadata/provenience/V1.0'
        //         },
        //         {
        //           'datatype': 'DateTime',
        //           'input_type': 'input_text',
        //           'ui_value': '2012-01-23',
        //           'xmlname': 'date_from',
        //           'xmlns': 'http://phaidra.univie.ac.at/XML/metadata/provenience/V1.0'
        //         },
        //         {
        //           'datatype': 'DateTime',
        //           'input_type': 'input_text',
        //           'ui_value': '2050-12-11',
        //           'xmlname': 'date_to',
        //           'xmlns': 'http://phaidra.univie.ac.at/XML/metadata/provenience/V1.0'
        //         },
        //         {
        //           'attributes': [
        //             {
        //               'input_type': 'select',
        //               'ui_value': 'en',
        //               'xmlname': 'lang'
        //             }
        //           ],
        //           'datatype': 'LangString',
        //           'input_type': 'input_text',
        //           'ui_value': '14th century',
        //           'xmlname': 'chronological',
        //           'xmlns': 'http://phaidra.univie.ac.at/XML/metadata/provenience/V1.0'
        //         },
        //         {
        //           'attributes': [
        //             {
        //               'input_type': 'select',
        //               'ui_value': 'en',
        //               'xmlname': 'lang'
        //             }
        //           ],
        //           'datatype': 'LangString',
        //           'input_type': 'input_text',
        //           'ui_value': 'magreb',
        //           'xmlname': 'location',
        //           'xmlns': 'http://phaidra.univie.ac.at/XML/metadata/provenience/V1.0'
        //         }
        //       ],
        //       'datatype': 'Node',
        //       'input_type': 'node',
        //       'xmlname': 'contribute',
        //       'xmlns': 'http://phaidra.univie.ac.at/XML/metadata/provenience/V1.0'
        //     }
        //   ],
        //   'datatype': 'Node',
        //   'input_type': 'node',
        //   'xmlname': 'provenience',
        //   'xmlns': 'http://phaidra.univie.ac.at/XML/metadata/provenience/V1.0'
        // },
        // {
        //   'children': [
        //     {
        //       'attributes': [
        //         {
        //           'input_type': 'select',
        //           'ui_value': 'en',
        //           'xmlname': 'lang'
        //         }
        //       ],
        //       'datatype': 'LangString',
        //       'input_type': 'input_text',
        //       'ui_value': 'Communications From Elsewhere',
        //       'xmlname': 'name_magazine',
        //       'xmlns': 'http://phaidra.univie.ac.at/XML/metadata/digitalbook/V1.0'
        //     },
        //     {
        //       'datatype': 'CharacterString',
        //       'input_type': 'input_text',
        //       'ui_value': '12',
        //       'xmlname': 'pagination',
        //       'xmlns': 'http://phaidra.univie.ac.at/XML/metadata/digitalbook/V1.0'
        //     },
        //     {
        //       'datatype': 'CharacterString',
        //       'input_type': 'input_text',
        //       'ui_value': 'Postmodernism Generator',
        //       'xmlname': 'reihentitel',
        //       'xmlns': 'http://phaidra.univie.ac.at/XML/metadata/digitalbook/V1.0'
        //     },
        //     {
        //       'datatype': 'CharacterString',
        //       'input_type': 'input_text',
        //       'ui_value': '2',
        //       'xmlname': 'volume',
        //       'xmlns': 'http://phaidra.univie.ac.at/XML/metadata/digitalbook/V1.0'
        //     },
        //     {
        //       'datatype': 'CharacterString',
        //       'input_type': 'input_text',
        //       'ui_value': '12',
        //       'xmlname': 'booklet',
        //       'xmlns': 'http://phaidra.univie.ac.at/XML/metadata/digitalbook/V1.0'
        //     },
        //     {
        //       'datatype': 'CharacterString',
        //       'input_type': 'input_text',
        //       'ui_value': '43',
        //       'xmlname': 'from_page',
        //       'xmlns': 'http://phaidra.univie.ac.at/XML/metadata/digitalbook/V1.0'
        //     },
        //     {
        //       'datatype': 'CharacterString',
        //       'input_type': 'input_text',
        //       'ui_value': '66',
        //       'xmlname': 'to_page',
        //       'xmlns': 'http://phaidra.univie.ac.at/XML/metadata/digitalbook/V1.0'
        //     },
        //     {
        //       'attributes': [
        //         {
        //           'input_type': 'select',
        //           'ui_value': 'en',
        //           'xmlname': 'lang'
        //         }
        //       ],
        //       'datatype': 'LangString',
        //       'input_type': 'input_text',
        //       'ui_value': 'Communications From Elsewhere',
        //       'xmlname': 'name_collection',
        //       'xmlns': 'http://phaidra.univie.ac.at/XML/metadata/digitalbook/V1.0'
        //     },
        //     {
        //       'datatype': 'CharacterString',
        //       'input_type': 'input_text',
        //       'ui_value': 'Gloggnitz',
        //       'xmlname': 'publisherlocation',
        //       'xmlns': 'http://phaidra.univie.ac.at/XML/metadata/digitalbook/V1.0'
        //     },
        //     {
        //       'datatype': 'CharacterString',
        //       'input_type': 'input_text',
        //       'ui_value': 'And/Or Press',
        //       'xmlname': 'publisher',
        //       'xmlns': 'http://phaidra.univie.ac.at/XML/metadata/digitalbook/V1.0'
        //     },
        //     {
        //       'datatype': 'DateTime',
        //       'input_type': 'input_text',
        //       'ui_value': '2020-03-27',
        //       'xmlname': 'releaseyear',
        //       'xmlns': 'http://phaidra.univie.ac.at/XML/metadata/digitalbook/V1.0'
        //     },
        //     {
        //       'datatype': 'CharacterString',
        //       'input_type': 'input_text',
        //       'ui_value': '33',
        //       'xmlname': 'edition',
        //       'xmlns': 'http://phaidra.univie.ac.at/XML/metadata/digitalbook/V1.0'
        //     },
        //     {
        //       'attributes': [
        //         {
        //           'input_type': 'select',
        //           'ui_value': 'en',
        //           'xmlname': 'lang'
        //         }
        //       ],
        //       'datatype': 'LangString',
        //       'input_type': 'input_text',
        //       'ui_value': 'Therefore, Werther[9] suggests that we have to choose\nbetween Baudrillardist simulacra and the precapitalist paradigm of context.\nBaudrillard uses the term ‘precultural rationalism’ to denote the stasis, and\neventually the dialectic, of textual sexual identity.',
        //       'xmlname': 'release_notes',
        //       'xmlns': 'http://phaidra.univie.ac.at/XML/metadata/digitalbook/V1.0'
        //     },
        //     {
        //       'datatype': 'Vocabulary',
        //       'input_type': 'select',
        //       'labels': {
        //         'de': 'CD',
        //         'en': 'CD',
        //         'it': 'CD',
        //         'sr': 'CD'
        //       },
        //       'ui_value': 'http://phaidra.univie.ac.at/XML/metadata/digitalbook/V1.0/voc_32/1552130',
        //       'xmlname': 'medium',
        //       'xmlns': 'http://phaidra.univie.ac.at/XML/metadata/digitalbook/V1.0'
        //     },
        //     {
        //       'datatype': 'CharacterString',
        //       'input_type': 'input_text',
        //       'ui_value': 'http://www.elsewhere.org/pomo/',
        //       'xmlname': 'alephurl',
        //       'xmlns': 'http://phaidra.univie.ac.at/XML/metadata/digitalbook/V1.0'
        //     }
        //   ],
        //   'datatype': 'Node',
        //   'input_type': 'node',
        //   'xmlname': 'digitalbook',
        //   'xmlns': 'http://phaidra.univie.ac.at/XML/metadata/digitalbook/V1.0'
        // }
      ],
      modsdisplay: [
        {
          attributes: [
            {
              input_type: 'input_text',
              label: 'Link',
              xmlname: 'xlink:href'
            },
            {
              input_type: 'input_text',
              label: 'Language',
              xmlname: 'lang'
            },
            {
              input_type: 'input_text',
              label: 'Script',
              xmlname: 'script'
            },
            {
              input_type: 'input_text',
              label: 'Transliteration',
              xmlname: 'transliteration'
            },
            {
              input_type: 'select',
              label: 'Type',
              xmlname: 'type'
            },
            {
              input_type: 'input_text',
              label: 'Other type',
              xmlname: 'otherType'
            },
            {
              input_type: 'select',
              label: 'Authority',
              xmlname: 'authority'
            },
            {
              input_type: 'input_text',
              label: 'Authority URI',
              xmlname: 'authorityURI'
            },
            {
              input_type: 'input_text',
              label: 'Value URI',
              xmlname: 'valueURI'
            },
            {
              input_type: 'input_text',
              label: 'Display label',
              xmlname: 'displayLabel'
            },
            {
              input_type: 'select',
              label: 'Supplied',
              xmlname: 'supplied'
            },
            {
              input_type: 'select',
              label: 'Usage',
              xmlname: 'usage'
            },
            {
              input_type: 'input_text',
              label: 'Alternative representation group',
              xmlname: 'altRepGroup'
            },
            {
              input_type: 'input_text',
              label: 'Name title group',
              xmlname: 'nameTitleGroup'
            },
            {
              input_type: 'input_text',
              label: 'Alternative format',
              xmlname: 'altFormat'
            },
            {
              input_type: 'input_text',
              label: 'Alternative content',
              xmlname: 'altContent'
            }
          ],
          children: [
            {
              attributes: [
                {
                  input_type: 'input_text',
                  label: 'Language',
                  xmlname: 'lang'
                },
                {
                  input_type: 'input_text',
                  label: 'Script',
                  xmlname: 'script'
                },
                {
                  input_type: 'input_text',
                  label: 'Transliteration',
                  xmlname: 'transliteration'
                }
              ],
              input_type: 'input_text',
              label: 'Title',
              mandatory: 1,
              ui_value: 'Der große Flug. Erlösung',
              xmlname: 'title'
            }
          ],
          input_type: 'node',
          label: 'Title info',
          ui_value: '\n    \n  ',
          xmlname: 'titleInfo'
        },
        {
          attributes: [
            {
              input_type: 'select',
              label: 'Type',
              ui_value: 'personal',
              xmlname: 'type'
            },
            {
              input_type: 'input_text',
              label: 'Language',
              xmlname: 'lang'
            },
            {
              input_type: 'input_text',
              label: 'Script',
              xmlname: 'script'
            },
            {
              input_type: 'input_text',
              label: 'Transliteration',
              xmlname: 'transliteration'
            },
            {
              input_type: 'select',
              label: 'Authority',
              xmlname: 'authority'
            },
            {
              input_type: 'input_text',
              label: 'Authority URI',
              xmlname: 'authorityURI'
            },
            {
              input_type: 'input_text',
              label: 'Value URI',
              xmlname: 'valueURI'
            },
            {
              input_type: 'input_text',
              label: 'Display label',
              xmlname: 'displayLabel'
            },
            {
              input_type: 'select',
              label: 'Usage',
              xmlname: 'usage'
            },
            {
              input_type: 'input_text',
              label: 'Alternative representation group',
              xmlname: 'altRepGroup'
            },
            {
              input_type: 'input_text',
              label: 'Name title group',
              xmlname: 'nameTitleGroup'
            }
          ],
          children: [
            {
              attributes: [
                {
                  input_type: 'select',
                  label: 'Type',
                  ui_value: 'family',
                  xmlname: 'type'
                },
                {
                  input_type: 'input_text',
                  label: 'Link',
                  xmlname: 'xlink:href'
                },
                {
                  input_type: 'input_text',
                  label: 'Language',
                  xmlname: 'lang'
                },
                {
                  input_type: 'input_text',
                  label: 'Script',
                  xmlname: 'script'
                },
                {
                  input_type: 'input_text',
                  label: 'Transliteration',
                  xmlname: 'transliteration'
                }
              ],
              input_type: 'input_text',
              label: 'Name part',
              mandatory: 1,
              ui_value: 'Heijermans',
              xmlname: 'namePart'
            },
            {
              attributes: [
                {
                  input_type: 'select',
                  label: 'Type',
                  ui_value: 'given',
                  xmlname: 'type'
                },
                {
                  input_type: 'input_text',
                  label: 'Link',
                  xmlname: 'xlink:href'
                },
                {
                  input_type: 'input_text',
                  label: 'Language',
                  xmlname: 'lang'
                },
                {
                  input_type: 'input_text',
                  label: 'Script',
                  xmlname: 'script'
                },
                {
                  input_type: 'input_text',
                  label: 'Transliteration',
                  xmlname: 'transliteration'
                }
              ],
              input_type: 'input_text',
              label: 'Name part',
              mandatory: 1,
              ui_value: 'Herman',
              xmlname: 'namePart'
            },
            {
              children: [
                {
                  attributes: [
                    {
                      input_type: 'select',
                      label: 'Type',
                      ui_value: 'code',
                      xmlname: 'type'
                    },
                    {
                      input_type: 'select',
                      label: 'Authority',
                      ui_value: 'marcrelator',
                      xmlname: 'authority'
                    },
                    {
                      input_type: 'input_text',
                      label: 'Authority URI',
                      xmlname: 'authorityURI'
                    },
                    {
                      input_type: 'input_text',
                      label: 'Value URI',
                      xmlname: 'valueURI'
                    },
                    {
                      input_type: 'input_text',
                      label: 'Language',
                      xmlname: 'lang'
                    },
                    {
                      input_type: 'input_text',
                      label: 'Script',
                      xmlname: 'script'
                    },
                    {
                      input_type: 'input_text',
                      label: 'Transliteration',
                      xmlname: 'transliteration'
                    }
                  ],
                  input_type: 'input_text',
                  label: 'Role term',
                  mandatory: 1,
                  ui_value: 'aut',
                  xmlname: 'roleTerm'
                },
                {
                  attributes: [
                    {
                      input_type: 'select',
                      label: 'Type',
                      ui_value: 'text',
                      xmlname: 'type'
                    },
                    {
                      input_type: 'select',
                      label: 'Authority',
                      ui_value: 'marcrelator',
                      xmlname: 'authority'
                    },
                    {
                      input_type: 'input_text',
                      label: 'Authority URI',
                      xmlname: 'authorityURI'
                    },
                    {
                      input_type: 'input_text',
                      label: 'Value URI',
                      xmlname: 'valueURI'
                    },
                    {
                      input_type: 'input_text',
                      label: 'Language',
                      xmlname: 'lang'
                    },
                    {
                      input_type: 'input_text',
                      label: 'Script',
                      xmlname: 'script'
                    },
                    {
                      input_type: 'input_text',
                      label: 'Transliteration',
                      xmlname: 'transliteration'
                    }
                  ],
                  input_type: 'input_text',
                  label: 'Role term',
                  mandatory: 1,
                  ui_value: 'author',
                  xmlname: 'roleTerm'
                }
              ],
              input_type: 'node',
              label: 'Role',
              ui_value: '\n      \n      \n    ',
              xmlname: 'role'
            }
          ],
          input_type: 'node',
          label: 'Name',
          ui_value: '\n    \n    \n    \n  ',
          xmlname: 'name'
        },
        {
          attributes: [
            {
              input_type: 'input_text',
              label: 'Language',
              xmlname: 'lang'
            },
            {
              input_type: 'input_text',
              label: 'Script',
              xmlname: 'script'
            },
            {
              input_type: 'input_text',
              label: 'Transliteration',
              xmlname: 'transliteration'
            },
            {
              input_type: 'input_text',
              label: 'Display label',
              xmlname: 'displayLabel'
            },
            {
              input_type: 'input_text',
              label: 'Alternative representation group',
              xmlname: 'altRepGroup'
            },
            {
              input_type: 'select',
              label: 'Event type',
              xmlname: 'eventType'
            }
          ],
          children: [
            {
              attributes: [
                {
                  input_type: 'select',
                  label: 'Encoding',
                  xmlname: 'encoding'
                },
                {
                  input_type: 'select',
                  label: 'Point',
                  xmlname: 'point'
                },
                {
                  input_type: 'select',
                  label: 'Key date',
                  xmlname: 'keyDate'
                },
                {
                  input_type: 'select',
                  label: 'Qualifier',
                  xmlname: 'qualifier'
                },
                {
                  input_type: 'input_text',
                  label: 'Language',
                  xmlname: 'lang'
                },
                {
                  input_type: 'input_text',
                  label: 'Script',
                  xmlname: 'script'
                },
                {
                  input_type: 'input_text',
                  label: 'Transliteration',
                  xmlname: 'transliteration'
                }
              ],
              input_type: 'input_datetime',
              label: 'Date created',
              ui_value: '1909',
              xmlname: 'dateCreated'
            },
            {
              attributes: [
                {
                  input_type: 'select',
                  label: 'Supplied',
                  xmlname: 'supplied'
                }
              ],
              children: [
                {
                  attributes: [
                    {
                      input_type: 'select',
                      label: 'Type',
                      ui_value: 'text',
                      xmlname: 'type'
                    },
                    {
                      input_type: 'input_text',
                      label: 'Language',
                      xmlname: 'lang'
                    },
                    {
                      input_type: 'input_text',
                      label: 'Script',
                      xmlname: 'script'
                    },
                    {
                      input_type: 'input_text',
                      label: 'Transliteration',
                      xmlname: 'transliteration'
                    },
                    {
                      input_type: 'select',
                      label: 'Authority',
                      xmlname: 'authority'
                    },
                    {
                      input_type: 'input_text',
                      label: 'Authority URI',
                      xmlname: 'authorityURI'
                    },
                    {
                      input_type: 'input_text',
                      label: 'Value URI',
                      xmlname: 'valueURI'
                    }
                  ],
                  input_type: 'input_text',
                  label: 'Place term',
                  ui_value: 'Berlin',
                  xmlname: 'placeTerm'
                }
              ],
              input_type: 'node',
              label: 'Place',
              ui_value: '\n      \n    ',
              xmlname: 'place'
            }
          ],
          input_type: 'node',
          label: 'Origin info',
          ui_value: '\n    \n    \n  ',
          xmlname: 'originInfo'
        },
        {
          attributes: [
            {
              input_type: 'input_text',
              label: 'Type',
              ui_value: 'DLBT',
              xmlname: 'type'
            },
            {
              input_type: 'input_text',
              label: 'Language',
              xmlname: 'lang'
            },
            {
              input_type: 'input_text',
              label: 'Script',
              xmlname: 'script'
            },
            {
              input_type: 'input_text',
              label: 'Transliteration',
              xmlname: 'transliteration'
            },
            {
              input_type: 'select',
              label: 'Authority',
              xmlname: 'authority'
            },
            {
              input_type: 'input_text',
              label: 'Authority URI',
              xmlname: 'authorityURI'
            },
            {
              input_type: 'input_text',
              label: 'Value URI',
              xmlname: 'valueURI'
            },
            {
              input_type: 'input_text',
              label: 'Display label',
              xmlname: 'displayLabel'
            },
            {
              input_type: 'select',
              label: 'Usage',
              xmlname: 'usage'
            },
            {
              input_type: 'input_text',
              label: 'Alternative representation group',
              xmlname: 'altRepGroup'
            }
          ],
          input_type: 'input_text',
          label: 'Genre',
          ui_value: 'book',
          xmlname: 'genre'
        },
        {
          attributes: [
            {
              input_type: 'select',
              label: 'Manuscript',
              xmlname: 'manuscript'
            },
            {
              input_type: 'select',
              label: 'Collection',
              xmlname: 'collection'
            },
            {
              input_type: 'input_text',
              label: 'Display label',
              xmlname: 'displayLabel'
            },
            {
              input_type: 'select',
              label: 'Usage',
              xmlname: 'usage'
            },
            {
              input_type: 'input_text',
              label: 'Alternative representation group',
              xmlname: 'altRepGroup'
            }
          ],
          input_type: 'select',
          label: 'Type of resource',
          ui_value: 'text',
          xmlname: 'typeOfResource'
        },
        {
          attributes: [
            {
              input_type: 'input_text',
              label: 'Object part',
              xmlname: 'objectPart'
            },
            {
              input_type: 'input_text',
              label: 'Language',
              xmlname: 'lang'
            },
            {
              input_type: 'input_text',
              label: 'Script',
              xmlname: 'script'
            },
            {
              input_type: 'input_text',
              label: 'Transliteration',
              xmlname: 'transliteration'
            },
            {
              input_type: 'input_text',
              label: 'Display label',
              xmlname: 'displayLabel'
            },
            {
              input_type: 'select',
              label: 'Usage',
              xmlname: 'usage'
            },
            {
              input_type: 'input_text',
              label: 'Alternative representation group',
              xmlname: 'altRepGroup'
            }
          ],
          children: [
            {
              attributes: [
                {
                  input_type: 'select',
                  label: 'Type',
                  ui_value: 'text',
                  xmlname: 'type'
                },
                {
                  input_type: 'select',
                  label: 'Authority',
                  xmlname: 'authority'
                },
                {
                  input_type: 'input_text',
                  label: 'Authority URI',
                  xmlname: 'authorityURI'
                },
                {
                  input_type: 'input_text',
                  label: 'Value URI',
                  xmlname: 'valueURI'
                },
                {
                  input_type: 'input_text',
                  label: 'Language',
                  xmlname: 'lang'
                },
                {
                  input_type: 'input_text',
                  label: 'Script',
                  xmlname: 'script'
                },
                {
                  input_type: 'input_text',
                  label: 'Transliteration',
                  xmlname: 'transliteration'
                }
              ],
              input_type: 'input_text',
              label: 'Language term',
              ui_value: 'German',
              xmlname: 'languageTerm'
            }
          ],
          input_type: 'node',
          label: 'Language',
          ui_value: '\n    \n  ',
          xmlname: 'language'
        },
        {
          attributes: [
            {
              input_type: 'select',
              label: 'Type',
              xmlname: 'type'
            },
            {
              input_type: 'input_text',
              label: 'Language',
              xmlname: 'lang'
            },
            {
              input_type: 'input_text',
              label: 'Script',
              xmlname: 'script'
            },
            {
              input_type: 'input_text',
              label: 'Transliteration',
              xmlname: 'transliteration'
            },
            {
              input_type: 'input_text',
              label: 'Display label',
              xmlname: 'displayLabel'
            },
            {
              input_type: 'input_text',
              label: 'Alternative representation group',
              xmlname: 'altRepGroup'
            }
          ],
          children: [
            {
              attributes: [
                {
                  input_type: 'select',
                  label: 'Unit',
                  ui_value: 'page',
                  xmlname: 'unit'
                }
              ],
              input_type: 'node',
              label: 'Extent',
              sequence: 1,
              ui_value: '188 p.',
              xmlname: 'extent'
            }
          ],
          input_type: 'node',
          label: 'Part',
          ordered: 1,
          ui_value: '\n    \n  ',
          xmlname: 'part'
        },
        {
          attributes: [
            {
              input_type: 'input_text',
              label: 'Link',
              xmlname: 'xlink:href'
            },
            {
              input_type: 'input_text',
              label: 'Language',
              xmlname: 'lang'
            },
            {
              input_type: 'input_text',
              label: 'Script',
              xmlname: 'script'
            },
            {
              input_type: 'input_text',
              label: 'Transliteration',
              xmlname: 'transliteration'
            },
            {
              input_type: 'select',
              label: 'Type',
              xmlname: 'type'
            },
            {
              input_type: 'input_text',
              label: 'Type URI',
              xmlname: 'typeURI'
            },
            {
              input_type: 'input_text',
              label: 'Alternative representation group',
              xmlname: 'altRepGroup'
            }
          ],
          input_type: 'input_text',
          label: 'Note',
          ui_value: 'Exported from DLBT, last modified on 2019-08-02',
          xmlname: 'note'
        },
        {
          attributes: [
            {
              input_type: 'input_text',
              label: 'Link',
              xmlname: 'xlink:href'
            },
            {
              input_type: 'input_text',
              label: 'Language',
              xmlname: 'lang'
            },
            {
              input_type: 'input_text',
              label: 'Script',
              xmlname: 'script'
            },
            {
              input_type: 'input_text',
              label: 'Transliteration',
              xmlname: 'transliteration'
            },
            {
              input_type: 'select',
              label: 'Type',
              xmlname: 'type'
            },
            {
              input_type: 'input_text',
              label: 'Type URI',
              xmlname: 'typeURI'
            },
            {
              input_type: 'input_text',
              label: 'Alternative representation group',
              xmlname: 'altRepGroup'
            }
          ],
          input_type: 'input_text',
          label: 'Note',
          ui_value: '158008',
          xmlname: 'note'
        },
        {
          attributes: [
            {
              input_type: 'input_text',
              label: 'Link',
              xmlname: 'xlink:href'
            },
            {
              input_type: 'input_text',
              label: 'Language',
              xmlname: 'lang'
            },
            {
              input_type: 'input_text',
              label: 'Script',
              xmlname: 'script'
            },
            {
              input_type: 'input_text',
              label: 'Transliteration',
              xmlname: 'transliteration'
            },
            {
              input_type: 'select',
              label: 'Authority',
              xmlname: 'authority'
            },
            {
              input_type: 'input_text',
              label: 'Authority URI',
              xmlname: 'authorityURI'
            },
            {
              input_type: 'input_text',
              label: 'Value URI',
              xmlname: 'valueURI'
            },
            {
              input_type: 'input_text',
              label: 'Display label',
              xmlname: 'displayLabel'
            },
            {
              input_type: 'select',
              label: 'Usage',
              xmlname: 'usage'
            },
            {
              input_type: 'input_text',
              label: 'Alternative representation group',
              xmlname: 'altRepGroup'
            }
          ],
          children: [
            {
              attributes: [
                {
                  input_type: 'select',
                  label: 'Authority',
                  xmlname: 'authority'
                },
                {
                  input_type: 'input_text',
                  label: 'Authority URI',
                  xmlname: 'authorityURI'
                },
                {
                  input_type: 'input_text',
                  label: 'Value URI',
                  xmlname: 'valueURI'
                },
                {
                  input_type: 'input_text',
                  label: 'Language',
                  xmlname: 'lang'
                },
                {
                  input_type: 'input_text',
                  label: 'Script',
                  xmlname: 'script'
                },
                {
                  input_type: 'input_text',
                  label: 'Transliteration',
                  xmlname: 'transliteration'
                }
              ],
              input_type: 'input_text',
              label: 'Topic',
              ui_value: 'primary, FWF',
              xmlname: 'topic'
            }
          ],
          input_type: 'node',
          label: 'Subject',
          ui_value: '\n    \n  ',
          xmlname: 'subject'
        },
        {
          attributes: [
            {
              input_type: 'input_text',
              label: 'Language',
              xmlname: 'lang'
            },
            {
              input_type: 'input_text',
              label: 'Script',
              xmlname: 'script'
            },
            {
              input_type: 'input_text',
              label: 'Transliteration',
              xmlname: 'transliteration'
            },
            {
              input_type: 'input_text',
              label: 'Display label',
              xmlname: 'displayLabel'
            },
            {
              input_type: 'select',
              label: 'Invalid',
              xmlname: 'invalid'
            },
            {
              input_type: 'input_text',
              label: 'Alternative representation group',
              xmlname: 'altRepGroup'
            }
          ],
          children: [
            {
              attributes: [
                {
                  input_type: 'input_text',
                  label: 'Display label',
                  ui_value: 'Element from Phaidra Collection',
                  xmlname: 'displayLabel'
                },
                {
                  input_type: 'input_datetime',
                  label: 'Date last accessed',
                  xmlname: 'dateLastAccessed'
                },
                {
                  input_type: 'input_text',
                  label: 'Note',
                  xmlname: 'note'
                },
                {
                  input_type: 'select',
                  label: 'Access',
                  xmlname: 'access'
                },
                {
                  input_type: 'select',
                  label: 'Usage',
                  xmlname: 'usage'
                }
              ],
              input_type: 'input_text',
              label: 'URL',
              ui_value: 'https://phaidra.univie.ac.at/detail_object/o:753157',
              xmlname: 'url'
            }
          ],
          input_type: 'node',
          label: 'Location',
          ui_value: '\n    \n  ',
          xmlname: 'location'
        },
        {
          attributes: [
            {
              input_type: 'select',
              label: 'Type',
              ui_value: 'use and reproduction',
              xmlname: 'type'
            },
            {
              input_type: 'input_text',
              label: 'Link',
              xmlname: 'xlink:href'
            },
            {
              input_type: 'input_text',
              label: 'Language',
              xmlname: 'lang'
            },
            {
              input_type: 'input_text',
              label: 'Script',
              xmlname: 'script'
            },
            {
              input_type: 'input_text',
              label: 'Transliteration',
              xmlname: 'transliteration'
            },
            {
              input_type: 'input_text',
              label: 'Display label',
              xmlname: 'displayLabel'
            },
            {
              input_type: 'input_text',
              label: 'Alternative representation group',
              xmlname: 'altRepGroup'
            },
            {
              input_type: 'input_text',
              label: 'Alternative format',
              xmlname: 'altFormat'
            },
            {
              input_type: 'input_text',
              label: 'Alternative content',
              xmlname: 'altContent'
            }
          ],
          extensible: 1,
          input_type: 'input_text',
          label: 'Access condition',
          ui_value: 'All rights reserved',
          xmlname: 'accessCondition'
        },
        {
          attributes: [
            {
              input_type: 'select',
              label: 'Type',
              ui_value: 'otherVersion',
              xmlname: 'type'
            },
            {
              input_type: 'input_text',
              label: 'Display label',
              ui_value: 'Translation of',
              xmlname: 'displayLabel'
            },
            {
              input_type: 'input_text',
              label: 'Link',
              xmlname: 'xlink:href'
            }
          ],
          children: [
            {
              attributes: [
                {
                  input_type: 'input_text',
                  label: 'Link',
                  xmlname: 'xlink:href'
                },
                {
                  input_type: 'input_text',
                  label: 'Language',
                  xmlname: 'lang'
                },
                {
                  input_type: 'input_text',
                  label: 'Script',
                  xmlname: 'script'
                },
                {
                  input_type: 'input_text',
                  label: 'Transliteration',
                  xmlname: 'transliteration'
                },
                {
                  input_type: 'select',
                  label: 'Type',
                  xmlname: 'type'
                },
                {
                  input_type: 'input_text',
                  label: 'Other type',
                  xmlname: 'otherType'
                },
                {
                  input_type: 'select',
                  label: 'Authority',
                  xmlname: 'authority'
                },
                {
                  input_type: 'input_text',
                  label: 'Authority URI',
                  xmlname: 'authorityURI'
                },
                {
                  input_type: 'input_text',
                  label: 'Value URI',
                  xmlname: 'valueURI'
                },
                {
                  input_type: 'input_text',
                  label: 'Display label',
                  xmlname: 'displayLabel'
                },
                {
                  input_type: 'select',
                  label: 'Supplied',
                  xmlname: 'supplied'
                },
                {
                  input_type: 'select',
                  label: 'Usage',
                  xmlname: 'usage'
                },
                {
                  input_type: 'input_text',
                  label: 'Alternative representation group',
                  xmlname: 'altRepGroup'
                },
                {
                  input_type: 'input_text',
                  label: 'Name title group',
                  xmlname: 'nameTitleGroup'
                },
                {
                  input_type: 'input_text',
                  label: 'Alternative format',
                  xmlname: 'altFormat'
                },
                {
                  input_type: 'input_text',
                  label: 'Alternative content',
                  xmlname: 'altContent'
                }
              ],
              children: [
                {
                  attributes: [
                    {
                      input_type: 'input_text',
                      label: 'Language',
                      xmlname: 'lang'
                    },
                    {
                      input_type: 'input_text',
                      label: 'Script',
                      xmlname: 'script'
                    },
                    {
                      input_type: 'input_text',
                      label: 'Transliteration',
                      xmlname: 'transliteration'
                    }
                  ],
                  input_type: 'input_text',
                  label: 'Title',
                  mandatory: 1,
                  ui_value: 'De groote vlucht, 1908; Uitkomst, 1909',
                  xmlname: 'title'
                }
              ],
              input_type: 'node',
              label: 'Title info',
              ui_value: '\n      \n    ',
              xmlname: 'titleInfo'
            },
            {
              attributes: [
                {
                  input_type: 'input_text',
                  label: 'Object part',
                  xmlname: 'objectPart'
                },
                {
                  input_type: 'input_text',
                  label: 'Language',
                  xmlname: 'lang'
                },
                {
                  input_type: 'input_text',
                  label: 'Script',
                  xmlname: 'script'
                },
                {
                  input_type: 'input_text',
                  label: 'Transliteration',
                  xmlname: 'transliteration'
                },
                {
                  input_type: 'input_text',
                  label: 'Display label',
                  xmlname: 'displayLabel'
                },
                {
                  input_type: 'select',
                  label: 'Usage',
                  xmlname: 'usage'
                },
                {
                  input_type: 'input_text',
                  label: 'Alternative representation group',
                  xmlname: 'altRepGroup'
                }
              ],
              children: [
                {
                  attributes: [
                    {
                      input_type: 'select',
                      label: 'Type',
                      ui_value: 'text',
                      xmlname: 'type'
                    },
                    {
                      input_type: 'select',
                      label: 'Authority',
                      xmlname: 'authority'
                    },
                    {
                      input_type: 'input_text',
                      label: 'Authority URI',
                      xmlname: 'authorityURI'
                    },
                    {
                      input_type: 'input_text',
                      label: 'Value URI',
                      xmlname: 'valueURI'
                    },
                    {
                      input_type: 'input_text',
                      label: 'Language',
                      xmlname: 'lang'
                    },
                    {
                      input_type: 'input_text',
                      label: 'Script',
                      xmlname: 'script'
                    },
                    {
                      input_type: 'input_text',
                      label: 'Transliteration',
                      xmlname: 'transliteration'
                    }
                  ],
                  input_type: 'input_text',
                  label: 'Language term',
                  ui_value: 'Dutch',
                  xmlname: 'languageTerm'
                }
              ],
              input_type: 'node',
              label: 'Language',
              ui_value: '\n      \n    ',
              xmlname: 'language'
            },
            {
              attributes: [
                {
                  input_type: 'input_text',
                  label: 'Language',
                  xmlname: 'lang'
                },
                {
                  input_type: 'input_text',
                  label: 'Script',
                  xmlname: 'script'
                },
                {
                  input_type: 'input_text',
                  label: 'Transliteration',
                  xmlname: 'transliteration'
                },
                {
                  input_type: 'input_text',
                  label: 'Display label',
                  xmlname: 'displayLabel'
                },
                {
                  input_type: 'input_text',
                  label: 'Alternative representation group',
                  xmlname: 'altRepGroup'
                },
                {
                  input_type: 'select',
                  label: 'Event type',
                  xmlname: 'eventType'
                }
              ],
              children: [
                {
                  attributes: [
                    {
                      input_type: 'select',
                      label: 'Encoding',
                      xmlname: 'encoding'
                    },
                    {
                      input_type: 'select',
                      label: 'Point',
                      xmlname: 'point'
                    },
                    {
                      input_type: 'select',
                      label: 'Key date',
                      xmlname: 'keyDate'
                    },
                    {
                      input_type: 'select',
                      label: 'Qualifier',
                      xmlname: 'qualifier'
                    },
                    {
                      input_type: 'input_text',
                      label: 'Language',
                      xmlname: 'lang'
                    },
                    {
                      input_type: 'input_text',
                      label: 'Script',
                      xmlname: 'script'
                    },
                    {
                      input_type: 'input_text',
                      label: 'Transliteration',
                      xmlname: 'transliteration'
                    }
                  ],
                  input_type: 'input_datetime',
                  label: 'Date issued',
                  xmlname: 'dateIssued'
                }
              ],
              input_type: 'node',
              label: 'Origin info',
              ui_value: '\n      \n    ',
              xmlname: 'originInfo'
            }
          ],
          input_type: 'node',
          label: 'Related item',
          ui_value: '\n    \n    \n    \n  ',
          xmlname: 'relatedItem'
        },
        {
          attributes: [
            {
              input_type: 'select',
              label: 'Type',
              ui_value: 'series',
              xmlname: 'type'
            },
            {
              input_type: 'input_text',
              label: 'Link',
              xmlname: 'xlink:href'
            },
            {
              input_type: 'input_text',
              label: 'Display label',
              xmlname: 'displayLabel'
            }
          ],
          children: [
            {
              attributes: [
                {
                  input_type: 'input_text',
                  label: 'Link',
                  xmlname: 'xlink:href'
                },
                {
                  input_type: 'input_text',
                  label: 'Language',
                  xmlname: 'lang'
                },
                {
                  input_type: 'input_text',
                  label: 'Script',
                  xmlname: 'script'
                },
                {
                  input_type: 'input_text',
                  label: 'Transliteration',
                  xmlname: 'transliteration'
                },
                {
                  input_type: 'select',
                  label: 'Type',
                  xmlname: 'type'
                },
                {
                  input_type: 'input_text',
                  label: 'Other type',
                  xmlname: 'otherType'
                },
                {
                  input_type: 'select',
                  label: 'Authority',
                  xmlname: 'authority'
                },
                {
                  input_type: 'input_text',
                  label: 'Authority URI',
                  xmlname: 'authorityURI'
                },
                {
                  input_type: 'input_text',
                  label: 'Value URI',
                  xmlname: 'valueURI'
                },
                {
                  input_type: 'input_text',
                  label: 'Display label',
                  xmlname: 'displayLabel'
                },
                {
                  input_type: 'select',
                  label: 'Supplied',
                  xmlname: 'supplied'
                },
                {
                  input_type: 'select',
                  label: 'Usage',
                  xmlname: 'usage'
                },
                {
                  input_type: 'input_text',
                  label: 'Alternative representation group',
                  xmlname: 'altRepGroup'
                },
                {
                  input_type: 'input_text',
                  label: 'Name title group',
                  xmlname: 'nameTitleGroup'
                },
                {
                  input_type: 'input_text',
                  label: 'Alternative format',
                  xmlname: 'altFormat'
                },
                {
                  input_type: 'input_text',
                  label: 'Alternative content',
                  xmlname: 'altContent'
                }
              ],
              children: [
                {
                  attributes: [
                    {
                      input_type: 'input_text',
                      label: 'Language',
                      xmlname: 'lang'
                    },
                    {
                      input_type: 'input_text',
                      label: 'Script',
                      xmlname: 'script'
                    },
                    {
                      input_type: 'input_text',
                      label: 'Transliteration',
                      xmlname: 'transliteration'
                    }
                  ],
                  input_type: 'input_text',
                  label: 'Title',
                  mandatory: 1,
                  ui_value: 'Schauspiele',
                  xmlname: 'title'
                }
              ],
              input_type: 'node',
              label: 'Title info',
              ui_value: '\n      \n    ',
              xmlname: 'titleInfo'
            },
            {
              attributes: [
                {
                  input_type: 'select',
                  label: 'Type',
                  xmlname: 'type'
                },
                {
                  input_type: 'input_text',
                  label: 'Language',
                  xmlname: 'lang'
                },
                {
                  input_type: 'input_text',
                  label: 'Script',
                  xmlname: 'script'
                },
                {
                  input_type: 'input_text',
                  label: 'Transliteration',
                  xmlname: 'transliteration'
                },
                {
                  input_type: 'input_text',
                  label: 'Display label',
                  xmlname: 'displayLabel'
                },
                {
                  input_type: 'input_text',
                  label: 'Alternative representation group',
                  xmlname: 'altRepGroup'
                }
              ],
              children: [
                {
                  attributes: [
                    {
                      input_type: 'select',
                      label: 'Type',
                      ui_value: 'volume',
                      xmlname: 'type'
                    },
                    {
                      input_type: 'input_text',
                      label: 'Level',
                      xmlname: 'level'
                    },
                    {
                      input_type: 'input_text',
                      label: 'Language',
                      xmlname: 'lang'
                    },
                    {
                      input_type: 'input_text',
                      label: 'Script',
                      xmlname: 'script'
                    },
                    {
                      input_type: 'input_text',
                      label: 'Transliteration',
                      xmlname: 'transliteration'
                    }
                  ],
                  children: [
                    {
                      attributes: [
                        {
                          input_type: 'input_text',
                          label: 'Language',
                          xmlname: 'lang'
                        },
                        {
                          input_type: 'input_text',
                          label: 'Script',
                          xmlname: 'script'
                        },
                        {
                          input_type: 'input_text',
                          label: 'Transliteration',
                          xmlname: 'transliteration'
                        }
                      ],
                      input_type: 'input_text',
                      label: 'Number',
                      ui_value: '\n2',
                      xmlname: 'number'
                    },
                    {
                      attributes: [
                        {
                          input_type: 'input_text',
                          label: 'Language',
                          xmlname: 'lang'
                        },
                        {
                          input_type: 'input_text',
                          label: 'Script',
                          xmlname: 'script'
                        },
                        {
                          input_type: 'input_text',
                          label: 'Transliteration',
                          xmlname: 'transliteration'
                        }
                      ],
                      input_type: 'input_text',
                      label: 'Caption',
                      ui_value: 'no.',
                      xmlname: 'caption'
                    }
                  ],
                  input_type: 'node',
                  label: 'Detail',
                  ui_value: '\n        \n        \n      ',
                  xmlname: 'detail'
                }
              ],
              input_type: 'node',
              label: 'Part',
              ordered: 1,
              ui_value: '\n      \n    ',
              xmlname: 'part'
            }
          ],
          input_type: 'node',
          label: 'Related item',
          ui_value: '\n    \n    \n  ',
          xmlname: 'relatedItem'
        }
      ],
      form: {
        sections: []
      },
      members: [],
      pid: 'o:753810',
      piddoc: {},
      collection: 'o:459021',
      sampleCollection: 'o:541829',
      solrbaseurl: 'https://app01.cc.univie.ac.at:8983/solr/phaidra_sandbox',
      phaidrabaseurl: 'phaidra-sandbox.univie.ac.at',
      apibaseurl: 'https://services.phaidra-sandbox.univie.ac.at/api',
      credentials: {
        username: '',
        password: ''
      },
      version: version,
      contentmodel: 'https://pid.phaidra.org/vocabulary/44TN-P1S0',
      contentmodels: [
        {
          text: 'Data',
          value: 'https://pid.phaidra.org/vocabulary/7AVS-Y482'
        },
        {
          text: 'Picture',
          value: 'https://pid.phaidra.org/vocabulary/44TN-P1S0'
        },
        {
          text: 'Audio',
          value: 'https://pid.phaidra.org/vocabulary/8YB5-1M0J'
        },
        {
          text: 'Video',
          value: 'https://pid.phaidra.org/vocabulary/B0Y6-GYT8'
        },
        {
          text: 'Document',
          value: 'https://pid.phaidra.org/vocabulary/69ZZ-2KGX'
        },
        {
          text: 'Container',
          value: 'https://pid.phaidra.org/vocabulary/8MY0-BQDQ'
        },
        {
          text: 'Resource',
          value: 'https://pid.phaidra.org/vocabulary/T8GH-F4V8'
        }
      ],
      psvis: true,
      submitRights: {}
    }
  },
  methods: {
    validate: function () {
      return true
    },
    getResourceTypeFromMimeType: function (mime) {
      switch (mime) {
        case 'image/jpeg':
        case 'image/tiff':
        case 'image/gif':
        case 'image/png':
        case 'image/x-ms-bmp':
          // picture
          return 'https://pid.phaidra.org/vocabulary/44TN-P1S0'

        case 'audio/wav':
        case 'audio/mpeg':
        case 'audio/flac':
        case 'audio/ogg':
          // audio
          return 'https://pid.phaidra.org/vocabulary/8YB5-1M0J'

        case 'application/pdf':
          // document
          return 'https://pid.phaidra.org/vocabulary/69ZZ-2KGX'

        case 'video/mpeg':
        case 'video/avi':
        case 'video/mp4':
        case 'video/quicktime':
        case 'video/x-matroska':
          // video
          return 'https://pid.phaidra.org/vocabulary/B0Y6-GYT8'

        // eg application/x-iso9660-image
        default:
          // data
          return 'https://pid.phaidra.org/vocabulary/7AVS-Y482'
      }
    },
    handleSelect: function (val) {
      var i
      var j
      var k
      if (val.predicate === 'ebucore:hasMimeType') {
        for (i = 0; i < this.form.sections.length; i++) {
          if (this.form.sections[i].fields) {
            var mime
            for (j = 0; j < this.form.sections[i].fields.length; j++) {
              if (
                this.form.sections[i].fields[j].predicate ===
                'ebucore:hasMimeType'
              ) {
                mime = this.form.sections[i].fields[j].value
              }
            }
            if (mime) {
              var resourcetype = this.getResourceTypeFromMimeType(mime)
              for (j = 0; j < this.form.sections[i].fields.length; j++) {
                if (
                  this.form.sections[i].fields[j].predicate === 'dcterms:type'
                ) {
                  var rt = this.form.sections[i].fields[j]
                  rt.value = resourcetype
                  var preflabels
                  for (
                    k = 0;
                    k < this.vocabularies['resourcetype'].terms.length;
                    k++
                  ) {
                    if (
                      this.vocabularies['resourcetype'].terms[k]['@id'] ===
                      rt.value
                    ) {
                      preflabels = this.vocabularies['resourcetype'].terms[k]['skos:prefLabel']
                    }
                  }
                  rt['skos:prefLabel'] = []
                  Object.entries(preflabels).forEach(([key, value]) => {
                    rt['skos:prefLabel'].push({
                      '@value': value,
                      '@language': key
                    })
                  })
                }
              }
              this.form.sections.splice(i, 1, this.form.sections[i])
            }
          }
        }
      }
    },
    addPhaidrasubjectSection: function (afterSection) {
      let s = {
        title: 'SUBJECT_SECTION',
        type: 'phaidra:Subject',
        id: this.form.sections.length + 1,
        removable: true,
        multiplicable: true,
        fields: []
      }
      this.form.sections.splice(
        this.form.sections.indexOf(afterSection) + 1,
        0,
        s
      )
    },
    loadManagement: function (pid) {
      this.loadMembers(pid)
      this.loadDoc(pid)
    },
    loadDoc: async function (pid) {
      this.piddoc = {}

      var params = {
        q: 'pid:"' + pid + '"',
        defType: 'edismax',
        wt: 'json',
        qf: 'pid^5'
      }

      try {
        let response = await this.$axios.request({
          method: 'GET',
          url: this.instance.solr + '/select',
          data: qs.stringify(params, { arrayFormat: 'repeat' }),
          headers: {
            'content-type': 'application/x-www-form-urlencoded'
          }
        })
        if (response.data.response.numFound > 0) {
          this.piddoc = response.data.response.docs[0]
        } else {
          this.piddoc = {}
        }
      } catch (error) {
        console.log(error)
      } finally {
        this.loading = false
      }
    },
    loadMembers: async function (pid) {
      this.members = []

      var params = {
        q: 'ismemberof:"' + pid + '"',
        defType: 'edismax',
        wt: 'json',
        qf: 'ismemberof^5',
        fl: 'pid,cmodel,dc_title,created',
        sort: 'pos_in_' + pid.replace(':', '_') + ' asc'
      }

      try {
        let response = await this.$axios.request({
          method: 'GET',
          url: this.instance.solr + '/select?',
          params: params
        })
        if (response.data.response.numFound > 0) {
          this.members = response.data.response.docs
        } else {
          this.members = []
        }
      } catch (error) {
        console.log(error)
      } finally {
        this.loading = false
      }
    },
    loadUwmetadata: async function (pid) {
      this.loadedMetadata = []
      this.loading = true
      try {
        let response = await this.$axios.request({
          method: 'GET',
          url:
            '/object/' +
            pid +
            '/metadata',
          params: {
            mode: 'full'
          }
        })
        if (response.data.alerts && response.data.alerts.length > 0) {
          this.$store.commit('setAlerts', response.data.alerts)
        }
        if (response.data.metadata['uwmetadata']) {
          return response.data.metadata['uwmetadata']
        }
      } catch (error) {
        console.log(error)
      } finally {
        this.loading = false
      }
    },
    loadMetadata: async function (pid) {
      this.loadedMetadata = []
      this.loading = true
      try {
        let response = await this.$axios.request({
          method: 'GET',
          url:
            '/object/' +
            pid +
            '/metadata',
          params: {
            mode: 'resolved'
          }
        })
        if (response.data.alerts && response.data.alerts.length > 0) {
          this.$store.commit('setAlerts', response.data.alerts)
        }
        if (response.data.metadata['JSON-LD']) {
          return response.data.metadata['JSON-LD']
        }
      } catch (error) {
        console.log(error)
      } finally {
        this.loading = false
      }
    },
    loadDisplay: function () {
      this.displayjsonld = {}
      let self = this
      this.loadMetadata(self.pid).then(function (jsonld) {
        self.displayjsonld = jsonld
      })
    },
    loadEdit: function () {
      let self = this
      this.loadMetadata(self.pid).then(function (jsonld) {
        self.editform = jsonLd.json2form(jsonld, null, this.vocabularies)
      })
    },
    loadUwmetadataEdit: function () {
      let self = this
      this.loadUwmetadata(self.pid).then(function (json) {
        self.uwmetadataeditform = json
      })
    },
    loadSearch: function () {
      this.collection = ''
      this.collection = this.sampleCollection
    },
    login: function () {
      this.$store.commit('setInstanceApi', this.apibaseurl)
      this.$store.commit('setInstanceSolr', this.solrbaseurl)
      this.$store.commit('setInstancePhaidra', this.phaidrabaseurl)
      this.$store.dispatch('login', this.credentials)
    },
    logout: function () {
      this.$store.dispatch('logout')
    },
    objectCreated: function (event) {
      this.$store.commit('setAlerts', [
        { type: 'success', msg: 'Object ' + event + ' created' }
      ])
    },
    objectSaved: function (event) {
      this.$store.commit('setAlerts', [
        { type: 'success', msg: 'Metadata for object ' + event + ' saved' }
      ])
    },
    orderSaved: function (event) {
      this.$store.commit('setAlerts', [{ type: 'success', key: 'order_saved_for_object', params: { o: event }}])
    },
    objectDeleted: function () {
      this.$store.commit('setAlerts', [
        { type: 'success', msg: 'Object was successfully deleted.' }
      ])
    },
    toggleVisibility: function () {
      this.psvis = !this.psvis
    },
    dismiss: function (alert) {
      this.$store.commit('clearAlert', alert)
    },
    resetForm: function (cm) {
      if (cm === 'https://pid.phaidra.org/vocabulary/8MY0-BQDQ') {
        this.createContainerForm()
      } else {
        if (cm === 'https://pid.phaidra.org/vocabulary/T8GH-F4V8') {
          this.createResourceForm()
        } else {
          this.createSimpleForm()
        }
      }
    },
    createResourceForm: function () {
      this.form = {
        sections: [
          {
            title: 'Resource link',
            type: 'resourcelink',
            id: 1,
            fields: []
          },
          {
            title: 'General metadata',
            type: 'digitalobject',
            id: 2,
            fields: []
          }
        ]
      }
      var rt = fields.getField('resource-type')
      rt.value = this.contentmodel
      this.form.sections[1].fields.push(rt)
      this.form.sections[1].fields.push(fields.getField('title'))
      this.form.sections[1].fields.push(fields.getField('description'))
    },
    createSimpleForm: function () {
      this.form = {
        sections: [
          {
            title: 'General metadata',
            type: 'digitalobject',
            id: 1,
            fields: []
          },
          /*
          {
            title: 'Digitized object',
            type: 'phaidra:Subject',
            id: 2,
            fields: []
          },
          {
            title: 'Subject',
            type: 'phaidra:Subject',
            id: 3,
            multiplicable: true,
            fields: []
          },
          */
          {
            title: 'File',
            id: 4,
            type: '',
            multiplicable: false,
            fields: []
          }
        ]
      }
      var rt = fields.getField('resource-type')
      rt.value = this.contentmodel
      this.form.sections[0].fields.push(rt)

      this.form.sections[0].fields.push(fields.getField('oefos-subject'))

      this.form.sections[0].fields.push(fields.getField('contained-in'))

      let t = fields.getField('title')
      t.hideSubtitle = true
      t.multilingual = false
      t.multiplicable = false
      this.form.sections[0].fields.push(t)

      // this.form.sections[0].fields.push(fields.getField('contained-in'))

      // this.form.sections[0].fields.push(fields.getField('language'))
      // let lang_vocab = fields.getField('language')
      // lang_vocab.vocabulary = 'lang_vocab'
      // this.form.sections[0].fields.push(lang_vocab)

      // this.form.sections[0].fields.push(fields.getField('keyword'))
      // this.form.sections[0].fields.push(fields.getField('see-also'))
      /* let containedIn = fields.getField('contained-in')
      containedIn.label = 'Book'
      containedIn.seriesLabel = 'Series'
      this.form.sections[0].fields.push(containedIn) */

      this.form.sections[1].fields.push(fields.getField('file'))
      this.form.sections[1].fields.push(fields.getField('license'))
      // this.form.sections[1].fields.push(fields.getField('rights'))

      /*
      this.form.sections[0].fields.push(fields.getField('description'))
      this.form.sections[0].fields.push(fields.getField('table-of-contents'))
      var gnd = fields.getField('gnd-subject')
      gnd.exactvoc = 'EthnographicName'
      gnd.label = 'Soziokulturelle Kategorie (GND)'
      this.form.sections[0].fields.push(gnd)
      this.form.sections[0].fields.push(fields.getField('keyword'))
      var lang = fields.getField('language')
      lang.value = 'deu'
      this.form.sections[0].fields.push(lang)
      this.form.sections[0].fields.push(fields.getField('role-extended'))
      this.form.sections[0].fields.push(fields.getField('bf-publication'))
      this.form.sections[0].fields.push(fields.getField('note'))
      let pf = fields.getField('project')
      pf.multiplicable = true
      this.form.sections[0].fields.push(pf)
      this.form.sections[0].fields.push(fields.getField('funder'))
      this.form.sections[0].fields.push(fields.getField('association'))
      let sf = fields.getField('series')
      sf.journalSuggest = true
      this.form.sections[0].fields.push(sf)
      this.form.sections[0].fields.push(fields.getField('citation'))
      this.form.sections[1].fields.push(fields.getField('title'))
      this.form.sections[1].fields.push(fields.getField('role'))
      this.form.sections[1].fields.push(fields.getField('shelf-mark'))
      this.form.sections[1].fields.push(fields.getField('temporal-coverage'))
      this.form.sections[1].fields.push(fields.getField('provenance'))
      this.form.sections[1].fields.push(fields.getField('physical-location'))
      this.form.sections[1].fields.push(fields.getField('page-start'))
      this.form.sections[1].fields.push(fields.getField('page-end'))
      this.form.sections[1].fields.push(fields.getField('scale'))
      var accessiondate = fields.getField('date-edtf')
      accessiondate.type = 'phaidra:dateAccessioned'
      this.form.sections[1].fields.push(accessiondate)
      this.form.sections[1].fields.push(fields.getField('accession-number'))
      this.form.sections[1].fields.push(fields.getField('condition-note'))
      this.form.sections[1].fields.push(fields.getField('reproduction-note'))
      this.form.sections[1].fields.push(fields.getField('technique-vocab'))
      this.form.sections[1].fields.push(fields.getField('technique-text'))
      this.form.sections[1].fields.push(fields.getField('material-text'))
      this.form.sections[1].fields.push(fields.getField('carrier-type'))
      this.form.sections[1].fields.push(fields.getField('height'))
      this.form.sections[1].fields.push(fields.getField('width'))
      this.form.sections[1].fields.push(fields.getField('inscription'))
      var localname = fields.getField('spatial-text')
      localname.type = 'dcterms:spatial'
      localname.disabletype = true
      localname.label = 'Place (native name)'
      this.form.sections[1].fields.push(localname)

      this.form.sections[2].fields.push(fields.getField('title'))
      this.form.sections[2].fields.push(fields.getField('description'))
      this.form.sections[2].fields.push(fields.getField('shelf-mark'))
      this.form.sections[2].fields.push(fields.getField('temporal-coverage'))
      this.form.sections[2].fields.push(fields.getField('provenance'))
      this.form.sections[2].fields.push(fields.getField('physical-location'))
      this.form.sections[2].fields.push(fields.getField('role'))
      // eingangsdatum
      var accessiondate2 = fields.getField('date-edtf')
      accessiondate2.type = 'phaidra:dateAccessioned'
      this.form.sections[2].fields.push(accessiondate2)
      this.form.sections[2].fields.push(fields.getField('accession-number'))
      this.form.sections[2].fields.push(fields.getField('technique-text'))
      this.form.sections[2].fields.push(fields.getField('material-text'))
      this.form.sections[2].fields.push(fields.getField('height'))
      this.form.sections[2].fields.push(fields.getField('width'))
      this.form.sections[2].fields.push(fields.getField('depth'))

      this.form.sections[3].fields.push(fields.getField('file'))
      this.form.sections[3].fields.push(fields.getField('license'))
      this.form.sections[3].fields.push(fields.getField('rights'))
      */
    },
    createContainerForm: function () {
      this.createSimpleForm()
      this.form.sections[3] = {
        title: 'File',
        id: 4,
        type: 'member',
        multiplicable: true,
        fields: []
      }
      var rt = fields.getField('resource-type')
      rt.value = 'https://pid.phaidra.org/vocabulary/8MY0-BQDQ'
      this.form.sections[3].fields.push(rt)
      this.form.sections[3].fields.push(fields.getField('file'))
      this.form.sections[3].fields.push(fields.getField('title'))
      this.form.sections[3].fields.push(fields.getField('description'))
      var mt = fields.getField('mime-type')
      mt.required = true
      this.form.sections[3].fields.push(mt)
      this.form.sections[3].fields.push(fields.getField('digitization-note'))
      this.form.sections[3].fields.push(fields.getField('role'))
      this.form.sections[3].fields.push(fields.getField('license'))
      this.form.sections[3].fields.push(fields.getField('rights'))
    },
    getCookie: function (name) {
      var value = '; ' + document.cookie
      var parts = value.split('; ' + name + '=')
      if (parts.length === 2) {
        var val = parts.pop().split(';').shift()
        return val === ' ' ? null : val
      }
    }
  },
  created: function () {
    this.$store.commit('setInstanceApi', this.apibaseurl)
    this.$store.commit('setInstanceSolr', this.solrbaseurl)
    this.$store.commit('setInstancePhaidra', this.phaidrabaseurl)
    this.$store.commit('setSuggester', {
      suggester: 'gnd',
      url: 'https://ws.gbv.de/suggest/gnd/'
    })
    this.$store.commit('setSuggester', {
      suggester: 'geonames',
      url: 'https://ws.gbv.de/suggest/geonames/'
    })
    this.$store.commit('initStore')
  },
  mounted: function () {
    var token = this.getCookie('X-XSRF-TOKEN')
    if (token) {
      this.$store.commit('setToken', token)
      if (!this.$store.state.user.username) {
        this.$store.dispatch('getLoginData')
      }
    }

    this.createSimpleForm()
  }
}
</script>

<style>
#app {
  font-family: "Roboto", sans-serif, Arial, Helvetica, sans-serif;
  font-size: 11.5pt;
  line-height: 1.42857143;
  color: black;
  background-color: white;
  font-weight: 300;
  text-rendering: optimizeLegibility;
}

.right {
  float: right;
}

.pdlabel {
  max-width: 100%;
}

#app .v-btn {
  text-transform: none;
}
#app .v-tabs__div {
  text-transform: none;
  font-weight: 300;
}

.jsonld-border-left {
  border-left: 1px solid;
  border-color: rgba(0, 0, 0, 0.12);
}

.svg-icon {
  display: inline-block;
  width: 16px;
  height: 16px;
  color: inherit;
  vertical-align: middle;
  fill: none;
  stroke: currentColor;
}

.svg-fill {
  fill: currentColor;
  stroke: none;
}

.svg-up {
  transform: rotate(0deg);
}

.svg-right {
  transform: rotate(90deg);
}

.svg-down {
  transform: rotate(180deg);
}

.svg-left {
  transform: rotate(-90deg);
}
</style>

<style lang="sass">
@require './stylus/main'
</style>
