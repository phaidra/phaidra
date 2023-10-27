module.exports = {
  configureWebpack: {
    output: {
      library: 'PhaidraVueComponents',
      libraryExport: 'default'
    }
    /*
    externals: {
      vue: {
        commonjs: 'vue',
        commonjs2: 'vue',
        root: 'Vue',
        amd: 'vue'
      }
    }
    */
  }
}
