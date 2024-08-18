<template>

  <v-row v-if="!hidden">
    <v-col cols="12">
      <v-card class="mb-8">
        <v-card-title class="title font-weight-light grey white--text">
            <span>{{ $t(label) }}</span>
            <v-spacer></v-spacer>
            <v-menu open-on-hover bottom offset-y v-if="actions.length">
              <template v-slot:activator="{ on }">
                <v-btn v-on="on" icon dark>
                  <v-icon dark>mdi-dots-vertical</v-icon>
                </v-btn>
              </template>
              <v-list>
                <v-list-item v-for="(action, i) in actions" :key="i" @click="$emit(action.event, $event)">
                  <v-list-item-title>{{ action.title }}</v-list-item-title>
                </v-list-item>
              </v-list>
            </v-menu>
        </v-card-title>
        <v-divider></v-divider>
        <v-card-text class="mt-4">
          <v-row>
            <v-col>
              <v-row >
                <v-col cols="5">
                  <v-text-field
                    :value="title"
                    :label="$t('Title')"
                    v-on:blur="$emit('input-title',$event.target.value)"
                    :filled="inputStyle==='filled'"
                    :outlined="inputStyle==='outlined'"
                  ></v-text-field>
                </v-col>
                <v-col cols="5">
                  <v-text-field
                    :value="subtitle"
                    :label="$t('Subtitle')"
                    v-on:blur="$emit('input-subtitle',$event.target.value)"
                    :filled="inputStyle==='filled'"
                    :outlined="inputStyle==='outlined'"
                  ></v-text-field>
                </v-col>
                <v-col cols="2">
                  <v-btn text @click="$refs.langdialog.open()">
                    <span class="grey--text text--darken-1">
                      ({{ titleLanguage ? titleLanguage : '--'}})
                    </span>
                  </v-btn>
                  <select-language ref="langdialog" @language-selected="$emit('input-title-language', $event)"></select-language>
                </v-col>
              </v-row>
              <v-row>
                <v-col cols="4">
                  <v-autocomplete
                    :disabled="disablerole"
                    v-on:input="$emit('input-role', $event)"
                    :label="$t('Role')"
                    :items="vocabularies['rolepredicate'].terms"
                    :value="getTerm('rolepredicate', role)"
                    :filter="autocompleteFilter"
                    :filled="inputStyle==='filled'"
                    :outlined="inputStyle==='outlined'"
                    return-object
                    clearable
                    :item-value="'@id'"
                  >
                    <template slot="item" slot-scope="{ item }">
                      <v-list-item-content two-line>
                        <v-list-item-title  v-html="`${getLocalizedTermLabel('rolepredicate', item['@id'])}`"></v-list-item-title>
                        <v-list-item-subtitle v-if="showIds" v-html="`${item['@id']}`"></v-list-item-subtitle>
                      </v-list-item-content>
                    </template>
                    <template slot="selection" slot-scope="{ item }">
                      <v-list-item-content>
                        <v-list-item-title v-html="`${getLocalizedTermLabel('rolepredicate', item['@id'])}`"></v-list-item-title>
                      </v-list-item-content>
                    </template>
                  </v-autocomplete>
                </v-col>
                <template v-if="showname">
                  <v-col cols="4" >
                    <v-text-field
                      :value="name"
                      :label="$t('Name')"
                      v-on:blur="$emit('input-name',$event.target.value)"
                      :filled="inputStyle==='filled'"
                      :outlined="inputStyle==='outlined'"
                    ></v-text-field>
                  </v-col>
                </template>
                <template v-else>
                  <v-col cols="4">
                    <v-text-field
                      :value="firstname"
                      :label="$t('Firstname')"
                      v-on:blur="$emit('input-firstname',$event.target.value)"
                      :filled="inputStyle==='filled'"
                      :outlined="inputStyle==='outlined'"
                    ></v-text-field>
                  </v-col>
                  <v-col cols="4">
                    <v-text-field
                      :value="lastname"
                      :label="$t('Lastname')"
                      v-on:blur="$emit('input-lastname',$event.target.value)"
                      :filled="inputStyle==='filled'"
                      :outlined="inputStyle==='outlined'"
                    ></v-text-field>
                  </v-col>
                </template>
              </v-row>
            </v-col>
          </v-row>
        </v-card-text>
      </v-card>
    </v-col>
  </v-row>
</template>

<script>
import { vocabulary } from '../../mixins/vocabulary'
import { fieldproperties } from '../../mixins/fieldproperties'
import SelectLanguage from '../select/SelectLanguage'

export default {
  name: 'p-i-adaptation',
  mixins: [vocabulary, fieldproperties],
  components: {
    SelectLanguage
  },
  props: {
    type: {
      type: String
    },
    label: {
      type: String
    },
    title: {
      type: String
    },
    subtitle: {
      type: String
    },
    titleLanguage: {
      type: String
    },
    firstname: {
      type: String
    },
    lastname: {
      type: String
    },
    name: {
      type: String
    },
    role: {
      type: String
    },
    disablerole: {
      type: Boolean,
      default: false
    },
    showname: {
      type: Boolean,
      default: false
    },
    showIds: {
      type: Boolean,
      default: false
    }
  }
}
</script>

<style scoped>
.v-btn {
  margin: 0;
}
.vertical-center {
 align-items: center;
}
</style>
