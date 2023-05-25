<script>
import { VImg } from 'vuetify/lib'

export default {
  name: 'p-img',
  extends: VImg,
  methods: {
    onError () {
      // Change the verbose error to a warning.
      // This is useful to declutter the console when testing
      // with phaidra-sandbox outside the network.
      // As of 2019-07-21 used in SearchResults component only.

      // disable message altogether
      // console.warn(`Image ${this.currentSrc} failed to load`)
    }
  }
}
</script>
