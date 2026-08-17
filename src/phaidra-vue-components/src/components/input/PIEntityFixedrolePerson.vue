<template>
  <v-row v-if="!hidden">
    <v-col :cols="12">
      <v-row>
        <v-col :cols="2">
          {{ roleLabel }}
        </v-col>
        <v-col :cols="4">
          <v-text-field
            :model-value="firstname"
            :label="$t(firstnameLabel ? firstnameLabel : 'Firstname')"
            @update:model-value="$emit('input-firstname', $event)"
            :variant="fieldVariant"
            :error-messages="firstnameErrorMessages"
          ></v-text-field>
        </v-col>
        <v-col :cols="4">
          <v-text-field
            :model-value="lastname"
            :label="$t(lastnameLabel ? lastnameLabel : 'Lastname')"
            @update:model-value="$emit('input-lastname', $event)"
            :variant="fieldVariant"
            :error-messages="lastnameErrorMessages"
          ></v-text-field>
        </v-col>
        <v-col v-if="multiplicable" :cols="2">
          <v-icon-btn @click="$emit('add', $event)" icon="mdi-plus" />
          <v-icon-btn @click="$emit('remove', $event)" icon="mdi-minus" />  
        </v-col>
      </v-row>
    </v-col>
  </v-row>
</template>

<script>
import { useVocabularyStore } from '../../stores/vocabulary'
import { vocabulary } from '../../mixins/vocabulary'
import { fieldproperties } from '../../mixins/fieldproperties'
import { validationrules } from '../../mixins/validationrules'

export default {
  name: 'p-i-entity-fixedrole-person',
  mixins: [vocabulary, fieldproperties, validationrules],
  props: {
    firstname: {
      type: String
    },
    lastname: {
      type: String
    },
    roleLabel: {
      type: String
    },
    firstnameLabel: {
      type: String
    },
    lastnameLabel: {
      type: String
    },
    role: {
      type: String
    },
    roleVocabulary: {
      type: String,
      default: 'rolepredicate'
    },
    firstnameErrorMessages: {
      type: Array
    },
    lastnameErrorMessages: {
      type: Array
    }
  },
  mounted: function () {
    this.$nextTick(function () {
      this.loading = !this.vocabularies[this.roleVocabulary].loaded
      useVocabularyStore().sortRoles(this.$i18n.locale)
      // emit input to set skos:prefLabel in parent
      if (this.role) {
        this.$emit('input', this.getTerm(this.roleVocabulary, this.role))
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
