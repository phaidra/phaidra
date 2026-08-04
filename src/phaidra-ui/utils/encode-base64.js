/** UTF-8 string to base64 in the browser and during Nuxt SSR. */
export function encodeUtf8ToBase64(text) {
  if (text == null) {
    return ''
  }
  if (typeof Buffer !== 'undefined') {
    return Buffer.from(text, 'utf8').toString('base64')
  }
  const bytes = new TextEncoder().encode(text)
  let binary = ''
  for (let i = 0; i < bytes.length; i++) {
    binary += String.fromCharCode(bytes[i])
  }
  return btoa(binary)
}
