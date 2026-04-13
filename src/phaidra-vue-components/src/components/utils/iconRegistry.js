const icons = Object.create(null)

export function registerIcon (name, def) {
  if (!name || !def) return
  icons[name] = def
}

export function getIcon (name) {
  return icons[name] || null
}

