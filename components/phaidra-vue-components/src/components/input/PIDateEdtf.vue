<template>
  <v-row v-if="!hidden">
    <v-col cols="5" v-if="!hideType">
      <v-autocomplete
        v-on:input="$emit('input-date-type', $event)"
        :label="$t('Type of date')"
        :items="vocabularies['datepredicate'].terms"
        :item-value="'@id'"
        :value="getTerm('datepredicate', type)"
        :filter="autocompleteFilter"
        :filled="inputStyle==='filled'"
        :outlined="inputStyle==='outlined'"
        return-object
        clearable
        :error-messages="typeErrorMessages"
      >
        <template slot="item" slot-scope="{ item }">
          <v-list-item-content two-line>
            <v-list-item-title  v-html="`${getLocalizedTermLabel('datepredicate', item['@id'])}`"></v-list-item-title>
            <v-list-item-subtitle v-if="showIds" v-html="`${item['@id']}`"></v-list-item-subtitle>
          </v-list-item-content>
        </template>
        <template slot="selection" slot-scope="{ item }">
          <v-list-item-content>
            <v-list-item-title v-html="`${getLocalizedTermLabel('datepredicate', item['@id'])}`"></v-list-item-title>
          </v-list-item-content>
        </template>
      </v-autocomplete>
    </v-col>
    <v-col :cols="hideType ? (actions.length ? 10 : 12) : (actions.length ? 5 : 7)">
      <template v-if="picker">
        <v-text-field
          :value="value"
          v-on:blur="$emit('input-date',$event.target.value)"
          :label="$t(dateLabel ? dateLabel : 'Date')"
          :background-color="backgroundColor ? backgroundColor : undefined"
          :required="required"
          :rules="[validationrules.date]"
          :filled="inputStyle==='filled'"
          :outlined="inputStyle==='outlined'"
          :error-messages="valueErrorMessages"
        >
          <template v-slot:append>
            <v-fade-transition leave-absolute>
              <v-menu
                ref="menu1"
                v-model="dateMenu"
                :close-on-content-click="false"
                transition="scale-transition"
                offset-y
                max-width="290px"
                min-width="290px"
              >
                <template v-slot:activator="{ on }">
                  <v-icon v-on="on">mdi-calendar</v-icon>
                </template>
                <v-date-picker
                  color="primary"
                  :value="value"
                  :show-current="false"
                  v-model="pickerModel"
                  :locale="$i18n.locale === 'deu' ? 'de-AT' : 'en-GB' "
                  v-on:input="dateMenu = false; $emit('input-date', $event)"
                ></v-date-picker>
              </v-menu>
            </v-fade-transition>
          </template>
        </v-text-field>
      </template>
      <template v-else>
        <v-text-field
          :value="value"
          v-on:blur="$emit('input-date',$event.target.value)"
          :background-color="backgroundColor ? backgroundColor : undefined"
          :label="$t(dateLabel ? dateLabel : 'Date')"
          :required="required"
          :hint="dateFormatHint"
          :rules="[validationrules.date]"
          :filled="inputStyle==='filled'"
          :outlined="inputStyle==='outlined'"
          :error-messages="valueErrorMessages"
        ></v-text-field>
      </template>
    </v-col>
    <v-col cols="2" v-if="actions.length">
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
import { validationrules } from '../../mixins/validationrules'

export default {
  name: 'p-i-date-edtf',
  mixins: [vocabulary, fieldproperties, validationrules],
  props: {
    value: {
      type: String
    },
    dateLabel: {
      type: String
    },
    type: {
      type: String
    },
    hideType: {
      type: Boolean
    },
    required: {
      type: Boolean
    },
    picker: {
      type: Boolean
    },
    valueErrorMessages: {
      type: Array
    },
    typeErrorMessages: {
      type: Array
    },
    showIds: {
      type: Boolean,
      default: false
    },
    dateFormatHint: {
      type: String,
      default: 'Format YYYY-MM-DD'
    }
  },
  data () {
    return {
      pickerModel: new Date().toISOString().substr(0, 10),
      dateMenu: false
    }
  },
  mounted: function () {
    this.$nextTick(function () {
      this.loading = !this.vocabularies['datepredicate'].loaded
      // emit input to set skos:prefLabel in parent
      if (this.type) {
        this.$emit('input-date-type', this.getTerm('datepredicate', this.type))
      }
    })
  }
}
</script>

<style scoped>
.v-btn {
  margin: 0;
}
</style>
