const RESOURCE_TYPE_PICTURE = 'https://pid.phaidra.org/vocabulary/44TN-P1S0'
const RESOURCE_TYPE_TEXT = 'https://pid.phaidra.org/vocabulary/69ZZ-2KGX'
const RESOURCE_TYPE_VIDEO = 'https://pid.phaidra.org/vocabulary/B0Y6-GYT8'
const RESOURCE_TYPE_SOUND = 'https://pid.phaidra.org/vocabulary/8YB5-1M0J'
const RESOURCE_TYPE_DATA = 'https://pid.phaidra.org/vocabulary/7AVS-Y482'

export const allowedMimetypes = {
  [RESOURCE_TYPE_PICTURE]: [
    'image/jpeg',
    'image/pjpeg',
    'image/gif',
    'image/tiff',
    'image/x-tiff',
    'image/png',
    'image/x-png',
    'image/x-ms-bmp',
    'image/bmp',
    'image/x-bmp',
    'image/x-bitmap',
    'image/jp2',
    'image/x-jp2',
    'image/jpx',
    'image/x-jpx'
  ],
  [RESOURCE_TYPE_TEXT]: [
    'application/pdf',
    'application/x-pdf'
  ],
  [RESOURCE_TYPE_VIDEO]: [
    'video/mpeg',
    'video/x-mpeg',
    'video/avi',
    'video/vnd.avi',
    'video/x-msvideo',
    'video/mp4',
    'video/x-m4v',
    'video/quicktime',
    'video/x-quicktime',
    'video/x-matroska',
    'video/mkv',
    'video/matroska'
  ],
  [RESOURCE_TYPE_SOUND]: [
    'audio/x-wav',
    'audio/wav',
    'audio/vnd.wave',
    'audio/mpeg',
    'audio/mp3',
    'audio/x-mp3',
    'audio/x-mpeg',
    'audio/flac',
    'audio/x-flac',
    'audio/ogg',
    'audio/x-ogg',
    'audio/x-matroska'
  ]
}

const resourceTypeToCreateMethod = {
  [RESOURCE_TYPE_PICTURE]: 'picture',
  [RESOURCE_TYPE_SOUND]: 'audio',
  [RESOURCE_TYPE_TEXT]: 'document',
  [RESOURCE_TYPE_VIDEO]: 'video'
}

const mimeToResourceTypeMap = {}
for (const [resourceType, mimes] of Object.entries(allowedMimetypes)) {
  for (const mime of mimes) {
    mimeToResourceTypeMap[mime] = resourceType
  }
}

export function mimeToResourceType (mime) {
  return mimeToResourceTypeMap[mime] || RESOURCE_TYPE_DATA
}

export function mimeToCreateMethod (mime) {
  const resourceType = mimeToResourceTypeMap[mime]
  return resourceTypeToCreateMethod[resourceType] || 'unknown'
}

export default {
  allowedMimetypes,
  mimeToResourceType,
  mimeToCreateMethod
}
