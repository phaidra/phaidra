<template>
  <div>
    <v-row>
      <v-col cols="12" md="10" offset-md="1">
        <v-row class="my-5">
          <v-col cols="auto" class="text-left">
            <span class="grey--text text--darken-2">
              <address>
                {{ instanceconfig.address }} | <abbr title="Telefon">T</abbr>
                {{ instanceconfig.phone }}
              </address>
            </span>
          </v-col>
          <v-col class="text-right">
            <nuxt-link :to="localePath('impressum')">{{ $t('Impressum') }}</nuxt-link> |
            <nuxt-link :to="localePath('termsofuse')">{{ $t('Terms of Use') }}</nuxt-link> |
            <nuxt-link :to="localePath('credits')">{{ $t('Credits') }}</nuxt-link>
            <!-- |
            <nuxt-link :to="localePath('statistics')">{{ $t('Statistics') }}</nuxt-link>-->
          </v-col>
        </v-row>
      </v-col>
    </v-row>
  </div>
</template>

<script>
import { config } from "@/mixins/config";

export default {
  mixins: [config],
};
</script>
