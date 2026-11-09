<template>
  <v-col cols="12">
    <v-checkbox
      class="mt-0 check"
      v-model="isChecked"
      :required="required"
      :rules="required ? [ v => v === true || $t('Required')] : []"
      :error-messages="errorMessages"
    >
      <template #label>
        <i18n-t :keypath="labelMessageId" tag="span" class="text-black">
          <a
            @click.stop
            :href="link"
            target="_blank"
            rel="noopener noreferrer"
          >{{ $t(linkLabelMessageId) }}</a>
        </i18n-t>
        <span v-if="required"> *</span>
      </template>
    </v-checkbox>
  </v-col>
</template>

<script>
import { vocabulary } from '../../mixins/vocabulary'
import { fieldproperties } from '../../mixins/fieldproperties'

export default {
  name: 'p-i-note-checkbox-with-link',
  mixins: [vocabulary, fieldproperties],
  emits: ['input', 'configure', 'add', 'remove', 'add-clear', 'up', 'down'],
  props: {
    labelMessageId: {
      type: String,
      required: true
    },
    linkLabelMessageId: {
      type: String,
      required: true
    },
    link: {
      type: String,
      required: true
    },
    note: {
      type: String,
      required: true
    },
    checked: {
      type: Boolean,
      default: false
    },
    value: {
      type: [String, Boolean],
      default: ''
    },
    errorMessages: {
      type: Array
    },
    language: {
      type: String
    },
    required: {
      type: Boolean,
      default: false
    }
  },
  computed: {
    isChecked: {
      get () {
        return this.checked === true || this.value === this.note || this.value === true
      },
      set (checked) {
        this.$emit('input', checked === true)
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
