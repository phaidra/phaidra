<template>
  <div>

    <v-row class="mx-4 mt-10">
      <v-col cols="12" md="10" offset-md="1">
        <v-row>
          <v-text-field
            v-model="q"
            :placeholder="$t('Search...')"
            autocomplete="off"
            append-icon="mdi-magnify"
            v-on:keyup.enter="$router.push({ name: 'search', query: { q } })"
            clearable
            solo
            hide-details
          >
          </v-text-field>
        </v-row>
        <v-row class="text-subtitle-1 font-weight-light text-center my-6">
          <v-col>{{ $t('Phaidra is the repository for the permanent secure storage of digital assets at the University of Vienna') }}</v-col>
        </v-row>
      </v-col>
    </v-row>

    <v-divider class="mb-4"></v-divider>

    <v-row class="px-2">

      <v-col cols="12" lg="10">
        <v-row>
          <h2 class="md-headline title font-weight-light primary--text pa-2" >{{ "Featured collections" }}</h2>
        </v-row>

        <v-row justify="center">
          <v-col cols="12" md="4" sm="12">
            <v-card flat>
              <div class="text-center">
                <img class="mb-4" src="../../assets/ext/open-access.jpg" alt="eod" title="By Rafabollas [CC BY-SA 4.0  (https://creativecommons.org/licenses/by-sa/4.0)], from Wikimedia Commons"/>
              </div>
              <v-card-text class="pa-0">
                <h3 class="title font-weight-light primary--text pb-2">Open Access Collection</h3>
                <div v-if="$i18n.locale === 'deu'">PHAIDRA unterstützt <a href="https://openaccess.univie.ac.at/ueber-open-access/oa-policy-der-uni-wien/" target="_blank">die Open-Access-Policy der Universität Wien</a>. Hier finden Sie frei verfügbare Texte, Bilder, Videos und Audiofiles.</div>
                <div v-else>PHAIDRA supports the <a href="https://openaccess.univie.ac.at/en/about-open-access/university-of-vienna-oa-policy/" target="_blank">Open Access Policy of the University of Vienna</a>. The Open Access Collection contains freely available texts, pictures, videos and audio files.</div>
              </v-card-text>
              <v-card-actions class="pl-0">
                <span>[<a color="primary" text href="https://phaidra.univie.ac.at/search#?collection=o:168770" target="_blank">Collection</a>]</span>
              </v-card-actions>
            </v-card>
          </v-col>
          <v-col cols="12" md="4" sm="12">
            <v-card flat>
              <div class="text-center">
                <img class="mb-4" src="../../assets/ext/OEA-Farbe-transparent-RGB_sm.jpg" title="CC BY 4.0" alt="OEA"/>
              </div>
              <v-card-text class="pa-0">
                <h3 class="title font-weight-light primary--text pb-2">Lehren und Lernen leicht gemacht</h3>
                <div v-if="$i18n.locale === 'deu'">Erkunden Sie Open Educational Resources (OER) von Lehrenden der Universität Wien und bereichern Sie Ihre Lehre mit frei nutzbaren und wiederverwendbaren Lehr/Lernmaterialien, die sich analog zu offenen Praktiken in der Forschung etablieren.</div>
                <div v-else>Erkunden Sie Open Educational Resources (OER) von Lehrenden der Universität Wien und bereichern Sie Ihre Lehre mit frei nutzbaren und wiederverwendbaren Lehr/Lernmaterialien, die sich analog zu offenen Praktiken in der Forschung etablieren.</div>
              </v-card-text>
              <v-card-actions class="pl-0">
                <span class="mr-3">[<a color="primary" text href="https://phaidra.univie.ac.at/collections/oer" target="_blank">More</a>]</span>
                <span>[<a color="primary" text href="https://phaidra.univie.ac.at/search#?q=dc_rights%3A%22http%3A%2F%2Fcreativecommons.org%2Flicenses%22+AND+oer%3Atrue" target="_blank">Collection</a>]</span>
              </v-card-actions>
            </v-card>
          </v-col>
          <v-col cols="12" md="4" sm="12">
            <v-card flat>
              <div class="text-center">
                <img class="mb-4" src="../../assets/ext/uscholar.jpg" title="© Universität Wien/ derknopfdruecker.com" alt="u:scholar" />
              </div>
              <v-card-text class="pa-0">
                <h3 class="title font-weight-light primary--text pb-2">u:scholar</h3>
                <div v-if="$i18n.locale === 'deu'">In der u:scholar-Collection von Phaidra finden Sie weltweit frei zugängliche wissenschaftliche Publikationen von Forschenden der Universität Wien.</div>
                <div v-else>The u: scholar Collection of Phaidra includes scientific publications by researchers of the University of Vienna that are freely accessible worldwide.</div>
              </v-card-text>
              <v-card-actions class="pl-0">
                <span class="mr-3">[<a color="primary" text :href="$i18n.locale === 'deu' ? 'http://openaccess.univie.ac.at/publikationsdienste/uscholar/' : 'https://openaccess.univie.ac.at/en/publication-services/uscholar/'" target="_blank">{{ $t('More') }}</a>]</span>
                <span>[<a color="primary" text href="http://uscholar.univie.ac.at/" target="_blank">Collection</a>]</span>
              </v-card-actions>
            </v-card>
          </v-col>
        </v-row>

        <v-row justify="center">
          <v-col cols="12" md="4" sm="12">
            <v-card flat>
              <div class="text-center">
                <img class="mb-4" src="../../assets/ext/valep.jpg" alt="VALEP" title="VALEP"/>
              </div>
              <v-card-text class="pa-0">
                <h3 class="title font-weight-light primary--text pb-2">VALEP</h3>
                <div v-if="$i18n.locale === 'deu'"><a href="https://valep.vc.univie.ac.at/" target="_blank">Virtual Archive of Logical Empiricism</a> ist ein Archiv- und Editionsmanagementwerkzeug, das als Plattform für die Geschichte des Logischen Empirismus und verwandter Strömungen angelegt ist. Die erste Version von VALEP ging 2020 online. Seit Sommer 2022 spiegelt VALEP seine Daten in Phaidra.</div>
                <div v-else><a href="https://valep.vc.univie.ac.at/" target="_blank">Virtual Archive of Logical Empiricism</a> is an archive and edition management tool designed as a platform for the history of Logical Empiricism and related currents. The first version of VALEP went online in 2020. Since summer 2022 VALEP mirrors its data in Phaidra.</div>
              </v-card-text>
              <v-card-actions class="pl-0">
                <span class="mr-3">[<a color="primary" text href="https://phaidra.univie.ac.at/o:1442698" target="_blank">Archives</a>]</span>
                <span>[<a color="primary" text href="https://phaidra.univie.ac.at/o:1442699" target="_blank">Documents</a>]</span>
              </v-card-actions>
            </v-card>
          </v-col>
          <v-col cols="12" md="4" sm="12">
            <v-card flat>
              <div class="text-center">
                <img class="mb-4" src="../../assets/ext/ErlErfSujet_FEATURE.jpg" alt="Erlesenes Erforschen" title="© UB Wien / Patrizia Wiesner-Ledermann"/>
              </div>
              <v-card-text class="pa-0">
                <h3 class="title font-weight-light primary--text pb-2">Erlesenes Erforschen</h3>
                <div v-if="$i18n.locale === 'deu'">Die Universitätsbibliothek präsentiert Videoaufzeichnungen von Buchpräsentationen mit Podiumsdiskussionen von Wissenschafter*innen der Universität Wien, quer durch alle Disziplinen.</div>
                <div v-else>The University Library presents video recordings of book presentations with panel discussions by scientists of the University of Vienna, across all disciplines.</div>
              </v-card-text>
              <v-card-actions class="pl-0">
                <span>[<a color="primary" text href="https://phaidra.univie.ac.at/o:1545123" target="_blank">Collection</a>]</span>
              </v-card-actions>
            </v-card>
          </v-col>
          <v-col cols="12" md="4" sm="12">
            <v-card flat>
              <div class="text-center">
                <img class="mb-4" src="../../assets/ext/board-g3e7952b2d_640.jpg" alt="oa" title="By Rafabollas [CC BY-SA 4.0  (https://creativecommons.org/licenses/by-sa/4.0)], from Wikimedia Commons"/>
              </div>
              <v-card-text class="pa-0">
                <h3 v-if="$i18n.locale === 'deu'" class="title font-weight-light primary--text pb-2">Forschungsdatenmanagement in Österreich</h3>
                <h3 v-else class="title font-weight-light primary--text pb-2">Research Data Management in Austria</h3>
                <div v-if="$i18n.locale === 'deu'">Webinar Series "Research Data Management in Austria" - Die Veranstaltungsreihe richtet sich an Forschende und/oder an Personen aus der Forschungsunterstützung und dient der Vernetzung und dem Austausch zum Thema Management von Forschungsdaten, Verfassen eines Datenmanagementplans und ähnlichen verwandten Themen. In Phaidra sind Folien und Videoaufzeichnungen zur Reihe in einer Collection vereint.</div>
                <div v-else>The webinar series is aimed at researchers and/or research support staff and serves as a networking and exchange platform on the topic of research data management, writing a data management plan, and similar related topics. In Phaidra, all slides and video recordings of the series are combined in one collection.</div>
              </v-card-text>
              <v-card-actions class="pl-0">
                <span class="mr-3">[<a color="primary" text href="https://phaidra.univie.ac.at/search#?collection=o:168770" target="_blank">Collection</a>]</span>
              </v-card-actions>
            </v-card>
          </v-col>
        </v-row>

        <v-row justify="center">
          <v-col cols="12" md="4" sm="12">
            <v-card flat>
              <div class="text-center">
                <img class="mb-4" src="../../assets/ext/lili.jpg" title="libri liberorum" alt="libri liberorum" />
              </div>
              <v-card-text class="pa-0">
                <h3 class="title font-weight-light primary--text pb-2">libri liberorum</h3>
                <div>Zeitschrift der Österreichischen Gesellschaft für Kinder- und Jugendliteraturforschung</div>
                <div>Die Fachzeitschrift hat sich zum Ziel gesetzt, die Ansätze zur Erforschung dieses Literaturzweiges an verschiedenen österreichischen Hochschul-Instituten und Pädagogischen Hochschulen zu vernetzen und dient auch als Basis für die
  Kommunikation mit ähnlichen Institutionen im In- und Ausland  insbesondere im Rahmen der Europäischen Union.</div>
              </v-card-text>
              <v-card-actions class="pl-0">
                <span class="mr-3">[<a color="primary" text href="https://journals.univie.ac.at/index.php/lili/issue/archive" target="_blank">More</a>]</span>
                <span>[<a color="primary" text href="https://phaidra.univie.ac.at/o:1030875" target="_blank">Collection</a>]</span>
              </v-card-actions>
            </v-card>
          </v-col>
          <v-col cols="12" md="4" sm="12">
            <v-card flat>
              <div class="text-center">
                <img class="mb-4" src="../../assets/ext/incunabel.jpg" alt="eod" title="Gaius Plinius Secundus: Historia naturalis: libri XXXVII. [© Universitätsbibliothek Wien]"/>
              </div>
              <v-card-text class="pa-0">
                <h3 class="title font-weight-light primary--text pb-2">E-Books on Demand</h3>
                <div v-if="$i18n.locale === 'deu'">In dieser Collection finden Sie die im Rahmen des Services eBooks on Demand (EOD) digitalisierten Bücher der Universitätsbibliothek Wien.</div>
                <div v-else>This collection includes books digitized by the Vienna University Library as part of the eBooks on Demand (EOD) service.</div>
              </v-card-text>
              <v-card-actions class="pl-0">
                <span class="mr-3" v-if="$i18n.locale === 'deu'">[<a color="primary" text href="http://bibliothek.univie.ac.at/eod" target="_blank">More</a>]</span>
                <span v-else>[<a color="primary" text href="http://bibliothek.univie.ac.at/en/eod.html" target="_blank">More</a>]</span>
                <span>[<a color="primary" text href="https://phaidra.univie.ac.at/o:1545123" target="_blank">Collection</a>]</span>
              </v-card-actions>
            </v-card>
          </v-col>
          <v-col cols="12" md="4" sm="12">
            <v-card flat>
              <div class="text-center">
                <img class="mb-4" src="../../assets/ext/Phaidra_Bobrowsky_Collection_Dialog_Publizistik_s.jpg" alt="oa" title="By Rafabollas [CC BY-SA 4.0  (https://creativecommons.org/licenses/by-sa/4.0)], from Wikimedia Commons"/>
              </div>
              <v-card-text class="pa-0">
                <h3 class="title font-weight-light primary--text pb-2">Dialoge Publizistik: Kommunikationswissenschaft audiovisuell</h3>
                <div>Ein audiovisuelles Projekt von Dr. Roland Burkart und Dr. Manfred Bobrowsky am Institut für Publizistik- und Kommunikationswissenschaft der Universität Wien.</div>
              </v-card-text>
              <v-card-actions class="pl-0">
                <span class="mr-3">[<a color="primary" text href="https://phaidra.univie.ac.at/search#?collection=o:168770" target="_blank">Collection</a>]</span>
              </v-card-actions>
            </v-card>
          </v-col>
        </v-row>

        <v-row justify="center">

          <v-col cols="12" md="4" sm="12">
          <v-card flat>
            <div class="text-center">
              <img class="mb-4" src="../../assets/ext/dmp.jpg" alt="dmp" title="CC0 Public Domain Dedication"/>
            </div>
            <h3 class="title font-weight-light primary--text pb-2">DMP Use Case Project</h3>
            <div v-if="$i18n.locale === 'deu'">Diese Sammlung enthält eine geprüfte Liste von 839 öffentlich zugänglichen Datenmanagementplänen (DMPs) aus dem EU-Rahmenprogramm Horizon 2020. Die Analyse solcher DMPs kann dabei helfen Best Practices aber auch wichtige Herausforderungen zu identifizieren.</div>
            <div v-else>This collection contains a vetted white list of 839 publicly accessible Data Management Plans (DMPs) from the EU Horizon 2020 Framework Programme. The analysis of such DMPs can help to identify good practices but also common challenges for researchers.</div>
            <v-card-actions class="pl-0">
              <span class="mr-3">[<a color="primary" href="https://doi.org/10.12688/openreseurope.13342.1" target="_blank">Publication</a>]</span>
              <span class="mr-3">[<a color="primary" href="https://phaidra.univie.ac.at/o:1140797" target="_blank">"Collection"</a>]</span>
            </v-card-actions>
            </v-card>
          </v-col>

          <v-col cols="12" md="4" sm="12">
          <v-card flat>
            <div class="text-center">
              <img class="mb-4" src="../../assets/ext/03008_14kk.jpg" alt="The Ethnographic Data Archive" title="© Wolfgang Kraus"/>
            </div>
            <h3 class="title font-weight-light primary--text pb-2">
              <span v-if="$i18n.locale === 'deu'">Das Ethnographische Datenarchiv</span>
              <span v-else>The Ethnographic Data Archive</span>
            </h3>
            <div v-if="$i18n.locale === 'deu'">Das Ethnographische Datenarchiv (eda) stellt eine Infrastruktur für die permanente Archivierung ethnographischer und anderer qualitativer Forschungsdaten zur Verfügung. Mit einem angepassten Metadatenset nimmt es Rücksicht auf die ethischen und rechtlichen Besonderheiten qualitativer Methodologien.</div>
            <div v-else>The Ethnographic Data Archive (eda) provides an infrastructure for permanently archiving ethnographic and other kinds of qualitative research data. Using an adapted metadata set, it aims at taking care of the ethical and legal specificities of qualitative methodologies.</div>
            <v-card-actions class="pl-0">
              <span class="mr-3">[<a color="primary" href="https://eda.univie.ac.at/" target="_blank">More</a>]</span>
              <span class="mr-3">[<a color="primary" href="https://phaidra.univie.ac.at/search#?owner=ethnograpp95" target="_blank">Collection</a>]</span>
            </v-card-actions>
            </v-card>
          </v-col>

          <v-col cols="12" md="4" sm="12">
            <v-card flat>
              <div class="text-center">
                <a href="https://phaidra.univie.ac.at/o:981810"><img class="mb-4" src="../../assets/ext/PlanderJugendhalle.jpg" alt="PlanderJugendhalle" title="Plan der Jugendhalle aus dem Katalog der Jubiläums-Sonderausstellung 'Jugendhalle' in Wien 1898. [CC BY-NC 4.0, Universitätsbibliothek Wien]"/></a>
              </div>
              <h3 class="title font-weight-light primary--text pb-2">Sammlung „Jugendhalle“</h3>
              <div v-if="$i18n.locale === 'deu'">Die Sammlung „Jugendhalle“ verfügt  über 364 Titel Methoden- und Schulbücher aus der Habsburgermonarchie im Original. Daneben wurden der Sammlung 30 Werke unterschiedlicher Provenienz in Fotokopie hinzugefügt.</div>
              <div v-else>Die Sammlung „Jugendhalle“ verfügt  über 364 Titel Methoden- und Schulbücher aus der Habsburgermonarchie im Original. Daneben wurden der Sammlung 30 Werke unterschiedlicher Provenienz in Fotokopie hinzugefügt.</div>
              <v-card-actions class="pl-0">
                <span class="mr-3">[<a color="primary" href="https://phaidra.univie.ac.at/o:988077" target="_blank">Collection</a>]</span>
              </v-card-actions>
            </v-card>
          </v-col>
        </v-row>

        <v-row justify="center">
          <v-col cols="12" md="4" sm="12">
            <v-card flat>
              <div class="text-center">
                <a href="https://phaidra.univie.ac.at/o:961913"><img class="mb-4" src="../../assets/ext/Wandtafeln.jpg" alt="wandtafeln" title="Wurmfarn [© Universität Wien]"/></a>
              </div>
              <h3 class="title font-weight-light primary--text pb-2">Botanische Wandtafeln</h3>
              <div v-if="$i18n.locale === 'deu'">Diese Collection präsentiert die digitalisierten botanischen Wandtafeln und Großdrucke aus dem Bestand des ehemaligen Botanischen sowie Pflanzenphysiologischen Instituts der Universität Wien.</div>
              <div v-else>This collection presents the digitized botanical wallcharts and large prints from the collection of the former Botanical and Plant Physiology Institute of the University of Vienna.</div>
              <v-card-actions class="pl-0">
                <span class="mr-3">[<a color="primary" href="https://phaidra.univie.ac.at/o:1018226" target="_blank">Collection</a>]</span>
              </v-card-actions>
            </v-card>
          </v-col>

          <v-col cols="12" md="4" sm="12">
            <v-card flat>
              <div class="text-center">
                <img class="mb-4" src="../../assets/ext/DLBT_featured_collections.jpg" alt="dlbt" title="Handschriftensammlung von Theaterstücken aus dem 17. Jahrhundert, Wienbibliothek [CC-BY 4.0, Claudia Zeller]"/>
              </div>
              <h3 class="title font-weight-light primary--text pb-2">Digital Library and Bibliography of Literature in Translation</h3>
              <div v-if="$i18n.locale === 'deu'">An ever-expanding collection, the DLBT provides access to translated works of fiction and their reception documents.</div>
              <div v-else>An ever-expanding collection, the DLBT provides access to translated works of fiction and their reception documents.</div>
              <v-card-actions class="pl-0">
                <span class="mr-3">[<a color="primary" href="https://dlbt.univie.ac.at/" target="_blank">More</a>]</span>
                <span class="mr-3">[<a color="primary" href="https://phaidra.univie.ac.at/search#?sortdef=title%20asc&collection=o:753158" target="_blank">Collection</a>]</span>
              </v-card-actions>
            </v-card>
          </v-col>

          <v-col cols="12" md="4" sm="12">
            <v-card flat>
              <div class="text-center">
                <a href="https://campusmedius.net"><img class="mb-4" src="../../assets/ext/campusmedius.jpg" title="Campus Medius" alt="Campus Medius"/></a>
              </div>
              <h3 class="title font-weight-light primary--text pb-2">Campus Medius</h3>
              <div v-if="$i18n.locale === 'deu'"><a href="https://campusmedius.net/" target="_blank">Campus Medius</a> erforscht und erweitert die Möglichkeiten der digitalen Kartografie in den Kultur- und Medienwissenschaften. Das von <a href="https://www.univie.ac.at/germanistik/simon-ganahl/" target="_blank">Simon Ganahl</a> geleitete Projekt entwickelt sich von einer historischen Fallstudie zu einer Mapping-Plattform.</div>
              <div v-else><a href="https://campusmedius.net/" target="_blank">Campus Medius</a> explores and expands the possibilities of digital cartography in cultural and media studies. The project, headed by <a href="https://www.univie.ac.at/germanistik/simon-ganahl/" target="_blank">Simon Ganahl</a>, is developing from a historical case study to a mapping platform.</div>
              <v-card-actions class="pl-0">
                <span class="mr-3">[<a color="primary" href="https://campusmedius.net/" target="_blank">More</a>]</span>
                <span class="mr-3">[<a color="primary" href="https://phaidra.univie.ac.at/o:884524" target="_blank">Collection</a>]</span>
              </v-card-actions>
            </v-card>
          </v-col>
        </v-row>

        <v-row justify="center">
          <v-col cols="12" md="4" sm="12">
            <v-card flat>
              <div class="text-center">
                <a href="https://phaidra.univie.ac.at/o:288359">
                  <img class="mb-4" src="../../assets/ext/135.49.jpg" title="Alter Universitatsplatz Wien [© Archiv der Universität Wien]" alt="Alter Universitatsplatz Wien"/>
                </a>
              </div>
              <h3 class="title font-weight-light primary--text pb-2">
                <span v-if="$i18n.locale === 'deu'">Digitalisierte Bestände des Universitätsarchivs</span>
                <span v-else>Digital Collections of the Vienna University Archive</span>
              </h3>
              <div v-if="$i18n.locale === 'deu'">Das Archiv der Universität Wien digitalisiert laufend besondere Stücke aus seinen Beständen. Erfahren Sie mehr über das Digitale Archiv auf der Website des Universitätsarchivs.</div>
              <div v-else>The archive of the University of Vienna is constantly digitizing special pieces from its collections. Learn more about the Digital Archive on the website of the Vienna University Archive.</div>
              <v-card-actions class="pl-0">
                <span class="mr-3" v-if="$i18n.locale === 'deu'">[<a color="primary" href="https://bibliothek.univie.ac.at/archiv/das_digitale_archiv.html" target="_blank">More</a>]</span>
                <span class="mr-3" v-else>[<a color="primary" href="https://bibliothek.univie.ac.at/archiv/en/das_digitale_archiv.html" target="_blank">More</a>]</span>
                <span class="mr-3">[<a color="primary" href="https://phaidra.univie.ac.at/o:527682" target="_blank">Collection</a>]</span>
              </v-card-actions>
            </v-card>
          </v-col>

          <v-col cols="12" md="4" sm="12">
            <v-card flat>
              <div class="text-center">
                <img class="mb-4" src="../../assets/ext/Eliserichter.jpg" alt="Elise Richter" title="Elise Richter [CC BY-NC-ND 4.0, Wienbibliothek im Rathaus, Tagblattarchiv: Fotosammlung, TF-008670]"/>
              </div>
              <h3 class="title font-weight-light primary--text pb-2">Autobiographien von Forscherinnen</h3>
              <div>In einem Masterseminar, das am Institut für Bildungswissenschaft der Universität Wien gehalten wurde, haben Studierende biographische Interviews mit Forscherinnen durchgeführt.</div>
              <v-card-actions class="pl-0">
                <span class="mr-3">[<a color="primary" href="https://phaidra.univie.ac.at/o:868598" target="_blank">Collection</a>]</span>
              </v-card-actions>
            </v-card>
          </v-col>

          <v-col cols="12" md="4" sm="12">
            <v-card flat>
              <div class="text-center">
                <img class="mb-4" src="../../assets/ext/Oral_History_Projekt_©_Manfred_Bobrowsky_1.jpg" title="© Manfred Bobrowsky" alt="Oral History"/>
              </div>
              <h3 class="title font-weight-light primary--text pb-2">
                <span v-if="$i18n.locale === 'deu'">Mündliche Geschichtsüberlieferung</span>
                <span v-else>Oral History</span>
              </h3>
              <div v-if="$i18n.locale === 'deu'">Im Rahmen einer regelmäßig stattfindenden Lehrveranstaltung wurde von Dr. Manfred Bobrowsky zwischen 1988 und 1996 ein Video-Projekt durchgeführt, das jungen Menschen einen „hautnahen“ Kontakt mit der eigenen Geschichte vermitteln sollte.</div>
              <div v-else>As part of a regular course, Dr. Ing. Manfred Bobrowsky carried out a video project between 1988 and 1996, which was intended to give young people "close contact" with their own history.</div>
              <v-card-actions class="pl-0">
                <span class="mr-3">[<a color="primary" href="https://phaidra.univie.ac.at/collections/oral-history" target="_blank">More</a>]</span>
                <span class="mr-3">[<a color="primary" href="https://phaidra.univie.ac.at/o:868526" target="_blank">Collection</a>]</span>
              </v-card-actions>
            </v-card>
          </v-col>
        </v-row>

        <v-row justify="center">
          <v-col cols="12" md="4" sm="12">
            <v-card flat>
              <div class="text-center">
                <a href="https://phaidra.univie.ac.at/o:575110">
                  <img class="mb-4" src="../../assets/ext/suez.jpg" alt="suez" title="Der Suez-Kanal [© Österreichische Zentralbibliothek für Physik, Universität Wien]"/>
                </a>
              </div>
              <h3 class="title font-weight-light primary--text pb-2">
                <span v-if="$i18n.locale === 'deu'">Franz Ferdinands Reise um die Erde</span>
                <span v-else>Franz Ferdinand's journey around the world</span>
              </h3>
              <div v-if="$i18n.locale === 'deu'">Eine Sammlung von 147 Fotografien, die Ludwig Lorenz von Liburnau zur Dokumentation der Weltreise des österreichischen Erzherzogs in den Jahren 1892/93 angelegt hat.</div>
              <div v-else>A collection of 147 photographs created by Ludwig Lorenz of Liburnau to document the world tour of the Austrian Archduke in the years 1892/93.</div>
              <v-card-actions class="pl-0">
                <span class="mr-3">[<a color="primary" href="https://phaidra.univie.ac.at/collections/franz-ferdinands-reise" target="_blank">More</a>]</span>
                <span class="mr-3">[<a color="primary" href="https://phaidra.univie.ac.at/o:575134" target="_blank">Collection</a>]</span>
              </v-card-actions>
            </v-card>
          </v-col>

          <v-col cols="12" md="4" sm="12">
            <v-card flat>
              <div class="text-center">
                <img class="mb-4" src="../../assets/ext/histphys.jpg" alt="histphys" title="Pendel im Holzgestell [CC BY 4.0, Fakultät für Physik, Universität Wien]"/>
              </div>
              <h3 class="title font-weight-light primary--text pb-2">The Historical Physics Collection</h3>
              <div>Here you can find several hundred beautiful objects of this collection. The showpieces are assigned to mechanics, heat, acoustics, optics and electricity.</div>
              <v-card-actions class="pl-0">
                <span class="mr-3">[<a color="primary" href="http://history-physics.univie.ac.at/" target="_blank">More</a>]</span>
                <span class="mr-3">[<a color="primary" href="https://phaidra.univie.ac.at/detail/o:724719" target="_blank">Collection</a>]</span>
              </v-card-actions>
            </v-card>
          </v-col>

          <v-col cols="12" md="4" sm="12">
            <v-card flat>
              <div class="text-center">
                <a href="https://phaidra.univie.ac.at/o:526660">
                  <img class="mb-4" src="../../assets/ext/difab.jpg" alt="difab" title="Sveta Bogorodica Periblepta (Sveti Kliment) [CC BY 4.0, Digitales Forschungsarchiv Byzanz, Universität Wien]"/>
                </a>
              </div>
              <h3 class="title font-weight-light primary--text pb-2">
                <span v-if="$i18n.locale === 'deu'">Digitales Forschungsarchiv Byzanz</span>
                <span v-else>Digital Research Archive for Byzantium</span>
              </h3>
              <div v-if="$i18n.locale === 'deu'">Das Ziel des Digitialen Forschungsarchiv Byzanz ist es, das Byzantinische Reich fotografisch möglichst umfangreich zu erfassen und zugänglich zu machen.</div>
              <div v-else>The Digital Research Archive for Byzantium is a visual resource database devoted to the cultural legacy of Byzantium.</div>
              <v-card-actions class="pl-0">
                <span class="mr-3" v-if="$i18n.locale === 'deu'">[<a color="primary" href="http://difab.univie.ac.at" target="_blank">More</a>]</span>
                <span class="mr-3" v-else>[<a color="primary" href="https://difab.univie.ac.at/en/digitales-forschungsarchiv-byzanz/" target="_blank">More</a>]</span>
                <span class="mr-3">[<a color="primary" href="https://phaidra.univie.ac.at/o:409288" target="_blank">Collection</a>]</span>
              </v-card-actions>
            </v-card>
          </v-col>
        </v-row>

        <v-row justify="center">
          <v-col cols="12" md="4" sm="12">
            <v-card flat>
              <div class="text-center">
                <a href="https://phaidra.univie.ac.at/o:424477">
                  <img class="mb-4" src="../../assets/ext/ubmaps.jpg" alt="ubmaps" title="Europa nach seinen oro-hydrographischen Verhältnissen [Public Domain, Bestand der Kartensammlung der Fachbereichsbibliothek Geographie und Regionalforschung, Universität Wien]"/>
                </a>
              </div>
              <h3 class="title font-weight-light primary--text pb-2">UB-Maps</h3>
              <div v-if="$i18n.locale === 'deu'">Der Kartenbestand der Fachbereichsbibliothek Geographie und Regionalforschung (Universität Wien) geht historisch bis in die Gründungszeit der Lehrkanzel für Geographie an der Universität Wien im Jahr 1851 zurück.</div>
              <div v-else>The map assets of the Geography and Regional Research Library of University of Vienna date back to the founding period of the Department of Geography at the University of Vienna in 1851.</div>
              <v-card-actions class="pl-0">
                <span class="mr-3">[<a color="primary" href="https://phaidra.univie.ac.at/o:423816" target="_blank">Collection</a>]</span>
              </v-card-actions>
            </v-card>
          </v-col>

          <v-col cols="12" md="4" sm="12">
            <v-card flat>
              <div class="text-center">
                <a href="https://phaidra.univie.ac.at/o:169294">
                  <img class="mb-4" src="../../assets/ext/physik.jpg" alt="physik" title="Foto von Max Planck, Berlin [© Österreichische Zentralbibliothek für Physik, Universität Wien]"/>
                </a>
              </div>
              <h3 class="title font-weight-light primary--text pb-2">
                <span v-if="$i18n.locale === 'deu'">Digitalisierte Bestände der Österreichischen Zentralbibliothek für Physik</span>
                <span v-else>Digitized assets of the Austrian Central Library for Physics</span>
              </h3>
              <div v-if="$i18n.locale === 'deu'">Diese Collection beinhaltet die an der Österreichischen Zentralbibliothek für Physik vorhandenen multimedialen Bestände (Videos, Tonaufzeichnungen etc.) sowie digitalisierte Nachlässe und Sondersammlungen.</div>
              <div v-else>This collection contains multimedia material (videos, audio recordings, etc.) available at the Austrian Central Library for Physics as well as digitized legacies and special collections.</div>
              <v-card-actions class="pl-0">
                <span class="mr-3">[<a color="primary" href="https://phaidra.univie.ac.at/o:263771" target="_blank">Collection</a>]</span>
              </v-card-actions>
            </v-card>
          </v-col>

          <v-col cols="12" md="4" sm="12">
            <v-card flat>
              <div class="text-center">
                <a href="https://phaidra.univie.ac.at/o:457737">
                  <img class="mb-4" src="../../assets/ext/650.jpg" alt="650" title="Jubiläumsfahnen [© Universität Wien]"/>
                </a>
              </div>
              <h3 class="title font-weight-light primary--text pb-2">
                <span v-if="$i18n.locale === 'deu'">650 Jahre Universität Wien</span>
                <span v-else>650 years of University of Vienna</span>
              </h3>
              <div v-if="$i18n.locale === 'deu'">Die Universität Wien feierte 2015 ihr 650. Gründungsjubiläum mit zahlreichen Veranstaltungen.</div>
              <div v-else>The University of Vienna celebrated its 650th anniversary in 2015 with numerous events.</div>
              <v-card-actions class="pl-0">
                <span class="mr-3">[<a color="primary" href="http://medienportal.univie.ac.at/videos/650-jahr-jubilaeum/" target="_blank">More</a>]</span>
                <span class="mr-3">[<a color="primary" href="https://phaidra.univie.ac.at/o:459021" target="_blank">Collection</a>]</span>
              </v-card-actions>
            </v-card>
          </v-col>
        </v-row>

        <v-row justify="center">
          <v-col cols="12" md="4" sm="12">
            <v-card flat>
              <div class="text-center">
                <a href="https://phaidra.univie.ac.at/o:423777">
                  <img class="mb-4" src="../../assets/ext/astronomie.jpg" alt="astrophysik" title="H-alpha Aufnahme der Sonne [CC BY 3.0 AT , Archiv des Instituts für Astrophysik, Universität Wien]"/>
                </a>
              </div>
              <h3 class="title font-weight-light primary--text pb-2">
                <span v-if="$i18n.locale === 'deu'">Das Archiv des Instituts für Astrophysik</span>
                <span v-else>The archive of the Institute of Astrophysics</span>
              </h3>
              <div v-if="$i18n.locale === 'deu'">Derzeit umfasst das "Digitale Archiv" bereits ca. 20.000 digitalisierte Objekte, darunter die Diasammlung, Teilnachlässe, Dokumente und Pläne aus der Zeit der Errichtung der Sternwarte auf der Türkenschanze, Handschriften und die Sammlung historischer Bücher.</div>
              <div v-else>Digital archive of the Institute of Astrophysics contains ca. 20,000 digitized objects, including photographic slides, documents and plans from time of construction of the observatory on the Türkenschanze, manuscripts or collection of historical books.</div>
              <v-card-actions class="pl-0">
                <span class="mr-3">[<a color="primary" href="https://phaidra.univie.ac.at/o:292203" target="_blank">Collection</a>]</span>
              </v-card-actions>
            </v-card>
          </v-col>

          <v-col cols="12" md="4" sm="12">
            <v-card flat>
              <div class="text-center">
                <a href="https://phaidra.univie.ac.at/o:460780">
                  <img class="mb-4" src="../../assets/ext/einfra.jpg" alt="einfra" title="Activity Report 2014-2016 [CC BY 4.0, e-Infrastructures Austria]"/>
                </a>
              </div>
              <h3 class="title font-weight-light primary--text pb-2">e-Infrastructures Austria</h3>
              <div v-if="$i18n.locale === 'deu'">Das Projekt e-Infrastructures Austria wurde 2014 vom Bundesministerium für Wissenschaft, Forschung und Wirtschaft initiiert, um österreichweit den koordinierten Aufbau sowie die Weiterentwicklung von Repositorieninfrastrukturen zu fördern.</div>
              <div v-else>The project e-Infrastructures Austria was initiated in 2014 by the Federal Ministry of Science, Research and Economy in order to promote the coordinated development of repository infrastructure throughout Austria.</div>
              <v-card-actions class="pl-0">
                <span class="mr-3" v-if="$i18n.locale === 'deu'">[<a color="primary" href="https://www.e-infrastructures.at" target="_blank">More</a>]</span>
                <span class="mr-3" v-else>[<a color="primary" href="https://www.e-infrastructures.at/en/" target="_blank">More</a>]</span>
                <span class="mr-3">[<a color="primary" href="https://phaidra.univie.ac.at/o:459171" target="_blank">Collection</a>]</span>
              </v-card-actions>
            </v-card>
          </v-col>

          <v-col cols="12" md="4" sm="12">
            <v-card flat>
              <div class="text-center">
                <a href="https://phaidra.univie.ac.at/o:472131">
                  <img class="mb-4" src="../../assets/ext/schubert.jpg" alt="schubert" title="Kurt und Ursula Schubert [CC BY-NC-ND 4.0, Institut für Judaistik, Universität Wien]"/>
                </a>
              </div>
              <h3 class="title font-weight-light primary--text pb-2">
                <span v-if="$i18n.locale === 'deu'">Kurt und Ursula Schubert-Archive</span>
                <span v-else>Kurt and Ursula Schubert online Archive</span>
              </h3>
              <div v-if="$i18n.locale === 'deu'">Diese Collection umfasst sämtliche Einträge aus dem wissenschaftlichen Nachlass von Professor Kurt und Dr. Ursula Schubert.</div>
              <div v-else>This collection provides access to the academic working documents left by the two scholars: manuscripts for their lectures at the Institute for Jewish Studies, conferences and notes for research.</div>
              <v-card-actions class="pl-0">
                <span class="mr-3">[<a color="primary" href="http://ks.univie.ac.at/" target="_blank">More</a>]</span>
                <span class="mr-3">[<a color="primary" href="https://phaidra.univie.ac.at/o:475243" target="_blank">Collection</a>]</span>
              </v-card-actions>
            </v-card>
          </v-col>
        </v-row>

      </v-col>

      <v-col cols="12" lg="2" class="border-left mt-2">
        <v-row>
          <v-col cols="12">
            <v-row>
              <h2 class="md-headline title font-weight-light primary--text pa-2 mb-3" ><icon width="27px" height="27px" name="univie-kartenkontakte" class="mr-2"></icon>{{ "Contact" }}</h2>
            </v-row>
            <v-divider class="my-4"></v-divider>
            <!-- <v-row class="pl-2 mb-4">
              <a href="mailto:phaidra@univie.ac.at">phaidra@univie.ac.at</a>
            </v-row> -->
            <v-row class="pl-2 mb-6 mt-4">
              <span v-if="$i18n.locale === 'deu'">Bei allen Fragen zu PHAIDRA steht Ihnen unsere Support-Adresse zur Verfügung</span>
              <span v-else>If you have any questions about Phaidra, please contact support</span> <a href="mailto:support.phaidra@univie.ac.at">support.phaidra@univie.ac.at</a>
            </v-row>
            <div class="gray-bg">
              <div class="content-box-uni-rot">
                <span v-if="$i18n.locale === 'deu'">Neu</span>
                <span v-else>New</span>
              </div>
                <a v-if="$i18n.locale === 'deu'" href="https://phaidra.univie.ac.at/o:1430148" target="_self">Guidelines für barrierearme Inhalte in Repositorien</a>
                <a v-else href="https://phaidra.univie.ac.at/o:1430148" target="_self">Guidelines for barrier-free content in repositories</a>
            </div>
            <v-row class="pl-2 mb-6 mt-4">
              <a :href="$i18n.locale === 'deu' ? 'https://datamanagement.univie.ac.at/ueber-phaidra/policy-von-phaidra/' : 'https://datamanagement.univie.ac.at/en/about-phaidra/policy-of-phaidra/'" target="_blank">{{ $t('Policy of Phaidra') }}</a>
            </v-row>
            <v-row class="pl-2 mb-6">
              <router-link :to="localePath('termsofuse')">{{ $t('Terms of Use')}}</router-link>
            </v-row>
            <v-row class="pl-2 mb-6">
              <a href="https://rdm.univie.ac.at/rdm-policy-and-faq/" target="_blank">Research data policy</a>
            </v-row>
            <v-row class="pl-2 mb-6">
              <a href="https://datamanagement.univie.ac.at/" target="_blank">{{ $t('Service page') }}</a>
            </v-row>
            <v-row class="pl-2 mb-6">
              <div class="gray-bg">
                <i18n path="HOME_SANDBOX" tag="p">
                  <a href="https://phaidra-sandbox.univie.ac.at" target="_blank">{{ $t('test instance') }}</a>
                </i18n>
                <a href="https://datamanagement.univie.ac.at/ueber-phaidra/downloads-und-anleitungen/" target="_blank">{{ $t('User guides')}}</a>
              </div>
            </v-row>
            <v-divider class="my-4"></v-divider>
            <v-row>
              <a href="https://www.facebook.com/univienna/" target="_blank"><icon class="mx-2" width="24px" height="18px" name="univie-facebook"></icon></a>
              <a href="https://twitter.com/univienna/" target="_blank"><icon class="ml-2 mr-4" width="26px" height="18px" name="univie-twitter"></icon></a>
              <a href="https://www.youtube.com/univienna/" target="_blank"><icon class="mx-2" width="24px" height="18px" name="univie-youtube"></icon></a>
              <a href="https://www.instagram.com/univienna/" target="_blank"><icon class="mx-2" width="24px" height="18px" name="univie-instagram"></icon></a>
              <a href="http://www.flickr.com/univienna/" target="_blank"><icon class="mx-2" width="24px" height="18px" name="univie-flickr"></icon></a>
            </v-row>
          </v-col>
        </v-row>
      </v-col>

    </v-row>
  </div>

</template>

<script>
import { context } from '../../mixins/context'
import '@/compiled-icons/univie-kartenkontakte'
import '@/compiled-icons/univie-facebook'
import '@/compiled-icons/univie-youtube'
import '@/compiled-icons/univie-twitter'
import '@/compiled-icons/univie-instagram'
import '@/compiled-icons/univie-flickr'

export default {
  name: 'home',
  mixins: [ context ],
  data () {
    return {
      q: ''
    }
  }
}
</script>

<style scoped>
.v-card img {
  max-width: 100%;
  height: auto;
}
.gray-bg {
    background-color: #f2f2f2;
    padding: 9px;
}
.content-box-uni-rot {
    background-color: #dd4814;
    font-size: 10.8pt;
    color: white;
    display: table;
    line-height: 14pt;
    margin: 0 0 20px -8px !important;
    padding: 5px 10px;
}
h2.md-headline {
  font-size: 21pt!important;
  font-weight: 300!important;
}
</style>
