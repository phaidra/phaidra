import vocstore from '../store/modules/vocabulary'

export default {
  setFieldValue (field, vocabulary, id) {
    for (let term of vocstore.state.vocabularies[vocabulary].terms) {
      if (term['@id'] === id) {
        field.value = id
        field['skos:prefLabel'] = []
        Object.entries(term['skos:prefLabel']).forEach(([lang, value]) => {
          field['skos:prefLabel'].push(
            {
              '@value': value,
              '@language': lang
            }
          )
        })
      }
    }
  },
  setFieldValueCustomVoc (field, vocabulary, id) {
    for (let term of vocabulary.terms) {
      if (term['@id'] === id) {
        field.value = id
        field['skos:prefLabel'] = []
        Object.entries(term['skos:prefLabel']).forEach(([lang, value]) => {
          field['skos:prefLabel'].push(
            {
              '@value': value,
              '@language': lang
            }
          )
        })
      }
    }
  }
}
