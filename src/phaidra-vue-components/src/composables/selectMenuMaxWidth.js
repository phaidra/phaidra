import { nextTick, reactive } from 'vue'

/**
 * Vuetify 4 select menus (v-autocomplete, v-select, v-combobox) grow with long
 * item content unless maxWidth is capped. This helper ties menu maxWidth to an
 * element (e.g. a form row) via ResizeObserver, using only Vuetify menu-props.
 *
 * Options API: create once in `created()`, call `observe()` in `mounted()`,
 * `disconnect()` in `beforeUnmount()`.
 *
 * @returns {{
 *   menuProps: { maxWidth: number | undefined, minWidth: string },
 *   observe: (getTarget: () => Element | undefined | null) => void,
 *   disconnect: () => void
 * }}
 */
export function createSelectMenuMaxWidthController () {
  const menuProps = reactive({
    maxWidth: undefined,
    minWidth: 'auto'
  })

  let ro = null

  function disconnect () {
    ro?.disconnect()
    ro = null
  }

  /**
   * @param {() => Element | undefined | null} getTarget
   */
  function observe (getTarget) {
    nextTick(() => {
      disconnect()
      const el = getTarget?.()
      if (!el) {
        menuProps.maxWidth = undefined
        return
      }
      if (typeof ResizeObserver === 'undefined') {
        menuProps.maxWidth = el.clientWidth
        return
      }
      ro = new ResizeObserver((entries) => {
        menuProps.maxWidth = entries[0].contentRect.width
      })
      ro.observe(el)
      menuProps.maxWidth = el.clientWidth
    })
  }

  return { menuProps, observe, disconnect }
}

/**
 * Merge width props with extra v-menu props (e.g. maxHeight).
 *
 * @param {{ maxWidth?: number, minWidth?: string }} widthProps
 * @param {Record<string, unknown>} [extra]
 */
export function mergeSelectMenuProps (widthProps, extra = {}) {
  return {
    minWidth: 'auto',
    ...widthProps,
    ...extra
  }
}

/**
 * Composition API helper (thin wrapper around {@link createSelectMenuMaxWidthController}).
 */
export function useSelectMenuMaxWidthFromElement () {
  return createSelectMenuMaxWidthController()
}
