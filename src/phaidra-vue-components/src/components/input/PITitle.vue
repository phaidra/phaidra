<template>
  

  <v-row v-if="!hidden">
    <v-col cols="12" :md="hideSubtitle ? ( (multilingual || actions.length) ? 8 : 12 ) : ( (multilingual || actions.length) ? 4 : 8 )">
      <v-text-field
        :value="title"
        :label="$t( titleLabel ? titleLabel : type )"
        v-on:blur="$emit('input-title',$event.target.value)"
        :background-color="titleBackgroundColor ? titleBackgroundColor : undefined"
        :error-messages="titleErrorMessages"
        :filled="inputStyle==='filled'"
        :outlined="inputStyle==='outlined'"
      ></v-text-field>
    </v-col>
    <v-col cols="12" md="4" v-if="!hideSubtitle">
      <v-text-field
        :value="subtitle"
        :label="$t( subtitleLabel ? subtitleLabel : 'Subtitle' )"
        v-on:blur="$emit('input-subtitle',$event.target.value)"
        :filled="inputStyle==='filled'"
        :outlined="inputStyle==='outlined'"
      ></v-text-field>
    </v-col>
 
    <v-col cols="2" v-if="multilingual || actions.length">
     
      <v-row>
        <v-col v-if="multilingual" cols="6">
          <v-btn text @click="$refs.langdialog.open()">
            <span>
              ({{ language ? language : '--' }})
            </span>
          </v-btn>
        </v-col>
        <v-col cols="6" v-if="actions.length">
          <v-btn icon @click="showMenu">
            <v-icon>mdi-dots-vertical</v-icon>
          </v-btn>
        </v-col>
      </v-row>
        
      <v-menu :position-x="menux" :position-y="menuy" absolute offset-y v-model="showMenuModel">
        <v-list>
          <v-list-item v-for="(action, i) in actions" :key="i" @click="$emit(action.event, $event)">
            <v-list-item-title>{{ action.title }}</v-list-item-title>
          </v-list-item>
        </v-list>
      </v-menu>

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
      return this.$root.$store.state.instanceconfig
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
