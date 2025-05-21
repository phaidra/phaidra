<template>
  <div v-if="instanceconfig.cms_footer" style="width:100%;">
    <runtimetemplate :template="instanceconfig.cms_footer" />
  </div>
  <v-row v-else class="my-6">
    <v-col cols="12" md="10" offset-md="1">
      <v-row>
        <v-col cols="auto">
          <address>
            {{ instanceconfig.address }} | <abbr :title="$t('Telephone')">T</abbr>
            {{ instanceconfig.phone }}
          </address>
        </v-col>
        <v-col class="text-md-right">
          <nuxt-link :to="localePath('impressum')">{{ $t('Impressum') }}</nuxt-link> |
          <nuxt-link :to="localePath('termsofuse')">{{ $t('Terms of Use') }}</nuxt-link> |
          <nuxt-link :to="localePath('credits')">{{ $t('Credits') }}</nuxt-link>
        </v-col>
      </v-row>
    </v-col>
  </v-row>
</template>

<script>
import { config } from "@/mixins/config";

export default {
  mixins: [config]
};
</script>
