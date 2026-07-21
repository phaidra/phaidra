<template>

  <v-row v-if="!hidden">
    <v-col cols="12">
      <v-card variant="outlined" class="mb-8">
        <v-card-title class="text-h6 font-weight-light text-white">
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
        <v-divider></v-divider>
        <v-card-text class="mt-4">
          <v-row>
            <v-col>
              <v-row >
                <v-col cols="5">
                  <v-text-field
                    :model-value="title"
                    :label="$t('Title')"
                    @update:model-value="$emit('input-title', $event)"
                    :variant="fieldVariant"
                  ></v-text-field>
                </v-col>
                <v-col cols="5">
                  <v-text-field
                    :model-value="subtitle"
                    :label="$t('Subtitle')"
                    @update:model-value="$emit('input-subtitle', $event)"
                    :variant="fieldVariant"
                  ></v-text-field>
                </v-col>
                <v-col cols="2">
                  <v-btn variant="text" @click="$refs.langdialog.open()">
                    <span>
                      ({{ titleLanguage ? titleLanguage : '--'}})
                    </span>
                  </v-btn>
                  <select-language ref="langdialog" @language-selected="$emit('input-title-language', $event)"></select-language>
                </v-col>
              </v-row>
              <v-row>
                <v-col cols="4">
                  <v-autocomplete
                    :no-data-text="$t('No data available')"
                    :disabled="disablerole"
                    @update:model-value="$emit('input-role', $event)"
                    :label="$t('Role')"
                    :items="vocabularies['authoronlyrolepredicate'].terms"
                    :model-value="getTerm('authoronlyrolepredicate', role)"
                    :item-title="adaptationRoleItemTitle"
                    :custom-filter="vocabAutocompleteFilter"
                    :variant="fieldVariant"
                    return-object
                    clearable
                    item-value="@id"
                  >
                    <template #item="{ props, internalItem }">
                      <v-list-item v-bind="props" :lines="showIds ? 'two' : 'one'">
                        <template #title>
                          <span v-html="`${getLocalizedTermLabel('rolepredicate', internalItem.raw['@id'])}`" />
                        </template>
                        <template v-if="showIds" #subtitle>
                          <span v-html="internalItem.raw['@id']" />
                        </template>
                      </v-list-item>
                    </template>
                    <template #selection="{ internalItem }">
                      <span v-html="`${getLocalizedTermLabel('rolepredicate', (internalItem.raw || internalItem)['@id'])}`" />
                    </template>
                  </v-autocomplete>
                </v-col>
                <template v-if="showname">
                  <v-col cols="4" >
                    <v-text-field
                      :model-value="name"
                      :label="$t('Name')"
                      @update:model-value="$emit('input-name', $event)"
                      :variant="fieldVariant"
                    ></v-text-field>
                  </v-col>
                </template>
                <template v-else>
                  <v-col cols="4">
                    <v-text-field
                      :model-value="firstname"
                      :label="$t('Firstname')"
                      @update:model-value="$emit('input-firstname', $event)"
                      :variant="fieldVariant"
                    ></v-text-field>
                  </v-col>
                  <v-col cols="4">
                    <v-text-field
                      :model-value="lastname"
                      :label="$t('Lastname')"
                      @update:model-value="$emit('input-lastname', $event)"
                      :variant="fieldVariant"
                    ></v-text-field>
                  </v-col>
                </template>
              </v-row>
            </v-col>
          </v-row>
        </v-card-text>
      </v-card>
    </v-col>
  </v-row>
</template>

<script>
import { vocabulary } from '../../mixins/vocabulary'
import { fieldproperties } from '../../mixins/fieldproperties'
import SelectLanguage from '../select/SelectLanguage'

export default {
  name: 'p-i-adaptation',
  mixins: [vocabulary, fieldproperties],
  components: {
    SelectLanguage
  },
  props: {
    type: {
      type: String
    },
    label: {
      type: String
    },
    title: {
      type: String
    },
    subtitle: {
      type: String
    },
    titleLanguage: {
      type: String
    },
    firstname: {
      type: String
    },
    lastname: {
      type: String
    },
    name: {
      type: String
    },
    role: {
      type: String
    },
    disablerole: {
      type: Boolean,
      default: false
    },
    showname: {
      type: Boolean,
      default: false
    },
    showIds: {
      type: Boolean,
      default: false
    }
  },
  methods: {
    adaptationRoleItemTitle (item) {
      const raw = item?.raw !== undefined ? item.raw : item
      if (!raw || !raw['@id']) return ''
      const s = this.getLocalizedTermLabel('rolepredicate', raw['@id'])
      return typeof s === 'string' ? s.replace(/<[^>]+>/g, '') : String(s || '')
    }
  }
}
</script>

<style scoped>
.v-btn {
  margin: 0;
}
.vertical-center {
 align-items: center;
}
</style>
