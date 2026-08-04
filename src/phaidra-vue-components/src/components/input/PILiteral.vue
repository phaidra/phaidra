<template>
  <v-row v-if="!hidden">
    <v-col :cols="multilingual ? (actions.length ? 8 : 10) : (actions.length ? 10 : 12)">
      <v-text-field
        :model-value="value"
        @update:model-value="$emit('input-value', $event)"
        :label="$t(label)"
        :variant="fieldVariant"
      ></v-text-field>
    </v-col>
    <v-col cols="12" md="2" v-if="multilingual || actions.length">
      <v-row>
        <v-col v-if="multilingual" cols="6">
          <v-btn variant="text" @click="$refs.langdialog.open()">
            <span>
              ({{ language ? language : '--' }})
            </span>
          </v-btn>
        </v-col>
        <v-col cols="6" v-if="actions.length">
          <v-menu location="bottom end" close-on-content-click>
            <template #activator="{ props: menuActivatorProps }">
              <v-icon-btn v-bind="menuActivatorProps" icon="mdi-dots-vertical" />
            </template>
            <v-list density="compact">
              <v-list-item
                v-for="(action, i) in actions"
                :key="i"
                @click="$emit(action.event, $event)"
              >
                <v-list-item-title>{{ action.title }}</v-list-item-title>
              </v-list-item>
            </v-list>
          </v-menu>
        </v-col>
      </v-row>

      <select-language ref="langdialog" :showReset="allowLanguageCancel && language ? true : false" @language-selected="$emit('input-language', $event)"></select-language>
    </v-col>
  </v-row>
</template>

<script>
import { fieldproperties } from '../../mixins/fieldproperties'
import SelectLanguage from '../select/SelectLanguage'

export default {
  name: 'p-i-literal',
  mixins: [fieldproperties],
  components: {
    SelectLanguage
  },
  props: {
    value: {
      type: String
    },
    label: {
      type: String,
      required: true
    },
    language: {
      type: String
    },
    multilingual: {
      type: Boolean
    },
    allowLanguageCancel: {
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
