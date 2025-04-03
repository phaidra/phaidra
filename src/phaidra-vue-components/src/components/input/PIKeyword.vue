<template>
  <v-row v-if="!hidden">
    <v-col cols="12" :md="multilingual ? (actions.length ? 8 : 10) : (actions.length ? 10 : 12)">
      <v-combobox
        v-model="model"
        v-on:input="onInput($event)"
        v-on:change="onInput($event)"
        :items="items"
        :loading="loading"
        :search-input.sync="disableSuggest ? null : search"
        :required="required"
        :rules="required ? [ v => !!v || 'Required'] : []"
        hide-no-data
        :item-text="'term'"
        :item-value="'payload'"
        :label="$t(label)"
        multiple
        clearable
        chips
        deletable-chips
        :filled="inputStyle==='filled'"
        :outlined="inputStyle==='outlined'"
        :error-messages="errorMessages"
        :hint="$t(hint)"
      >
        <template slot="item" slot-scope="{ item }">
          <v-list-item-content two-line>
            <v-list-item-title inset v-html="item.term"></v-list-item-title>
          </v-list-item-content>
        </template>
        <template
          slot="selection"
          slot-scope="data"
        >
          <v-chip
            close
            :input-value="data.selected"
            :disabled="data.disabled"
            class="v-chip--select-multi"
            @click:close="removeKeyword(data.item)"
          >
            {{ htmlToPlaintext(data.item) }}
          </v-chip>
        </template>
      </v-combobox>
    </v-col>
    <v-col cols="12" md="2" v-if="multilingual || actions.length">
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
import xmlUtils from '../../utils/xml'
import arrayUtils from '../../utils/arrays'
import SelectLanguage from '../select/SelectLanguage'

export default {
  name: 'p-i-keyword',
  mixins: [vocabulary, fieldproperties],
  components: {
    SelectLanguage
  },
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
    },
    disableSuggest: {
      type: Boolean,
      default: false
    },
    hint: {
      type: String
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
    },
    value: {
      handler: function (val) {
        this.model = this.value
      },
      deep: true
    }
  },
  methods: {
    onInput (value) {
      let arr = []
      for (let v of value) {
        if (v.payload) {
          arr.push(v.payload)
        } else {
          arr.push(v)
        }
      }
      this.$emit('input', arr)
    },
    removeKeyword (keyword) {
      arrayUtils.remove(this.model, keyword)
    },
    htmlToPlaintext (html) {
      return xmlUtils.htmlToPlaintext(html)
    },
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
          this.items.push(response.data.suggest[this.suggester][q].suggestions[i])
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
.v-btn {
  margin: 0;
}
</style>
