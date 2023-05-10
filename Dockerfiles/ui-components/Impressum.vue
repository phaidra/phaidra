<template>
  <div class="ma-6">
    <template v-if="$i18n.locale === 'deu'">
      <p>Bei <strong>allgemeinen Problemen und Fragen rund um Phaidra</strong> und ihre Services wenden Sie sich bitte an <a href="mailto:support.phaidra@univie.ac.at">support.phaidra@univie.ac.at</a></p>

      <p><strong>Feedback zur Webseite</strong>, insbesondere Hinweise auf Inhalts- oder Darstellungs-Fehler, richten Sie bitte per eMail an den Webmaster - <a href="mailto:support.phaidra@univie.ac.at">support.phaidra@univie.ac.at</a></p>

      <p>Alle sonstigen Ansprechpartner zu den jeweiligen Bereichen finden Sie auf der Kontakt-Seite.</p>

      <h3 class="title font-weight-light primary--text mb-4">Impressum</h3>
      <p>Offenlegung gem. § 25 MedG - <strong>Verantwortlich für den Inhalt dieser Seite</strong>:</p>

      <p>Universität Wien<br/>
      <a target="_blank" href="http://www.ub.univie.ac.at/">Bibliotheks- und Archivwesen</a><br/>
      Universitätsring 1<br/>
      A-1010 Wien<br/>
      Österreich<br/></p>

      <p>Bei technischen Problemen können sie sich auch an den Helpdesk des ZID wenden:<br/>
      <strong>T</strong> +43-1-4277-140 60<br/>
      <strong>F</strong> +43-1-4277-140 60<br/></p>

      <p>E-Mail an uns:<br/>
      <strong>eMail</strong><a class="ml-2" href="mailto:support.phaidra@univie.ac.at">support.phaidra@univie.ac.at</a><br/>
      <strong>Web</strong><a class="ml-2" target="_blank" href="http://www.ub.univie.ac.at/">http://www.ub.univie.ac.at/</a><br/></p>

      <p>Phaidra übernimmt keine Haftung für den Inhalt verlinkter, 'externer' Webseiten.</p>

      <p>© Copyright UB</p>
    </template>
    <template v-else>
      <p>If you have <strong>problems or questions</strong>, please contact <a href="mailto:support.phaidra@univie.ac.at">support.phaidra@univie.ac.at</a></p>

      <p>Please report <strong>feedback or bugs</strong>, via E-Mail to the webmaster - <a href="mailto:support.phaidra@univie.ac.at">support.phaidra@univie.ac.at</a></p>

      <p>All other contact persons you find at the contact page.</p>

      <h3 class="title font-weight-light primary--text mb-4">Impressum</h3>
      <p>Publication according to § 25 MedG - <strong>(Section 25 of Austrian Media Code) responsible for the content of this page</strong>:</p>

      <p>University of Vienna<br/>
      <a target="_blank" href="http://www.ub.univie.ac.at/">Library and archive services</a><br/>
      Universitätsring 1<br/>
      A-1010 Vienna<br/>
      Austria<br/></p>

      <p>If you have technical problems, please contact the helpdesk:<br/>
      <strong>T</strong> +43-1-4277-140 60<br/>
      <strong>F</strong> +43-1-4277-140 60<br/></p>

      <p>Send an E-Mail to us:<br/>
      <strong>eMail</strong><a class="ml-2" href="mailto:support.phaidra@univie.ac.at">support.phaidra@univie.ac.at</a><br/>
      <strong>Web</strong><a class="ml-2" target="_blank" href="http://www.ub.univie.ac.at/">http://www.ub.univie.ac.at/</a><br/></p>

      <p>Phaidra does not assume responsibility for linked content or external pages.</p>

      <p>© Copyright UB</p>
    </template>
  </div>
</template>

<script>
export default {
  name: 'impressum'
}
</script>
