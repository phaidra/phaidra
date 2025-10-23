<template>
  <v-overlay :value="!isLoggedIn" absolute>
    <v-card class="pa-6 text-center" light>
      <v-icon size="64" class="mb-4">mdi-account-lock</v-icon>
      <h2 class="text-h5">{{ $t('Please log in to continue') }}</h2>
      <v-btn
          color="primary"
          to="/login"
          large
          class="my-4"
      >{{ $t('Login') }}
      </v-btn>
      <p>
        {{ $t('You must be logged in to bulk upload to PHAIDRA.') }}
      </p>
    </v-card>
  </v-overlay>
</template>

<script>
export default {
  name: 'LoginOverlay',
  props: {
    isLoggedIn: {
      type: Boolean,
      required: true
    }
  }
}
</script> 