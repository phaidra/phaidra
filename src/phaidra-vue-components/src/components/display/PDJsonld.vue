<template>

  <p-d-jsonld-layout v-if="jsonld" :jsonld="jsonld" class="pdjsonld-grid-compat">

    <template v-if="pid && !predicatesToHide.includes('pid')"  v-slot:pid>
      <v-row>
        <v-col :md="labelColMd" cols="12" class="pdlabel text-secondary font-weight-bold text-md-right">{{ $t('Persistent identifier') }}</v-col>
        <v-col :md="valueColMd" cols="12"><a :href="`${instance.baseurl}/${pid}`">{{ instance.baseurl }}/{{ pid }}</a></v-col>
      </v-row>
    </template>

    <template v-slot:role>
      <template v-for="(role, i) of roles" :key="componentid+'role'+i">
        <template v-if="!predicatesToHide.includes(role.p)">
          <p-d-entity :role="role.p" :entity="e" :hideLabel="j !== 0" v-for="(e, j) in getEntities(role.p, role.o)" :key="componentid+'entity'+role.p+i+j" v-bind="displayProperties"></p-d-entity>
          <v-row v-if="entitiesLimited[role.p] && !showAllEntities[role.p]" :key="componentid+'entitymore'+role.p">
            <v-col :md="valueColMd" :offset-md="labelColMd">
              <span class="mx-2 text-primary" @click="setShowAllEntities(role.p)">... {{ $t('show all') }}</span>
            </v-col>
          </v-row>
        </template>
      </template>
    </template>

    <template v-if="!predicatesToHide.includes('dce:subject')"  v-slot:["dce:subject"]>
      <p-d-keyword :p="'dce:subject'" :language="language === 'xxx' ? null : language" :keywords="keywords" v-for="(keywords, language) in langKeywords" :key="componentid+'kw'+language" v-bind="displayProperties"></p-d-keyword>
    </template>

    <template  v-slot:overallAccessibility v-if="overallAccessibility">
        <p-d-accessibility :p="'overallAccessibility'" :o="overallAccessibility" v-bind="displayProperties"></p-d-accessibility>
    </template>
    <template v-if="jsonld && jsonld['dcterms:subject']" v-slot:["dcterms:subject"]>
      <template v-for="(subject, j) in jsonld['dcterms:subject']" :key="componentid+'subj'+j">
        <p-d-skos-preflabel v-if="subject['@type']!=='phaidra:Subject'" :p="'dcterms:subject'" :o="subject" v-bind="displayProperties"></p-d-skos-preflabel>
      </template>
    </template>

    <template v-slot:["phaidra:Subject"]>
      <template v-if="jsonld && jsonld['dcterms:subject']">
        <template v-for="(subject, j) in jsonld['dcterms:subject']" :key="componentid+'subjph'+j">
          <v-card variant="outlined" class="mt-4" v-if="subject['@type']==='phaidra:Subject'">
            <v-card-text>
              <div class="text-label-medium text-uppercase mb-4">{{ $t('SUBJECT_SECTION') }}</div>
              <p-d-jsonld :jsonld="subject" v-bind="displayProperties"></p-d-jsonld>
            </v-card-text>
          </v-card>
        </template>
      </template>
    </template>

    <template v-for="entry in jsonldSlotEntries" :key="String(entry.p) + '-' + componentid" #[entry.slotKey]>
        <template v-if="entry.p==='rdam:P30004'">
          <p-d-identifier :p="entry.p" :o="item" v-for="(item, j) in entry.o" :key="componentid+'hasid'+j" v-bind="displayProperties"></p-d-identifier>
        </template>

        <template v-else-if="entry.p==='edm:hasType'">
          <p-d-skos-preflabel :p="entry.p" :o="item" v-for="(item, j) in entry.o" :key="componentid+'objtyp'+j" v-bind="displayProperties"></p-d-skos-preflabel>
        </template>

        <template v-else-if="entry.p==='schema:genre'">
          <p-d-skos-preflabel :p="entry.p" :o="item" v-for="(item, j) in entry.o" :key="componentid+'genre'+j" v-bind="displayProperties"></p-d-skos-preflabel>
        </template>

        <template v-else-if="entry.p==='schema:accessMode'">
          <p-d-skos-preflabel :p="entry.p" :o="item" v-for="(item, j) in entry.o" :key="componentid+'accessMode'+j" v-bind="displayProperties"></p-d-skos-preflabel>
        </template>
        
        <template v-else-if="entry.p==='schema:accessibilityFeature'">
          <p-d-skos-preflabel :p="entry.p" :o="item" v-for="(item, j) in entry.o" :key="componentid+'accessibilityFeature'+j" v-bind="displayProperties"></p-d-skos-preflabel>
        </template>

        <template v-else-if="entry.p==='schema:accessibilityControl'">
          <p-d-skos-preflabel :p="entry.p" :o="item" v-for="(item, j) in entry.o" :key="componentid+'accessibilityControl'+j" v-bind="displayProperties"></p-d-skos-preflabel>
        </template>

        <template v-else-if="entry.p==='schema:accessibilityHazard'">
          <p-d-skos-preflabel :p="entry.p" :o="item" v-for="(item, j) in entry.o" :key="componentid+'accessibilityHazard'+j" v-bind="displayProperties"></p-d-skos-preflabel>
        </template>

        <template v-else-if="entry.p==='oaire:version'">
          <p-d-skos-preflabel :p="entry.p" :o="item" v-for="(item, j) in entry.o" :key="componentid+'oairev'+j" v-bind="displayProperties"></p-d-skos-preflabel>
        </template>

        <template v-else-if="entry.p==='dcterms:accessRights'">
          <p-d-skos-preflabel :p="entry.p" :o="item" v-for="(item, j) in entry.o" :key="componentid+'dtar'+j" v-bind="displayProperties"></p-d-skos-preflabel>
        </template>

        <template v-else-if="entry.p==='rdau:P60059'">
          <p-d-skos-preflabel :p="entry.p" :o="item" v-for="(item, j) in entry.o" :key="componentid+'P60059'+j" v-bind="displayProperties"></p-d-skos-preflabel>
        </template>

        <template v-else-if="entry.p==='dce:title'">
          <p-d-title :o="t" v-for="(t, j) in entry.o" :key="componentid+'title'+j" v-bind="displayProperties"></p-d-title>
        </template>

        <template v-else-if="entry.p==='bf:note'">
          <p-d-skos-preflabel :p="entry.p" :o="item" v-for="(item, j) in entry.o" :key="componentid+'text'+j" v-bind="displayProperties"></p-d-skos-preflabel>
        </template>

        <template v-else-if="entry.p==='bf:tableOfContents'">
          <p-d-skos-preflabel :p="entry.p" :o="item" v-for="(item, j) in entry.o" :key="componentid+'toc'+j" v-bind="displayProperties"></p-d-skos-preflabel>
        </template>

        <template v-else-if="entry.p==='dcterms:language'">
          <template v-for="(item, j) in entry.o" :key="componentid+'lan'+j">
            <p-d-skos-preflabel v-if="(typeof item === 'object') && (item !== null) && item.hasOwnProperty('skos:exactMatch')" :p="entry.p" :o="item" v-bind="displayProperties"></p-d-skos-preflabel>
            <p-d-labeled-value v-else :p="entry.p" :o="item" v-bind="displayProperties"></p-d-labeled-value>
          </template>
        </template>

        <template v-else-if="entry.p==='schema:subtitleLanguage'">
          <template v-for="(item, j) in entry.o" :key="componentid+'sublan'+j">
            <p-d-skos-preflabel v-if="(typeof item === 'object') && (item !== null) && item.hasOwnProperty('skos:exactMatch')" :p="entry.p" :o="item" v-bind="displayProperties"></p-d-skos-preflabel>
            <p-d-labeled-value v-else :p="entry.p" :o="item" v-bind="displayProperties"></p-d-labeled-value>
          </template>
        </template>

        <template v-else-if="entry.p==='schema:availableLanguage'">
          <template v-for="(item, j) in entry.o" :key="componentid+'availan'+j">
            <p-d-skos-preflabel v-if="(typeof item === 'object') && (item !== null) && item.hasOwnProperty('skos:exactMatch')" :p="entry.p" :o="item" v-bind="displayProperties"></p-d-skos-preflabel>
            <p-d-labeled-value v-else :p="entry.p" :o="item" v-bind="displayProperties"></p-d-labeled-value>
          </template>
        </template>

        <template v-else-if="entry.p==='dcterms:date'">
          <p-d-date :p="entry.p" :o="item" v-for="(item, j) in entry.o" :key="componentid+'date'+j" v-bind="displayProperties"></p-d-date>
        </template>

        <template v-else-if="entry.p==='dcterms:created'">
          <p-d-date :p="entry.p" :o="item" v-for="(item, j) in entry.o" :key="componentid+'created'+j" v-bind="displayProperties"></p-d-date>
        </template>

        <template v-else-if="entry.p==='dcterms:modified'">
          <p-d-date :p="entry.p" :o="item" v-for="(item, j) in entry.o" :key="componentid+'modified'+j" v-bind="displayProperties"></p-d-date>
        </template>

        <template v-else-if="entry.p==='dcterms:available'">
          <p-d-date :p="entry.p" :o="item" v-for="(item, j) in entry.o" :key="componentid+'available'+j" v-bind="displayProperties"></p-d-date>
        </template>

        <template v-else-if="entry.p==='dcterms:issued'">
          <p-d-date :p="entry.p" :o="item" v-for="(item, j) in entry.o" :key="componentid+'issued'+j" v-bind="displayProperties"></p-d-date>
        </template>

        <template v-else-if="entry.p==='dcterms:valid'">
          <p-d-date :p="entry.p" :o="item" v-for="(item, j) in entry.o" :key="componentid+'valid'+j" v-bind="displayProperties"></p-d-date>
        </template>

        <template v-else-if="entry.p==='dcterms:dateAccepted'">
          <p-d-date :p="entry.p" :o="item" v-for="(item, j) in entry.o" :key="componentid+'dateAccepted'+j" v-bind="displayProperties"></p-d-date>
        </template>

        <template v-else-if="entry.p==='dcterms:dateCopyrighted'">
          <p-d-date :p="entry.p" :o="item" v-for="(item, j) in entry.o" :key="componentid+'dateCopyrighted'+j" v-bind="displayProperties"></p-d-date>
        </template>

        <template v-else-if="entry.p==='dcterms:dateSubmitted'">
          <p-d-date :p="entry.p" :o="item" v-for="(item, j) in entry.o" :key="componentid+'dateSubmitted'+j" v-bind="displayProperties"></p-d-date>
        </template>

        <template v-else-if="entry.p==='rdau:P60071'">
          <p-d-date :p="entry.p" :o="item" v-for="(item, j) in entry.o" :key="componentid+'dateOfProduction'+j" v-bind="displayProperties"></p-d-date>
        </template>

        <template v-else-if="entry.p==='phaidra:dateAccessioned'">
          <p-d-date :p="entry.p" :o="item" v-for="(item, j) in entry.o" :key="componentid+'phaidra:dateAccessioned'+j" v-bind="displayProperties"></p-d-date>
        </template>

        <template v-else-if="entry.p==='phaidra:dateApprobation'">
          <p-d-date :p="entry.p" :o="item" v-for="(item, j) in entry.o" :key="componentid+'phaidra:dateApprobation'+j" v-bind="displayProperties"></p-d-date>
        </template>

        <template v-else-if="entry.p==='dcterms:temporal'">
          <p-d-date :p="entry.p" :o="item" v-for="(item, j) in entry.o" :key="componentid+'temporal'+j" v-bind="displayProperties"></p-d-date>
        </template>

        <template v-else-if="entry.p==='rdau:P60193'">
          <p-d-series :p="entry.p" :o="item" v-for="(item, j) in entry.o" :key="componentid+'series'+j" v-bind="displayProperties"></p-d-series>
        </template>

        <template v-else-if="entry.p==='rdau:P60101'">
          <p-d-contained-in :p="entry.p" :o="item" v-for="(item, j) in entry.o" :key="componentid+'contained-in'+j" v-bind="displayProperties"></p-d-contained-in>
        </template>

        <template v-else-if="entry.p==='bf:provisionActivity'">
          <p-d-bf-publication :p="entry.p" :o="item" v-for="(item, j) in entry.o" :key="componentid+'bfpubl'+j" v-bind="displayProperties"></p-d-bf-publication>
        </template>

        <template v-else-if="entry.p==='cito:cites'">
          <p-d-citation :p="entry.p" :o="item" v-for="(item, j) in entry.o" :key="componentid+'cites'+j" v-bind="displayProperties"></p-d-citation>
        </template>

        <template v-else-if="entry.p==='cito:citesAsDataSource'">
          <p-d-citation :p="entry.p" :o="item" v-for="(item, j) in entry.o" :key="componentid+'citesAsDataSource'+j" v-bind="displayProperties"></p-d-citation>
        </template>

        <template v-else-if="entry.p==='cito:isCitedBy'">
          <p-d-citation :p="entry.p" :o="item" v-for="(item, j) in entry.o" :key="componentid+'citedby'+j" v-bind="displayProperties"></p-d-citation>
        </template>

        <template v-else-if="entry.p==='rdau:P60227'">
          <p-d-adaptation :p="entry.p" :o="item" v-for="(item, j) in entry.o" :key="componentid+'adaptation'+j" v-bind="displayProperties"></p-d-adaptation>
        </template>

        <template v-else-if="entry.p==='bf:instanceOf'">
          <p-d-instance-of :p="entry.p" :o="item" v-for="(item, j) in entry.o" :key="componentid+'instanceof'+j" v-bind="displayProperties"></p-d-instance-of>
        </template>

        <template v-else-if="entry.p==='frapo:isOutputOf'">
          <template v-for="(item, j) in entry.o" :key="componentid+'study-plan'+j">
            <p-d-study-plan v-if="item['@type']==='aiiso:Programme'" :p="entry.p" :o="item" v-bind="displayProperties"></p-d-study-plan>
          </template>
          <template v-for="(item, j) in projectIds" :key="componentid+'proj-wrap'+j">
            <p-d-project v-if="item && item['@type']==='foaf:Project'" :p="entry.p" :o="item" :hideLabel="j !== 0" v-bind="displayProperties"></p-d-project>
          </template>
            <v-row v-if="!shownAllProjectIds">
                <v-col cols="6" offset="3">
                      <span @click="showAllProjectIds()" class="mx-1 text-primary">... {{ $t('show all') }}</span>
                </v-col>
            </v-row>
        </template>

        <template v-else-if="entry.p==='frapo:hasFundingAgency'">
          <p-d-funder :p="entry.p" :o="item" v-for="(item, j) in entry.o" :key="componentid+'funder'+j" v-bind="displayProperties"></p-d-funder>
        </template>

        <template v-else-if="entry.p==='ebucore:hasRelatedEvent'">
          <p-d-event :p="entry.p" :o="item" v-for="(item, j) in entry.o" :key="componentid+'event'+j" v-bind="displayProperties"></p-d-event>
        </template>

        <template v-else-if="entry.p==='rdax:P00009'">
          <p-d-skos-preflabel :p="entry.p" :o="item" v-for="(item, j) in entry.o" :key="componentid+'association'+j" v-bind="displayProperties"></p-d-skos-preflabel>
        </template>

        <template v-else-if="entry.p==='bf:physicalLocation'">
          <p-d-lang-value :p="entry.p" :o="item" v-for="(item, j) in entry.o" :key="componentid+'physloc'+j" v-bind="displayProperties"></p-d-lang-value>
        </template>

        <template v-else-if="entry.p==='rdau:P60550'">
          <p-d-lang-value :p="entry.p" :o="item" v-for="(item, j) in entry.o" :key="componentid+'extent'+j" v-bind="displayProperties"></p-d-lang-value>
        </template>

        <template v-else-if="entry.p==='bf:shelfMark'">
          <p-d-value :p="entry.p" :o="item" v-for="(item, j) in entry.o" :key="componentid+'callnr'+j" v-bind="displayProperties"></p-d-value>
        </template>

        <template v-else-if="entry.p==='dcterms:provenance'">
          <p-d-skos-preflabel :p="entry.p" :o="item" v-for="(item, j) in entry.o" :key="componentid+'prov'+j" v-bind="displayProperties"></p-d-skos-preflabel>
        </template>

        <template v-else-if="entry.p==='dcterms:spatial'">
          <p-d-georeference :p="entry.p" :o="item" v-for="(item, j) in entry.o" :key="componentid+'spatial'+j" v-bind="displayProperties" ></p-d-georeference>
        </template>

        <template v-else-if="entry.p==='vra:placeOfCreation'">
          <p-d-georeference :p="entry.p" :o="item" v-for="(item, j) in entry.o" :key="componentid+'placeOfCreation'+j" v-bind="displayProperties"></p-d-georeference>
        </template>

        <template v-else-if="entry.p==='vra:placeOfRepository'">
          <p-d-georeference :p="entry.p" :o="item" v-for="(item, j) in entry.o" :key="'placeOfRepository'+j" v-bind="displayProperties"></p-d-georeference>
        </template>

        <template v-else-if="entry.p==='vra:placeOfSite'">
          <p-d-georeference :p="entry.p" :o="item" v-for="(item, j) in entry.o" :key="componentid+'placeOfSite'+j" v-bind="displayProperties"></p-d-georeference>
        </template>

        <template v-else-if="entry.p==='ebucore:filename'">
          <p-d-value :p="entry.p" :o="item" v-for="(item, j) in entry.o" :key="componentid+'filename'+j" v-bind="displayProperties"></p-d-value>
        </template>

        <template v-else-if="entry.p==='ebucore:hasMimeType'">
          <p-d-labeled-value :p="entry.p" :o="item" v-for="(item, j) in entry.o" :key="componentid+'mime'+j" v-bind="displayProperties"></p-d-labeled-value>
        </template>

        <template v-else-if="entry.p==='opaque:cco_accessionNumber'">
          <p-d-value :p="entry.p" :o="item" v-for="(item, j) in entry.o" :key="componentid+'accnr'+j" v-bind="displayProperties"></p-d-value>
        </template>

        <template v-else-if="entry.p==='vra:hasInscription'">
          <p-d-skos-preflabel :p="entry.p" :o="item" v-for="(item, j) in entry.o" :key="componentid+'inscr'+j" v-bind="displayProperties"></p-d-skos-preflabel>
        </template>

        <template v-else-if="entry.p==='vra:material'">
          <p-d-skos-preflabel :p="entry.p" :o="item" v-for="(item, j) in entry.o" :key="componentid+'material'+j" v-bind="displayProperties"></p-d-skos-preflabel>
        </template>

        <template v-else-if="entry.p==='vra:hasTechnique'">
          <p-d-skos-preflabel :p="entry.p" :o="item" v-for="(item, j) in entry.o" :key="componentid+'techn'+j" v-bind="displayProperties"></p-d-skos-preflabel>
        </template>

        <template v-else-if="entry.p==='dce:format'">
          <p-d-skos-preflabel :p="entry.p" :o="item" v-for="(item, j) in entry.o" :key="componentid+'format'+j" v-bind="displayProperties"></p-d-skos-preflabel>
        </template>

        <template v-else-if="entry.p==='rdau:P60048'">
          <p-d-skos-preflabel :p="entry.p" :o="item" v-for="(item, j) in entry.o" :key="componentid+'carriertype'+j" v-bind="displayProperties"></p-d-skos-preflabel>
        </template>

        <template v-else-if="entry.p==='phaidra:levelOfDescription'">
          <p-d-skos-preflabel :p="entry.p" :o="item" v-for="(item, j) in entry.o" :key="componentid+'lvlofdesc'+j" v-bind="displayProperties"></p-d-skos-preflabel>
        </template>

        <template v-else-if="entry.p==='rdau:P60059'">
          <p-d-skos-preflabel :p="entry.p" :o="item" v-for="(item, j) in entry.o" :key="componentid+'regenc'+j" v-bind="displayProperties"></p-d-skos-preflabel>
        </template>

        <template v-else-if="entry.p==='schema:width'">
          <p-d-dimension :p="entry.p" :o="item" v-for="(item, j) in entry.o" :key="componentid+'width'+j" v-bind="displayProperties"></p-d-dimension>
        </template>

        <template v-else-if="entry.p==='schema:height'">
          <p-d-dimension :p="entry.p" :o="item" v-for="(item, j) in entry.o" :key="componentid+'height'+j" v-bind="displayProperties"></p-d-dimension>
        </template>

        <template v-else-if="entry.p==='schema:depth'">
          <p-d-dimension :p="entry.p" :o="item" v-for="(item, j) in entry.o" :key="componentid+'depth'+j" v-bind="displayProperties"></p-d-dimension>
        </template>

        <template v-else-if="entry.p==='vra:diameter'">
          <p-d-dimension :p="entry.p" :o="item" v-for="(item, j) in entry.o" :key="componentid+'diameter'+j" v-bind="displayProperties"></p-d-dimension>
        </template>

        <template v-else-if="entry.p==='schema:weight'">
          <p-d-dimension :p="entry.p" :o="item" v-for="(item, j) in entry.o" :key="componentid+'weight'+j" v-bind="displayProperties"></p-d-dimension>
        </template>

        <template v-else-if="entry.p==='schema:duration'">
          <p-d-duration :p="entry.p" :o="item" v-for="(item, j) in entry.o" :key="componentid+'duration'+j" v-bind="displayProperties"></p-d-duration>
        </template>

        <template v-else-if="entry.p==='schema:numberOfPages'">
          <p-d-value :p="entry.p" :o="item" v-for="(item, j) in entry.o" :key="componentid+'numberOfPages'+j" v-bind="displayProperties"></p-d-value>
        </template>

        <template v-else-if="entry.p==='bibo:issue'">
          <p-d-lang-value :p="entry.p" :o="item" v-for="(item, j) in entry.o" :key="componentid+'issue'+j" v-bind="displayProperties"></p-d-lang-value>
        </template>

        <template v-else-if="entry.p==='bibo:volume'">
          <p-d-lang-value :p="entry.p" :o="item" v-for="(item, j) in entry.o" :key="componentid+'volume'+j" v-bind="displayProperties"></p-d-lang-value>
        </template>

        <template v-else-if="entry.p==='bf:soundCharacteristic'">
          <p-d-value :p="entry.p" :o="item" v-for="(item, j) in entry.o" :key="componentid+'soundCharacteristic'+j" v-bind="displayProperties"></p-d-value>
        </template>

        <template v-else-if="entry.p==='schema:pageStart'">
          <p-d-value :p="entry.p" :o="item" v-for="(item, j) in entry.o" :key="componentid+'pageStart'+j" v-bind="displayProperties"></p-d-value>
        </template>

        <template v-else-if="entry.p==='schema:pageEnd'">
          <p-d-value :p="entry.p" :o="item" v-for="(item, j) in entry.o" :key="componentid+'pageEnd'+j" v-bind="displayProperties"></p-d-value>
        </template>

        <template v-else-if="entry.p==='bf:supplementaryContent'">
          <p-d-skos-preflabel :p="entry.p" :o="item" v-for="(item, j) in entry.o" :key="componentid+'supplementaryContent'+j" v-bind="displayProperties"></p-d-skos-preflabel>
        </template>

        <template v-else-if="entry.p==='dcterms:audience'">
          <p-d-skos-preflabel :p="entry.p" :o="item" v-for="(item, j) in entry.o" :key="componentid+'audience'+j" v-bind="displayProperties"></p-d-skos-preflabel>
        </template>

        <template v-else-if="entry.p==='bf:awards'">
          <p-d-skos-preflabel :p="entry.p" :o="item" v-for="(item, j) in entry.o" :key="componentid+'awards'+j" v-bind="displayProperties"></p-d-skos-preflabel>
        </template>

        <template v-else-if="entry.p==='bf:scale'">
          <p-d-skos-preflabel :p="entry.p" :o="item" v-for="(item, j) in entry.o" :key="componentid+'scale'+j" v-bind="displayProperties"></p-d-skos-preflabel>
        </template>

        <template v-else-if="entry.p==='rdfs:seeAlso'">
          <p-d-see-also :p="entry.p" :o="item" v-for="(item, j) in entry.o" :key="componentid+'seealso'+j" v-bind="displayProperties"></p-d-see-also>
        </template>

        <template v-else-if="entry.p==='edm:rights'">
          <p-d-license :p="entry.p" :o="item" :copyrightLink="copyrightLink" v-for="(item, j) in entry.o" :key="componentid+'license'+j" v-bind="displayProperties"></p-d-license>
        </template>

        <template v-else-if="entry.p==='dce:rights'">
          <p-d-lang-value :p="entry.p" :o="item" v-for="(item, j) in entry.o" :key="componentid+'rights'+j" v-bind="displayProperties"></p-d-lang-value>
        </template>

        <template v-else-if="entry.p==='phaidra:systemTag'">
          <p-d-value v-if="showSystemFields" :p="entry.p" :o="item" v-for="(item, j) in entry.o" :key="componentid+'systemTag'+j" v-bind="displayProperties"></p-d-value>
        </template>

        <template v-else>
          <v-container class="my-4" :key="entry.p">
            <v-alert :type="'error'" :model-value="true" transition="fade-transition">Unknown predicate <b>{{ entry.p }}</b></v-alert>
            <p-d-unknown :jsonld="entry.o" :label="entry.p" v-bind="displayProperties"></p-d-unknown>
          </v-container>
        </template>

    </template>
  </p-d-jsonld-layout>

</template>

<script>
import order from '../../utils/order'
import PDAccessibility from './PDAccessibility'
import PDLicense from './PDLicense'
import PDTitle from './PDTitle'
import PDSkosPreflabel from './PDSkosPreflabel'
import PDKeyword from './PDKeyword'
import PDLangValue from './PDLangValue'
import PDValue from './PDValue'
import PDDate from './PDDate'
import PDDimension from './PDDimension'
import PDDuration from './PDDuration'
import PDGeoreference from './PDGeoreference'
import PDEntity from './PDEntity'
import PDLabeledValue from './PDLabeledValue'
import PDFunder from './PDFunder'
import PDProject from './PDProject'
import PDEvent from './PDEvent'
import PDBfPublication from './PDBfPublication'
import PDStudyPlan from './PDStudyPlan'
import PDSeries from './PDSeries'
import PDContainedIn from './PDContainedIn'
import PDInstanceOf from './PDInstanceOf'
import PDAdaptation from './PDAdaptation'
import PDCitation from './PDCitation'
import PDIdentifier from './PDIdentifier'
import PDJsonldLayout from './PDJsonldLayout'
import PDSeeAlso from './PDSeeAlso'
import PDUnknown from './PDUnknown'
import { vocabulary } from '../../mixins/vocabulary'
import { displayproperties } from '../../mixins/displayproperties'

/** Predicates with dedicated render branches (others map to unknown-predicate slot). */
const PD_JSONLD_KNOWN_PREDICATES = new Set([
  'rdam:P30004', 'edm:hasType', 'schema:genre', 'schema:accessMode', 'schema:accessibilityFeature',
  'schema:accessibilityControl', 'schema:accessibilityHazard', 'oaire:version', 'dcterms:accessRights',
  'rdau:P60059', 'dce:title', 'bf:note', 'bf:tableOfContents', 'dcterms:language', 'schema:subtitleLanguage',
  'dcterms:date', 'dcterms:created', 'dcterms:modified', 'dcterms:available', 'dcterms:issued',
  'dcterms:valid', 'dcterms:dateAccepted', 'dcterms:dateCopyrighted', 'dcterms:dateSubmitted',
  'rdau:P60071', 'phaidra:dateAccessioned', 'phaidra:dateApprobation', 'dcterms:temporal',
  'rdau:P60193', 'rdau:P60101', 'bf:provisionActivity', 'cito:cites', 'cito:citesAsDataSource',
  'cito:isCitedBy', 'rdau:P60227', 'bf:instanceOf', 'frapo:isOutputOf', 'frapo:hasFundingAgency',
  'ebucore:hasRelatedEvent', 'rdax:P00009', 'bf:physicalLocation', 'rdau:P60550', 'bf:shelfMark',
  'dcterms:provenance', 'dcterms:spatial', 'vra:placeOfCreation', 'vra:placeOfRepository',
  'vra:placeOfSite', 'ebucore:filename', 'ebucore:hasMimeType', 'opaque:cco_accessionNumber',
  'vra:hasInscription', 'vra:material', 'vra:hasTechnique', 'dce:format', 'rdau:P60048',
  'phaidra:levelOfDescription', 'schema:width', 'schema:height', 'schema:depth', 'vra:diameter',
  'schema:weight', 'schema:duration', 'schema:numberOfPages', 'bibo:issue', 'bibo:volume',
  'bf:soundCharacteristic', 'schema:pageStart', 'schema:pageEnd', 'bf:supplementaryContent',
  'dcterms:audience', 'bf:awards', 'bf:scale', 'rdfs:seeAlso', 'edm:rights', 'dce:rights',
  'phaidra:systemTag'
])

export default {
  name: 'p-d-jsonld',
  mixins: [vocabulary, displayproperties],
  props: {
    jsonld: {
      type: Object,
      default: null
    },
    limitRoles: {
      type: Number,
      default: 0
    },
    showSystemFields: {
      type: Boolean,
      default: false
    },
    copyrightLink: {
      type: String
    },
    predicatesToHide: {
      type: Array,
      default: () => []
    },
    pid: String
  },
  components: {
    PDTitle,
    PDEntity,
    PDJsonldLayout,
    PDSkosPreflabel,
    PDKeyword,
    PDLangValue,
    PDLicense,
    PDAccessibility,
    PDValue,
    PDDate,
    PDDimension,
    PDDuration,
    PDGeoreference,
    PDLabeledValue,
    PDFunder,
    PDProject,
    PDEvent,
    PDBfPublication,
    PDStudyPlan,
    PDSeries,
    PDContainedIn,
    PDAdaptation,
    PDInstanceOf,
    PDIdentifier,
    PDCitation,
    PDSeeAlso,
    PDUnknown
  },
  computed: {
    instance: function () {
      return this.$store?.state?.instanceconfig ?? { api: '', baseurl: '', solr: '' }
    },
    componentid: function () {
      return Math.floor(Math.random() * 10000000)
    },
    displayProperties: function () {
      return {
        labelColMd: this.labelColMd,
        valueColMd: this.valueColMd,
        showLang: this.showLang,
        boldLabelFields: this.boldLabelFields
      }
    },
    langKeywords: function () {
      let hash = {}
      if (this.jsonld) {
        Object.entries(this.jsonld).forEach(([key, value]) => {
          if (key === 'dce:subject') {
            for (let v of value) {
              if (v['@type'] === 'skos:Concept') {
                for (let pl of v['skos:prefLabel']) {
                  let lang = pl['@language'] ? pl['@language'] : 'xxx'
                  if (!hash[lang]) {
                    hash[lang] = []
                  }
                  hash[lang].push(pl['@value'])
                }
              }
            }
          }
        })
      }
      return hash
    },
    roles: function () {
      let objectType = this.getObjectType()
      let roles = []
      if (this.jsonld) {
        Object.entries(this.jsonld).forEach(([p, o]) => {
          if (p.startsWith('role:')) {
            roles.push({ p, o, ord: objectType && objectType['@id'] === 'https://pid.phaidra.org/vocabulary/47QB-8QF1' ? order.bookTypeOrder[p] : order.roles[p] })
          }
        })
      }
      roles.sort(function (a, b) {
        return a.ord - b.ord
      })
      return roles
    },
    jsonldSlotEntries () {
      if (!this.jsonld) return []
      const entries = []
      for (const [p, o] of Object.entries(this.jsonld)) {
        if (this.predicatesToHide.includes(p)) continue
        if (p.startsWith('role:')) continue
        if (p === 'dcterms:subject') continue
        if (p === '@type' || p === 'dce:subject' || p === 'dcterms:type') continue
        const slotKey = PD_JSONLD_KNOWN_PREDICATES.has(p) ? p : 'unknown-predicate'
        entries.push({ p, o, slotKey })
      }
      return entries
    }
  },
  data () {
    return {
      nrRoles: 0,
      showAllEntities: {},
      entitiesLimited: {},
      projectIds: [],
      shownAllProjectIds: true,
      overallAccessibility: null,
    }
  },
  methods: {
    getObjectType: function() {
      if(this.jsonld && this.jsonld['edm:hasType'] && this.jsonld['edm:hasType'].length) {
        const localTerm = this.getTerm('objecttype', this.jsonld['edm:hasType'][0]['skos:exactMatch'][0])
        return localTerm
      }
      return null
    },
    getProjectIds: function () {
      if (this.jsonld) {
        const projectIds = []
        Object.entries(this.jsonld).forEach(([p, o]) => {
          if (p === 'frapo:isOutputOf') {
            o.forEach((item, j) => {
              if (j >= 3) return
              projectIds.push(item)
            })
            if (o.length > 3) this.shownAllProjectIds = false
          }
        })
        this.projectIds = projectIds
      }
    },
    showAllProjectIds: function () {
      if (this.jsonld) {
        this.shownAllProjectIds = true
        const projectIds = []
        Object.entries(this.jsonld).forEach(([p, o]) => {
          if (p === 'frapo:isOutputOf') {
            o.forEach((item, j) => {
              projectIds.push(item)
            })
          }
        })
        this.projectIds = projectIds
      }
    },
    getEntities: function (p, o) {
      if ((this.limitRoles === 0) || this.showAllEntities[p]) {
        return o
      }
      let entities = []
      let i = 0
      for (let e of o) {
        i++
        if (i < this.limitRoles) {
          entities.push(e)
        } else {
          this.entitiesLimited[p] = true
          break
        }
      }
      return entities
    },
    setShowAllEntities: function (p) {
      this.showAllEntities[p] = true
    }
  },
  mounted: function () {
    this.$store.dispatch('vocabulary/loadLanguages', this.$i18n.locale)
    this.getProjectIds()
    if (!this.jsonld) return
    this.overallAccessibility = {
      control: this.jsonld['schema:accessibilityControl'] || [],
      feature: this.jsonld['schema:accessibilityFeature'] || [],
      hazard: this.jsonld['schema:accessibilityHazard'] || [],
      mode: this.jsonld['schema:accessMode'] || []
    }
  }
}
</script>

<style>
.valuefield {
  white-space: pre-wrap;
}
.pdlabel {
  overflow-wrap: break-word;
  word-wrap: break-word; /* legacy fallback */
  hyphens: auto;
}

/* Vuetify 4 compatibility: restore Vuetify 2-like inner col padding */
.pdjsonld-grid-compat .v-row > .v-col,
.pdjsonld-grid-compat .v-row > [class*='v-col-'] {
  padding: 12px;
  padding-top: 0;
}
</style>

<style scoped>
.wiv {
  font-weight: 400;
}
.theme--dark.v-card {
  background-color: transparent !important;
}
</style>
