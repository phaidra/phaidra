<template>
<client-only>
  <div>
    <h1 class="d-sr-only">Groups</h1>
    <p-groups></p-groups>
  </div>
</client-only>
</template>
<script>

export default {
  middleware: "auth",
}
</script>
