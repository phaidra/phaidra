<template>
<client-only>
  <p-lists></p-lists>
</client-only>
</template>
<script>

export default {
  middleware: "auth",
}
</script>
