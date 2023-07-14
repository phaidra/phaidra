<template>
  <v-row v-if="!hidden">
    <v-col cols="8">
      <v-combobox
        v-model="model"
        v-on:input="$emit('input', xmlUtils.htmlToPlaintext($event))"
        v-on:change="$emit('input', xmlUtils.htmlToPlaintext($event))"
        :items="items"
        :loading="loading"
        :search-input.sync="search"
        :required="required"
        :rules="required ? [ v => !!v || 'Required'] : []"
        cache-items
        hide-no-data
        hide-selected
        item-text="text"
        item-value="value"
        :label="$t(label)"
        :filled="inputStyle==='filled'"
        :outlined="inputStyle==='outlined'"
        clearable
      >
        <template slot="item" slot-scope="{ item }">
          <v-list-item-content two-line>
            <v-list-item-title inset v-html="item"></v-list-item-title>
          </v-list-item-content>
        </template>
        <template slot="selection" slot-scope="{ item }">
          <v-list-item-content>
            <v-list-item-title inset>{{ xmlUtils.htmlToPlaintext(item) }}</v-list-item-title>
          </v-list-item-content>
        </template>
      </v-combobox>
    </v-col>
    <v-col cols="2" v-if="multilingual">
      <v-autocomplete
        :value="getTerm('lang', language)"
        v-on:input="$emit('input-language', $event )"
        :items="vocabularies['lang'].terms"
        :item-value="'@id'"
        :filter="autocompleteFilter"
        hide-no-data
        :label="$t('Language')"
        :filled="inputStyle==='filled'"
        :outlined="inputStyle==='outlined'"
        return-object
        clearable
      >
        <template slot="item" slot-scope="{ item }">
          <v-list-item-content two-line>
            <v-list-item-title  v-html="`${getLocalizedTermLabel('lang', item['@id'])}`"></v-list-item-title>
            <v-list-item-subtitle v-if="showIds" v-html="`${item['@id']}`"></v-list-item-subtitle>
          </v-list-item-content>
        </template>
        <template slot="selection" slot-scope="{ item }">
          <v-list-item-content>
            <v-list-item-title v-html="`${getLocalizedTermLabel('lang', item['@id'])}`"></v-list-item-title>
          </v-list-item-content>
        </template>
      </v-autocomplete>
    </v-col>
    <v-col cols="1" v-if="actions.length">
      <v-menu open-on-hover bottom offset-y>
        <template v-slot:activator="{ on }">
          <v-btn v-on="on" icon>
            <v-icon>mdi-dots-vertical</v-icon>
          </v-btn>
        </template>
        <v-list>
          <v-list-item v-for="(action, i) in actions" :key="i" @click="$emit(action.event, $event)">
            <v-list-item-title>{{ action.title }}</v-list-item-title>
          </v-list-item>
        </v-list>
      </v-menu>
    </v-col>
  </v-row>
</template>

<script>
import { vocabulary } from '../../mixins/vocabulary'
import { fieldproperties } from '../../mixins/fieldproperties'

export default {
  name: 'p-i-text-field-suggest',
  mixins: [vocabulary, fieldproperties],
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
