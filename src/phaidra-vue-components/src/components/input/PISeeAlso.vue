<template>
  <v-row v-if="!hidden">
    <v-col cols="3">
      <v-text-field
        :value="title"
        v-on:blur="$emit('input-title',$event.target.value)"
        :label="$t(titleLabel)"
        :variant="fieldVariant"
        append-inner-icon="mdi-magnify"
        @click:append-inner="$refs.yarmselect.open()"
      ></v-text-field>
    </v-col>
    <v-col cols="4">
      <v-text-field
        :value="url"
        v-on:blur="$emit('input-url',$event.target.value)"
        :label="$t(urlLabel)"
        :variant="fieldVariant"
      ></v-text-field>
    </v-col>
    <v-col cols="12" md="1" v-if="multilingual || actions.length">
      <v-row>
        <v-col v-if="multilingual" cols="6">
          <v-btn variant="text" @click="$refs.langdialog.open()">
            <span>
              ({{ titleLanguage ? titleLanguage : '--' }})
            </span>
          </v-btn>
        </v-col>
        <v-col cols="6" v-if="actions.length">
          <v-menu location="bottom end" close-on-content-click>
            <template #activator="{ props: menuActivatorProps }">
              <v-btn icon v-bind="menuActivatorProps">
                <v-icon>mdi-dots-vertical</v-icon>
              </v-btn>
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

      <select-language ref="langdialog" :showReset="allowLanguageCancel && titleLanguage ? true : false" @language-selected="$emit('input-title-language', $event)"></select-language>
      <yarm-ref ref="yarmselect" @input-citation="$emit('input-title', $event)" @input-identifier="$emit('input-url', $event)"></yarm-ref>
    </v-col>
  </v-row>
</template>

<script>
import { vocabulary } from '../../mixins/vocabulary'
import { fieldproperties } from '../../mixins/fieldproperties'
import SelectLanguage from '../select/SelectLanguage'
import YarmRef from '../select/YarmRef'

export default {
  name: 'p-i-see-also',
  mixins: [fieldproperties, vocabulary],
  components: {
    SelectLanguage,
    YarmRef
  },
  props: {
    url: {
      type: String
    },
    urlLabel: {
      type: String,
      default: 'URL'
    },
    title: {
      type: String
    },
    titleLabel: {
      type: String,
      default: 'Title'
    },
    titleLanguage: {
      type: String
    },
    multilingual: {
      type: Boolean
    },
    showIds: {
      type: Boolean,
      default: false
    },
    allowLanguageCancel: {
      type: Boolean,
      default: false
    }
  }
}
</script>
