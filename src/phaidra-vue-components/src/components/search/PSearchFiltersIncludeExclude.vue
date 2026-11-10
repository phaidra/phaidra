<template>
  <div>
    <h3 class="text-body-large">{{ labelOf(facet) }}</h3>
    <p ref="summary" class="text-label-medium facet-summary" tabindex="-1">
      <span>{{ includedCount }} {{ $t('Include') }} · {{ excludedCount }} {{ $t('Exclude') }}</span>
      <v-tooltip location="bottom" max-width="280">
        <template #activator="{ props: tipProps }">
          <v-icon
            v-bind="tipProps"
            class="ms-1"
            icon="mdi-information-outline"
            size="small"
            :aria-label="$t('Only objects with a defined object type are shown')"
            tabindex="0"
          />
        </template>
        <span>{{ $t('Only objects with a defined object type are shown') }}</span>
      </v-tooltip>
    </p>
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
        <template v-if="item.level === 'object'">{{ item.excluded ? '−' : '+' }} </template>{{ item.label }}
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
          <v-checkbox
            v-model="q.active"
            class="facet-label"
            color="primary"
            hide-details
            density="compact"
            :aria-label="labelOf(q)"
            @update:model-value="toggleResourceType(q)"
          >
            <template #label>
              <span class="facet-label text-primary">{{ labelOf(q) }}</span>
              <span class="facet-count text-secondary font-weight-medium" v-if="q.count > 0">({{ q.count }})</span>
            </template>
          </v-checkbox>
          <v-btn
            v-if="hasChildren(q)"
            :icon="isExpanded(keyOf(q, j)) ? 'mdi-chevron-up' : 'mdi-chevron-down'"
            size="x-small"
            variant="text"
            :aria-expanded="isExpanded(keyOf(q, j))"
            :aria-controls="treeId(keyOf(q, j))"
            :aria-label="labelOf(q)"
            @click="toggle(keyOf(q, j))"
          />
        </div>
        <ul
          v-if="hasChildren(q) && isExpanded(keyOf(q, j))"
          :id="treeId(keyOf(q, j))"
          class="object-type-list"
        >
          <li v-for="(q1, k) in q.childFacet.queries" v-show="isVisible(q1, [q])" :key="keyOf(q1, k)">
            <div class="facet-row">
              <v-btn
                icon="mdi-plus"
                size="x-small"
                variant="text"
                :color="q1.active ? 'primary' : undefined"
                :aria-pressed="q1.active === true"
                :aria-label="actionLabel('Include', q1)"
                @click="includeObjectType(q, q1)"
              />
              <v-btn
                icon="mdi-minus"
                size="x-small"
                variant="text"
                :color="q1.excluded ? 'error' : undefined"
                :aria-pressed="q1.excluded === true"
                :aria-label="actionLabel('Exclude', q1)"
                @click="excludeObjectType(q, q1)"
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
                    @click="includeObjectType(q, q2)"
                  />
                  <v-btn
                    icon="mdi-minus"
                    size="x-small"
                    variant="text"
                    :color="q2.excluded ? 'error' : undefined"
                    :aria-pressed="q2.excluded === true"
                    :aria-label="actionLabel('Exclude', q2)"
                    @click="excludeObjectType(q, q2)"
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
import { hasSelectedFacetQuery, deactivateFacetQueries } from './facets'

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
      for (const [index, query] of (this.facet.queries || []).entries()) {
        const key = this.keyOf(query, index)
        const label = this.labelOf(query)
        if (query.active && !hasSelectedFacetQuery(query.childFacet && query.childFacet.queries)) {
          selected.push({ key, query, label, level: 'resource', excluded: false })
        }
        for (const [childIndex, child] of ((query.childFacet && query.childFacet.queries) || []).entries()) {
          if (child.active || child.excluded) {
            selected.push({
              key: key + '/' + this.keyOf(child, childIndex),
              query: child,
              label: label + ' → ' + this.labelOf(child),
              level: 'object',
              excluded: child.excluded === true
            })
          }
        }
      }
      return selected
    },
    includedCount () {
      return this.selectedFilters.filter(item => item.level === 'object' && !item.excluded).length
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
      if (item.level === 'resource') {
        return this.labelOf(item.query)
      }
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
    toggleResourceType: function (query) {
      if (!query.active && query.childFacet) {
        deactivateFacetQueries(query.childFacet)
      }
      query.excluded = false
      this.runSearch()
      this.$forceUpdate()
    },
    includeObjectType: function (parent, query) {
      query.active = !query.active
      if (query.active) {
        query.excluded = false
        parent.active = true
      }
      this.runSearch()
      this.$forceUpdate()
    },
    excludeObjectType: function (parent, query) {
      query.excluded = !query.excluded
      if (query.excluded) {
        query.active = false
        parent.active = true
      }
      this.runSearch()
      this.$forceUpdate()
    },
    clearSelected: function (item) {
      item.query.active = false
      item.query.excluded = false
      if (item.level === 'resource' && item.query.childFacet) {
        deactivateFacetQueries(item.query.childFacet)
      }
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
  display: flex;
  align-items: center;
  margin: 0.5em 0 0.5em;
}

.selected-filters {
  margin-bottom: 0.75em;
}

.facet-row {
  display: flex;
  align-items: center;
  gap: 0.25em;
}

.object-type-list {
  max-height: 16rem;
  overflow-y: auto;
  margin: 0 0 0.5em;
  padding-left: 1.5em;
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
