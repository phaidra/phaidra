const modules = import.meta.glob(
  [
    '../components/**/*.vue',
    '!../components/Runtimetemplate.vue',
    '!../components/Submit.vue',
    '!../components/Help.vue',
    '!../components/ext/**/*.vue',
    '!../components/bulk-upload/**/*.vue',
    '!../components/BulkUploadSteps.vue'
  ],
  {
    eager: true,
    import: 'default'
  }
)

function toPascalSegment(segment) {
  return segment
    .split(/[^a-zA-Z0-9]+/)
    .filter(Boolean)
    .map((part) => part.charAt(0).toUpperCase() + part.slice(1))
    .join('')
}

/** Nuxt pathPrefix naming: components/dashboard/Uploads.vue → DashboardUploads */
function componentNameFromPath(path) {
  return path
    .replace(/^.*\/components\//, '')
    .replace(/\.vue$/i, '')
    .split('/')
    .map(toPascalSegment)
    .join('')
}

export const cmsLocalComponents = Object.fromEntries(
  Object.entries(modules)
    .filter(([, component]) => component)
    .map(([path, component]) => [componentNameFromPath(path), component])
    .filter(([name]) => name)
)
