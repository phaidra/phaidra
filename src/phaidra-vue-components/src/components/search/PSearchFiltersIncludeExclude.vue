<template>
  <div>
    <h3 class="text-title-small">{{ labelOf(facet) }}</h3>
    <p ref="summary" class="facet-summary" tabindex="-1">{{ includedCount }} {{ $t('Include') }} · {{ excludedCount }} {{ $t('Exclude') }}</p>
    <div v-if="selectedFilters.length" class="selected-filters">
      <v-chip
        v-for="item in selectedFilters"
        :key="item.key"
        class="ma-1"
        closable
        size="small"
        :color="item.excluded ? 'error' : 'primary'"
        variant="tonal"
        :aria-label="chipAriaLabel(item)"
        @click:close="clearSelected(item)"
      >
        {{ item.excluded ? '−' : '+' }} {{ item.label }}
      </v-chip>
    </div>
    <v-text-field
      v-model="filterText"
      class="my-2"
      :label="$t('Find type')"
      prepend-inner-icon="mdi-magnify"
      density="compact"
      variant="outlined"
      hide-details
      clearable
    />
    <ul class="searchFilters">
      <li v-for="(q, j) in facet.queries" v-show="isVisible(q, [])" :key="keyOf(q, j)">
        <div class="facet-row">
          <v-btn
            icon="mdi-plus"
            size="x-small"
            variant="text"
            :color="q.active ? 'primary' : undefined"
            :aria-pressed="q.active === true"
            :aria-label="actionLabel('Include', q)"
            @click="includeQuery(q)"
          />
          <v-btn
            icon="mdi-minus"
            size="x-small"
            variant="text"
            :color="q.excluded ? 'error' : undefined"
            :aria-pressed="q.excluded === true"
            :aria-label="actionLabel('Exclude', q)"
            @click="excludeQuery(q)"
          />
          <button
            v-if="hasChildren(q)"
            type="button"
            class="facet-toggle"
            :aria-expanded="isExpanded(keyOf(q, j))"
            :aria-controls="treeId(keyOf(q, j))"
            @click="toggle(keyOf(q, j))"
          >
            {{ labelOf(q) }}
          </button>
          <span v-else>{{ labelOf(q) }}</span>
          <span class="facet-count text-secondary font-weight-medium" v-if="q.count > 0">({{ q.count }})</span>
        </div>
        <ul v-if="hasChildren(q) && isExpanded(keyOf(q, j))" :id="treeId(keyOf(q, j))">
          <li v-for="(q1, k) in q.childFacet.queries" v-show="isVisible(q1, [q])" :key="keyOf(q1, k)">
            <div class="facet-row">
              <v-btn
                icon="mdi-plus"
                size="x-small"
                variant="text"
                :color="q1.active ? 'primary' : undefined"
                :aria-pressed="q1.active === true"
                :aria-label="actionLabel('Include', q1)"
                @click="includeQuery(q1)"
              />
              <v-btn
                icon="mdi-minus"
                size="x-small"
                variant="text"
                :color="q1.excluded ? 'error' : undefined"
                :aria-pressed="q1.excluded === true"
                :aria-label="actionLabel('Exclude', q1)"
                @click="excludeQuery(q1)"
              />
              <button
                v-if="hasChildren(q1)"
                type="button"
                class="facet-toggle"
                :aria-expanded="isExpanded(keyOf(q, j) + '/' + keyOf(q1, k))"
                :aria-controls="treeId(keyOf(q, j) + '/' + keyOf(q1, k))"
                @click="toggle(keyOf(q, j) + '/' + keyOf(q1, k))"
              >
                {{ labelOf(q1) }}
              </button>
              <span v-else>{{ labelOf(q1) }}</span>
              <span class="facet-count text-secondary font-weight-medium" v-if="q1.count > 0">({{ q1.count }})</span>
            </div>
            <ul v-if="hasChildren(q1) && isExpanded(keyOf(q, j) + '/' + keyOf(q1, k))" :id="treeId(keyOf(q, j) + '/' + keyOf(q1, k))">
              <li v-for="(q2, l) in q1.childFacet.queries" v-show="isVisible(q2, [q, q1])" :key="keyOf(q2, l)">
                <div class="facet-row">
                  <v-btn
                    icon="mdi-plus"
                    size="x-small"
                    variant="text"
                    :color="q2.active ? 'primary' : undefined"
                    :aria-pressed="q2.active === true"
                    :aria-label="actionLabel('Include', q2)"
                    @click="includeQuery(q2)"
                  />
                  <v-btn
                    icon="mdi-minus"
                    size="x-small"
                    variant="text"
                    :color="q2.excluded ? 'error' : undefined"
                    :aria-pressed="q2.excluded === true"
                    :aria-label="actionLabel('Exclude', q2)"
                    @click="excludeQuery(q2)"
                  />
                  <span>{{ labelOf(q2) }}</span>
                  <span class="facet-count text-secondary font-weight-medium" v-if="q2.count > 0">({{ q2.count }})</span>
                </div>
              </li>
            </ul>
          </li>
        </ul>
      </li>
    </ul>
  </div>
</template>

<script>
import { hasSelectedFacetQuery } from './facets'

export default {
  name: 'p-search-filters-include-exclude',
  props: {
    search: {
      type: Function,
      required: true
    },
    facet: {
      type: Object,
      required: true
    }
  },
  data () {
    return {
      open: {},
      filterText: ''
    }
  },
  computed: {
    selectedFilters () {
      const selected = []
      const walk = (queries, path, labels) => {
        (queries || []).forEach((query, index) => {
          const key = path + '/' + this.keyOf(query, index)
          const label = labels.concat(this.labelOf(query))
          if (query.active || query.excluded) {
            selected.push({ key, query, label: label.join(' → '), excluded: query.excluded === true })
          }
          walk(query.childFacet && query.childFacet.queries, key, label)
        })
      }
      walk(this.facet.queries, '', [])
      return selected
    },
    includedCount () {
      return this.selectedFilters.filter(item => !item.excluded).length
    },
    excludedCount () {
      return this.selectedFilters.filter(item => item.excluded).length
    }
  },
  watch: {
    facet: {
      handler: function () {
        this.openSelected(this.facet.queries, '')
      },
      immediate: true
    }
  },
  methods: {
    labelOf: function (item) {
      return this.$t(item && item.label ? item.label.toString() : '')
    },
    actionLabel: function (action, query) {
      return this.$t(action) + ' ' + this.labelOf(query)
    },
    chipAriaLabel: function (item) {
      return this.$t(item.excluded ? 'Exclude' : 'Include') + ': ' + item.label
    },
    keyOf: function (query, index) {
      return String(query.id || index)
    },
    treeId: function (key) {
      return 'facet-tree-' + this.facet.id + '-' + key
    },
    hasChildren: function (query) {
      return !!(query.childFacet && query.childFacet.queries && query.childFacet.queries.length)
    },
    isExpanded: function (key) {
      return !!this.filterText || this.open[key] === true
    },
    toggle: function (key) {
      this.open[key] = !this.open[key]
    },
    matchesFilter: function (query) {
      return this.labelOf(query).toLocaleLowerCase().includes(this.filterText.toLocaleLowerCase())
    },
    // a row stays visible when it, one of its parents or one of its children matches the finder
    isVisible: function (query, ancestors) {
      if (!this.filterText) {
        return true
      }
      const matchesBelow = (q) => this.matchesFilter(q) || (q.childFacet && q.childFacet.queries || []).some(matchesBelow)
      return ancestors.some(this.matchesFilter) || matchesBelow(query)
    },
    openSelected: function (queries, path) {
      (queries || []).forEach((query, index) => {
        const key = (path ? path + '/' : '') + this.keyOf(query, index)
        if (query.childFacet && hasSelectedFacetQuery(query.childFacet.queries)) {
          this.open[key] = true
          this.openSelected(query.childFacet.queries, key)
        }
      })
    },
    runSearch: function () {
      this.search({ currentPage: 1 })
    },
    includeQuery: function (query) {
      query.active = !query.active
      if (query.active) {
        query.excluded = false
      }
      this.runSearch()
      this.$forceUpdate()
    },
    excludeQuery: function (query) {
      query.excluded = !query.excluded
      if (query.excluded) {
        query.active = false
      }
      this.runSearch()
      this.$forceUpdate()
    },
    clearSelected: function (item) {
      item.query.active = false
      item.query.excluded = false
      this.runSearch()
      this.$forceUpdate()
      this.$nextTick(() => this.$refs.summary && this.$refs.summary.focus())
    }
  }
}
</script>

<style scoped>
.searchFilters,
.searchFilters ul {
  list-style: none;
  padding-left: 1em;
}

.facet-summary {
  margin: 0 0 0.5em;
}

.selected-filters {
  margin-bottom: 0.75em;
}

.facet-row {
  display: flex;
  align-items: center;
  gap: 0.25em;
}

.facet-toggle {
  background: none;
  border: 0;
  padding: 0;
  color: inherit;
  font: inherit;
  cursor: pointer;
  text-align: left;
}

.facet-count {
  margin-left: 5px;
}
</style>
