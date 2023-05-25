import QuickChart from 'quickchart-js'

export const commonChart = {
  methods: {
    generateChartSrc(config, height = 330, title = false, width) {
      config.options.title.display = title
      const myChart = new QuickChart()
      myChart.setConfig(config)
      myChart.setHeight(height)
      if (width) {
        myChart.setWidth(width)
      }
      return myChart.getUrl()
    },

    generateChartUrl(config, height, width) {
      config.options.title.display = true
      const myChart = new QuickChart()
      myChart.setFormat('pdf')
      if (height) {
        myChart.setHeight(height)
      } else {
        myChart.setHeight(330)
      }
      if (width) {
        myChart.setWidth(width)
      }
      myChart.setConfig(config)

      const url = myChart.getUrl()
      fetch(url)
        .then(res => res.blob())
        .then((blob) => {
          const objectURL = URL.createObjectURL(blob)
          window.open(objectURL, { target: '_blank' })
        })
    }
  }
}
