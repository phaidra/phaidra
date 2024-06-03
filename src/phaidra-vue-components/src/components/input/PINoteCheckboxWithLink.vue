<template>
  <v-row>
    <v-col cols="12">
      <v-checkbox class="mt-0 check" v-model="checkbox" @click.capture="$emit('input', note)">
        <template v-slot:label>
          <i18n :path="labelMessageId" tag="span" class="black--text">
            <a
              @click.stop
              :href="link"
              target="_blank"
              >{{ $t(linkLabelMessageId) }}</a
            ></i18n>
        </template>
      </v-checkbox>
    </v-col>
  </v-row>
</template>

<script>
import { vocabulary } from '../../mixins/vocabulary'
import { fieldproperties } from '../../mixins/fieldproperties'

export default {
  name: 'p-i-note-checkbox-with-link',
  mixins: [vocabulary, fieldproperties],
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
    errorMessages: {
      type: Array
    },
    language: {
      type: String
    }
  },
  data () {
    return {
      checkbox: false
    }
  }
}
</script>

<style scoped>
.v-btn {
  margin: 0;
}
</style>
