# Using phaidra-vue-components in Nuxt 3

This package is built as a Vue 3 component library (ESM + CJS). Nuxt 3 does not install it automatically; register peers and wire the same runtime pieces the demo app uses.

## Peer dependencies

Install alongside the library:

- `vue` ^3.5
- `vuetify` ^3.7
- `vuex` ^4
- `vue-i18n` ^9
- `axios` ^1 (optional peer; required if components call `$axios` or store actions use `store.$axios`)

## Vuetify 3

Add Vuetify with the [official Nuxt module](https://vuetifyjs.com/en/getting-started/installation/#nuxt-install) or a Nuxt plugin that calls `createVuetify()` and `app.use(vuetify)`. Ensure Material Design Icons are loaded (e.g. `@mdi/font`), matching the demo.

## Vuex 4

Mount a store that matches what these components expect:

- Root state used in the wild includes at least `instanceconfig`, `appconfig`, `user`, `upload`, `alerts`, and modules **`vocabulary`**, **`info`**, **`search`** (see `src/store`).

You can import `createStore` from `vuex` and register the same module files from this repo, or replicate their names and state shape.

Attach axios for actions that call `this.$axios`:

```js
store.$axios = myAxiosInstance
```

(or use the same pattern as `setStoreAxios` in `src/store/index.js`).

## Axios and `$axios`

Components and store actions use `this.$axios`. In Nuxt, provide a plugin that assigns your client to `nuxtApp.vueApp.config.globalProperties.$axios` and to `store.$axios` after the store is created.

## i18n

Messages are grouped under locale codes such as `deu`, `eng`, `ita` (see `src/i18n`). Use `@nuxtjs/i18n` with `vue-i18n` v9, or merge this package’s locale JSON into your `messages`.

## Router links and localized paths

Templates no longer use `nuxt-link` or a global `localePath`. The library injects:

| `provide` key       | Purpose |
|---------------------|---------|
| `phaidraLink`       | Component used for internal links (default: `RouterLink` from `vue-router`). In Nuxt, pass `NuxtLink` if you prefer. |
| `phaidraLocalePath` | `(path: string) => string` — prefix or rewrite paths for the active locale (default: identity). Use `useLocalePath()` from `@nuxtjs/i18n` inside a Nuxt plugin. |

For localized routes, use `@nuxtjs/i18n` (or equivalent) and **provide** a function that wraps `useLocalePath()` from your root layout or from a Nuxt plugin that has access to i18n composables—match whatever API your app already uses for prefixing paths.

To use **`NuxtLink`** instead of **`RouterLink`**, call `provide('phaidraLink', …)` with the link component your app standardizes on.

## Leaflet (optional)

Components that show maps depend on `leaflet` and `@vue-leaflet/vue-leaflet`. Render them only on the client (`<ClientOnly>`) if SSR throws window/Leaflet errors.

## Library build

`npm run build-bundle` outputs `dist/phaidra-vue-components.{esm,cjs}.js` with `vue`, `vue-router`, `vuex`, `vuetify`, `vue-i18n`, and `axios` externalized. Your Nuxt app should dedupe those packages via normal dependency resolution.
