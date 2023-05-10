<template>
  <v-container fluid>
    <v-row class="grey lighten-4 quicklinksfooter">
      <v-col cols="12" md="10" offset-md="1">
        <v-row no-gutters>
          <v-col cols="12">
            <h2 class="underline md-headline footer-headline">
              {{ $t("Information about") }} ...
            </h2>
          </v-col>
        </v-row>

        <v-row no-gutters>
          <v-col cols="12" md="3">
            <div class="footer-quicklinks-list">
              <a href="http://datamanagement.univie.ac.at/" target="_blank">
                <div>
                  <span>Datenmanagement</span>
                  <icon name="univie-right" class="float-right"></icon>
                </div>
              </a>
            </div>
            <div class="footer-quicklinks-list">
              <a href="https://uscholar.univie.ac.at/" target="_blank">
                <div>
                  <span>u:scholar</span>
                  <icon name="univie-right" class="float-right"></icon>
                </div>
              </a>
            </div>
            <div class="footer-quicklinks-list">
              <a href="http://unidam.univie.ac.at/" target="_blank">
                <div>
                  <span>unidam</span>
                  <icon name="univie-right" class="float-right"></icon>
                </div>
              </a>
            </div>
          </v-col>

          <v-col cols="12" md="3">
            <div class="footer-quicklinks-list">
              <a :href="'http://openaccess.univie.ac.at/home/?l=' + ($i18n.locale === 'deu' ? 'de' : 'en')" target="_blank">
                <div>
                  <span>Open Access Office</span>
                  <icon name="univie-right" class="float-right"></icon>
                </div>
              </a>
            </div>
            <div class="footer-quicklinks-list">
              <a :href="'https://ucris.univie.ac.at/portal/' + ($i18n.locale === 'deu' ? 'de/' : 'en/')" target="_blank">
                <div>
                  <span>u:cris</span>
                  <icon name="univie-right" class="float-right"></icon>
                </div>
              </a>
            </div>
          </v-col>
        </v-row>
      </v-col>

      <v-col cols="12" md="10" offset-md="1">
        <v-row no-gutters>
          <v-col cols="12">
            <h2 class="underline md-headline footer-headline">
              {{ $t("Most searched-for services") }} ...
            </h2>
          </v-col>
        </v-row>

        <v-row no-gutters>
          <v-col cols="12" md="3">
            <div class="footer-quicklinks-list">
              <a href="http://studieren.univie.ac.at" target="_blank">
                <div>
                  <span>Studieren an der Universität Wien</span>
                  <icon name="univie-right" class="float-right"></icon>
                </div>
              </a>
            </div>
            <div class="footer-quicklinks-list">
              <a
                href="http://ufind.univie.ac.at/de/search.html"
                target="_blank"
              >
                <div>
                  <span>u:find Vorlesungs-/ Personensuche</span>
                  <icon name="univie-right" class="float-right"></icon>
                </div>
              </a>
            </div>
            <div class="footer-quicklinks-list">
              <a href="http://uspace.univie.ac.at" target="_blank">
                <div>
                  <span>u:space</span>
                  <icon name="univie-right" class="float-right"></icon>
                </div>
              </a>
            </div>
          </v-col>

          <v-col cols="12" md="3">
            <div class="footer-quicklinks-list">
              <a href="http://bibliothek.univie.ac.at/" target="_blank">
                <div>
                  <span>Bibliotheksservices</span>
                  <icon name="univie-right" class="float-right"></icon>
                </div>
              </a>
            </div>
            <div class="footer-quicklinks-list">
              <a href="http://moodle.univie.ac.at/" target="_blank">
                <div>
                  <span>Moodle (E-Learning)</span>
                  <icon name="univie-right" class="float-right"></icon>
                </div>
              </a>
            </div>
            <div class="footer-quicklinks-list">
              <a
                href="http://www.univie.ac.at/ueber-uns/leitung-organisation/fakultaeten-zentren/"
                target="_blank"
              >
                <div>
                  <span>Fakultäten &amp; Zentren</span>
                  <icon name="univie-right" class="float-right"></icon>
                </div>
              </a>
            </div>
          </v-col>

          <v-col cols="12" md="3">
            <div class="footer-quicklinks-list">
              <a href="http://webmail.univie.ac.at" target="_blank">
                <div>
                  <span>Webmail</span>
                  <icon name="univie-right" class="float-right"></icon>
                </div>
              </a>
            </div>
            <div class="footer-quicklinks-list">
              <a href="http://intra.univie.ac.at/" target="_blank">
                <div>
                  <span>Intranet für MitarbeiterInnen</span>
                  <icon name="univie-right" class="float-right"></icon>
                </div>
              </a>
            </div>
            <div class="footer-quicklinks-list">
              <a
                href="http://www.univie.ac.at/ueber-uns/weitere-informationen/kontakt-services-von-a-z/"
                target="_blank"
              >
                <div>
                  <span>Kontakt &amp; Services von A-Z</span>
                  <icon name="univie-right" class="float-right"></icon>
                </div>
              </a>
            </div>
          </v-col>

          <v-col cols="12" md="3"> </v-col>
        </v-row>
      </v-col>
    </v-row>
  </v-container>
</template>

<script>
import "@/compiled-icons/univie-right";

export default {
  name: "quicklinks-footer",
};
</script>

<style scoped>
.quicklinksfooter {
  margin-top: 40px;
  padding-bottom: 30px;
}

.svg-icon {
  margin: 3px 0 0 3px;
  color: #a4a4a4;
}

.footer-quicklinks-list {
  font-size: 11pt;
  margin: 4px 20px 0 0;
  padding: 2px 5px 2px 5px;
  position: relative;
}

.footer-quicklinks-list a {
  color: #0063a6;
  display: block;
  padding-right: 5px;
}

.footer-quicklinks-list:hover {
  background-color: #a4a4a4;
}

.footer-quicklinks-list:hover a {
  color: white;
}

.footer-quicklinks-list:hover .svg-icon {
  color: white;
}

h2.footer-headline {
  margin-top: 16pt;
  margin-bottom: 8pt;
}

.underline {
  padding-bottom: 2px;
  border-bottom: solid 1px #bdbdbd;
}

h2.md-headline {
  font-size: 21pt;
  border-bottom: solid 1px #bdbdbd;
  color: #0063a6;
  font-weight: 300;
}
</style>
