<template>
  <v-container fluid>
    <slot name="phaidra:levelOfDescription"></slot>
    <!-- basics -->
    <slot name="dce:title"></slot>
    <slot name="role"></slot>

    <!-- description -->
    <slot name="bf:note"></slot>
    <slot name="dce:subject"></slot>
    <slot name="dcterms:subject"></slot><!-- not @type=phaidra:Subject -->
    <slot name="dcterms:type"></slot><!-- usually hidden -->
    <slot name="edm:hasType"></slot>
    <slot name="schema:genre"></slot>
    <slot name="bf:tableOfContents"></slot>
    <slot name="bf:supplementaryContent"></slot>
    <slot name="bf:awards"></slot>
    <slot name="dcterms:audience"></slot>
    <slot name="dcterms:language"></slot>
    <slot name="schema:subtitleLanguage"></slot>

    <!-- IDs -->
    <slot name="pid"></slot>
    <slot name="rdam:P30004"></slot><!-- alternative identifier -->
    <slot name="opaque:cco_accessionNumber"></slot>
    <slot name="bf:shelfMark"></slot>

    <!-- periodicals and related stuff -->
    <slot name="rdau:P60101"></slot><!-- is contained in -->
    <slot name="rdau:P60193"></slot><!-- is in series -->
    <slot name="rdau:P60550"></slot><!-- extent -->
    <slot name="bibo:issue"></slot>
    <slot name="bibo:volume"></slot>
    <slot name="schema:numberOfPages"></slot>
    <slot name="schema:pageStart"></slot>
    <slot name="schema:pageEnd"></slot>
    <slot name="bf:provisionActivity"></slot>
    <slot name="bf:instanceOf"></slot>
    <slot name="rdau:P60227"></slot><!-- adaptation of -->
    <slot name="oaire:version"></slot>

    <!-- provenance -->
    <slot name="dcterms:provenance"></slot>

    <!-- funding -->
    <slot name="frapo:hasFundingAgency"></slot>
    <slot name="frapo:isOutputOf"></slot>

    <!-- dates -->
    <slot name="dcterms:date"></slot>
    <slot name="dcterms:created"></slot>
    <slot name="dcterms:modified"></slot>
    <slot name="dcterms:available"></slot>
    <slot name="dcterms:issued"></slot>
    <slot name="dcterms:valid"></slot>
    <slot name="dcterms:dateAccepted"></slot>
    <slot name="dcterms:dateCopyrighted"></slot>
    <slot name="dcterms:dateSubmitted"></slot>
    <slot name="rdau:P60071"></slot><!-- date of production -->
    <slot name="phaidra:dateAccessioned"></slot>
    <slot name="phaidra:dateApprobation"></slot>
    <slot name="dcterms:temporal"></slot>

    <!-- a11y -->
    <slot name="overallAccessibility"></slot>

    <!-- events -->
    <slot name="ebucore:hasRelatedEvent"></slot>

    <!-- places -->
    <slot name="dcterms:spatial"></slot>
    <slot name="vra:placeOfCreation"></slot>
    <slot name="vra:placeOfRepository"></slot>
    <slot name="vra:placeOfSite"></slot>
    <slot name="bf:physicalLocation"></slot>

    <!-- properties of physical object -->
    <slot name="vra:hasInscription"></slot>
    <slot name="vra:material"></slot>
    <slot name="vra:hasTechnique"></slot>
    <slot name="dce:format"></slot>
    <slot name="rdau:P60048"></slot><!-- carrier type -->
    <slot name="schema:width"></slot>
    <slot name="schema:height"></slot>
    <slot name="schema:depth"></slot>
    <slot name="vra:diameter"></slot>
    <slot name="schema:weight"></slot>
    <slot name="schema:duration"></slot>
    <slot name="bf:scale"></slot>

    <!-- association -->
    <slot name="rdax:P00009"></slot>

    <!-- technical -->
    <slot name="bf:soundCharacteristic"></slot>
    <slot name="rdau:P60059"></slot><!-- regional encoding -->
    <slot name="ebucore:filename"></slot>
    <slot name="ebucore:hasMimeType"></slot>
    <slot name="phaidra:systemTag"></slot><!-- usually hidden -->

    <!-- rights -->
    <slot name="dcterms:accessRights"></slot>
    <slot name="edm:rights"></slot>
    <slot name="dce:rights"></slot>

    <!-- error message -->
    <slot name="unknown-predicate"></slot>

    <v-card flat outlined class="pb-4 my-4" v-if="jsonld.hasOwnProperty('cito:cites') || jsonld.hasOwnProperty('cito:citesAsDataSource') || jsonld.hasOwnProperty('cito:isCitedBy') || jsonld.hasOwnProperty('rdfs:seeAlso')">
      <v-card-title class="title font-weight-light grey white--text">{{ $t('Bibliography') }}</v-card-title>
      <v-divider class="mb-4"></v-divider>
      <slot name="cito:cites"></slot>
      <slot name="cito:citesAsDataSource"></slot>
      <slot name="cito:isCitedBy"></slot>
      <slot name="rdfs:seeAlso"></slot>
    </v-card>

    <!-- recursion starts here -->
    <slot name="phaidra:Subject"></slot><!-- dcterms:subject @type=phaidra:Subject -->
  </v-container>
</template>
<script>
export default {
  name: 'p-d-jsonld-layout',
  props: {
    jsonld: {
      type: Object,
      default: null
    }
  }
}
</script>
