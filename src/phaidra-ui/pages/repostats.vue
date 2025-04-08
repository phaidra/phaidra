<template>
  <v-container>
    <h1 class="sr-only">Repository statistics</h1>
    <PRepostat></PRepostat>
  </v-container>
</template>

<script>

import PRepostat from '../components/Repostat.vue';

export default {
  components: {PRepostat}
};
</script>
