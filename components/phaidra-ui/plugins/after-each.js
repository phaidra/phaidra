export default ({ app }) => {
  const { localePath } = app
  app.router.afterEach((to, from) => {
    app.store.commit('updateBreadcrumbs', { to, from, localePath })
  })
}
