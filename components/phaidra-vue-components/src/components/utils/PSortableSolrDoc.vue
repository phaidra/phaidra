<template>
  <li class="list-item">
    <img :src="'https://' + instance.baseurl + '/preview/' + item.pid + '///120'"  class="elevation-1"/>
    <div class="list-item-title">{{item.pid}} - {{item.cmodel}}<template v-if="'dc_title' in item"> - {{item.dc_title[0]}}</template></div>
  </li>
</template>

<script>
import { ElementMixin } from 'vue-slicksort'
export default {
  name: 'p-sortable-solr-doc',
  mixins: [ElementMixin],
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
</style>
