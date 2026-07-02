<template>
  <v-row v-if="!hidden">
    <v-col :cols="actions.length ? 10 : 12">
      <v-text-field
        :model-value="value"
        :label="$t('Filename')"
        @update:model-value="$emit('input-value', $event)"
        :variant="fieldVariant"
      ></v-text-field>
    </v-col>
    <v-col cols="2" v-if="actions.length">
      <v-menu location="bottom end" close-on-content-click>
        <template #activator="{ props: menuActivatorProps }">
          <v-icon-btn v-bind="menuActivatorProps" icon="mdi-dots-vertical" />
        </template>
        <v-list density="compact">
          <v-list-item v-for="(action, i) in actions" :key="i" @click="$emit(action.event)">
            <v-list-item-title>{{ action.title }}</v-list-item-title>
          </v-list-item>
        </v-list>
      </v-menu>
    </v-col>
  </v-row>
</template>

<script>
import { fieldproperties } from '../../mixins/fieldproperties'

export default {
  name: 'p-i-filename',
  mixins: [fieldproperties],
  props: {
    value: {
      type: String
    },
    label: {
      type: String,
      required: true
    }
  }
}
</script>

<style scoped>
.v-btn {
  margin: 0;
}
</style>
