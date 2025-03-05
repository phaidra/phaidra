export default {
    methods: {
      updateFavicon(val) {
        if (document) {
          let link = document.querySelector("link[rel='icon']") || document.createElement("link")
          link.rel = "icon"
          link.href = val
          document.head.appendChild(link)
        }
      }
    }
  }
  