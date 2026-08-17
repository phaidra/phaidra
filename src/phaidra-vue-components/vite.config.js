import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
import vuetify from 'vite-plugin-vuetify'
import path from 'path'
import { fileURLToPath } from 'url'

const __dirname = path.dirname(fileURLToPath(import.meta.url))
const buildLib = process.env.BUILD_LIB === '1'

const external = ['vue', 'vue-router', 'pinia', 'vuetify', 'vue-i18n', 'axios']

export default defineConfig({
  plugins: [
    vue(),
    vuetify({ autoImport: true })
  ],
  resolve: {
    extensions: ['.vue', '.mjs', '.js', '.mts', '.ts', '.jsx', '.tsx', '.json'],
    alias: {
      '@': path.resolve(__dirname, 'src')
    }
  },
  server: {
    port: 8080
  },
  build: buildLib
    ? {
        lib: {
          entry: path.resolve(__dirname, 'src/components/index.js'),
          name: 'PhaidraVueComponents',
          fileName: (format) =>
            format === 'es'
              ? 'phaidra-vue-components.esm.js'
              : 'phaidra-vue-components.cjs.js',
          formats: ['es', 'cjs']
        },
        rollupOptions: {
          external,
          output: {
            globals: {
              vue: 'Vue',
              'vue-router': 'VueRouter',
              pinia: 'Pinia',
              vuetify: 'Vuetify',
              'vue-i18n': 'VueI18n',
              axios: 'axios'
            }
          }
        },
        emptyOutDir: true
      }
    : {
        outDir: 'dist',
        emptyOutDir: true
      }
})
