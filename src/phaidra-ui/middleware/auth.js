export default function ({ store, redirect, route }) {
  if (!store.state.user.token) {
    if (process.client) {
      localStorage.setItem('redirect', route.fullPath)
    }
    redirect('/login')
  }
}
