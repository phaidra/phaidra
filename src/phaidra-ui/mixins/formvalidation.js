export const formvalidation = {
  data() {
    return {
      validationError: false,
      fieldsMissing: [],
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
  methods: {
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
    markMandatoryNoOefosNoAssoc() {
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
    validate() {
      this.validationError = false
      this.fieldsMissing = []
      let missingTitle = true
      let missingDescription = true
      let missingKeyword = true
      let missingRole = true
      let missingLicense = true
      let missingResourceType = true
      let missingObjectType = true
      let missingFile = true
      let missingAssociation = true
      let missingOefos = true
      let resourceType = null
      let hasReadonlyOefos = false
      for (const s of this.form.sections) {
        for (const f of s.fields) {
          if (f.predicate === 'dcterms:type') {
            resourceType = f.value
          }
          if (f.component === 'p-vocab-ext-readonly') {
            if (f.value.startsWith('oefos2012')) {
              hasReadonlyOefos = true
            }
          }
        }
      }
      switch (resourceType) {
        case 'https://pid.phaidra.org/vocabulary/GXS7-ENXJ':
          // collection
          missingFile = false
          missingLicense = false
          missingObjectType = false
          missingOefos = false
          break
        case 'https://pid.phaidra.org/vocabulary/T8GH-F4V8':
          // resource
          missingFile = false
          missingLicense = false
          break
      }

      for (const s of this.form.sections) {
        for (const f of s.fields) {
          if (f.predicate === 'dcterms:type') {
            missingResourceType = false
            if (f.value.length < 1) {
              f.errorMessages.push(this.$t('Please select'))
              this.validationError = true
            }
          }
          if (f.predicate === 'edm:hasType') {
            missingObjectType = false
            if (Object.prototype.hasOwnProperty.call(f, 'selectedTerms')) {
              if (f.selectedTerms.length < 1) {
                f.errorMessage = []
                f.errorMessages.push(this.$t('Please select one or more object types'))
                this.validationError = true
              }
            } else if (f.value.length < 1) {
              f.errorMessage = []
              f.errorMessages.push(this.$t('Please select one or more object types'))
              this.validationError = true
            }
          }
          if (f.component === 'p-title') {
            missingTitle = false
            f.titleErrorMessages = []
            if (f.title.length < 1) {
              f.titleErrorMessages.push(this.$t('Missing title'))
              this.validationError = true
            }
          }
          if ((f.predicate === 'bf:note') && (f.type === 'bf:Note')) {
            missingDescription = false
            f.errorMessages = []
            if (f.value.length < 1) {
              f.errorMessages.push(this.$t('Missing description'))
              this.validationError = true
            }
          }
          if (f.component === 'p-keyword') {
            missingKeyword = false
            f.errorMessages = []
            if (f.value.length < 1) {
              f.errorMessages.push(this.$t('Missing keywords'))
              this.validationError = true
            }
          }
          if ((f.component === 'p-entity') || (f.component === 'p-entity-extended')) {
            missingRole = false
            f.firstnameErrorMessages = []
            f.lastnameErrorMessages = []
            f.roleErrorMessages = []
            f.affiliationErrorMessages = []
            f.affiliationTextErrorMessages = []
            f.organizationErrorMessages = []
            f.organizationTextErrorMessages = []
            if (f.role.length < 1) {
              f.roleErrorMessages.push(this.$t('Missing role'))
              this.validationError = true
            }
            if (f.type === 'schema:Person') {
              if (f.firstname.length < 1) {
                f.firstnameErrorMessages.push(this.$t('Missing firstname'))
                this.validationError = true
              }
              if (f.lastname.length < 1) {
                f.lastnameErrorMessages.push(this.$t('Missing lastname'))
                this.validationError = true
              }
            }
          }
          if (f.component === 'p-select') {
            if (f.predicate === 'edm:rights') {
              f.errorMessages = []
              missingLicense = false
              if (f.value.length < 1) {
                f.errorMessages.push(this.$t('Please select'))
                this.validationError = true
              }
            }
          }
          if (resourceType !== 'https://pid.phaidra.org/vocabulary/GXS7-ENXJ') {
            if (f.component === 'p-subject-oefos') {
              missingOefos = false
              f.errorMessages = []
              if (!hasReadonlyOefos) {
                if (f.value.length < 1) {
                  f.errorMessages.push(this.$t('Please select'))
                  this.validationError = true
                }
              }
            }
          }
          if (f.component === 'p-association') {
            missingAssociation = false
            f.errorMessages = []
            if (f.value.length < 1) {
              f.errorMessages.push(this.$t('Please select'))
              this.validationError = true
            }
          }
          if (f.component === 'p-file') {
            missingFile = false
            f.fileErrorMessages = []
            f.mimetypeErrorMessages = []
            if (!f.file) {
              f.fileErrorMessages.push(this.$t('Please select'))
              this.validationError = true
            }
            if (f.mimetype.length < 1 && (resourceType !== 'https://pid.phaidra.org/vocabulary/7AVS-Y482')) {
              f.mimetypeErrorMessages.push(this.$t('Please select'))
              this.validationError = true
            } else if (this.allowedMimetypes[resourceType]) {
              if (!this.allowedMimetypes[resourceType].includes(f.mimetype)) {
                f.mimetypeErrorMessages.push(this.$t('This file type is not supported for the chosen resource type.'))
                f.fileErrorMessages.push(this.$t('Wrong file format.'))
                this.validationError = true
              }
            }
          }
        }
      }

      if (missingTitle) {
        this.fieldsMissing.push(this.$t('Title'))
      }
      if (missingDescription) {
        this.fieldsMissing.push(this.$t('Description'))
      }
      if (missingKeyword) {
        this.fieldsMissing.push(this.$t('Keyword'))
      }
      if (missingRole) {
        this.fieldsMissing.push(this.$t('Role'))
      }
      if (missingLicense) {
        this.fieldsMissing.push(this.$t('License'))
      }
      if (missingResourceType) {
        this.fieldsMissing.push(this.$t('Resource type'))
      }
      if (missingObjectType) {
        this.fieldsMissing.push(this.$t('Object type'))
      }
      if (missingAssociation) {
        this.fieldsMissing.push(this.$t('Association'))
      }
      if (missingOefos) {
        this.fieldsMissing.push(this.$t('OEFOS Classification'))
      }
      if (missingFile) {
        this.fieldsMissing.push(this.$t('File'))
      }
      if (this.validationError) {
        this.$vuetify.goTo(0)
      }
      return !this.validationError
    },
    validateNoOefosNoAssoc() {
      this.validationError = false
      this.fieldsMissing = []
      let missingTitle = true
      let missingDescription = true
      let missingKeyword = true
      let missingRole = true
      let missingLicense = true
      let missingResourceType = true
      let missingObjectType = true
      let missingFile = true
      let resourceType = null
      for (const s of this.form.sections) {
        for (const f of s.fields) {
          if (f.predicate === 'dcterms:type') {
            resourceType = f.value
          }
        }
      }
      switch (resourceType) {
        case 'https://pid.phaidra.org/vocabulary/GXS7-ENXJ':
          // collection
          missingFile = false
          missingLicense = false
          missingObjectType = false
          break
        case 'https://pid.phaidra.org/vocabulary/T8GH-F4V8':
          // resource
          missingFile = false
          missingLicense = false
          break
      }

      for (const s of this.form.sections) {
        for (const f of s.fields) {
          if (f.predicate === 'dcterms:type') {
            missingResourceType = false
            if (f.value.length < 1) {
              f.errorMessages.push(this.$t('Please select'))
              this.validationError = true
            }
          }
          if (f.predicate === 'edm:hasType') {
            missingObjectType = false
            if (Object.prototype.hasOwnProperty.call(f, 'selectedTerms')) {
              if (f.selectedTerms.length < 1) {
                f.errorMessage = []
                f.errorMessages.push(this.$t('Please select one or more object types'))
                this.validationError = true
              }
            } else if (f.value.length < 1) {
              f.errorMessage = []
              f.errorMessages.push(this.$t('Please select one or more object types'))
              this.validationError = true
            }
          }
          if (f.component === 'p-title') {
            missingTitle = false
            f.titleErrorMessages = []
            if (f.title.length < 1) {
              f.titleErrorMessages.push(this.$t('Missing title'))
              this.validationError = true
            }
          }
          if ((f.predicate === 'bf:note') && (f.type === 'bf:Note')) {
            missingDescription = false
            f.errorMessages = []
            if (f.value.length < 1) {
              f.errorMessages.push(this.$t('Missing description'))
              this.validationError = true
            }
          }
          if (f.component === 'p-keyword') {
            missingKeyword = false
            f.errorMessages = []
            if (f.value.length < 1) {
              f.errorMessages.push(this.$t('Missing keywords'))
              this.validationError = true
            }
          }
          if ((f.component === 'p-entity') || (f.component === 'p-entity-extended')) {
            missingRole = false
            f.firstnameErrorMessages = []
            f.lastnameErrorMessages = []
            f.roleErrorMessages = []
            f.affiliationErrorMessages = []
            f.affiliationTextErrorMessages = []
            f.organizationErrorMessages = []
            f.organizationTextErrorMessages = []
            if (f.role.length < 1) {
              f.roleErrorMessages.push(this.$t('Missing role'))
              this.validationError = true
            }
            if (f.type === 'schema:Person') {
              if (f.firstname.length < 1) {
                f.firstnameErrorMessages.push(this.$t('Missing firstname'))
                this.validationError = true
              }
              if (f.lastname.length < 1) {
                f.lastnameErrorMessages.push(this.$t('Missing lastname'))
                this.validationError = true
              }
            }
          }
          if (f.component === 'p-select') {
            if (f.predicate === 'edm:rights') {
              f.errorMessages = []
              missingLicense = false
              if (f.value.length < 1) {
                f.errorMessages.push(this.$t('Please select'))
                this.validationError = true
              }
            }
          }
          if (f.component === 'p-file') {
            missingFile = false
            f.fileErrorMessages = []
            f.mimetypeErrorMessages = []
            if (!f.file) {
              f.fileErrorMessages.push(this.$t('Please select'))
              this.validationError = true
            }
            if (f.mimetype.length < 1) {
              f.mimetypeErrorMessages.push(this.$t('Please select'))
              this.validationError = true
            } else if (this.allowedMimetypes[resourceType]) {
              if (!this.allowedMimetypes[resourceType].includes(f.mimetype)) {
                f.mimetypeErrorMessages.push(this.$t('This file type is not supported for the chosen resource type.'))
                f.fileErrorMessages.push(this.$t('Wrong file format.'))
                this.validationError = true
              }
            }
          }
        }
      }

      if (missingTitle) {
        this.fieldsMissing.push(this.$t('Title'))
      }
      if (missingDescription) {
        this.fieldsMissing.push(this.$t('Description'))
      }
      if (missingKeyword) {
        this.fieldsMissing.push(this.$t('Keyword'))
      }
      if (missingRole) {
        this.fieldsMissing.push(this.$t('Role'))
      }
      if (missingLicense) {
        this.fieldsMissing.push(this.$t('License'))
      }
      if (missingResourceType) {
        this.fieldsMissing.push(this.$t('Resource type'))
      }
      if (missingObjectType) {
        this.fieldsMissing.push(this.$t('Object type'))
      }
      if (missingFile) {
        this.fieldsMissing.push(this.$t('File'))
      }
      if (this.validationError) {
        this.$vuetify.goTo(0)
      }
      return !this.validationError
    }
  }
}
