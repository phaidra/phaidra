export default ({ app }) => {
  const { localePath } = app
  app.router.afterEach((to, from) => {
    if (process.client && to.path !== '/login') {
      localStorage.setItem('redirect', to.fullPath)
    }
    app.store.commit('updateBreadcrumbs', { to, from, localePath })
  })
}
