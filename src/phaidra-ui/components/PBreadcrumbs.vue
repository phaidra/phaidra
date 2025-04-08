<template>
  <v-row>
    <v-col>
      <span class="youarehere secondary--text">{{ $t("You are here") }}:</span>
      <template v-for="(item, index) in translatedArray">
        <icon
          :key="'icon' + index"
          left
          dark
          name="univie-right"
          color="#a4a4a4"
          width="8px"
          height="8px"
          class="mx-1"
        ></icon>
        <span :key="'distext' + index" v-if="item.disabled" class="text">{{
          $t(item.text)
        }}</span>
        <template v-else>
          <a
            :key="'iconex' + index"
            v-if="item.external"
            :href="item.to"
            class="text"
            >{{ $t(item.text) }}</a
          >
          <nuxt-link
            :key="'link' + index"
            v-else
            :to="item.to"
            class="text"
            >{{ $t(item.text) }}</nuxt-link
          >
        </template>
      </template>
      <v-divider></v-divider>
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
</style>
