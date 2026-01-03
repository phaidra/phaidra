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
          'image/x-ms-bmp',
          'image/jp2',
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
    addAsterixIfNotPresent(value) {
      return value ? (value.includes('*') ? value : value + ' *') : value 
    },
    applySchemaBasedRequired() {
      const groupFirstInstanceMarked = {}
      
      for (const s of this.form.sections) {
        if (!s.fields) continue
        
        for (const f of s.fields) {
          if (f.mandatory === undefined && f.groupMandatory === undefined) {
            continue
          }
          
          if (f.mandatory === true) {
            f.required = true
          }
          
          if (f.groupMandatory === true && f.group) {
            const groupKey = f.group
            
            if (!groupFirstInstanceMarked[groupKey]) {
              f.required = true
              groupFirstInstanceMarked[groupKey] = true
            } else {
              f.required = false
            }
          }
        }
      }
    },
    applyAsterisksToLabels() {
      for (const s of this.form.sections) {
        if (!s.fields) continue
        
        for (const f of s.fields) {
          if (f.required === true) {
            if (f.component === 'p-title' && f.titleLabel) {
              f.titleLabel = this.addAsterixIfNotPresent(f.titleLabel)
            }
            if (f.component === 'p-text-field' && f.label) {
              f.label = this.addAsterixIfNotPresent(f.label)
            }
            if (f.component === 'p-keyword' && f.label) {
              f.label = this.addAsterixIfNotPresent(f.label)
            }
            if (f.component === 'p-select' && f.label) {
              f.label = this.addAsterixIfNotPresent(f.label)
            }
            if (f.component === 'p-file' && f.label) {
              f.label = this.addAsterixIfNotPresent(f.label)
            }
            if ((f.component === 'p-entity') || (f.component === 'p-entity-extended')) {
              if (f.label) f.label = this.addAsterixIfNotPresent(f.label)
              if (f.roleLabel) f.roleLabel = this.addAsterixIfNotPresent(f.roleLabel)
              if (f.firstnameLabel) f.firstnameLabel = this.addAsterixIfNotPresent(f.firstnameLabel)
              if (f.lastnameLabel) f.lastnameLabel = this.addAsterixIfNotPresent(f.lastnameLabel)
              if (f.component === 'p-entity-extended') {
                if (!f.organizationSelectLabel) f.organizationSelectLabel = 'Please choose'
                f.organizationSelectLabel = this.addAsterixIfNotPresent(f.organizationSelectLabel)
                if (!f.rorSearchLabel) f.rorSearchLabel = 'ROR Search'
                f.rorSearchLabel = this.addAsterixIfNotPresent(f.rorSearchLabel)
                if (!f.organizationTextLabel) f.organizationTextLabel = 'Organization'
                f.organizationTextLabel = this.addAsterixIfNotPresent(f.organizationTextLabel)
              }
            }
          }
        }
      }
    },
    markMandatoryWithOefosAndAssoc() {
      for (const s of this.form.sections) {
        for (const f of s.fields) {
          if (f.predicate === 'dcterms:type') {
            f.label = this.addAsterixIfNotPresent(f.label)
          }
          if (f.predicate === 'edm:hasType') {
            f.label = f.label = this.addAsterixIfNotPresent(f.label)
          }
          const hasSchemaMetadata = f.mandatory === true || f.groupMandatory === true
          
          if (f.component === 'p-title' && !hasSchemaMetadata) {
            f.titleLabel = f.titleLabel ? this.addAsterixIfNotPresent(f.titleLabel) : this.addAsterixIfNotPresent(f.type)
          }
          if ((f.predicate === 'bf:note') && (f.type === 'bf:Note') && !hasSchemaMetadata) {
            f.label = this.addAsterixIfNotPresent(f.label)
          }
          if (f.component === 'p-keyword' && !hasSchemaMetadata) {
            f.label = this.addAsterixIfNotPresent(f.label)
          }
          if (f.component === 'p-subject-oefos') {
            f.label = this.addAsterixIfNotPresent(f.label)
          }
          if (f.component === 'p-association') {
            f.label = this.addAsterixIfNotPresent(f.label)
          }
          if ((f.component === 'p-entity') || (f.component === 'p-entity-extended')) {
            if (!hasSchemaMetadata) {
              f.label = this.addAsterixIfNotPresent(f.label)
              f.roleLabel = this.addAsterixIfNotPresent(f.roleLabel)
              f.firstnameLabel = this.addAsterixIfNotPresent(f.firstnameLabel)
              f.lastnameLabel = this.addAsterixIfNotPresent(f.lastnameLabel)
            }
          }
          if (f.component === 'p-select') {
            if (f.predicate === 'edm:rights' && !hasSchemaMetadata) {
              f.label = this.addAsterixIfNotPresent(f.label)
            }
          }
          if (f.component === 'p-file' && !hasSchemaMetadata) {
            f.label = this.addAsterixIfNotPresent(f.label)
          }
        }
      }
      this.applySchemaBasedRequired()
      this.applyAsterisksToLabels()
    },
    markMandatoryWithoutKeywords() {
      for (const s of this.form.sections) {
        for (const f of s.fields) {
          if (f.predicate === 'dcterms:type') {
            f.label = this.addAsterixIfNotPresent(f.label)
          }
          if (f.predicate === 'edm:hasType') {
            f.label = this.addAsterixIfNotPresent(f.label)
          }
          // Skip label mutations for fields with schema metadata (components handle * display via required prop)
          const hasSchemaMetadata = f.mandatory === true || f.groupMandatory === true
          
          if (f.component === 'p-title' && !hasSchemaMetadata) {
            f.titleLabel = f.titleLabel ? this.addAsterixIfNotPresent(f.titleLabel) : this.addAsterixIfNotPresent(f.type)
          }
          if ((f.predicate === 'bf:note') && (f.type === 'bf:Note') && !hasSchemaMetadata) {
            f.label = this.addAsterixIfNotPresent(f.label)
          }
          if ((f.component === 'p-entity') || (f.component === 'p-entity-extended')) {
            // Only mutate labels if field doesn't have schema metadata
            if (!hasSchemaMetadata) {
              f.label = this.addAsterixIfNotPresent(f.label)
              f.roleLabel = this.addAsterixIfNotPresent(f.roleLabel)
              f.firstnameLabel = this.addAsterixIfNotPresent(f.firstnameLabel)
              f.lastnameLabel = this.addAsterixIfNotPresent(f.lastnameLabel)
            }
          }
          if (f.component === 'p-select') {
            if (f.predicate === 'edm:rights' && !hasSchemaMetadata) {
              f.label = this.addAsterixIfNotPresent(f.label)
            }
          }
          if (f.component === 'p-file' && !hasSchemaMetadata) {
            f.label = this.addAsterixIfNotPresent(f.label)
          }
        }
      }
      // Apply schema-based required flags
      this.applySchemaBasedRequired()
      // Apply asterisks to labels based on required prop (centralized)
      this.applyAsterisksToLabels()
    },
    markMandatoryWithoutKeywordsWithAbstract() {
      for (const s of this.form.sections) {
        for (const f of s.fields) {
          if (f.predicate === 'dcterms:type') {
            f.label = this.addAsterixIfNotPresent(f.label)
          }
          if (f.predicate === 'edm:hasType') {
            f.label = this.addAsterixIfNotPresent(f.label)
          }
          // Skip label mutations for fields with schema metadata (components handle * display via required prop)
          const hasSchemaMetadata = f.mandatory === true || f.groupMandatory === true
          
          if (f.component === 'p-title' && !hasSchemaMetadata) {
            f.titleLabel = f.titleLabel ? this.addAsterixIfNotPresent(f.titleLabel) : this.addAsterixIfNotPresent(f.type)
          }
          if ((f.predicate === 'bf:note') && (f.type === 'bf:Summary') && !hasSchemaMetadata) {
            f.label = this.addAsterixIfNotPresent(f.label)
          }
          if ((f.component === 'p-entity') || (f.component === 'p-entity-extended')) {
            // Only mutate labels if field doesn't have schema metadata
            if (!hasSchemaMetadata) {
              f.label = this.addAsterixIfNotPresent(f.label)
              f.roleLabel = this.addAsterixIfNotPresent(f.roleLabel)
              f.firstnameLabel = this.addAsterixIfNotPresent(f.firstnameLabel)
              f.lastnameLabel = this.addAsterixIfNotPresent(f.lastnameLabel)
            }
          }
          if (f.component === 'p-select') {
            if (f.predicate === 'edm:rights' && !hasSchemaMetadata) {
              f.label = this.addAsterixIfNotPresent(f.label)
            }
          }
          if (f.component === 'p-file' && !hasSchemaMetadata) {
            f.label = this.addAsterixIfNotPresent(f.label)
          }
        }
      }
      // Apply schema-based required flags
      this.applySchemaBasedRequired()
      // Apply asterisks to labels based on required prop (centralized)
      this.applyAsterisksToLabels()
    },
    markMandatory() {
      for (const s of this.form.sections) {
        for (const f of s.fields) {
          if (f.predicate === 'dcterms:type') {
            f.label = this.addAsterixIfNotPresent(f.label)
          }
          if (f.predicate === 'edm:hasType') {
            f.label = this.addAsterixIfNotPresent(f.label)
          }
          // Skip label mutations for fields with schema metadata (components handle * display via required prop)
          const hasSchemaMetadata = f.mandatory === true || f.groupMandatory === true
          
          if (f.component === 'p-title' && !hasSchemaMetadata) {
            f.titleLabel = f.titleLabel ? this.addAsterixIfNotPresent(f.titleLabel) : this.addAsterixIfNotPresent(f.type)
          }
          if ((f.predicate === 'bf:note') && (f.type === 'bf:Note') && !hasSchemaMetadata) {
            f.label = this.addAsterixIfNotPresent(f.label)
          }
          if (f.component === 'p-keyword' && !hasSchemaMetadata) {
            f.label = this.addAsterixIfNotPresent(f.label)
          }
          if ((f.component === 'p-entity') || (f.component === 'p-entity-extended')) {
            // Only mutate labels if field doesn't have schema metadata
            if (!hasSchemaMetadata) {
              f.label = this.addAsterixIfNotPresent(f.label)
              f.roleLabel = this.addAsterixIfNotPresent(f.roleLabel)
              f.firstnameLabel = this.addAsterixIfNotPresent(f.firstnameLabel)
              f.lastnameLabel = this.addAsterixIfNotPresent(f.lastnameLabel)
            }
          }
          if (f.component === 'p-select') {
            if (f.predicate === 'edm:rights' && !hasSchemaMetadata) {
              f.label = this.addAsterixIfNotPresent(f.label)
            }
          }
          if (f.component === 'p-file' && !hasSchemaMetadata) {
            f.label = this.addAsterixIfNotPresent(f.label)
          }
        }
      }
      // Apply schema-based required flags
      this.applySchemaBasedRequired()
      // Apply asterisks to labels based on required prop (centralized)
      this.applyAsterisksToLabels()
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
        if (!s.fields) continue
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
        case 'https://pid.phaidra.org/vocabulary/8MY0-BQDQ':
          // container
          this.mandatoryFieldsFound['File'] = true
          this.mandatoryFieldsFound['License'] = true
          this.mandatoryFieldsValidated['File'] = true
          this.mandatoryFieldsValidated['License'] = true
          break
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
          // link/resource - uses resourcelink instead of file
          this.mandatoryFieldsFound['File'] = true
          this.mandatoryFieldsValidated['File'] = true
          break
      }
      if (targetpid) {
        this.mandatoryFieldsFound['File'] = true
        this.mandatoryFieldsValidated['File'] = true
      }

      // Check for resourcelink section (for Link resource type)
      for (const s of this.form.sections) {
        if (s.type === 'resourcelink') {
          this.mandatoryFieldsFound['File'] = true
          if (s.resourcelink && s.resourcelink.length > 0) {
            this.mandatoryFieldsValidated['File'] = true
          }
        }
      }

      for (const s of this.form.sections) {
        if (!s.fields) continue // Skip sections without fields (like resourcelink)
        for (const f of s.fields) {
          console.log('checking p[' + f.predicate + '] c[' + f.component + ']') 
          if (f.predicate === 'dcterms:type') {
            this.mandatoryFieldsFound['Resource type'] = true
            if (f.value?.length > 0) {
              this.mandatoryFieldsValidated['Resource type'] = true
            }
          }
          if (f.predicate === 'edm:hasType') {
            this.mandatoryFieldsFound['Object type'] = true
            if (Object.prototype.hasOwnProperty.call(f, 'selectedTerms')) {
              if (f.selectedTerms.length > 0) {
                this.mandatoryFieldsValidated['Object type'] = true
              }
            } 
            if (f.value?.length > 0) {
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
          if ((f.predicate === 'bf:note') && ((f.type === 'bf:Note') || (f.type === 'bf:Summary'))) {
            this.mandatoryFieldsFound['Description'] = true
            if (f.value?.length > 0) {
              this.mandatoryFieldsValidated['Description'] = true
            }
          }
          if (f.component === 'p-keyword') {
            this.mandatoryFieldsFound['Keyword'] = true
            if (f.value?.length > 0) {
              this.mandatoryFieldsValidated['Keyword'] = true
            }
          }
          if ((f.component === 'p-entity') || (f.component === 'p-entity-extended') || (f.component === 'p-entity-fixedrole-person')) {
            console.log('checking p[' + f.predicate + '] c[' + f.component + '] r[' + f.role + '] fn[' + f.firstname + '] ln[' + f.lastname + '] n[' + f.name + '] org[' + f.organization + '] orgtext[' + f.organizationText + ']')
            if (f.role.length > 0) {
              this.mandatoryFieldsFound['Role'] = true
            }
            if (f.type === 'schema:Person') {
              if (f.firstname) {
                if (f.firstname.length > 0) {
                  this.mandatoryFieldsValidated['Role'] = true
                }
              }
              if (f.lastname) {
                if (f.lastname.length > 0) {
                  this.mandatoryFieldsValidated['Role'] = true
                }
              }
              if (f.name) {
                if (f.name.length > 0) {
                  this.mandatoryFieldsValidated['Role'] = true
                }
              }
            }
            if (f.type === 'schema:Organization') {
              if (f.organization) {
                if (f.organization.length > 0) {
                  this.mandatoryFieldsValidated['Role'] = true
                }
              }
              if (f.organizationText) {
                if (f.organizationText.length > 0) {
                  this.mandatoryFieldsValidated['Role'] = true
                }
              }
            }
          }
          if (f.component === 'p-select') {
            if (f.predicate === 'edm:rights') {
              this.mandatoryFieldsFound['License'] = true
              if (f.value?.length > 0) {
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
                if (f.value?.length > 0) {
                  this.mandatoryFieldsValidated['OEFOS Classification'] = true
                }
              }
            }
          }
          if (f.component === 'p-association') {
            this.mandatoryFieldsFound['Association'] = true
            if (f.value?.length > 0) {
              this.mandatoryFieldsValidated['Association'] = true
            }
          }
          if (f.component === 'p-file') {
            f.fileErrorMessages = []
            console.log('checking p[' + f.predicate + '] c[' + f.component + '] mimetype[' + f.mimetype + '] file[' + f.file + ']')
            console.log(f.file)
            this.mandatoryFieldsFound['File'] = true
            if (f.file) {
              this.mandatoryFieldsValidated['File'] = true
            }
            if (this.allowedMimetypes[resourceType]) {
              if (!this.allowedMimetypes[resourceType].includes(f.mimetype)) {
                console.error('wrong file format')
                f.mimetypeErrorMessages.push(this.$t('This file type is not supported for the chosen resource type.'))
                f.fileErrorMessages.push(this.$t('Wrong file format.'))
                this.validationError = true
              }
            } else {
              this.mandatoryFieldsValidated['File'] = true
            }
          }
          if ((f.component === 'p-filename-readonly') || f.component === 'p-filename') {
            console.log('checking p[' + f.predicate + '] c[' + f.component + '] v[' + f.value + ']')
            this.mandatoryFieldsFound['File'] = true
            if (f.value?.length > 0) {
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
        if (!s.fields) continue // Skip sections without fields (like resourcelink)
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
        case 'https://pid.phaidra.org/vocabulary/8MY0-BQDQ':
          // container
          this.mandatoryFieldsFound['File'] = true
          this.mandatoryFieldsFound['License'] = true
          this.mandatoryFieldsValidated['File'] = true
          this.mandatoryFieldsValidated['License'] = true
          break
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
          // link/resource - uses resourcelink instead of file
          this.mandatoryFieldsFound['File'] = true
          this.mandatoryFieldsValidated['File'] = true
          break
      }
      if (targetpid) {
        this.mandatoryFieldsFound['File'] = true
        this.mandatoryFieldsValidated['File'] = true
      }

      // Check for resourcelink section (for Link resource type)
      for (const s of this.form.sections) {
        if (s.type === 'resourcelink') {
          this.mandatoryFieldsFound['File'] = true
          if (s.resourcelink && s.resourcelink.length > 0) {
            this.mandatoryFieldsValidated['File'] = true
          }
        }
      }

      for (const s of this.form.sections) {
        if (!s.fields) continue // Skip sections without fields (like resourcelink)
        for (const f of s.fields) {
          console.log('checking p[' + f.predicate + '] c[' + f.component + ']') 
          if (f.predicate === 'dcterms:type') {
            this.mandatoryFieldsFound['Resource type'] = true
            if (f.value?.length > 0) {
              this.mandatoryFieldsValidated['Resource type'] = true
            }
          }
          if (f.predicate === 'edm:hasType') {
            this.mandatoryFieldsFound['Object type'] = true
            if (Object.prototype.hasOwnProperty.call(f, 'selectedTerms')) {
              if (f.selectedTerms.length > 0) {
                this.mandatoryFieldsValidated['Object type'] = true
              }
            } 
            if (f.value?.length > 0) {
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
          if ((f.predicate === 'bf:note') && ((f.type === 'bf:Note') || (f.type === 'bf:Summary'))) {
            this.mandatoryFieldsFound['Description'] = true
            if (f.value?.length > 0) {
              this.mandatoryFieldsValidated['Description'] = true
            }
          }
          if (f.component === 'p-keyword') {
            this.mandatoryFieldsFound['Keyword'] = true
            if (f.value?.length > 0) {
              this.mandatoryFieldsValidated['Keyword'] = true
            }
          }
          if ((f.component === 'p-entity') || (f.component === 'p-entity-extended') || (f.component === 'p-entity-fixedrole-person')) {
            console.log('checking p[' + f.predicate + '] c[' + f.component + '] r[' + f.role + '] fn[' + f.firstname + '] ln[' + f.lastname + '] n[' + f.name + '] org[' + f.organization + '] orgtext[' + f.organizationText + ']')
            if (f.role.length > 0) {
              this.mandatoryFieldsFound['Role'] = true
            }
            if (f.type === 'schema:Person') {
              if (f.firstname) {
                if (f.firstname.length > 0) {
                  this.mandatoryFieldsValidated['Role'] = true
                }
              }
              if (f.lastname) {
                if (f.lastname.length > 0) {
                  this.mandatoryFieldsValidated['Role'] = true
                }
              }
              if (f.name) {
                if (f.name.length > 0) {
                  this.mandatoryFieldsValidated['Role'] = true
                }
              }
            }
            if (f.type === 'schema:Organization') {
              if (f.organization) {
                if (f.organization.length > 0) {
                  this.mandatoryFieldsValidated['Role'] = true
                }
              }
              if (f.organizationText) {
                if (f.organizationText.length > 0) {
                  this.mandatoryFieldsValidated['Role'] = true
                }
              }
            }
          }
          if (f.component === 'p-select') {
            if (f.predicate === 'edm:rights') {
              this.mandatoryFieldsFound['License'] = true
              if (f.value?.length > 0) {
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
                if (f.value?.length > 0) {
                  this.mandatoryFieldsValidated['OEFOS Classification'] = true
                }
              }
            }
          }
          if (f.component === 'p-file') {
            f.fileErrorMessages = []
            console.log('checking p[' + f.predicate + '] c[' + f.component + '] mimetype[' + f.mimetype + '] file[' + f.file + ']')
            console.log(f.file)
            this.mandatoryFieldsFound['File'] = true
            if (f.file) {
              this.mandatoryFieldsValidated['File'] = true
            }
            if (this.allowedMimetypes[resourceType]) {
              if (!this.allowedMimetypes[resourceType].includes(f.mimetype)) {
                console.error('wrong file format')
                f.mimetypeErrorMessages.push(this.$t('This file type is not supported for the chosen resource type.'))
                f.fileErrorMessages.push(this.$t('Wrong file format.'))
                this.validationError = true
              }
            } else {
              this.mandatoryFieldsValidated['File'] = true
            }
          }
          if ((f.component === 'p-filename-readonly') || f.component === 'p-filename') {
            console.log('checking p[' + f.predicate + '] c[' + f.component + '] v[' + f.value + ']')
            this.mandatoryFieldsFound['File'] = true
            if (f.value?.length > 0) {
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
    validationThesis(targetpid) {
      let hasAut = false
      let hasAdvisor = false
      this.validationError = false
      this.fieldsMissing = []
      this.mandatoryFieldsFound = {
        'Title': false,
        'Description': false,
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
        'Role': false,
        'Author': false,
        'Advisor': false,
        'License': false,
        'File': false
      }
      let resourceType = null
      for (const s of this.form.sections) {
        if (!s.fields) continue // Skip sections without fields (like resourcelink)
        for (const f of s.fields) {
          if (f.predicate === 'dcterms:type') {
            resourceType = f.value
            console.log('resourceType ' + f['skos:prefLabel'][0]['@value'])
          }
        }
      }
      switch (resourceType) {
        case 'https://pid.phaidra.org/vocabulary/8MY0-BQDQ':
          // container
          this.mandatoryFieldsFound['File'] = true
          this.mandatoryFieldsFound['License'] = true
          this.mandatoryFieldsValidated['File'] = true
          this.mandatoryFieldsValidated['License'] = true
          break
        case 'https://pid.phaidra.org/vocabulary/GXS7-ENXJ':
          // collection
          this.mandatoryFieldsFound['File'] = true
          this.mandatoryFieldsFound['License'] = true
          this.mandatoryFieldsFound['Object type'] = true
          this.mandatoryFieldsValidated['File'] = true
          this.mandatoryFieldsValidated['License'] = true
          this.mandatoryFieldsValidated['Object type'] = true
          break
        case 'https://pid.phaidra.org/vocabulary/T8GH-F4V8':
          // resource
          this.mandatoryFieldsFound['File'] = true
          this.mandatoryFieldsValidated['File'] = true
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
            if (f.value?.length > 0) {
              this.mandatoryFieldsValidated['Resource type'] = true
            }
          }
          if (f.predicate === 'edm:hasType') {
            console.log('checking p[' + f.predicate + '] c[' + f.component + '] v[' + f.value + '] selterms[' + f.selectedTerms?.length + ']') 
            this.mandatoryFieldsFound['Object type'] = true
            if (Object.prototype.hasOwnProperty.call(f, 'selectedTerms')) {
              if (f.selectedTerms.length > 0) {
                this.mandatoryFieldsValidated['Object type'] = true
              }
            } 
            if (f.value?.length > 0) {
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
          if ((f.predicate === 'bf:note') && ((f.type === 'bf:Note') || (f.type === 'bf:Summary'))) {
            console.log('checking p[' + f.predicate + '] c[' + f.component + '] v[' + f.value + ']') 
            this.mandatoryFieldsFound['Description'] = true
            if (f.value?.length > 0) {
              this.mandatoryFieldsValidated['Description'] = true
            }
          }
          if ((f.component === 'p-entity') || (f.component === 'p-entity-extended') || (f.component === 'p-entity-fixedrole-person')) {
            console.log('checking p[' + f.predicate + '] c[' + f.component + '] r[' + f.role + '] fn[' + f.firstname + '] ln[' + f.lastname + '] n[' + f.name + '] org[' + f.organization + '] orgtext[' + f.organizationText + ']')
            if (f.role.length > 0) {
              this.mandatoryFieldsFound['Role'] = true
            }
            if (f.type === 'schema:Person') {
              if (f.firstname) {
                if (f.firstname.length > 0) {
                  this.mandatoryFieldsValidated['Role'] = true
                }
              }
              if (f.lastname) {
                if (f.lastname.length > 0) {
                  this.mandatoryFieldsValidated['Role'] = true
                }
              }
              if (f.name) {
                if (f.name.length > 0) {
                  this.mandatoryFieldsValidated['Role'] = true
                }
              }
            }
            if (f.type === 'schema:Organization') {
              if (f.organization) {
                if (f.organization.length > 0) {
                  this.mandatoryFieldsValidated['Role'] = true
                }
              }
              if (f.organizationText) {
                if (f.organizationText.length > 0) {
                  this.mandatoryFieldsValidated['Role'] = true
                }
              }
            }
            if (f.role === 'role:aut') {
              if (f.type === 'schema:Person') {
                if (f.firstname.length > 0) {
                  hasAut = true
                  this.mandatoryFieldsValidated['Author'] = true
                }
                if (f.lastname.length > 0) {
                  hasAut = true
                  this.mandatoryFieldsValidated['Author'] = true
                }
                if (f.name.length > 0) {
                  hasAut = true
                  this.mandatoryFieldsValidated['Author'] = true
                }
              }
            }
            if (f.role === 'role:advisor' || f.role === 'role:dgs') {
              if (f.type === 'schema:Person') {
                if (f.firstname.length > 0) {
                  hasAdvisor = true
                  this.mandatoryFieldsValidated['Advisor'] = true
                }
                if (f.lastname.length > 0) {
                  hasAdvisor = true
                  this.mandatoryFieldsValidated['Advisor'] = true
                }
                if (f.name.length > 0) {
                  hasAdvisor = true
                  this.mandatoryFieldsValidated['Advisor'] = true
                }
              }
            }
          }
          if (f.component === 'p-select') {
            if (f.predicate === 'edm:rights') {
              console.log('checking p[' + f.predicate + '] c[' + f.component + '] v[' + f.value + ']')
              this.mandatoryFieldsFound['License'] = true
              if (f.value?.length > 0) {
                this.mandatoryFieldsValidated['License'] = true
              }
            }
          }
          if (f.component === 'p-file') {
            f.fileErrorMessages = []
            console.log('checking p[' + f.predicate + '] c[' + f.component + '] mimetype[' + f.mimetype + '] file[' + f.file + ']')
            console.log(f.file)
            this.mandatoryFieldsFound['File'] = true
            if (f.file) {
              this.mandatoryFieldsValidated['File'] = true
            }
            if (this.allowedMimetypes[resourceType]) {
              if (!this.allowedMimetypes[resourceType].includes(f.mimetype)) {
                console.error('wrong file format')
                f.mimetypeErrorMessages.push(this.$t('This file type is not supported for the chosen resource type.'))
                f.fileErrorMessages.push(this.$t('Wrong file format.'))
                this.validationError = true
              }
            } else {
              this.mandatoryFieldsValidated['File'] = true
            }
          }
          if ((f.component === 'p-filename-readonly') || f.component === 'p-filename') {
            console.log('checking p[' + f.predicate + '] c[' + f.component + '] v[' + f.value + ']')
            this.mandatoryFieldsFound['File'] = true
            if (f.value?.length > 0) {
              this.mandatoryFieldsValidated['File'] = true
            }
          }
        }
      }

      if (!hasAut || !hasAdvisor) {
        this.validationError = true
        console.error('Author or advisor missing')
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
    validationWithoutKeywords(targetpid) {
      this.validationError = false
      this.fieldsMissing = []
      this.mandatoryFieldsFound = {
        'Title': false,
        'Description': false,
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
        'Role': false,
        'License': false,
        'File': false
      }
      let resourceType = null
      for (const s of this.form.sections) {
        if (!s.fields) continue // Skip sections without fields (like resourcelink)
        for (const f of s.fields) {
          if (f.predicate === 'dcterms:type') {
            resourceType = f.value
            console.log('resourceType ' + f['skos:prefLabel'][0]['@value'])
          }
        }
      }
      switch (resourceType) {
        case 'https://pid.phaidra.org/vocabulary/8MY0-BQDQ':
          // container
          this.mandatoryFieldsFound['File'] = true
          this.mandatoryFieldsFound['License'] = true
          this.mandatoryFieldsFound['Keyword'] = true
          this.mandatoryFieldsValidated['File'] = true
          this.mandatoryFieldsValidated['License'] = true
          this.mandatoryFieldsValidated['Keyword'] = true
          break
        case 'https://pid.phaidra.org/vocabulary/GXS7-ENXJ':
          // collection
          this.mandatoryFieldsFound['File'] = true
          this.mandatoryFieldsFound['License'] = true
          this.mandatoryFieldsFound['Object type'] = true
          this.mandatoryFieldsValidated['File'] = true
          this.mandatoryFieldsValidated['License'] = true
          this.mandatoryFieldsValidated['Object type'] = true
          break
        case 'https://pid.phaidra.org/vocabulary/T8GH-F4V8':
          // resource
          this.mandatoryFieldsFound['File'] = true
          this.mandatoryFieldsValidated['File'] = true
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
            if (f.value?.length > 0) {
              this.mandatoryFieldsValidated['Resource type'] = true
            }
          }
          if (f.predicate === 'edm:hasType') {
            console.log('checking p[' + f.predicate + '] c[' + f.component + '] v[' + f.value + '] selterms[' + f.selectedTerms?.length + ']') 
            this.mandatoryFieldsFound['Object type'] = true
            if (Object.prototype.hasOwnProperty.call(f, 'selectedTerms')) {
              if (f.selectedTerms.length > 0) {
                this.mandatoryFieldsValidated['Object type'] = true
              }
            } 
            if (f.value?.length > 0) {
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
          if ((f.predicate === 'bf:note') && ((f.type === 'bf:Note') || (f.type === 'bf:Summary'))) {
            console.log('checking p[' + f.predicate + '] c[' + f.component + '] v[' + f.value + ']') 
            this.mandatoryFieldsFound['Description'] = true
            if (f.value?.length > 0) {
              this.mandatoryFieldsValidated['Description'] = true
            }
          }
          if ((f.component === 'p-entity') || (f.component === 'p-entity-extended') || (f.component === 'p-entity-fixedrole-person')) {
            console.log('checking p[' + f.predicate + '] c[' + f.component + '] r[' + f.role + '] fn[' + f.firstname + '] ln[' + f.lastname + '] n[' + f.name + '] org[' + f.organization + '] orgtext[' + f.organizationText + ']')
            if (f.role.length > 0) {
              this.mandatoryFieldsFound['Role'] = true
            }
            if (f.type === 'schema:Person') {
              if (f.firstname) {
                if (f.firstname.length > 0) {
                  this.mandatoryFieldsValidated['Role'] = true
                }
              }
              if (f.lastname) {
                if (f.lastname.length > 0) {
                  this.mandatoryFieldsValidated['Role'] = true
                }
              }
              if (f.name) {
                if (f.name.length > 0) {
                  this.mandatoryFieldsValidated['Role'] = true
                }
              }
            }
            if (f.type === 'schema:Organization') {
              if (f.organization) {
                if (f.organization.length > 0) {
                  this.mandatoryFieldsValidated['Role'] = true
                }
              }
              if (f.organizationText) {
                if (f.organizationText.length > 0) {
                  this.mandatoryFieldsValidated['Role'] = true
                }
              }
            }
          }
          if (f.component === 'p-select') {
            if (f.predicate === 'edm:rights') {
              console.log('checking p[' + f.predicate + '] c[' + f.component + '] v[' + f.value + ']')
              this.mandatoryFieldsFound['License'] = true
              if (f.value?.length > 0) {
                this.mandatoryFieldsValidated['License'] = true
              }
            }
          }
          if (f.component === 'p-file') {
            f.fileErrorMessages = []
            console.log('checking p[' + f.predicate + '] c[' + f.component + '] mimetype[' + f.mimetype + '] file[' + f.file + ']')
            console.log(f.file)
            this.mandatoryFieldsFound['File'] = true
            if (f.file) {
              this.mandatoryFieldsValidated['File'] = true
            }
            if (this.allowedMimetypes[resourceType]) {
              if (!this.allowedMimetypes[resourceType].includes(f.mimetype)) {
                console.error('wrong file format')
                f.mimetypeErrorMessages.push(this.$t('This file type is not supported for the chosen resource type.'))
                f.fileErrorMessages.push(this.$t('Wrong file format.'))
                this.validationError = true
              }
            } else {
              this.mandatoryFieldsValidated['File'] = true
            }
          }
          if ((f.component === 'p-filename-readonly') || f.component === 'p-filename') {
            console.log('checking p[' + f.predicate + '] c[' + f.component + '] v[' + f.value + ']')
            this.mandatoryFieldsFound['File'] = true
            if (f.value?.length > 0) {
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
        if (!s.fields) continue // Skip sections without fields (like resourcelink)
        for (const f of s.fields) {
          if (f.predicate === 'dcterms:type') {
            resourceType = f.value
            console.log('resourceType ' + f['skos:prefLabel'][0]['@value'])
          }
        }
      }
      switch (resourceType) {
        case 'https://pid.phaidra.org/vocabulary/8MY0-BQDQ':
          // container
          this.mandatoryFieldsFound['File'] = true
          this.mandatoryFieldsFound['License'] = true
          this.mandatoryFieldsValidated['File'] = true
          this.mandatoryFieldsValidated['License'] = true
          break
        case 'https://pid.phaidra.org/vocabulary/GXS7-ENXJ':
          // collection
          this.mandatoryFieldsFound['File'] = true
          this.mandatoryFieldsFound['License'] = true
          this.mandatoryFieldsFound['Object type'] = true
          this.mandatoryFieldsValidated['File'] = true
          this.mandatoryFieldsValidated['License'] = true
          this.mandatoryFieldsValidated['Object type'] = true
          break
        case 'https://pid.phaidra.org/vocabulary/T8GH-F4V8':
          // resource
          this.mandatoryFieldsFound['File'] = true
          this.mandatoryFieldsValidated['File'] = true
          break
      }
      if (targetpid) {
        this.mandatoryFieldsFound['File'] = true
        this.mandatoryFieldsValidated['File'] = true
      }
      for (const s of this.form.sections) {
        if (s.type === 'resourcelink') {
          this.mandatoryFieldsFound['File'] = true
          if (s.resourcelink && s.resourcelink.length > 0) {
            this.mandatoryFieldsValidated['File'] = true
          }
        }
      }
      
      for (const s of this.form.sections) {
        if (!s.fields) continue // Skip sections without fields (like resourcelink)
        for (const f of s.fields) {
          if (f.predicate === 'dcterms:type') {
            console.log('checking p[' + f.predicate + '] c[' + f.component + '] v[' + f.value + ']') 
            this.mandatoryFieldsFound['Resource type'] = true
            if (f.value?.length > 0) {
              this.mandatoryFieldsValidated['Resource type'] = true
            }
          }
          if (f.predicate === 'edm:hasType') {
            console.log('checking p[' + f.predicate + '] c[' + f.component + '] v[' + f.value + '] selterms[' + f.selectedTerms?.length + ']') 
            this.mandatoryFieldsFound['Object type'] = true
            if (Object.prototype.hasOwnProperty.call(f, 'selectedTerms')) {
              if (f.selectedTerms.length > 0) {
                this.mandatoryFieldsValidated['Object type'] = true
              }
            } 
            if (f.value?.length > 0) {
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
          if ((f.predicate === 'bf:note') && ((f.type === 'bf:Note') || (f.type === 'bf:Summary'))) {
            console.log('checking p[' + f.predicate + '] c[' + f.component + '] v[' + f.value + ']') 
            this.mandatoryFieldsFound['Description'] = true
            if (f.value?.length > 0) {
              this.mandatoryFieldsValidated['Description'] = true
            }
          }
          if (f.component === 'p-keyword') {
            console.log('checking p[' + f.predicate + '] c[' + f.component + '] v[' + f.value + ']') 
            this.mandatoryFieldsFound['Keyword'] = true
            if (f.value?.length > 0) {
              this.mandatoryFieldsValidated['Keyword'] = true
            }
          }
          if ((f.component === 'p-entity') || (f.component === 'p-entity-extended') || (f.component === 'p-entity-fixedrole-person')) {
            console.log('checking p[' + f.predicate + '] c[' + f.component + '] r[' + f.role + '] fn[' + f.firstname + '] ln[' + f.lastname + '] n[' + f.name + '] org[' + f.organization + '] orgtext[' + f.organizationText + ']')
            if (f.role.length > 0) {
              this.mandatoryFieldsFound['Role'] = true
            }
            if (f.type === 'schema:Person') {
              if (f.firstname) {
                if (f.firstname.length > 0) {
                  this.mandatoryFieldsValidated['Role'] = true
                }
              }
              if (f.lastname) {
                if (f.lastname.length > 0) {
                  this.mandatoryFieldsValidated['Role'] = true
                }
              }
              if (f.name) {
                if (f.name.length > 0) {
                  this.mandatoryFieldsValidated['Role'] = true
                }
              }
            }
            if (f.type === 'schema:Organization') {
              if (f.organization) {
                if (f.organization.length > 0) {
                  this.mandatoryFieldsValidated['Role'] = true
                }
              }
              if (f.organizationText) {
                if (f.organizationText.length > 0) {
                  this.mandatoryFieldsValidated['Role'] = true
                }
              }
            }
          }
          if (f.component === 'p-select') {
            if (f.predicate === 'edm:rights') {
              console.log('checking p[' + f.predicate + '] c[' + f.component + '] v[' + f.value + ']')
              this.mandatoryFieldsFound['License'] = true
              if (f.value?.length > 0) {
                this.mandatoryFieldsValidated['License'] = true
              }
            }
          }
          if (f.component === 'p-file') {
            f.fileErrorMessages = []
            console.log('checking p[' + f.predicate + '] c[' + f.component + '] mimetype[' + f.mimetype + '] file[' + f.file + ']')
            console.log(f.file)
            this.mandatoryFieldsFound['File'] = true
            if (f.file) {
              this.mandatoryFieldsValidated['File'] = true
            }
            if (this.allowedMimetypes[resourceType]) {
              if (!this.allowedMimetypes[resourceType].includes(f.mimetype)) {
                console.error('wrong file format')
                f.mimetypeErrorMessages.push(this.$t('This file type is not supported for the chosen resource type.'))
                f.fileErrorMessages.push(this.$t('Wrong file format.'))
                this.validationError = true
              }
            } else {
              this.mandatoryFieldsValidated['File'] = true
            }
          }
          if ((f.component === 'p-filename-readonly') || f.component === 'p-filename') {
            console.log('checking p[' + f.predicate + '] c[' + f.component + '] v[' + f.value + ']')
            this.mandatoryFieldsFound['File'] = true
            if (f.value?.length > 0) {
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
