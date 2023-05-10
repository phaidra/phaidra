<template>
  <div class="ma-6">

    <h3 class="title font-weight-light primary--text mb-4">{{ $t('PHAIDRA is using following free services') }}:</h3>

    <v-container>
      <v-row>
        <v-col><a href="https://citation.crosscite.org/" target="_blank">Crosscite</a> - The DOI Citation Formatter | <a
            href="http://crossref.org/" target="_blank">Crossref</a>, <a href="https://www.medra.org/"
            target="_blank">mEDRA</a>, <a href="http://www.doi.org.cn/portal/index.htm" target="_blank">ISTIC</a>, <a
            href="https://japanlinkcenter.org/top/english.html" target="_blank">JaLC</a></v-col>
      </v-row>

      <v-row>
        <v-col><a href="https://api.dante.gbv.de/" target="_blank">DANTE</a> - Datendrehscheibe für Normdaten und
          Terminologien
          - <a href="https://www.gbv.de/informationen/Verbundzentrale" target="_blank">Verbundzentrale (VZG)</a>, <a
            href="https://www.gbv.de/" target="_blank">Gemeinsamen Bibliotheksverbundes (GBV)</a></v-col>
      </v-row>

      <v-row>
        <v-col><a href="https://www.geonames.org/" target="_blank">GeoNames</a> - The GeoNames geographical database
        </v-col>
      </v-row>

      <v-row>
        <v-col><a href="https://lobid.org" target="_blank">lobid</a> - LOD services | <a href="https://www.hbz-nrw.de/"
            target="_blank">Hochschulbibliothekszentrum des Landes NRW</a></v-col>
      </v-row>

      <v-row>
        <v-col><a href="https://ror.org/" target="_blank">ROR</a> - Research Organization Registry</v-col>
      </v-row>

      <v-row>
        <v-col><a href="https://v2.sherpa.ac.uk/" target="_blank">Sherpa Services</a> - Tools to access and comply with
          OA
          archiving policies | <a href="https://www.jisc.ac.uk/" target="_blank">Jisc</a></v-col>
      </v-row>
    </v-container>

  </div>
</template>

<script>
export default {
  name: 'credits'
}
</script>
