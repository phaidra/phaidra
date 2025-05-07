<template>
  <div>
    <span class="prewrap" v-html="formattedString" :lang="lang"></span>
    <span v-show="text.length > maxChars">
      <a :href="link" id="readmore" v-show="!isReadMore" v-on:click="triggerReadMore($event, true)">{{ moreStr }}</a>
      <a :href="link" id="readmore" v-show="isReadMore" v-on:click="triggerReadMore($event, false)">{{ lessStr }}</a>
    </span>
  </div>
</template>

<script>
export default {
  name: 'p-expand-text',
  props: {
    moreStr: {
      type: String,
      default: 'read more'
    },
    lessStr: {
      type: String,
      default: ''
    },
    lang: {
      type: String,
      default: 'en'
    },
    text: {
      type: String,
      required: true
    },
    link: {
      type: String,
      default: '#'
    },
    maxChars: {
      type: Number,
      default: 500
    }
  },
  data () {
    return {
      isReadMore: false
    }
  },
  computed: {
    formattedString () {
      var valContainer = this.text
      if (!this.isReadMore && this.text.length > this.maxChars) {
        valContainer = valContainer.substring(0, this.maxChars) + '... '
      }
      return valContainer
    }
  },
  methods: {
    triggerReadMore (e, b) {
      if (this.link === '#') {
        e.preventDefault()
      }
      if (this.lessStr !== null || this.lessStr !== '') this.isReadMore = b
    }
  }
}
</script>

<style scoped>
.v-application a {
  text-decoration: none;
}

.v-application a:hover, .v-application a:focus {
  text-decoration: underline;
}

.prewrap {
  white-space: pre-wrap;
}
</style>
