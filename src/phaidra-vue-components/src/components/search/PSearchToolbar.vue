<template lang="html">
  <v-container class="toolbar">
    <v-row>
      <v-col>
        <v-tooltip location="bottom">
          <template v-slot:activator="{ props: activatorProps }">
            <v-icon-btn
              class="toolbar-btn"
              variant="text"
              :color="sortIsActive('title asc') ? 'primary' : undefined"
              @click="setSort('title asc')"
              v-bind="activatorProps"
              :aria-label="$t('Title ascending')"
            >
              <icon width="16px" height="16px" name="fontello-sort-name-up"></icon>
            </v-icon-btn>
          </template>
          <span>{{ $t('Title ascending')}}</span>
        </v-tooltip>
      </v-col>
      <v-col>
        <v-tooltip location="bottom">
          <template v-slot:activator="{ props: activatorProps }">
            <v-icon-btn
              class="toolbar-btn"
              variant="text"
              :color="sortIsActive('title desc') ? 'primary' : undefined"
              @click="setSort('title desc')"
              v-bind="activatorProps"
              :aria-label="$t('Title descending')"
            >
              <icon width="16px" height="16px" name="fontello-sort-name-down"></icon>
            </v-icon-btn>
          </template>
          <span>{{ $t('Title descending')}}</span>
        </v-tooltip>
      </v-col>
      <v-col>
        <v-tooltip location="bottom">
          <template v-slot:activator="{ props: activatorProps }">
            <v-icon-btn
              class="toolbar-btn"
              variant="text"
              :color="sortIsActive('created asc') ? 'primary' : undefined"
              @click="setSort('created asc')"
              v-bind="activatorProps"
              :aria-label="$t('Upload date ascending')"
            >
              <icon width="16px" height="16px" name="fontello-sort-number-up"></icon>
            </v-icon-btn>
          </template>
          <span>{{ $t('Upload date ascending')}}</span>
        </v-tooltip>
      </v-col>
      <v-col>
        <v-tooltip location="bottom">
          <template v-slot:activator="{ props: activatorProps }">
            <v-icon-btn
              class="toolbar-btn"
              variant="text"
              :color="sortIsActive('created desc') ? 'primary' : undefined"
              @click="setSort('created desc')"
              v-bind="activatorProps"
              :aria-label="$t('Upload date descending')"
            >
              <icon width="16px" height="16px" name="fontello-sort-number-down"></icon>
            </v-icon-btn>
          </template>
          <span>{{ $t('Upload date descending')}}</span>
        </v-tooltip>
      </v-col>
      <v-col>
        <v-dialog v-model="linkdialog" max-width="800px">
          <v-card>
            <v-card-title class="text-title-large font-weight-light text-white mb-6">
              {{ $t('Link to search results') }}
            </v-card-title>
            <v-card-text>
              {{ link }}
              <v-tooltip location="bottom">
                <template v-slot:activator="{ props: activatorProps }">
                  <v-icon-btn
                    v-bind="activatorProps"
                    icon="mdi-content-copy"
                    @click="copyToClipboard()"
                    @blur="resetCopyTooltip()"
                    class="ml-1"
                    :aria-label="$t('Copy to clipboard')"
                  />
                </template>
                <span>{{ $t(getCopyTooltipText('search-link')) }}</span>
              </v-tooltip>
            </v-card-text>
            <v-divider></v-divider>
            <v-card-actions>
              <v-spacer></v-spacer>
              <v-btn variant="outlined" @click.stop="linkdialog=false">{{ $t("Close") }}</v-btn>
            </v-card-actions>
          </v-card>
        </v-dialog>
        <v-tooltip location="bottom">
          <template v-slot:activator="{ props: activatorProps }">
            <v-icon-btn class="toolbar-btn" @click="linkdialog=true" v-bind="activatorProps" :aria-label="$t('Link to search results')">
              <icon width="18px" height="18px" name="material-content-link"></icon>
            </v-icon-btn>
          </template>
          <span>{{ $t('Link to search results')}}</span>
        </v-tooltip>
      </v-col>
      <v-col v-if="signedin">
        <v-tooltip location="bottom">
          <template v-slot:activator="{ props: activatorProps }">
            <v-icon-btn
              class="toolbar-btn"
              variant="text"
              v-bind="activatorProps"
              :color="selectioncheck ? 'primary' : undefined"
              @click.stop="toggleSelection()"
              :aria-label="$t('Select results')"
              icon="mdi-bookmark-plus-outline"
            />
          </template>
          <span>{{ $t('Select results')}}</span>
        </v-tooltip>
      </v-col>
      <v-col>
        <v-tooltip location="bottom">
          <template v-slot:activator="{ props: activatorProps }">
            <v-icon-btn class="toolbar-btn" v-bind="activatorProps" icon="mdi-download" @click="csvExport()" :aria-label="$t('Download search results as a CSV file')" />
          </template>
          <span>{{ $t('Download search results as a CSV file') }}</span>
        </v-tooltip>
      </v-col>
    </v-row>
  </v-container>
</template>

<script>
import copyTooltip from '../../mixins/copyTooltip'

export default {
  name: 'p-search-toolbar',
  props: {
    signedin: {
      type: Number,
      default: 0
    },
    setSort: {
      type: Function,
      required: true
    },
    sortIsActive: {
      type: Function,
      required: true
    },
    link: {
      type: String
    },
    toggleSelection: {
      type: Function,
      required: true
    },
    selectioncheck: Boolean,
    csvExport: Function
  },
  mixins: [copyTooltip],
  computed: {
    instance: function () {
      return this.$store.state.instanceconfig
    }
  },
  data () {
    return {
      linkdialog: false
    }
  },
  methods: {
    copyToClipboard () {
      this.copyWithTooltip(this.link, 'search-link')
    }
  }
}
</script>

<style scoped>
.v-container .toolbar {
  padding: 0px;
}

.toolbar-btn.v-icon-btn:focus-visible {
  outline-style: auto;
  outline-offset: 2px;
}

</style>
