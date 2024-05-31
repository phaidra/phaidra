export const formvalidation = {
  data() {
    return {
      validationError: false,
      mandatoryFieldsFound: {},
      mandatoryFieldsValidated: {},
      allowedMimetypes: {
        // image
        'https://pid.phaidra.org/vocabulary/44TN-P1S0': [
          'image/jpeg',
          'image/gif',
          'image/tiff',
          'image/png',
          'image/x-ms-bmp'
        ],
        // text
        'https://pid.phaidra.org/vocabulary/69ZZ-2KGX': [
          'application/pdf',
          'application/x-pdf'
        ],
        // video
        'https://pid.phaidra.org/vocabulary/B0Y6-GYT8': [
          'video/mpeg',
          'video/avi',
          'video/x-msvideo',
          'video/mp4',
          'video/quicktime',
          'video/x-matroska'
        ],
        // sound
        'https://pid.phaidra.org/vocabulary/8YB5-1M0J': [
          'audio/x-wav',
          'audio/wav',
          'audio/mpeg',
          'audio/flac',
          'audio/ogg'
        ]
      }
    }
  },
  computed: {
    mandatoryFieldsMissing() {
      return Object.keys(this.mandatoryFieldsFound).filter(key=>!this.mandatoryFieldsFound[key])
    },
    mandatoryFieldsIncomplete() {
      return Object.keys(this.mandatoryFieldsValidated).filter(key=>!this.mandatoryFieldsValidated[key])
    }
  },
  methods: {
    markMandatoryWithOefosAndAssoc() {
      for (const s of this.form.sections) {
        for (const f of s.fields) {
          if (f.predicate === 'dcterms:type') {
            f.label = f.label + ' *'
          }
          if (f.predicate === 'edm:hasType') {
            f.label = f.label + ' *'
          }
          if (f.component === 'p-title') {
            f.titleLabel = f.titleLabel ? f.titleLabel + ' *' : f.type + ' *'
          }
          if ((f.predicate === 'bf:note') && (f.type === 'bf:Note')) {
            f.label = f.label + ' *'
          }
          if (f.component === 'p-keyword') {
            f.label = f.label + ' *'
          }
          if (f.component === 'p-subject-oefos') {
            f.label = f.label + ' *'
          }
          if (f.component === 'p-association') {
            f.label = f.label + ' *'
          }
          if ((f.component === 'p-entity') || (f.component === 'p-entity-extended')) {
            f.label = f.label + ' *'
            f.roleLabel = f.roleLabel + ' *'
            f.firstnameLabel = f.firstnameLabel + ' *'
            f.lastnameLabel = f.lastnameLabel + ' *'
          }
          if (f.component === 'p-select') {
            if (f.predicate === 'edm:rights') {
              f.label = f.label + ' *'
            }
          }
          if (f.component === 'p-file') {
            f.label = f.label + ' *'
          }
        }
      }
    },
    markMandatory() {
      for (const s of this.form.sections) {
        for (const f of s.fields) {
          if (f.predicate === 'dcterms:type') {
            f.label = f.label + ' *'
          }
          if (f.predicate === 'edm:hasType') {
            f.label = f.label + ' *'
          }
          if (f.component === 'p-title') {
            f.titleLabel = f.titleLabel ? f.titleLabel + ' *' : f.type + ' *'
          }
          if ((f.predicate === 'bf:note') && (f.type === 'bf:Note')) {
            f.label = f.label + ' *'
          }
          if (f.component === 'p-keyword') {
            f.label = f.label + ' *'
          }
          if ((f.component === 'p-entity') || (f.component === 'p-entity-extended')) {
            f.label = f.label + ' *'
            f.roleLabel = f.roleLabel + ' *'
            f.firstnameLabel = f.firstnameLabel + ' *'
            f.lastnameLabel = f.lastnameLabel + ' *'
          }
          if (f.component === 'p-select') {
            if (f.predicate === 'edm:rights') {
              f.label = f.label + ' *'
            }
          }
          if (f.component === 'p-file') {
            f.label = f.label + ' *'
          }
        }
      }
    },
    validationWithOefosAndAssoc(targetpid) {
      this.validationError = false
      this.mandatoryFieldsFound = {
        'Title': false,
        'Description': false,
        'Keyword': false,
        'Role': false,
        'License': false,
        'Resource type': false,
        'Object type': false,
        'Association': false,
        'OEFOS Classification': false,
        'File': false
      }
      this.mandatoryFieldsValidated = {
        'Resource type': false,
        'Object type': false,
        'Title': false,
        'Description': false,
        'Keyword': false,
        'Role': false,
        'License': false,
        'Association': false,
        'OEFOS Classification': false,
        'File': false
      }
      let resourceType = null
      let hasReadonlyOefos = false
      for (const s of this.form.sections) {
        for (const f of s.fields) {
          if (f.predicate === 'dcterms:type') {
            console.log('resourceType ' + f['skos:prefLabel'][0]['@value'])
            resourceType = f.value
          }
          if (f.component === 'p-vocab-ext-readonly') {
            if (f['skos:exactMatch']) {
              for (let v of f['skos:exactMatch']) {
                if (v.startsWith('oefos2012')) {
                  hasReadonlyOefos = true
                }
              }
            }
          }
        }
      }
      switch (resourceType) {
        case 'https://pid.phaidra.org/vocabulary/GXS7-ENXJ':
          // collection
          this.mandatoryFieldsFound['File'] = true
          this.mandatoryFieldsFound['License'] = true
          this.mandatoryFieldsFound['Object type'] = true
          this.mandatoryFieldsFound['OEFOS Classification'] = true
          this.mandatoryFieldsValidated['File'] = true
          this.mandatoryFieldsValidated['License'] = true
          this.mandatoryFieldsValidated['Object type'] = true
          this.mandatoryFieldsValidated['OEFOS Classification'] = true
          break
        case 'https://pid.phaidra.org/vocabulary/T8GH-F4V8':
          // resource
          this.mandatoryFieldsFound['File'] = true
          this.mandatoryFieldsFound['License'] = true
          this.mandatoryFieldsValidated['File'] = true
          this.mandatoryFieldsValidated['License'] = true
          break
      }
      if (targetpid) {
        this.mandatoryFieldsFound['File'] = true
        this.mandatoryFieldsValidated['File'] = true
      }

      for (const s of this.form.sections) {
        for (const f of s.fields) {
          console.log('checking p[' + f.predicate + '] c[' + f.component + ']') 
          if (f.predicate === 'dcterms:type') {
            this.mandatoryFieldsFound['Resource type'] = true
            if (f.value.length > 0) {
              this.mandatoryFieldsValidated['Resource type'] = true
            }
          }
          if (f.predicate === 'edm:hasType') {
            this.mandatoryFieldsFound['Object type'] = true
            if (Object.prototype.hasOwnProperty.call(f, 'selectedTerms')) {
              if (f.selectedTerms.length > 0) {
                this.mandatoryFieldsValidated['Object type'] = true
              }
            } else if (f.value.length > 0) {
              this.mandatoryFieldsValidated['Object type'] = true
            }
          }
          if (f.component === 'p-title') {
            this.mandatoryFieldsFound['Title'] = true
            f.titleErrorMessages = []
            if (f.title.length > 0) {
              this.mandatoryFieldsValidated['Title'] = true
            }
          }
          if ((f.predicate === 'bf:note') && (f.type === 'bf:Note')) {
            this.mandatoryFieldsFound['Description'] = true
            if (f.value.length > 0) {
              this.mandatoryFieldsValidated['Description'] = true
            }
          }
          if (f.component === 'p-keyword') {
            this.mandatoryFieldsFound['Keyword'] = true
            if (f.value.length > 0) {
              this.mandatoryFieldsValidated['Keyword'] = true
            }
          }
          if ((f.component === 'p-entity') || (f.component === 'p-entity-extended') || (f.component === 'p-entity-fixedrole-person')) {
            console.log('found role r[' + f.role + '] fn[' + f.firstname + '] ln[' + f.lastname + ']')
            if (f.role.length > 0) {
              this.mandatoryFieldsFound['Role'] = true
            }
            if (f.type === 'schema:Person') {
              if (f.firstname.length > 0) {
                this.mandatoryFieldsValidated['Role'] = true
              }
              if (f.lastname.length > 0) {
                this.mandatoryFieldsValidated['Role'] = true

              }
            }
          }
          if (f.component === 'p-select') {
            if (f.predicate === 'edm:rights') {
              this.mandatoryFieldsFound['License'] = true
              if (f.value.length > 0) {
                this.mandatoryFieldsValidated['License'] = true
              }
            }
          }
          if (resourceType !== 'https://pid.phaidra.org/vocabulary/GXS7-ENXJ') {
            if (f.component === 'p-subject-oefos') {
              this.mandatoryFieldsFound['OEFOS Classification'] = true
              if (hasReadonlyOefos) {
                this.mandatoryFieldsValidated['OEFOS Classification'] = true
              } else {
                if (f.value.length > 0) {
                  this.mandatoryFieldsValidated['OEFOS Classification'] = true
                }
              }
            }
          }
          if (f.component === 'p-association') {
            this.mandatoryFieldsFound['Association'] = true
            if (f.value.length > 0) {
              this.mandatoryFieldsValidated['Association'] = true
            }
          }
          if (f.component === 'p-file') {
            this.mandatoryFieldsFound['File'] = true
            if (f.file && (f.mimetype.length > 0) && (resourceType !== 'https://pid.phaidra.org/vocabulary/7AVS-Y482')) {
              this.mandatoryFieldsValidated['File'] = true
            }
            if (this.allowedMimetypes[resourceType]) {
              if (!this.allowedMimetypes[resourceType].includes(f.mimetype)) {
                console.error('wrong file format')
                f.mimetypeErrorMessages.push(this.$t('This file type is not supported for the chosen resource type.'))
                f.fileErrorMessages.push(this.$t('Wrong file format.'))
                this.validationError = true
              }
            }
          }
        }
      }

      for (const field in this.mandatoryFieldsFound) {
        if (!this.mandatoryFieldsFound[field]) {
          this.validationError = true
          console.error('field ' + field + ' not found')
        }
      }

      for (const field in this.mandatoryFieldsValidated) {
        if (!this.mandatoryFieldsValidated[field]) {
          this.validationError = true
          console.error('field ' + field + ' incomplete')
        }
      }
   
      if (this.validationError) {
        this.$vuetify.goTo(0)
      }
      console.log('validation error ' + this.validationError)
      return !this.validationError
    },
    validationWithOefos(targetpid) {
      this.validationError = false
      this.mandatoryFieldsFound = {
        'Title': false,
        'Description': false,
        'Keyword': false,
        'Role': false,
        'License': false,
        'Resource type': false,
        'Object type': false,
        'OEFOS Classification': false,
        'File': false
      }
      this.mandatoryFieldsValidated = {
        'Resource type': false,
        'Object type': false,
        'Title': false,
        'Description': false,
        'Keyword': false,
        'Role': false,
        'License': false,
        'OEFOS Classification': false,
        'File': false
      }
      let resourceType = null
      let hasReadonlyOefos = false
      for (const s of this.form.sections) {
        for (const f of s.fields) {
          if (f.predicate === 'dcterms:type') {
            console.log('resourceType ' + f['skos:prefLabel'][0]['@value'])
            resourceType = f.value
          }
          if (f.component === 'p-vocab-ext-readonly') {
            if (f['skos:exactMatch']) {
              for (let v of f['skos:exactMatch']) {
                if (v.startsWith('oefos2012')) {
                  hasReadonlyOefos = true
                }
              }
            }
          }
        }
      }
      switch (resourceType) {
        case 'https://pid.phaidra.org/vocabulary/GXS7-ENXJ':
          // collection
          this.mandatoryFieldsFound['File'] = true
          this.mandatoryFieldsFound['License'] = true
          this.mandatoryFieldsFound['Object type'] = true
          this.mandatoryFieldsFound['OEFOS Classification'] = true
          this.mandatoryFieldsValidated['File'] = true
          this.mandatoryFieldsValidated['License'] = true
          this.mandatoryFieldsValidated['Object type'] = true
          this.mandatoryFieldsValidated['OEFOS Classification'] = true
          break
        case 'https://pid.phaidra.org/vocabulary/T8GH-F4V8':
          // resource
          this.mandatoryFieldsFound['File'] = true
          this.mandatoryFieldsFound['License'] = true
          this.mandatoryFieldsValidated['File'] = true
          this.mandatoryFieldsValidated['License'] = true
          break
      }
      if (targetpid) {
        this.mandatoryFieldsFound['File'] = true
        this.mandatoryFieldsValidated['File'] = true
      }

      for (const s of this.form.sections) {
        for (const f of s.fields) {
          console.log('checking p[' + f.predicate + '] c[' + f.component + ']') 
          if (f.predicate === 'dcterms:type') {
            this.mandatoryFieldsFound['Resource type'] = true
            if (f.value.length > 0) {
              this.mandatoryFieldsValidated['Resource type'] = true
            }
          }
          if (f.predicate === 'edm:hasType') {
            this.mandatoryFieldsFound['Object type'] = true
            if (Object.prototype.hasOwnProperty.call(f, 'selectedTerms')) {
              if (f.selectedTerms.length > 0) {
                this.mandatoryFieldsValidated['Object type'] = true
              }
            } else if (f.value.length > 0) {
              this.mandatoryFieldsValidated['Object type'] = true
            }
          }
          if (f.component === 'p-title') {
            this.mandatoryFieldsFound['Title'] = true
            f.titleErrorMessages = []
            if (f.title.length > 0) {
              this.mandatoryFieldsValidated['Title'] = true
            }
          }
          if ((f.predicate === 'bf:note') && (f.type === 'bf:Note')) {
            this.mandatoryFieldsFound['Description'] = true
            if (f.value.length > 0) {
              this.mandatoryFieldsValidated['Description'] = true
            }
          }
          if (f.component === 'p-keyword') {
            this.mandatoryFieldsFound['Keyword'] = true
            if (f.value.length > 0) {
              this.mandatoryFieldsValidated['Keyword'] = true
            }
          }
          if ((f.component === 'p-entity') || (f.component === 'p-entity-extended') || (f.component === 'p-entity-fixedrole-person')) {
            console.log('found role r[' + f.role + '] fn[' + f.firstname + '] ln[' + f.lastname + ']')
            if (f.role.length > 0) {
              this.mandatoryFieldsFound['Role'] = true
            }
            if (f.type === 'schema:Person') {
              if (f.firstname.length > 0) {
                this.mandatoryFieldsValidated['Role'] = true
              }
              if (f.lastname.length > 0) {
                this.mandatoryFieldsValidated['Role'] = true

              }
            }
          }
          if (f.component === 'p-select') {
            if (f.predicate === 'edm:rights') {
              this.mandatoryFieldsFound['License'] = true
              if (f.value.length > 0) {
                this.mandatoryFieldsValidated['License'] = true
              }
            }
          }
          if (resourceType !== 'https://pid.phaidra.org/vocabulary/GXS7-ENXJ') {
            if (f.component === 'p-subject-oefos') {
              this.mandatoryFieldsFound['OEFOS Classification'] = true
              if (hasReadonlyOefos) {
                this.mandatoryFieldsValidated['OEFOS Classification'] = true
              } else {
                if (f.value.length > 0) {
                  this.mandatoryFieldsValidated['OEFOS Classification'] = true
                }
              }
            }
          }
          if (f.component === 'p-file') {
            this.mandatoryFieldsFound['File'] = true
            if (f.file && (f.mimetype.length > 0) && (resourceType !== 'https://pid.phaidra.org/vocabulary/7AVS-Y482')) {
              this.mandatoryFieldsValidated['File'] = true
            }
            if (this.allowedMimetypes[resourceType]) {
              if (!this.allowedMimetypes[resourceType].includes(f.mimetype)) {
                console.error('wrong file format')
                f.mimetypeErrorMessages.push(this.$t('This file type is not supported for the chosen resource type.'))
                f.fileErrorMessages.push(this.$t('Wrong file format.'))
                this.validationError = true
              }
            }
          }
        }
      }

      for (const field in this.mandatoryFieldsFound) {
        if (!this.mandatoryFieldsFound[field]) {
          this.validationError = true
          console.error('field ' + field + ' not found')
        }
      }

      for (const field in this.mandatoryFieldsValidated) {
        if (!this.mandatoryFieldsValidated[field]) {
          this.validationError = true
          console.error('field ' + field + ' incomplete')
        }
      }
   
      if (this.validationError) {
        this.$vuetify.goTo(0)
      }
      console.log('validation error ' + this.validationError)
      return !this.validationError
    },
    fieldsAreMissing() {
      for (const field in this.mandatoryFieldsFound) {
        if (!this.mandatoryFieldsFound[field]) {
          return true
        }
      }
      return false
    },
    fieldsNotValidated() {
      for (const field in this.mandatoryFieldsValidated) {
        if (!this.mandatoryFieldsValidated[field]) {
          return true
        }
      }
      return false
    },
    defaultValidation(targetpid) {
      this.validationError = false
      this.fieldsMissing = []
      this.mandatoryFieldsFound = {
        'Title': false,
        'Description': false,
        'Keyword': false,
        'Role': false,
        'License': false,
        'Resource type': false,
        'Object type': false,
        'File': false
      }
      this.mandatoryFieldsValidated = {
        'Resource type': false,
        'Object type': false,
        'Title': false,
        'Description': false,
        'Keyword': false,
        'Role': false,
        'License': false,
        'File': false
      }
      let resourceType = null
      for (const s of this.form.sections) {
        for (const f of s.fields) {
          if (f.predicate === 'dcterms:type') {
            resourceType = f.value
            console.log('resourceType ' + f['skos:prefLabel'][0]['@value'])
          }
        }
      }
      switch (resourceType) {
        case 'https://pid.phaidra.org/vocabulary/GXS7-ENXJ':
          // collection
          this.mandatoryFieldsFound['File'] = true
          this.mandatoryFieldsFound['License'] = true
          this.mandatoryFieldsFound['Object type'] = true
          this.mandatoryFieldsValidated['File'] = true
          this.mandatoryFieldsValidated['License'] = true
          this.mandatoryFieldsValidated['Object type'] = true
          this.mandatoryFieldsValidated['OEFOS Classification'] = true
          break
        case 'https://pid.phaidra.org/vocabulary/T8GH-F4V8':
          // resource
          this.mandatoryFieldsFound['File'] = true
          this.mandatoryFieldsFound['License'] = true
          this.mandatoryFieldsValidated['File'] = true
          this.mandatoryFieldsValidated['License'] = true
          break
      }
      if (targetpid) {
        this.mandatoryFieldsFound['File'] = true
        this.mandatoryFieldsValidated['File'] = true
      }

      for (const s of this.form.sections) {
        for (const f of s.fields) {
          if (f.predicate === 'dcterms:type') {
            console.log('checking p[' + f.predicate + '] c[' + f.component + '] v[' + f.value + ']') 
            this.mandatoryFieldsFound['Resource type'] = true
            if (f.value.length > 0) {
              this.mandatoryFieldsValidated['Resource type'] = true
            }
          }
          if (f.predicate === 'edm:hasType') {
            console.log('checking p[' + f.predicate + '] c[' + f.component + '] v[' + f.value + '] selterms[' + f.selectedTerms?.length + ']') 
            this.mandatoryFieldsFound['Object type'] = true
            if (Object.prototype.hasOwnProperty.call(f, 'selectedTerms')) {
              if (f.selectedTerms.length > 0) {
                console.log(f.selectedTerms)
                this.mandatoryFieldsValidated['Object type'] = true
              }
            } else if (f.value.length > 0) {
              this.mandatoryFieldsValidated['Object type'] = true
            }
          }
          if (f.component === 'p-title') {
            console.log('checking p[' + f.predicate + '] c[' + f.component + '] title[' + f.title + ']') 
            this.mandatoryFieldsFound['Title'] = true
            f.titleErrorMessages = []
            if (f.title.length > 0) {
              this.mandatoryFieldsValidated['Title'] = true
            }
          }
          if ((f.predicate === 'bf:note') && (f.type === 'bf:Note')) {
            console.log('checking p[' + f.predicate + '] c[' + f.component + '] v[' + f.value + ']') 
            this.mandatoryFieldsFound['Description'] = true
            if (f.value.length > 0) {
              this.mandatoryFieldsValidated['Description'] = true
            }
          }
          if (f.component === 'p-keyword') {
            console.log('checking p[' + f.predicate + '] c[' + f.component + '] v[' + f.value + ']') 
            this.mandatoryFieldsFound['Keyword'] = true
            if (f.value.length > 0) {
              this.mandatoryFieldsValidated['Keyword'] = true
            }
          }
          if ((f.component === 'p-entity') || (f.component === 'p-entity-extended')) {
            console.log('checking p[' + f.predicate + '] c[' + f.component + '] r[' + f.role + '] fn[' + f.firstname + '] ln[' + f.lastname + ']')
            if (f.role.length > 0) {
              this.mandatoryFieldsFound['Role'] = true
            }
            if (f.type === 'schema:Person') {
              if (f.firstname.length > 0) {
                this.mandatoryFieldsValidated['Role'] = true
              }
              if (f.lastname.length > 0) {
                this.mandatoryFieldsValidated['Role'] = true
              }
            }
          }
          if (f.component === 'p-select') {
            if (f.predicate === 'edm:rights') {
              console.log('checking p[' + f.predicate + '] c[' + f.component + '] v[' + f.value + ']')
              this.mandatoryFieldsFound['License'] = true
              if (f.value.length > 0) {
                this.mandatoryFieldsValidated['License'] = true
              }
            }
          }
          if (f.component === 'p-file') {
            console.log('checking p[' + f.predicate + '] c[' + f.component + '] mimetype[' + f.mimetype + '] file[' + f.file + ']')
            console.log(f.file)
            this.mandatoryFieldsFound['File'] = true
            if (f.file && (f.mimetype.length > 0) && (resourceType !== 'https://pid.phaidra.org/vocabulary/7AVS-Y482')) {
              this.mandatoryFieldsValidated['File'] = true
            }
            if (this.allowedMimetypes[resourceType]) {
              if (!this.allowedMimetypes[resourceType].includes(f.mimetype)) {
                console.error('wrong file format')
                f.mimetypeErrorMessages.push(this.$t('This file type is not supported for the chosen resource type.'))
                f.fileErrorMessages.push(this.$t('Wrong file format.'))
                this.validationError = true
              }
            }
          }
          if ((f.component === 'p-filename-readonly') || f.component === 'p-filename') {
            console.log('checking p[' + f.predicate + '] c[' + f.component + '] v[' + f.value + ']')
            this.mandatoryFieldsFound['File'] = true
            if (f.value.length > 0) {
              this.mandatoryFieldsValidated['File'] = true
            }
          }
        }
      }

      for (const field in this.mandatoryFieldsFound) {
        if (!this.mandatoryFieldsFound[field]) {
          this.validationError = true
          console.error('field ' + field + ' not found')
        }
      }

      for (const field in this.mandatoryFieldsValidated) {
        if (!this.mandatoryFieldsValidated[field]) {
          this.validationError = true
          console.error('field ' + field + ' incomplete')
        }
      }
   
      if (this.validationError) {
        this.$vuetify.goTo(0)
      }
      console.log('validation error ' + this.validationError)
      return !this.validationError
    }
  }
}
