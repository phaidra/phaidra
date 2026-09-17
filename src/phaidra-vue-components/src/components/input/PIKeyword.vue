<template>
  <v-row v-if="!hidden">
    <v-col cols="12" :md="multilingual ? (actions.length ? 8 : 10) : (actions.length ? 10 : 12)">
      <v-combobox
        v-model="model"
        v-model:search="search"
        @keydown.enter.capture="onKeywordEnter"
        @update:model-value="onInput"
        :items="items"
        :loading="loading"
        :required="required"
        :rules="required ? [ v => !!v || $t('Required')] : []"
        hide-no-data
        item-title="term"
        item-value="payload"
        :label="composedLabel"
        multiple
        :disabled="disabled"
        clearable
        chips
        closable-chips
        :variant="fieldVariant"
        :error-messages="combinedErrorMessages"
        :hint="$t(hint)"
      >
        <template #item="{ props, internalItem }">
          <v-list-item v-bind="props" lines="one">
            <template #title>
              <span v-html="internalItem.raw.term" />
            </template>
          </v-list-item>
        </template>
        <template #chip="{ item, props: chipProps }">
          <v-chip v-bind="chipProps" @click:close="removeKeyword(resolveChipValue(item))">
            {{ htmlToPlaintext(resolveChipLabel(item)) }}
          </v-chip>
        </template>
      </v-combobox>
    </v-col>
    <v-col cols="12" md="2" v-if="multilingual || actions.length">
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

      <select-language ref="langdialog" @language-selected="$emit('input-language', $event)"></select-language>
    </v-col>
  </v-row>
</template>

<script>
import { useHostRootStore as useRootStore } from '../../stores/host-root'
import { vocabulary } from '../../mixins/vocabulary'
import { fieldproperties } from '../../mixins/fieldproperties'
import xmlUtils from '../../utils/xml'
import arrayUtils from '../../utils/arrays'
import { resolveKeywordMaxLength } from '../../utils/keywordMaxLength'
import SelectLanguage from '../select/SelectLanguage'

export default {
  name: 'p-i-keyword',
  mixins: [vocabulary, fieldproperties],
  components: {
    SelectLanguage
  },
  emits: ['input', 'input-language', 'add', 'remove', 'configure', 'add-clear', 'up', 'down'],
  props: {
    value: {
      type: Array,
      required: true
    },
    errorMessages: {
      type: Array
    },
    language: {
      type: String
    },
    label: {
      type: String,
      required: true
    },
    required: {
      type: Boolean
    },
    multilingual: {
      type: Boolean
    },
    debounce: {
      type: Number,
      default: 500
    },
    showIds: {
      type: Boolean,
      default: false
    },
    hint: {
      type: String
    },
    disabled: {
      type: Boolean,
      default: false
    }
  },
  data () {
    return {
      items: [],
      loading: false,
      model: this.value,
      search: null,
      lengthErrorMessages: []
    }
  },
  computed: {
    keywordMaxLength () {
      return resolveKeywordMaxLength(useRootStore().instanceconfig)
    },
    composedLabel () {
      return this.$t(this.label) + ' (' + this.$t('Confirm each keyword with enter, max {max} characters', { max: this.keywordMaxLength }) + ')'
    },
    combinedErrorMessages () {
      return [...(this.errorMessages || []), ...this.lengthErrorMessages]
    }
  },
  watch: {
    value: {
      handler: function (val) {
        this.model = this.value
      },
      deep: true
    }
  },
  methods: {
    onKeywordEnter (e) {
      if (String(this.search || '').length <= this.keywordMaxLength) return
      e.preventDefault()
      e.stopPropagation()
      this.lengthErrorMessages = [this.$t('Each keyword must be at most {max} characters.', { max: this.keywordMaxLength })]
    },
    onInput (value) {
      let arr = []
      for (let v of value) {
        if (v && typeof v === 'object') {
          if (v.payload !== undefined) {
            arr.push(v.payload)
            continue
          }
          if (v.value !== undefined && typeof v.value !== 'object') {
            arr.push(v.value)
            continue
          }
          if (v.raw !== undefined) {
            arr.push(v.raw)
            continue
          }
        }
        arr.push(v)
      }
      this.lengthErrorMessages = []
      this.$emit('input', arr)
    },
    resolveChipValue (chipItem) {
      if (!chipItem || typeof chipItem !== 'object') return chipItem
      if (chipItem.raw !== undefined) return chipItem.raw
      if (chipItem.value !== undefined) return chipItem.value
      return chipItem
    },
    resolveChipLabel (chipItem) {
      const value = this.resolveChipValue(chipItem)
      if (value && typeof value === 'object') {
        if (value.term != null) return value.term
        if (value.title != null) return value.title
        if (typeof value.value !== 'object' && value.value != null) return value.value
      }
      return value
    },
    removeKeyword (keyword) {
      arrayUtils.remove(this.model, keyword)
    },
    htmlToPlaintext (html) {
      return xmlUtils.htmlToPlaintext(html)
    }
  }

}
</script>

<style scoped>
.v-btn {
  margin: 0;
}
</style>
