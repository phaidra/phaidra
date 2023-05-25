<template>
  <div>
    <template v-if="$i18n.locale === 'deu'">

      <v-slide-y-transition hide-on-leave>
        <div v-if="license === 'http://rightsstatements.org/vocab/InC/1.0/'" class="license-desc">
          <p>
            Wenn Sie keine Lizenz w&auml;hlen, darf Ihr Schutzgegenstand lediglich im Rahmen der Schranken des <a href="http://www.ris.bka.gv.at/GeltendeFassung.wxe?Abfrage=Bundesnormen&Gesetzesnummer=10001848" target="_blank">Urheberrechts</a> verwertet werden. Darüber hinaus gestatten Sie weder eine kommerzielle noch eine nicht kommerzielle Verwertung, insbesondere Vervielf&auml;ltigung, Verbreitung, Sendung, Zurverfügungstellung und Bearbeitung Ihres Schutzgegenstandes.
          </p>
        </div>
      </v-slide-y-transition>

      <v-slide-y-transition hide-on-leave>
        <div v-if="license === 'http://creativecommons.org/licenses/by/4.0/'" class="license-desc">
          <p>
            Der Lizenznehmer darf:
            <br/><strong>Teilen</strong> — das Material in jedwedem Format oder Medium vervielfältigen und weiterverbreiten
            <br/><strong>Bearbeiten</strong> — das Material remixen, verändern und darauf aufbauen, sogar kommerziell
          </p>
          <p>
            Unter folgenden Bedingungen:
            <br/><strong>Namensnennung</strong>
          </p>
          <p>
            Kurzfassung der Lizenz:
            <br/><a href="https://creativecommons.org/licenses/by/4.0/deed.de" target="_blank">https://creativecommons.org/licenses/by/4.0/deed.de</a>
            <br/>Vollständiger Lizenztext:
            <br/><a href="https://creativecommons.org/licenses/by/4.0/legalcode" target="_blank">https://creativecommons.org/licenses/by/4.0/legalcode</a>
          </p>
        </div>
      </v-slide-y-transition>

      <v-slide-y-transition hide-on-leave>
        <div v-if="license === 'http://creativecommons.org/licenses/by-sa/4.0/'" class="license-desc">
          <p>
            Der Lizenznehmer darf:
            <br/><strong>Teilen</strong> — das Material in jedwedem Format oder Medium vervielfältigen und weiterverbreiten
            <br/><strong>Bearbeiten</strong> — das Material remixen, verändern und darauf aufbauen, sogar kommerziell
          </p>
          <p>
            Unter folgenden Bedingungen:
            <br/><strong>Namensnennung — Weitergabe unter gleichen Bedingungen</strong>
          </p>
          <p>
            Kurzfassung der Lizenz:
            <br/><a href="https://creativecommons.org/licenses/by-sa/4.0/deed.de" target="_blank">https://creativecommons.org/licenses/by-sa/4.0/deed.de</a>
            <br/>Vollständiger Lizenztext:
            <br/><a href="https://creativecommons.org/licenses/by-sa/4.0/legalcode" target="_blank">https://creativecommons.org/licenses/by-sa/4.0/legalcode</a>
          </p>
        </div>
      </v-slide-y-transition>

      <v-slide-y-transition hide-on-leave>
        <div v-if="license === 'http://creativecommons.org/licenses/by-nc/4.0/'" class="license-desc">
          <p>
            Der Lizenznehmer darf:
            <br/><strong>Teilen</strong> — das Material in jedwedem Format oder Medium vervielfältigen und weiterverbreiten
            <br/><strong>Bearbeiten</strong> — das Material remixen, verändern und darauf aufbauen
          </p>
          <p>
            Unter folgenden Bedingungen:
            <br/><strong>Namensnennung — nicht kommerziell</strong>
          </p>
          <p>
            Kurzfassung der Lizenz:
            <br/><a href="https://creativecommons.org/licenses/by-nc/4.0/deed.de" target="_blank">https://creativecommons.org/licenses/by-nc/4.0/deed.de</a>
            <br/>Vollständiger Lizenztext:
            <br/><a href="https://creativecommons.org/licenses/by-nc/4.0/legalcode" target="_blank">https://creativecommons.org/licenses/by-nc/4.0/legalcode</a>
          </p>
        </div>
      </v-slide-y-transition>

      <v-slide-y-transition hide-on-leave>
        <div v-if="license === 'http://creativecommons.org/licenses/by-nd/4.0/'" class="license-desc">
          <p>
            Der Lizenznehmer darf:
            <br/><strong>Teilen</strong> — das Material in jedwedem Format oder Medium vervielfältigen und weiterverbreiten und zwar für beliebige Zwecke, sogar kommerziell
          </p>
          <p>
            Unter folgenden Bedingungen:
            <br/><strong>Namensnennung — keine Bearbeitungen</strong>
          </p>
          <p>
            Kurzfassung der Lizenz:
            <br/><a href="https://creativecommons.org/licenses/by-nd/4.0/deed.de" target="_blank">https://creativecommons.org/licenses/by-nd/4.0/deed.de</a>
            <br/>Vollständiger Lizenztext:
            <br/><a href="https://creativecommons.org/licenses/by-nd/4.0/legalcode" target="_blank">https://creativecommons.org/licenses/by-nd/4.0/legalcode</a>
          </p>
        </div>
      </v-slide-y-transition>

      <v-slide-y-transition hide-on-leave>
        <div v-if="license === 'http://creativecommons.org/licenses/by-nc-sa/4.0/'" class="license-desc">
          <p>
            Der Lizenznehmer darf:
            <br/><strong>Teilen</strong> — das Material in jedwedem Format oder Medium vervielfältigen und weiterverbreiten
            <br/><strong>Bearbeiten</strong> — das Material remixen, verändern und darauf aufbauen
          </p>
          <p>
            Unter folgenden Bedingungen:
            <br/><strong>Namensnennung — nicht kommerziell — Weitergabe unter gleichen Bedingungen</strong>
          </p>
          <p>
            Kurzfassung der Lizenz:
            <br/><a href="https://creativecommons.org/licenses/by-nc-sa/4.0/deed.de" target="_blank">https://creativecommons.org/licenses/by-nc-sa/4.0/deed.de</a>
            <br/>Vollständiger Lizenztext:
            <br/><a href="https://creativecommons.org/licenses/by-nc-sa/4.0/legalcode" target="_blank">https://creativecommons.org/licenses/by-nc-sa/4.0/legalcode</a>
          </p>
        </div>
      </v-slide-y-transition>

      <v-slide-y-transition hide-on-leave>
        <div v-if="license === 'http://creativecommons.org/licenses/by-nc-nd/4.0/'" class="license-desc">
          <p>
            Der Lizenznehmer darf:
            <br/><strong>Teilen</strong> — das Material in jedwedem Format oder Medium vervielfältigen und weiterverbreiten
          </p>
          <p>
            Unter folgenden Bedingungen:
            <br/><strong>Namensnennung — nicht kommerziell — keine Bearbeitungen</strong>
          </p>
          <p>
            Kurzfassung der Lizenz:
            <br/><a href="https://creativecommons.org/licenses/by-nc-nd/4.0/deed.de" target="_blank">https://creativecommons.org/licenses/by-nc-nd/4.0/deed.de</a>
            <br/>Vollständiger Lizenztext:
            <br/><a href="https://creativecommons.org/licenses/by-nc-nd/4.0/legalcode" target="_blank">https://creativecommons.org/licenses/by-nc-nd/4.0/legalcode</a>
          </p>
        </div>
      </v-slide-y-transition>

    </template>
    <template v-else>

      <v-slide-y-transition hide-on-leave>
        <div v-if="license === 'http://rightsstatements.org/vocab/InC/1.0/'" class="license-desc">
          <p>
            If you do not select a license, your protected subject matter may only be utilized in the context of the limitations of the <a href="http://www.ris.bka.gv.at/GeltendeFassung.wxe?Abfrage=Bundesnormen&Gesetzesnummer=10001848" target="_blank">copyright</a>. In addition, you do not allow commercial nor non-commercial use, in particular the reproduction, distribution, broadcasting, supplying and processing of your protected subject matter.
          </p>
        </div>
      </v-slide-y-transition>

      <v-slide-y-transition hide-on-leave>
        <div v-if="license === 'http://creativecommons.org/licenses/by/4.0/'" class="license-desc">
          <p>
            The licensee may:
            <br/><strong>Share</strong> — copy and redistribute the material in any medium or format
            <br/><strong>Adapt</strong> — remix, transform, and build upon the material, even commercially
          </p>
          <p>
            Under the following terms:
            <br/><strong>Attribution</strong>
          </p>
          <p>
            Licence outline:
            <br/><a href="https://creativecommons.org/licenses/by/4.0/" target="_blank">https://creativecommons.org/licenses/by/4.0/</a>
            <br/>Full licence:
            <br/><a href="https://creativecommons.org/licenses/by/4.0/legalcode" target="_blank">https://creativecommons.org/licenses/by/4.0/legalcode</a>
          </p>
        </div>
      </v-slide-y-transition>

      <v-slide-y-transition hide-on-leave>
        <div v-if="license === 'http://creativecommons.org/licenses/by-sa/4.0/'" class="license-desc">
          <p>
            The licensee may:
            <br/><strong>Share</strong> — copy and redistribute the material in any medium or format
            <br/><strong>Adapt</strong> — remix, transform, and build upon the material, even commercially
          </p>
          <p>
            Under the following terms:
            <br/><strong>Attribution — ShareAlike</strong>
          </p>
          <p>
            Licence outline:
            <br/><a href="https://creativecommons.org/licenses/by-sa/4.0/" target="_blank">https://creativecommons.org/licenses/by-sa/4.0/</a>
            <br/>Full licence:
            <br/><a href="https://creativecommons.org/licenses/by-sa/4.0/legalcode" target="_blank">https://creativecommons.org/licenses/by-sa/4.0/legalcode</a>
          </p>
        </div>
      </v-slide-y-transition>

      <v-slide-y-transition hide-on-leave>
        <div v-if="license === 'http://creativecommons.org/licenses/by-nc/4.0/'" class="license-desc">
          <p>
            The licensee may:
            <br/><strong>Share</strong> — copy and redistribute the material in any medium or format
            <br/><strong>Adapt</strong> — remix, transform, and build upon the material
          </p>
          <p>
            Under the following terms:
            <br/><strong>Attribution — NonCommercial</strong>
          </p>
          <p>
            Licence outline:
            <br/><a href="https://creativecommons.org/licenses/by-nc/4.0/" target="_blank">https://creativecommons.org/licenses/by-nc/4.0/</a>
            <br/>Full licence:
            <br/><a href="https://creativecommons.org/licenses/by-nc/4.0/legalcode" target="_blank">https://creativecommons.org/licenses/by-nc/4.0/legalcode</a>
          </p>
        </div>
      </v-slide-y-transition>

      <v-slide-y-transition hide-on-leave>
        <div v-if="license === 'http://creativecommons.org/licenses/by-nd/4.0/'" class="license-desc">
          <p>
            The licensee may:
            <br/><strong>Share</strong> — copy and redistribute the material in any medium or format for any purpose, even commercially
          </p>
          <p>
            Under the following terms:
            <br/><strong>Attribution — NoDerivatives</strong>
          </p>
          <p>
            Licence outline:
            <br/><a href="https://creativecommons.org/licenses/by-nd/4.0/" target="_blank">https://creativecommons.org/licenses/by-nd/4.0/</a>
            <br/>Full licence:
            <br/><a href="https://creativecommons.org/licenses/by-nd/4.0/legalcode" target="_blank">https://creativecommons.org/licenses/by-nd/4.0/legalcode</a>
          </p>
        </div>
      </v-slide-y-transition>

      <v-slide-y-transition hide-on-leave>
        <div v-if="license === 'http://creativecommons.org/licenses/by-nc-sa/4.0/'" class="license-desc">
          <p>
            The licensee may:
            <br/><strong>Share</strong> — copy and redistribute the material in any medium or format
            <br/><strong>Adapt</strong> — remix, transform, and build upon the material
          </p>
          <p>
            Under the following terms:
            <br/><strong>Attribution — NonCommercial — ShareAlike</strong>
          </p>
          <p>
            Licence outline:
            <br/><a href="https://creativecommons.org/licenses/by-nc-sa/4.0/" target="_blank">https://creativecommons.org/licenses/by-nc-sa/4.0/</a>
            <br/>Full licence:
            <br/><a href="https://creativecommons.org/licenses/by-nc-sa/4.0/legalcode" target="_blank">https://creativecommons.org/licenses/by-nc-sa/4.0/legalcode</a>
          </p>
        </div>
      </v-slide-y-transition>

      <v-slide-y-transition hide-on-leave>
        <div v-if="license === 'http://creativecommons.org/licenses/by-nc-nd/4.0/'" class="license-desc">
          <p>
            The licensee may:
            <br/><strong>Share</strong> — copy and redistribute the material in any medium or format
          </p>
          <p>
            Under the following terms:
            <br/><strong>Attribution — NonCommercial — NoDerivatives</strong>
          </p>
          <p>
            Licence outline:
            <br/><a href="https://creativecommons.org/licenses/by-nc-nd/4.0/" target="_blank">https://creativecommons.org/licenses/by-nc-nd/4.0/</a>
            <br/>Full licence:
            <br/><a href="https://creativecommons.org/licenses/by-nc-nd/4.0/legalcode" target="_blank">https://creativecommons.org/licenses/by-nc-nd/4.0/legalcode</a>
          </p>
        </div>
      </v-slide-y-transition>

    </template>
  </div>
</template>

<script>
export default {
  name: 'p-d-license-info',
  props: {
    license: String
  }
}
</script>
