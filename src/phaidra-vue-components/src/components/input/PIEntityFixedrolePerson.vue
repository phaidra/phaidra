<template>
  <v-row v-if="!hidden">
    <v-col :cols="12">
      <v-row>
        <v-col :cols="2">
          {{ roleLabel }}
        </v-col>
        <v-col :cols="4">
          <v-text-field
            :value="firstname"
            :label="$t(firstnameLabel ? firstnameLabel : 'Firstname')"
            v-on:blur="$emit('input-firstname',$event.target.value)"
            :filled="inputStyle==='filled'"
            :outlined="inputStyle==='outlined'"
            :error-messages="firstnameErrorMessages"
          ></v-text-field>
        </v-col>
        <v-col :cols="4">
          <v-text-field
            :value="lastname"
            :label="$t(lastnameLabel ? lastnameLabel : 'Lastname')"
            v-on:blur="$emit('input-lastname',$event.target.value)"
            :filled="inputStyle==='filled'"
            :outlined="inputStyle==='outlined'"
            :error-messages="lastnameErrorMessages"
          ></v-text-field>
        </v-col>
        <v-col v-if="multiplicable" :cols="2">
          <v-btn icon @click="$emit('add', $event)">
            <v-icon>mdi-plus</v-icon>
          </v-btn>
          <v-btn icon @click="$emit('remove', $event)">
            <v-icon>mdi-minus</v-icon>
          </v-btn>  
        </v-col>
      </v-row>
    </v-col>
  </v-row>
</template>

<script>
import { mask } from 'vue-the-mask'
import { vocabulary } from '../../mixins/vocabulary'
import { fieldproperties } from '../../mixins/fieldproperties'
import { validationrules } from '../../mixins/validationrules'

export default {
  name: 'p-i-entity-fixedrole-person',
  mixins: [vocabulary, fieldproperties, validationrules],
  directives: {
    mask
  },
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
      this.$store.dispatch('vocabulary/sortRoles', this.$i18n.locale)
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
