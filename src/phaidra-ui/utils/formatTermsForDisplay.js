export function formatTermsForDisplay(terms) {
  if (!terms) return ''
  if (/<[a-zA-Z\/!?]/.test(terms)) return terms
  return String(terms).replace(/\r\n|\r|\n/g, '<br />')
}
