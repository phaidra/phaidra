<template>
  <ul class="list">
    <slot />
  </ul>
</template>

<script>
import { ContainerMixin } from 'vue-slicksort'
export default {
  name: 'p-sortable-list',
  mixins: [ContainerMixin]
}
</script>

<style scoped>
.list {
  max-height: 80vh;
  margin: 0 auto;
  padding: 0;
  overflow: auto;
  background-color: #f3f3f3;
  border: 1px solid #efefef;
  border-radius: 3;
}
</style>
