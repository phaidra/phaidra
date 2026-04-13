/**
 * Scroll the main window to a vertical offset. Replaces Vuetify 2's
 * `this.$vuetify.goTo(y)`, which is not on `$vuetify` in Vuetify 3.
 */
export function vuetifyGoTo (y = 0) {
  window.scrollTo({ top: y, left: 0, behavior: 'auto' })
}
