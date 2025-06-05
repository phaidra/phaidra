<template>
  <v-overlay :value="!isLoggedIn" absolute>
    <v-card class="pa-6 text-center" light>
      <v-icon size="64" color="primary" class="mb-4">mdi-account-lock</v-icon>
      <h2 class="text-h5 mb-4">Please
        <v-btn
          color="primary"
          to="/login"
          large
        >
          Login
        </v-btn>
        to Continue
      </h2>

      <p>
        You must be logged in to bulk upload to PHAIDRA.
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