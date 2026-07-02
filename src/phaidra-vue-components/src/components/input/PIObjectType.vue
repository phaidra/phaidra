<template>
  <div v-if="!hidden">
    <v-alert v-if="errorMessages && errorMessages.length > 0" type="error" variant="tonal" transition="slide-y-transition">
      <span v-for="(em, i) in errorMessages" :key="'em'+i">{{ em }}<br/></span>
    </v-alert>
    <v-card variant="outlined" class="mt-4 mb-8">
      <v-card-title v-if="showLabel" class="title font-weight-light text-white">
        <span>{{ $t(label) }}</span>
        <v-spacer></v-spacer>
        <v-menu open-on-hover bottom offset-y v-if="actions.length">
          <template v-slot:activator="{ props: activatorProps }">
            <v-icon-btn v-bind="activatorProps" variant="text" color="white" icon="mdi-dots-vertical" />
          </template>
          <v-list>
            <v-list-item v-for="(action, i) in actions" :key="i" @click="$emit(action.event, $event)">
              <v-list-item-title>{{ action.title }}</v-list-item-title>
            </v-list-item>
          </v-list>
        </v-menu>
      </v-card-title>
      <v-card-text class="mt-4">
        <v-row no-gutters>
          <v-col cols="12" :md="terms.length <= 6 ? 12 : 6" v-for="(term, i) in terms" :key="'ot'+i">
            <v-checkbox
              class="mt-0 check"
              v-model="checkboxes[term['@id']]"
              :label="getLocalizedTermLabel(vocabulary, term['@id'])"
              :key="'chot'+i"
            ></v-checkbox>
            <v-spacer></v-spacer>
          </v-col>
        </v-row>
      </v-card-text>
    </v-card>
  </div>
</template>

<script>
import { vocabulary } from '../../mixins/vocabulary'
import { fieldproperties } from '../../mixins/fieldproperties'

export default {
  name: 'p-i-object-type',
  mixins: [vocabulary, fieldproperties],
  emits: ['input', 'configure', 'add', 'remove', 'add-clear', 'up', 'down'],
  props: {
    label: {
      type: String,
      required: true
    },
    showLabel: {
      type: Boolean,
      default: true
    },
    vocabulary: {
      type: String,
      required: true
    },
    resourceType: {
      type: String
    },
    ot4rt: {
      type: Object
    },
    errorMessages: {
      type: Array
    },
    selectedTerms: {
      type: Array
    }
  },
  watch: {
    checkboxes: {
      deep: true,
      handler (val) {
        this.$emit('input', val)
      }
    },
    resourceType () {
      this.checkboxes = {}
      this.$emit('input', this.checkboxes)
    },
    selectedTerms: {
      handler: function (newVal) {
        if (!newVal || newVal.length === 0) {
          return
        }
        
        this.$nextTick(() => {
          // Only update checkboxes that aren't already set correctly
          let hasChanges = false
          for (let term of newVal) {
            if (term.value && !this.checkboxes[term.value]) {
              Vue.set(this.checkboxes, term.value, true)
              hasChanges = true
            }
          }
          if (hasChanges) {
            this.$emit('input', this.checkboxes)
          }
        })
      },
      deep: true
    }
  },
  computed: {
    terms: function () {
      if (this.vocabulary === 'uniakobjecttypetheses' || this.vocabulary === 'oerobjecttype') {
        return this.vocabularies[this.vocabulary].terms
      } else {
        return this.resourceType ? this.$store.getters['vocabulary/getObjectTypeForResourceType'](this.resourceType, this.$i18n.locale, this.ot4rt) : this.vocabularies[this.vocabulary].terms
      }
    }
  },
  data () {
    return {
      checkboxes: {},
      key: 0
    }
  },
  mounted: function () {
    if (this.resourceType) {
      this.$store.getters['vocabulary/getObjectTypeForResourceType'](this.resourceType, this.$i18n.locale)
    }
    this.$nextTick(() => {
      if (!this.selectedTerms || !this.selectedTerms.length) return
      const next = { ...this.checkboxes }
      for (const t of this.selectedTerms) {
        if (t.value) next[t.value] = true
      }
      this.checkboxes = next
    })
  }
}
</script>

<style scoped>
.check {
  min-width: 220px;
}
</style>
