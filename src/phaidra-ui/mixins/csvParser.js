import Papa from 'papaparse'

/**
 * Standalone function to parse CSV content
 * Can be used in Vuex stores or anywhere outside Vue components
 */
export function parseCsv(csvContent) {
  if (!csvContent) {
    return { data: [], errors: [], meta: {} }
  }

  const parsed = Papa.parse(csvContent, {
    skipEmptyLines: true,
    quoteChar: '"',
    escapeChar: '"'
  })

  if (parsed.errors && parsed.errors.length > 0) {
    console.warn('CSV Parser - Parsing errors:', parsed.errors)
  }

  parsed.data = parsed.data.map(row => {
    if (row.length === 1 && row[0].includes(';')) {
      console.warn('CSV Warning: Row has all data in single field. This suggests improper quoting.')
      return row[0].split(';')
    }
    return row
  })

  return parsed
}

export const csvParser = {
  methods: {
    /**
     * Parse CSV content using PapaParse
     * Handles quoted fields, commas, quotes, and newlines properly
     * 
     * @param {String} csvContent - The raw CSV content to parse
     * @returns {Object} Parsed result with { data: Array, errors: Array, meta: Object }
     */
    parseCsvContent(csvContent) {
      if (!csvContent) {
        return { data: [], errors: [], meta: {} }
      }

      const parsed = Papa.parse(csvContent, {
        skipEmptyLines: true,
        quoteChar: '"',
        escapeChar: '"'
      })

      console.log('CSV Parser - Parsed data:', parsed.data)
      
      if (parsed.errors && parsed.errors.length > 0) {
        console.warn('CSV Parser - Parsing errors:', parsed.errors)
      }

      parsed.data = parsed.data.map(row => {
        if (row.length === 1 && row[0].includes(';')) {
          console.warn('CSV Warning: Row has all data in single field. This suggests improper quoting.')
          return row[0].split(';')
        }
        return row
      })

      return parsed
    },
  }
}

