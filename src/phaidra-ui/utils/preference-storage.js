export const THEME_KEY = 'theme'
export const LOCALE_KEY = 'locale'
export const PREFERENCE_MAX_AGE = 60 * 60 * 24 * 365

export function normalizeTheme (value, fallback = 'light') {
  return value === 'dark' ? 'dark' : (value === 'light' ? 'light' : fallback)
}

export function syncLocalStorage (key, value) {
  if (!import.meta.client || value == null) return
  try {
    localStorage.setItem(key, value)
  } catch (_) {}
}

export function setPreferenceCookie (name, value) {
  if (!import.meta.client || value == null) return
  document.cookie = `${name}=${encodeURIComponent(value)}; path=/; max-age=${PREFERENCE_MAX_AGE}; SameSite=Lax`
}

export function persistPreference (name, value) {
  setPreferenceCookie(name, value)
  syncLocalStorage(name, value)
}
