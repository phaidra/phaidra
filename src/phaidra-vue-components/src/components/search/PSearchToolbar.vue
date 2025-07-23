<template lang="html">
  <v-container class="toolbar">
    <v-row>
      <v-col>
        <v-tooltip bottom>
          <template v-slot:activator="{ on, attrs }">
            <v-btn icon class="toolbar-btn" @click="setSort('title asc')" :color="sortIsActive('title asc') ? 'primary' : ''" v-on="on" v-bind="attrs" :aria-label="$t('Title ascending')">
              <icon width="16px" height="16px" name="fontello-sort-name-up"></icon>
            </v-btn>
          </template>
          <span>{{ $t('Title ascending')}}</span>
        </v-tooltip>
      </v-col>
      <v-col>
        <v-tooltip bottom>
          <template v-slot:activator="{ on, attrs }">
            <v-btn icon class="toolbar-btn" @click="setSort('title desc')" :color="sortIsActive('title desc') ? 'primary' : ''" v-on="on" v-bind="attrs" :aria-label="$t('Title descending')">
              <icon width="16px" height="16px" name="fontello-sort-name-down"></icon>
            </v-btn>
          </template>
          <span>{{ $t('Title descending')}}</span>
        </v-tooltip>
      </v-col>
      <v-col>
        <v-tooltip bottom>
          <template v-slot:activator="{ on, attrs }">
            <v-btn icon class="toolbar-btn" @click="setSort('created asc')" :color="sortIsActive('created asc') ? 'primary' : ''" v-on="on" v-bind="attrs" :aria-label="$t('Upload date ascending')">
              <icon width="16px" height="16px" name="fontello-sort-number-up"></icon>
            </v-btn>
          </template>
          <span>{{ $t('Upload date ascending')}}</span>
        </v-tooltip>
      </v-col>
      <v-col>
        <v-tooltip bottom>
          <template v-slot:activator="{ on, attrs }">
            <v-btn icon class="toolbar-btn" @click="setSort('created desc')" :color="sortIsActive('created desc') ? 'primary' : ''" v-on="on" v-bind="attrs" :aria-label="$t('Upload date descending')">
              <icon width="16px" height="16px" name="fontello-sort-number-down"></icon>
            </v-btn>
          </template>
          <span>{{ $t('Upload date descending')}}</span>
        </v-tooltip>
      </v-col>
      <v-col>
        <v-dialog v-model="linkdialog" max-width="800px">
          <v-card>
            <v-card-title class="title font-weight-light white--text mb-6">
              {{ $t('Link to search results') }}
            </v-card-title>
            <v-card-text>
              {{ link }}
              <v-tooltip bottom>
                <template v-slot:activator="{ on, attrs }">
                  <v-btn
                    v-on="on"
                    v-bind="attrs"
                    icon
                    @click="copyToClipboard()"
                    class="ml-1"
                    :aria-label="$t('Copy to clipboard')"
                  >
                    <v-icon>mdi-content-copy</v-icon>
                  </v-btn>
                </template>
                <span>{{ $t('Copy to clipboard') }}</span>
              </v-tooltip>
            </v-card-text>
            <v-divider></v-divider>
            <v-card-actions>
              <v-spacer></v-spacer>
              <v-btn outlined @click.stop="linkdialog=false">{{ $t("Close") }}</v-btn>
            </v-card-actions>
          </v-card>
        </v-dialog>
        <v-tooltip bottom>
          <template v-slot:activator="{ on, attrs }">
            <v-btn icon class="toolbar-btn" @click="linkdialog=true" v-on="on" v-bind="attrs" :aria-label="$t('Link to search results')">
              <icon width="18px" height="18px" name="material-content-link"></icon>
            </v-btn>
          </template>
          <span>{{ $t('Link to search results')}}</span>
        </v-tooltip>
      </v-col>
      <v-col v-if="signedin">
        <v-tooltip bottom>
          <template v-slot:activator="{ on, attrs }">
            <v-btn icon class="toolbar-btn" v-on="on" v-bind="attrs" :color="selectioncheck ? 'primary' : ''" @click.stop="toggleSelection()" :aria-label="$t('Select results')">
              <v-icon>mdi-bookmark-plus-outline</v-icon>
            </v-btn>
          </template>
          <span>{{ $t('Select results')}}</span>
        </v-tooltip>
      </v-col>
      <v-col>
        <v-tooltip bottom>
          <template v-slot:activator="{ on, attrs }">
            <v-btn icon class="toolbar-btn" v-on="on" v-bind="attrs" @click.native="csvExport()" :aria-label="$t('Download search results as a CSV file')">
              <v-icon>mdi-download</v-icon>
            </v-btn>
          </template>
          <span>{{ $t('Download search results as a CSV file') }}</span>
        </v-tooltip>
      </v-col>
    </v-row>
  </v-container>
</template>

<script>
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
  computed: {
    instance: function () {
      return this.$root.$store.state.instanceconfig
    }
  },
  data () {
    return {
      linkdialog: false
    }
  },
  methods: {
    copyToClipboard: function () {
      navigator.clipboard.writeText(this.link)
    }
  }
}
</script>

<style scoped>
.container .toolbar {
  padding: 0px;
}

.toolbar-btn.theme--light.v-btn:focus::before {
    opacity: 0.5;
    outline-style: auto;
}

.v-icon:focus::before {
  opacity: 0.7 !important;
}

.v-icon:focus::after {
  opacity: 0.7 !important;
}

</style>
