<template>
  <v-row class="mb-8">
    <v-col cols="12" class="breadcrumbs-container pb-0" aria-label="Breadcrumbs">
      <span class="youarehere secondary--text">{{ $t("You are here") }}:</span>
      <ol class="breadcrumbs-list">
        <template v-for="(item, index) in translatedArray">
          <li :key="'item' + index" class="breadcrumb-item" :aria-current="item.disabled ? 'page' : undefined">
            <icon
              v-if="index > 0"
              :key="'icon' + index"
              left
              dark
              name="univie-right"
              color="#a4a4a4"
              width="8px"
              height="8px"
              class="mx-1"
            ></icon>
            <span v-if="item.disabled" class="text">{{ $t(item.text) }}</span>
            <template v-else>
              <a
                v-if="item.external"
                :href="item.to"
                class="text"
                >{{ $t(item.text) }}</a
              >
              <nuxt-link
                v-else
                :to="item.to"
                class="text"
                >{{ $t(item.text) }}</nuxt-link
              >
            </template>
          </li>
        </template>
      </ol>
      <v-divider class="mt-1"></v-divider>
    </v-col>
    <v-col cols="12" class="py-0">
      <v-progress-linear
        :active="$store.state.loading"
        :height="2"
        indeterminate
        color="primary"
      ></v-progress-linear>
    </v-col>
  </v-row>
</template>

<script>
export default {
  name: "p-breadcrumbs",
  props: {
    items: Array,
  },
   computed: {
    translatedArray() {
      if (!this.items) return []
      return JSON.parse(JSON.stringify(this.items)).map((item) => {
        if(item.text.includes(" o:")){
          const [staticText, dynamicPart] = item.text.split(" o:");
          const translatedText = this.$t(staticText.trim());
          item.text = `${translatedText} o:${dynamicPart}`;
        }
        return item
      });
    }
  }
};
</script>

<style scoped>
.youarehere {
  font-weight: bold;
  font-size: 10pt;
}

.text {
  font-size: 10pt;
}

.breadcrumbs-list {
  display: inline;
  list-style: none;
  padding: 0;
  margin: 0;
}

.breadcrumb-item {
  display: inline;
}
</style>
