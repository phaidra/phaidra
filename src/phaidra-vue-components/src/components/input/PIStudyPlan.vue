<template>
  <v-row v-if="!hidden">
    <v-col cols="12">

      <v-card class="mb-8">
        <v-card-title class="title font-weight-light white--text">
            <span>{{ $t('Study plan') }}</span>
            <v-spacer></v-spacer>
            <v-menu open-on-hover bottom offset-y v-if="actions.length">
              <template v-slot:activator="{ on, attrs }">
                <v-btn v-on="on" v-bind="attrs" icon dark>
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
          <v-row >
            <v-col cols="8">
              <v-text-field
                :value="name"
                v-on:blur="$emit('input-name',$event.target.value)"
                :label="$t('Study plan name')"
                :required="required"
                :rules="required ? [ v => !!v || 'Required'] : []"
                :filled="inputStyle==='filled'"
                :outlined="inputStyle==='outlined'"
              ></v-text-field>
            </v-col>
            <v-col cols="4" v-if="multilingual">
              <v-btn text @click="$refs.langdialog.open()">
                <span>
                  ({{ nameLanguage ? nameLanguage : '--' }})
                </span>
              </v-btn>
              <select-language ref="langdialog" @language-selected="$emit('input-name-language', $event)"></select-language>
            </v-col>
          </v-row>
          <v-row >
            <v-col cols="6">
              <v-text-field
                :value="notation"
                v-on:blur="$emit('input-notation',$event.target.value)"
                :label="$t('Study plan notation')"
                :filled="inputStyle==='filled'"
                :outlined="inputStyle==='outlined'"
              ></v-text-field>
            </v-col>
            <v-col cols="6">
              <v-text-field
                :value="identifier"
                v-on:blur="$emit('input-identifier',$event.target.value)"
                :label="$t('Study plan identifier')"
                :filled="inputStyle==='filled'"
                :outlined="inputStyle==='outlined'"
              ></v-text-field>
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
  name: 'p-i-study-plan',
  mixins: [vocabulary, fieldproperties],
  components: {
    SelectLanguage
  },
  props: {
    notation: {
      type: String,
      required: true
    },
    name: {
      type: String,
      required: true
    },
    nameLanguage: {
      type: String
    },
    required: {
      type: Boolean
    },
    identifier: {
      type: String
    },
    multiline: {
      type: Boolean
    },
    multilingual: {
      type: Boolean
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
</style>
