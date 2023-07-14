<template>
  <div :class="`${getClassName('wrapper')} autocomplete-wrapper`">
    <v-text-field
      ref="input"
      :id="id"
      :class="`${getClassName('input')} autocomplete-input`"
      :placeholder="placeholder"
      :name="name"
      v-model="type"
      @input="handleInput"
      @blur="handleBlur"
      @keydown="handleKeyDown"
      @focus="handleFocus"
      autocomplete="off"
      clearable
      :filled="!solo"
      single-line
      :solo="solo"
      append-icon="mdi-magnify"
      @click:append="onSelect({ term: type })"
      :messages="messages"
    />
    <div :class="`${getClassName('list')} autocomplete autocomplete-list elevation-2`" v-show="showList && suggestions && suggestions.length">
      <v-list>
        <v-list-item v-for="(data, i) in suggestions" :class="activeClass(i)" :key="i" @click.prevent="selectList(data)">
          <v-list-item-title v-html="data.term"></v-list-item-title>
        </v-list-item>
      </v-list>
    </div>
  </div>
</template>

<script>
import qs from 'qs'

export default {
  props: {
    id: String,
    name: String,
    solo: Boolean,
    className: String,
    classes: {
      type: Object,
      default: () => ({
        wrapper: false,
        input: false,
        list: false,
        item: false
      })
    },
    placeholder: String,
    required: Boolean,

    // Intial Value
    initValue: {
      type: String,
      default: ''
    },

    // Debounce time
    debounce: Number,

    suggester: {
      type: String,
      required: true
    },

    // minimum length
    min: {
      type: Number,
      default: 0
    },

    onSelect: Function,

    messages: Array
  },

  data () {
    return {
      showList: false,
      type: '',
      focusList: '',
      debounceTask: undefined,
      suggestions: []
    }
  },

  methods: {
    getClassName (part) {
      const { classes, className } = this
      if (classes[part]) return `${classes[part]}`
      return className ? `${className}-${part}` : ''
    },

    clearInput () {
      this.showList = false
      this.type = ''
      this.suggestions = []
      this.focusList = ''
    },

    // Get the original data (TODO move to single used place)
    cleanUp (data) {
      return JSON.parse(JSON.stringify(data))
    },

    handleInput (value) {
      if (value) {
        this.showList = true

        // If Debounce
        if (this.debounce) {
          if (this.debounceTask !== undefined) clearTimeout(this.debounceTask)
          this.debounceTask = setTimeout(() => {
            return this.getData(value)
          }, this.debounce)
        } else {
          return this.getData(value)
        }
      } else {
        this.clearInput()
        this.onSelect({ term: '' })
      }
    },

    handleKeyDown (e) {
      let key = e.keyCode

      // Key List
      const DOWN = 40
      const UP = 38
      const ENTER = 13
      const ESC = 27

      // Prevent Default for Prevent Cursor Move & Form Submit
      switch (key) {
        case DOWN:
          e.preventDefault()
          this.focusList++
          break
        case UP:
          e.preventDefault()
          this.focusList--
          break
        case ENTER:
          e.preventDefault()
          if (this.focusList === 0) {
            if (this.onSelect) {
              this.onSelect({ term: this.type })
            }
          } else {
            this.selectList(this.suggestions[this.focusList])
          }
          this.showList = false
          break
        case ESC:
          this.showList = false
          break
      }

      const listLength = this.suggestions.length - 1
      const outOfRangeBottom = this.focusList > listLength
      const outOfRangeTop = this.focusList < 0
      const topItemIndex = 0
      const bottomItemIndex = listLength

      let nextFocusList = this.focusList
      if (outOfRangeBottom) nextFocusList = topItemIndex
      if (outOfRangeTop) nextFocusList = bottomItemIndex
      this.focusList = nextFocusList
    },

    // unused?
    // setValue (val) { // TODO used anywhere?
    //   debugger
    //   this.type = val
    // },

    handleBlur () {
      setTimeout(() => {
        this.showList = false
      }, 250)
    },

    handleFocus () {
      this.focusList = 0
    },

    // unused?
    // mousemove (i) {
    //   debugger
    //   this.focusList = i
    // },

    activeClass (i) {
      const focusClass = i === this.focusList ? 'grey lighten-4' : ''
      return `${focusClass}`
    },

    selectList (data) {
      // Deep clone of the original object
      const clean = this.cleanUp(data)
      // Put the selected data to type (model)
      this.type = clean['payload']
      // Hide List
      this.showList = false

      if (this.onSelect) {
        this.onSelect(clean)
      }
    },

    getData (value) {
      if (value.length < this.min || !this.suggester) return
      this.suggest(value)
    },

    async suggest (value) {
      let params = {
        suggest: true,
        'suggest.dictionary': this.suggester,
        wt: 'json',
        'suggest.q': value
      }
      try {
        let response = await this.$axios.request({
          method: 'POST',
          url: '/search/suggest',
          data: qs.stringify(params, { arrayFormat: 'repeat' }),
          headers: {
            'content-type': 'application/x-www-form-urlencoded'
          }
        })
        this.suggestions = response.data.suggest[this.suggester][value].suggestions
      } catch (error) {
        console.log(error)
      }
    }
  },

  created () {
    // Sync parent model with initValue Props
    this.type = this.initValue ? this.initValue : null
  },

  mounted () {
    if (this.required) { this.$refs.input.setAttribute('required', this.required) }
  }
}
</script>

<style scoped>
.searchbox{
  font-size: 14px;
  box-sizing: border-box;
  border: none;
  box-shadow: none;
  outline: 0;
  background: 0 0;
  width: 100%;
  padding: 0 15px;
  line-height: 40px;
  height: 40px;
}

.autocomplete {
  position: absolute;
  z-index: 999;
  margin-top: 2px;
}

</style>
