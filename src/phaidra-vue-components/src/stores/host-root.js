import { getActivePinia } from 'pinia'

/**
 * Access the host app's root Pinia store (id: 'root') without importing UI code.
 * Used by PVC stores that previously read rootState / committed with { root: true }.
 */
export function useHostRootStore () {
  const pinia = getActivePinia()
  if (!pinia) {
    throw new Error('Pinia is not active')
  }
  const store = pinia._s.get('root')
  if (!store) {
    throw new Error("Root store (id: 'root') is not registered")
  }
  return store
}
