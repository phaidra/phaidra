<template>
  <v-row v-if="!hidden">
    <v-col cols="5" v-if="!hideType">
      <v-autocomplete
        :no-data-text="$t('No data available')"
        @update:model-value="$emit('input-date-type', $event)"
        :label="$t('Type of date')"
        :items="vocabularies['datepredicate'].terms"
        item-value="@id"
        :item-title="(item) => skosTermItemTitle(item, 'datepredicate')"
        :model-value="getTerm('datepredicate', type)"
        :custom-filter="vocabAutocompleteFilter"
        :variant="fieldVariant"
        return-object
        clearable
        :error-messages="typeErrorMessages"
      >
        <template #item="{ props, internalItem }">
          <v-list-item v-bind="props" :lines="showIds ? 'two' : 'one'">
            <template #title>
              <span v-html="getLocalizedTermLabel('datepredicate', internalItem.raw['@id'])" />
            </template>
            <template v-if="showIds" #subtitle>
              <span v-html="internalItem.raw['@id']" />
            </template>
          </v-list-item>
        </template>
        <template #selection="{ internalItem }">
          <span v-html="getLocalizedTermLabel('datepredicate', (internalItem.raw || internalItem)['@id'])" />
        </template>
      </v-autocomplete>
    </v-col>
    <v-col :cols="hideType ? (actions.length ? 10 : 12) : (actions.length ? 5 : 7)">
      <template v-if="picker">
        <v-text-field
          :model-value="value"
          @update:model-value="$emit('input-date', $event)"
          :label="$t(dateLabel ? dateLabel : 'Date')"
          :bg-color="backgroundColor ? backgroundColor : undefined"
          :required="required"
          :rules="[validationrules.date]"
          :variant="fieldVariant"
          :error-messages="valueErrorMessages"
        >
          <template v-slot:append-inner>
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
                <template v-slot:activator="{ props: activatorProps }">
                  <v-icon v-bind="activatorProps">mdi-calendar</v-icon>
                </template>
                <v-date-picker
                  color="primary"
                  :show-current="false"
                  v-model="pickerModel"
                  :first-day-of-week="1"
                  :locale="alpha2bcp47($i18n.locale)"
                  @update:model-value="dateMenu = false; $emit('input-date', $event)"
                ></v-date-picker>
              </v-menu>
            </v-fade-transition>
          </template>
        </v-text-field>
      </template>
      <template v-else>
        <v-text-field
          :model-value="value"
          @update:model-value="$emit('input-date', $event)"
          :bg-color="backgroundColor ? backgroundColor : undefined"
          :label="$t(dateLabel ? dateLabel : 'Date')"
          :required="required"
          :hint="$t(dateFormatHint)"
          :rules="[validationrules.date]"
          :variant="fieldVariant"
          :error-messages="valueErrorMessages"
        >
          <template v-slot:append-inner>
            <v-tooltip bottom>
              <template v-slot:activator="{ props: activatorProps }">
                <v-icon v-bind="activatorProps">mdi-help-circle-outline</v-icon>
              </template>
              <span>{{ $t('EDTF Examples: 1984? (uncertain 1984), 1964/2008 (range), 2001-21 (Spring 2001), 156X (1560s), 2004-06~ (approximate June 2004), 1984-03-12% (uncertain and approximate date in 1984)') }}</span>
            </v-tooltip>
          </template>
        </v-text-field>
      </template>
    </v-col>
    <v-col cols="2" v-if="actions.length">
      <v-menu open-on-hover bottom offset-y>
        <template v-slot:activator="{ props: activatorProps }">
          <v-btn v-bind="activatorProps" icon variant="text">
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
import datepickerproperties from '../../mixins/datepickerproperties'
import { vocabulary } from '../../mixins/vocabulary'
import { fieldproperties } from '../../mixins/fieldproperties'
import { validationrules } from '../../mixins/validationrules'

export default {
  name: 'p-i-date-edtf',
  mixins: [vocabulary, fieldproperties, validationrules, datepickerproperties],
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
      default: 'Format: YYYY-MM-DD or EDTF (e.g. 1984~, 1964/2008, 2001-21)'
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
