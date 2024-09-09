import PImg from './utils/PImg'
import PDDimension from './display/PDDimension.vue'
import PDIdentifier from './display/PDIdentifier.vue'
import PDDuration from './display/PDDuration.vue'
import PDEntity from './display/PDEntity.vue'
import PDExactMatch from './display/PDExactMatch.vue'
import PDFunder from './display/PDFunder.vue'
import PDGeoreference from './display/PDGeoreference.vue'
import PDJsonld from './display/PDJsonld.vue'
import PDJsonldLayout from './display/PDJsonldLayout.vue'
import PDLangValue from './display/PDLangValue.vue'
import PDLicense from './display/PDLicense.vue'
import PDProject from './display/PDProject.vue'
import PDEvent from './display/PDEvent.vue'
import PDSeries from './display/PDSeries.vue'
import PDContainedIn from './display/PDContainedIn.vue'
import PDBfPublication from './display/PDBfPublication.vue'
import PDCitation from './display/PDCitation.vue'
import PDAdaptation from './display/PDAdaptation.vue'
import PDInstanceOf from './display/PDInstanceOf.vue'
import PDSkosPreflabel from './display/PDSkosPreflabel.vue'
import PDKeyword from './display/PDKeyword.vue'
import PDTitle from './display/PDTitle.vue'
import PDLabeledValue from './display/PDLabeledValue.vue'
import PDUwmetadata from './display/PDUwmetadata.vue'
import PDValue from './display/PDValue.vue'
import PDUnknown from './display/PDUnknown.vue'
import PDSeeAlso from './display/PDSeeAlso.vue'
import PIDimension from './input/PIDimension.vue'
import PIDuration from './input/PIDuration.vue'
import PIAlternateIdentifier from './input/PIAlternateIdentifier.vue'
import PIEntity from './input/PIEntity.vue'
import PIEntityExtended from './input/PIEntityExtended'
import PIEntityFixedrolePerson from './input/PIEntityFixedrolePerson'
import PIDateEdtf from './input/PIDateEdtf.vue'
import PIDateEdmtimespan from './input/PIDateEdmtimespan.vue'
import PIFilenameReadonly from './input/PIFilenameReadonly.vue'
import PIFilename from './input/PIFilename.vue'
import PIForm from './input/PIForm.vue'
import PIFunder from './input/PIFunder.vue'
import PIAssociation from './input/PIAssociation.vue'
import PISeries from './input/PISeries.vue'
import PIContainedIn from './input/PIContainedIn.vue'
import PIBfPublication from './input/PIBfPublication.vue'
import PICitation from './input/PICitation.vue'
import PIAdaptation from './input/PIAdaptation.vue'
import PIInstanceOf from './input/PIInstanceOf.vue'
import PISubjectGnd from './input/PISubjectGnd.vue'
import PISubjectBk from './input/PISubjectBk.vue'
import PISubjectOefos from './input/PISubjectOefos.vue'
import PISubjectThema from './input/PISubjectThema.vue'
import PISubjectBic from './input/PISubjectBic.vue'
import PISpatialGeonames from './input/PISpatialGeonames.vue'
import PISpatialText from './input/PISpatialText.vue'
import PIProject from './input/PIProject.vue'
import PIEvent from './input/PIEvent.vue'
import PISelect from './input/PISelect.vue'
import PISelectText from './input/PISelectText.vue'
import PITextField from './input/PITextField.vue'
import PITextFieldSuggest from './input/PITextFieldSuggest.vue'
import PITitle from './input/PITitle.vue'
import PIFile from './input/PIFile'
import PIUnknown from './input/PIUnknown.vue'
import PIVocabExtReadonly from './input/PIVocabExtReadonly.vue'
import PISpatialReadonly from './input/PISpatialReadonly'
import PILiteral from './input/PILiteral'
import PIKeyword from './input/PIKeyword'
import PIObjectType from './input/PIObjectType'
import PIResourceType from './input/PIResourceType'
import PISeeAlso from './input/PISeeAlso.vue'
import PINoteCheckbox from './input/PINoteCheckbox.vue'
import PINoteCheckboxWithLink from './input/PINoteCheckboxWithLink.vue'
import PIAlert from './input/PIAlert.vue'
import PSearch from './search/PSearch'
import PMDelete from './management/PMDelete'
import PMSort from './management/PMSort'
import PMSortTextinput from './management/PMSortTextinput'
import PMRights from './management/PMRights'
import PMRelationships from './management/PMRelationships'
import PMObjectMembers from './management/PMObjectMembers'
import PMCollectionMembers from './management/PMCollectionMembers'
import PTemplates from './templates/PTemplates'
import PLists from './lists/PLists'
import PDList from './lists/PDList'
import PGroups from './groups/PGroups'
import PIFormUwm from './legacy/PIFormUwm'
import PDUwmRec from './legacy/PDUwmRec'
import PDModsRec from './legacy/PDModsRec'
import PFeedback from './utils/PFeedback'
import PExpandText from './utils/PExpandText'
import PMetadataFieldsHelp from './info/PMetadataFieldsHelp'
import PHelp from './info/PHelp'
import CollectionDialog from './select/CollectionDialog'

const Components = {
  PImg,
  PDDuration,
  PDDimension,
  PDIdentifier,
  PDEntity,
  PDExactMatch,
  PDFunder,
  PDGeoreference,
  PDJsonld,
  PDJsonldLayout,
  PDLangValue,
  PDLicense,
  PDSeries,
  PDContainedIn,
  PDBfPublication,
  PDCitation,
  PDAdaptation,
  PDInstanceOf,
  PDProject,
  PDEvent,
  PDSkosPreflabel,
  PDKeyword,
  PDTitle,
  PDLabeledValue,
  PDUwmetadata,
  PDValue,
  PDUnknown,
  PDSeeAlso,
  PIDimension,
  PIAlternateIdentifier,
  PIEntity,
  PIEntityExtended,
  PIEntityFixedrolePerson,
  PIDateEdtf,
  PIDateEdmtimespan,
  PIFilenameReadonly,
  PIFilename,
  PIFile,
  PIForm,
  PIFunder,
  PIAssociation,
  PISeries,
  PIContainedIn,
  PIBfPublication,
  PICitation,
  PIInstanceOf,
  PIAdaptation,
  PISubjectGnd,
  PISubjectBk,
  PISubjectOefos,
  PISubjectThema,
  PISubjectBic,
  PISpatialGeonames,
  PISpatialText,
  PIProject,
  PIEvent,
  PISelect,
  PISelectText,
  PITextField,
  PITextFieldSuggest,
  PITitle,
  PIUnknown,
  PIVocabExtReadonly,
  PISpatialReadonly,
  PILiteral,
  PIKeyword,
  PIObjectType,
  PIResourceType,
  PIDuration,
  PISeeAlso,
  PINoteCheckbox,
  PINoteCheckboxWithLink,
  PIAlert,
  PSearch,
  PMDelete,
  PMSort,
  PMSortTextinput,
  PMRights,
  PMRelationships,
  PMObjectMembers,
  PMCollectionMembers,
  PTemplates,
  PLists,
  PDList,
  PGroups,
  PIFormUwm,
  PDUwmRec,
  PDModsRec,
  PFeedback,
  PHelp,
  PMetadataFieldsHelp,
  PExpandText,
  CollectionDialog
}

export default {
  install (Vue) {
    Object.keys(Components).forEach(name => {
      Vue.component(name, Components[name])
    })
  },
  ...Components
}
