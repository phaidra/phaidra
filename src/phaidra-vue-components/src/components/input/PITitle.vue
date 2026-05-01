<template>
  

  <v-row v-if="!hidden">
    <v-col cols="12" :md="hideSubtitle ? ( (multilingual || actions.length) ? 8 : 12 ) : ( (multilingual || actions.length) ? 4 : 8 )">
      <v-text-field
        :model-value="title"
        :label="$t( titleLabel ? titleLabel : type )"
        @update:model-value="$emit('input-title', $event)"
        :bg-color="titleBackgroundColor ? titleBackgroundColor : undefined"
        :error-messages="titleErrorMessages"
        :variant="fieldVariant"
      ></v-text-field>
    </v-col>
    <v-col cols="12" md="4" v-if="!hideSubtitle">
      <v-text-field
        :model-value="subtitle"
        :label="$t( subtitleLabel ? subtitleLabel : 'Subtitle' )"
        @update:model-value="$emit('input-subtitle', $event)"
        :variant="fieldVariant"
      ></v-text-field>
    </v-col>
 
    <v-col cols="2" v-if="multilingual || actions.length">
     
      <v-row>
        <v-col v-if="multilingual" cols="6">
          <v-btn @click="$refs.langdialog.open()" variant="text">
            <span>
              ({{ language ? language : '--' }})
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

      <select-language ref="langdialog" @language-selected="$emit('input-language', $event)"></select-language>

    </v-col>
  </v-row>
</template>

<script>
import { vocabulary } from '../../mixins/vocabulary'
import { fieldproperties } from '../../mixins/fieldproperties'
import SelectLanguage from '../select/SelectLanguage'

export default {
  name: 'p-i-title',
  mixins: [vocabulary, fieldproperties],
  components: {
    SelectLanguage
  },
  computed: {
    instanceconfig: function () {
      return this.$store.state.instanceconfig
    }
  },
  props: {
    title: {
      type: String
    },
    titleErrorMessages: {
      type: Array
    },
    titleLabel: {
      type: String
    },
    type: {
      type: String
    },
    subtitle: {
      type: String
    },
    subtitleLabel: {
      type: String
    },
    hideSubtitle: {
      type: Boolean
    },
    language: {
      type: String
    },
    required: {
      type: Boolean
    },
    multilingual: {
      type: Boolean
    },
    showIds: {
      type: Boolean,
      default: false
    },
    titleBackgroundColor: {
      type: String,
      default: undefined
    }
  }
}
</script>

<style scoped>
.v-btn {
  margin: 0;
}
</style>
