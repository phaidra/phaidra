<template>
  <component :is="tag" class="list mt-4">
    <slot />
  </component>
</template>

<script>
/** Presentational wrapper; drag logic lives in parent (e.g. PMSort with vue-draggable-next). */
export default {
  name: 'p-sortable-list',
  props: {
    tag: {
      type: String,
      default: 'ul'
    }
  }
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
  border-radius: 3px;
}
</style>
