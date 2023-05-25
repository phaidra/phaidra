<template>
<client-only>
  <p-groups></p-groups>
</client-only>
</template>
<script>

export default {
  middleware: "auth",
}
</script>
