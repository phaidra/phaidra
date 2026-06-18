/** True when value is a string that contains at least one non-whitespace character. */
export function isNonBlankString (value) {
  return typeof value === 'string' && value.trim().length > 0
}

/** Returns the trimmed string, or null when value is missing or whitespace-only. */
export function trimToNull (value) {
  if (typeof value !== 'string') {
    return null
  }
  const trimmed = value.trim()
  return trimmed.length > 0 ? trimmed : null
}
