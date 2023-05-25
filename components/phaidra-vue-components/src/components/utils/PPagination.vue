<script>
// this class is a hack until Vuetify supports flat pagination
import VPagination from 'vuetify/es5/components/VPagination'
import VIcon from 'vuetify/es5/components/VIcon'

export default {
  name: 'p-pagination',
  extends: VPagination,
  methods: {
    genIcon: function genIcon (h, icon, disabled, fn, label) {
      return h('li', [h('button', {
        staticClass: 'v-pagination__navigation',
        class: {
          'v-pagination__navigation--disabled': disabled
        },
        attrs: {
          type: 'button',
          'aria-label': label
        },
        on: disabled ? {} : {
          click: fn
        }
      }, [h(VIcon.default, [icon])])])
    },
    genItem: function genItem (h, i) {
      var _this2 = this

      var color = i === this.value && (this.color || 'primary')
      var isCurrentPage = i === this.value
      var ariaLabel = isCurrentPage ? this.currentPageAriaLabel : this.pageAriaLabel
      return h('button', this.setBackgroundColor(color, {
        staticClass: 'v-pagination__item',
        class: {
          'v-pagination__item--active': i === this.value
        },
        attrs: {
          type: 'button',
          'aria-current': isCurrentPage,
          'aria-label': this.$vuetify.lang.t(ariaLabel, i)
        },
        on: {
          click: function click () {
            return _this2.$emit('input', i)
          }
        }
      }), [i.toString()])
    }
  }
}
</script>
