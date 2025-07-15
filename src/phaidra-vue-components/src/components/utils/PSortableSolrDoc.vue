<template>
  <li class="list-item">
    <p-img :src="instance.api + '/object/' + item.pid + '/thumbnail'" class="elevation-1 mt-2 preview-maxwidth" :alt="item.dc_title ? item.dc_title[0] : item.pid">
      <template v-slot:placeholder>
        <div class="fill-height ma-0" align="center" justify="center" >
          <v-progress-circular indeterminate color="grey lighten-5"></v-progress-circular>
        </div>
      </template>
    </p-img>
    <div class="list-item-title">{{item.pid}} - {{item.cmodel}}<template v-if="'dc_title' in item"> - {{getObjectTitle(item)}}</template></div>
  </li>
</template>

<script>
import { ElementMixin } from 'vue-slicksort'
import objectMixin from 'phaidra-vue-components/src/mixins/object'
export default {
  name: 'p-sortable-solr-doc',
  mixins: [ElementMixin, objectMixin],
  props: {
    item: Object
  },
  computed: {
    instance: function () {
      return this.$store.state.instanceconfig
    }
  }
}
</script>

<style scoped>
.list-item {
  display: -webkit-box;
  display: -ms-flexbox;
  display: flex;
  -webkit-box-align: center;
  -ms-flex-align: center;
  align-items: center;
  width: 100%;
  padding: 20px;
  background-color: #fff;
  border-bottom: 1px solid #efefef;
  box-sizing: border-box;
  -webkit-user-select: none;
  -moz-user-select: none;
  -ms-user-select: none;
  user-select: none;
  color: #333;
  font-weight: 400;
}
.list-item-title {
  padding-left: 20px;
}
.preview-maxwidth {
  max-width: 120px;
}
</style>


