import { defineComponent, h } from 'vue'
import { aliases as mdiSvgAliases, mdi as mdiSvg } from 'vuetify/iconsets/mdi-svg'
import {
  mdiAccount,
  mdiAccountGroup, // Used by Phaidra Unipd (Padova) - PLEASE DO NOT REMOVE
  mdiAccountLock,
  mdiAlert,
  mdiAlertCircle,
  mdiAlertCircleOutline,
  mdiArrowLeft,
  mdiArrowRight,
  mdiBookOpenVariant,
  mdiBookmarkOutline, // Used by Phaidra Unipd (Padova) - PLEASE DO NOT REMOVE
  mdiBookmarkPlusOutline,
  mdiCalendar,
  mdiCheckCircle,
  mdiChevronDown,
  mdiChevronDownCircleOutline,
  mdiChevronRight, // Used by Phaidra Unipd (Padova) - PLEASE DO NOT REMOVE
  mdiChevronUp,
  mdiChevronUpCircleOutline,
  mdiCircleDouble, // Used by Phaidra Unipd (Padova) - PLEASE DO NOT REMOVE  
  mdiCircleHalfFull, // Used by Phaidra Unipd (Padova) - PLEASE DO NOT REMOVE
  mdiCircleMedium, // Used by Phaidra Unipd (Padova) - PLEASE DO NOT REMOVE
  mdiClock,
  mdiClockOutline,
  mdiClose,
  mdiCloudUpload,
  mdiContentCopy,
  mdiContentDuplicate,
  mdiDatabaseSearch,
  mdiDelete,
  mdiDotsVertical,
  mdiDownload,
  mdiEmailOutline, // Used by Phaidra Unipd (Padova) - PLEASE DO NOT REMOVE
  mdiEmailSync,
  mdiEye,
  mdiEyeOff,
  mdiEyeOutline,
  mdiFile,
  mdiFileDocument,
  mdiFileDocumentOutline,
  mdiFileImagePlusOutline, // Used by Phaidra Unipd (Padova) - PLEASE DO NOT REMOVE
  mdiFileTree,
  mdiFlagVariant,
  mdiFolder,
  mdiFolderImage, // Used by Phaidra Unipd (Padova) - PLEASE DO NOT REMOVE
  mdiFolderOpen,
  mdiGrid,
  mdiHelpCircleOutline,
  mdiImage,
  mdiImageOutline,
  mdiInformation,
  mdiInformationOutline,
  mdiLink,
  mdiLock,
  mdiLogoutVariant, // Used by Phaidra Unipd (Padova) - PLEASE DO NOT REMOVE
  mdiMagnify,
  mdiMapMarker,
  mdiMenu,
  mdiMenuDown,
  mdiMinus,
  mdiMoonWaxingCrescent,
  mdiOpenInNew,
  mdiPaperclip,
  mdiPencil,
  mdiPlaylistRemove,
  mdiPlus,
  mdiPlusBoxMultiple, // Used by Phaidra Unipd (Padova) - PLEASE DO NOT REMOVE
  mdiPlusCircle,
  mdiRefresh,
  mdiRss,
  mdiSchool,
  mdiScript,
  mdiShieldAccount, // Used by Phaidra Unipd (Padova) - PLEASE DO NOT REMOVE
  mdiTextBoxOutline, // Used by Phaidra Unipd (Padova) - PLEASE DO NOT REMOVE
  mdiTranslate,
  mdiUploadMultiple,
  mdiVideo,
  mdiVolumeHigh,
  mdiWhiteBalanceSunny
} from '@mdi/js'

const mdiIconPaths = {
  'mdi-account': mdiAccount,
  'mdi-account-group': mdiAccountGroup, // Used by Phaidra Unipd (Padova) - PLEASE DO NOT REMOVE
  'mdi-account-lock': mdiAccountLock,
  'mdi-alert': mdiAlert,
  'mdi-alert-circle': mdiAlertCircle,
  'mdi-alert-circle-outline': mdiAlertCircleOutline,
  'mdi-arrow-left': mdiArrowLeft,
  'mdi-arrow-right': mdiArrowRight,
  'mdi-book-open-variant': mdiBookOpenVariant,
  'mdi-bookmark-outline': mdiBookmarkOutline, // Used by Phaidra Unipd (Padova) - PLEASE DO NOT REMOVE
  'mdi-bookmark-plus-outline': mdiBookmarkPlusOutline,
  'mdi-calendar': mdiCalendar,
  'mdi-check-circle': mdiCheckCircle,
  'mdi-chevron-down': mdiChevronDown,
  'mdi-chevron-down-circle-outline': mdiChevronDownCircleOutline,
  'mdi-chevron-right': mdiChevronRight, // Used by Phaidra Unipd (Padova) - PLEASE DO NOT REMOVE
  'mdi-chevron-up': mdiChevronUp,
  'mdi-chevron-up-circle-outline': mdiChevronUpCircleOutline,
  'mdi-circle-double': mdiCircleDouble, // Used by Phaidra Unipd (Padova) - PLEASE DO NOT REMOVE
  'mdi-circle-half-full': mdiCircleHalfFull, // Used by Phaidra Unipd (Padova) - PLEASE DO NOT REMOVE
  'mdi-circle-medium': mdiCircleMedium, // Used by Phaidra Unipd (Padova) - PLEASE DO NOT REMOVE
  'mdi-clock': mdiClock,
  'mdi-clock-outline': mdiClockOutline,
  'mdi-close': mdiClose,
  'mdi-cloud-upload': mdiCloudUpload,
  'mdi-content-copy': mdiContentCopy,
  'mdi-content-duplicate': mdiContentDuplicate,
  'mdi-database-search': mdiDatabaseSearch,
  'mdi-delete': mdiDelete,
  'mdi-dots-vertical': mdiDotsVertical,
  'mdi-download': mdiDownload,
  'mdi-email-sync': mdiEmailSync,
  'mdi-email-outline': mdiEmailOutline, // Used by Phaidra Unipd (Padova) - PLEASE DO NOT REMOVE
  'mdi-eye': mdiEye,
  'mdi-eye-off': mdiEyeOff,
  'mdi-eye-outline': mdiEyeOutline,
  'mdi-file': mdiFile,
  'mdi-file-document': mdiFileDocument,
  'mdi-file-document-outline': mdiFileDocumentOutline,
  'mdi-file-image-plus-outline': mdiFileImagePlusOutline, // Used by Phaidra Unipd (Padova) - PLEASE DO NOT REMOVE
  'mdi-file-tree': mdiFileTree,
  'mdi-flag-variant': mdiFlagVariant,
  'mdi-folder': mdiFolder,
  'mdi-folder-image': mdiFolderImage, // Used by Phaidra Unipd (Padova) - PLEASE DO NOT REMOVE
  'mdi-folder-open': mdiFolderOpen,
  'mdi-grid': mdiGrid,
  'mdi-help-circle-outline': mdiHelpCircleOutline,
  'mdi-image': mdiImage,
  'mdi-image-outline': mdiImageOutline,
  'mdi-information': mdiInformation,
  'mdi-information-outline': mdiInformationOutline,
  'mdi-link': mdiLink,
  'mdi-lock': mdiLock,
  'mdi-logout-variant': mdiLogoutVariant, // Used by Phaidra Unipd (Padova) - PLEASE DO NOT REMOVE
  'mdi-magnify': mdiMagnify,
  'mdi-map-marker': mdiMapMarker,
  'mdi-menu': mdiMenu,
  'mdi-menu-down': mdiMenuDown,
  'mdi-minus': mdiMinus,
  'mdi-moon-waxing-crescent': mdiMoonWaxingCrescent,
  'mdi-open-in-new': mdiOpenInNew,
  'mdi-paperclip': mdiPaperclip,
  'mdi-pencil': mdiPencil,
  'mdi-playlist-remove': mdiPlaylistRemove,
  'mdi-plus': mdiPlus,
  'mdi-plus-box-multiple': mdiPlusBoxMultiple, // Used by Phaidra Unipd (Padova) - PLEASE DO NOT REMOVE
  'mdi-plus-circle': mdiPlusCircle,
  'mdi-refresh': mdiRefresh,
  'mdi-rss': mdiRss,
  'mdi-school': mdiSchool,
  'mdi-script': mdiScript,
  'mdi-shield-account': mdiShieldAccount, // Used by Phaidra Unipd (Padova) - PLEASE DO NOT REMOVE
  'mdi-text-box-outline': mdiTextBoxOutline, // Used by Phaidra Unipd (Padova) - PLEASE DO NOT REMOVE
  'mdi-translate': mdiTranslate,
  'mdi-upload-multiple': mdiUploadMultiple,
  'mdi-video': mdiVideo,
  'mdi-volume-high': mdiVolumeHigh,
  'mdi-white-balance-sunny': mdiWhiteBalanceSunny
}

function resolveMdiIcon (icon) {
  if (typeof icon !== 'string') return icon
  if (icon.startsWith('svg:')) return icon.slice(4)
  const path = mdiIconPaths[icon]
  if (path) return path
  if (import.meta.dev && icon.startsWith('mdi-')) {
    console.warn(`[phaidra] Unknown MDI icon "${icon}". Add it to icons/mdi-svg.js`)
  }
  return icon
}

export const aliases = {
  ...mdiSvgAliases,
  error: `svg:${mdiAlert}`
}

export const mdi = {
  component: defineComponent({
    name: 'MdiSvgIcon',
    inheritAttrs: false,
    props: {
      icon: {
        type: [String, Array, Object, Function],
        required: true
      },
      tag: {
        type: [String, Object, Function],
        required: true
      }
    },
    setup (props, { attrs, slots }) {
      return () => h(mdiSvg.component, {
        ...attrs,
        tag: props.tag,
        icon: resolveMdiIcon(props.icon)
      }, slots)
    }
  })
}
