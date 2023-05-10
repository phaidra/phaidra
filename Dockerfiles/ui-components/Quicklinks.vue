<template>
  <transition name="slide">
    <v-container
      v-if="showquicklinks"
      fluid
      class="quicklinks-content pb-6"
      id="quicklinks"
    >
      <v-row class="py-4">
        <v-col cols="2" offset="4">
          <v-row>
            <h3 class="top-row-header">{{ $t("Information about") }} ...</h3>
          </v-row>

          <v-row>
            <a href="http://datamanagement.univie.ac.at/" target="_blank">
              <span>Datenmanagement</span>
              <icon width="16" height="16" name="univie-extern"></icon>
            </a>
          </v-row>

          <v-row>
            <a href="https://uscholar.univie.ac.at/" target="_blank">
              <span>u:scholar</span>
              <icon width="16" height="16" name="univie-extern"></icon>
            </a>
          </v-row>

          <v-row>
            <a href="http://unidam.univie.ac.at/" target="_blank">
              <span>unidam</span>
              <icon width="16" height="16" name="univie-extern"></icon>
            </a>
          </v-row>

          <v-row>
            <a :href="'http://openaccess.univie.ac.at/home/?l=' + ($i18n.locale === 'deu' ? 'de' : 'en')" target="_blank">
              <span>Open Access Office</span>
              <icon width="16" height="16" name="univie-extern"></icon>
            </a>
          </v-row>

          <v-row>
            <a :href="'https://ucris.univie.ac.at/portal/' + ($i18n.locale === 'deu' ? 'de/' : 'en/')" target="_blank">
              <span>u:cris</span>
              <icon width="16" height="16" name="univie-extern"></icon>
            </a>
          </v-row>
        </v-col>

        <v-col cols="1"></v-col>

        <v-col cols="3">
          <v-row>
            <h3 class="top-row-header">
              {{ $t("Most searched-for services") }} ...
            </h3>
          </v-row>

          <v-row>
            <a href="http://studieren.univie.ac.at" target="_blank">
              <icon
                width="16"
                height="16"
                name="univie-quick-studienpoint"
              ></icon>
              <span>Studieren an der Universität Wien</span>
              <icon width="16" height="16" name="univie-extern"></icon>
            </a>
          </v-row>

          <v-row>
            <a href="http://ufind.univie.ac.at/de/search.html" target="_blank">
              <icon width="16" height="16" name="univie-quick-lesung"></icon>
              <span>u:find Vorlesungs-/ Personenverzeichnis</span>
              <icon width="16" height="16" name="univie-extern"></icon>
            </a>
          </v-row>

          <v-row>
            <a href="http://uspace.univie.ac.at" target="_blank">
              <icon width="16" height="16" name="univie-quick-univis"></icon>
              <span>u:space</span>
              <icon width="16" height="16" name="univie-extern"></icon>
            </a>
          </v-row>

          <v-row>
            <a href="http://bibliothek.univie.ac.at/" target="_blank">
              <icon width="16" height="16" name="univie-quick-biblio"></icon>
              <span>Bibliotheksservices</span>
              <icon width="16" height="16" name="univie-extern"></icon>
            </a>
          </v-row>

          <v-row>
            <a href="http://moodle.univie.ac.at/" target="_blank">
              <icon width="16" height="16" name="univie-quick-lesung"></icon>
              <span>Moodle (E-Learning)</span>
              <icon width="16" height="16" name="univie-extern"></icon>
            </a>
          </v-row>

          <v-row>
            <a
              href="http://www.univie.ac.at/ueber-uns/leitung-organisation/fakultaeten-zentren/"
              target="_blank"
            >
              <icon
                width="16"
                height="16"
                name="univie-quick-fakultaeten"
              ></icon>
              <span>Fakultäten &amp; Zentren</span>
              <icon width="16" height="16" name="univie-extern"></icon>
            </a>
          </v-row>

          <v-row>
            <a href="http://webmail.univie.ac.at" target="_blank">
              <icon width="16" height="16" name="univie-quick-webmail"></icon>
              <span>Webmail</span>
              <icon width="16" height="16" name="univie-extern"></icon>
            </a>
          </v-row>

          <v-row>
            <a href="http://intra.univie.ac.at/" target="_blank">
              <icon width="16" height="16" name="univie-quick-intranet"></icon>
              <span>Intranet für MitarbeiterInnen</span>
              <icon width="16" height="16" name="univie-extern"></icon>
            </a>
          </v-row>

          <v-row>
            <a
              href="http://www.univie.ac.at/ueber-uns/weitere-informationen/kontakt-services-von-a-z/"
              target="_blank"
            >
              <icon width="16" height="16" name="univie-quick-kontakt"></icon>
              <span>Kontakt &amp; Services von A-Z</span>
              <icon width="16" height="16" name="univie-extern"></icon>
            </a>
          </v-row>
        </v-col>

        <v-col cols="2"></v-col>
      </v-row>
    </v-container>
  </transition>
</template>

<script>
import "@/compiled-icons/univie-extern";
import "@/compiled-icons/univie-quick-biblio";
import "@/compiled-icons/univie-quick-fakultaeten";
import "@/compiled-icons/univie-quick-intranet";
import "@/compiled-icons/univie-quick-kontakt";
import "@/compiled-icons/univie-quick-lesung";
import "@/compiled-icons/univie-quick-studienpoint";
import "@/compiled-icons/univie-quick-univis";
import "@/compiled-icons/univie-quick-webmail";

export default {
  name: "quicklinks",
  props: ["showquicklinks"],
};
</script>

<style scoped>
.svg-icon {
  margin: 3px 6px 0 3px;
}

.quicklinks-content {
  background: #1a74b0 url(../../assets/ext/quicklinksbackground.png) no-repeat;
  font-size: 12pt;
  color: white;
  padding-bottom: 30px;
  width: 100%;
}

h3.top-row-header {
  margin-top: 0px;
  font-size: 19pt;
  color: white;
  background: url(../../assets/ext/verlauf-weiss.png) no-repeat left bottom;
  font-weight: 300;
  margin-bottom: 8pt;
}

.slide-enter-active,
.slide-leave-active {
  transition: all 0.8s cubic-bezier(0, 1, 0.5, 1);
  overflow-y: hidden;
  max-height: 310px;
}
.slide-enter,
.slide-leave-to {
  max-height: 0px;
}

#quicklinks ul {
  list-style-type: none;
  padding: 0px;
  margin-left: -5px;
}

#quicklinks ul li {
  padding-left: 5px;
}

#quicklinks a {
  color: white;
  text-decoration: none;
  display: flex;
  align-items: center;
}

#quicklinks a:hover {
  color: #909090;
  background-color: white;
}

#quicklinks a:hover md-icon {
  color: #909090;
}

.quicklinks-button {
  background-color: #0063a6;
  text-decoration: none;
  color: white;
  margin-top: 0px;
  width: 263px;
}

.quicklinks-button:hover {
  background-color: #1a74b0;
}

.quicklinks-button-open {
  background-color: #1a74b0;
}
</style>
