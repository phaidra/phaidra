<template>
  <div v-if="instanceconfig.cms_footer">
    <runtimetemplate :template="instanceconfig.cms_footer" />
  </div>
  <v-row v-else>
    <v-col cols="12" md="10" offset-md="1">
      <v-row class="my-5">
        <v-col cols="auto" class="text-left">
          <address>
            {{ instanceconfig.address }} | <abbr title="Telefon">T</abbr>
            {{ instanceconfig.phone }}
          </address>
        </v-col>
        <v-col class="text-right">
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
