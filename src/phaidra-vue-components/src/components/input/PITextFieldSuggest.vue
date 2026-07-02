<template>
  <v-row v-if="!hidden">
    <v-col cols="8">
      <v-combobox
        v-model="model"
        @update:model-value="(v) => $emit('input', xmlUtils.htmlToPlaintext(v == null ? '' : String(v)))"
        :items="items"
        :loading="loading"
        v-model:search="search"
        :required="required"
        :rules="required ? [ v => !!v || $t('Required')] : []"
        cache-items
        hide-no-data
        hide-selected
        :label="$t(label)"
        :variant="fieldVariant"
        clearable
      >
        <template #item="{ props, internalItem }">
          <v-list-item v-bind="props" lines="one">
            <template #title>
              <span v-html="internalItem.raw" />
            </template>
          </v-list-item>
        </template>
        <template #selection="{ internalItem }">
          {{ xmlUtils.htmlToPlaintext(internalItem.raw) }}
        </template>
      </v-combobox>
    </v-col>
    <v-col cols="1" v-if="multilingual || actions.length">
     
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

     <select-language ref="langdialog" @language-selected="$emit('input-language', $event)"></select-language>

   </v-col>
  </v-row>
</template>

<script>
import { vocabulary } from '../../mixins/vocabulary'
import { fieldproperties } from '../../mixins/fieldproperties'
import SelectLanguage from '../select/SelectLanguage'

export default {
  name: 'p-i-text-field-suggest',
  mixins: [vocabulary, fieldproperties],
  components: {
    SelectLanguage
  },
  emits: ['input', 'input-language', 'add', 'remove', 'configure', 'add-clear', 'up', 'down'],
  props: {
    value: {
      type: String,
      required: true
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
    suggester: {
      type: String,
      required: true
    },
    debounce: {
      type: Number,
      default: 500
    },
    showIds: {
      type: Boolean,
      default: false
    }
  },
  data () {
    return {
      items: [],
      loading: false,
      model: this.value,
      search: null
    }
  },
  watch: {
    search (val) {
      val && this.querySuggestionsDebounce(val)
    }
  },
  methods: {
    querySuggestionsDebounce (value) {
      this.showList = true

      if (this.debounce) {
        if (this.debounceTask !== undefined) clearTimeout(this.debounceTask)
        this.debounceTask = setTimeout(() => {
          return this.querySuggestions(value)
        }, this.debounce)
      } else {
        return this.querySuggestions(value)
      }
    },
    querySuggestions: async function (q) {
      if (q.length < this.min || !this.suggester) return

      this.loading = true

      var params = {
        suggest: true,
        'suggest.dictionary': this.suggester,
        wt: 'json',
        'suggest.q': q
      }

      try {
        let response = await this.$axios.request({
          method: 'GET',
          url: this.$store.state.instanceconfig.solr + '/suggest',
          params: params
        })
        this.items = []
        for (var i = 0; i < response.data.suggest[this.suggester][q].suggestions.length; i++) {
          this.items.push(response.data.suggest[this.suggester][q].suggestions[i].term)
        }
      } catch (error) {
        console.log(error)
      } finally {
        this.loading = false
      }
    }
  }

}
</script>

<style scoped>
.searchbox{
  font-size: 14px;
  box-sizing: border-box;
  border: none;
  box-shadow: none;
  outline: 0;
  background: 0 0;
  width: 100%;
  padding: 0 15px;
  line-height: 40px;
  height: 40px;
}

.autocomplete {
  position: absolute;
  z-index: 999;
  margin-top: 2px;
}
.v-btn {
  margin: 0;
}
</style>
