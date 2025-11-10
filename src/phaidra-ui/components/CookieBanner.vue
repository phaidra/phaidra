<template>
  <v-slide-y-reverse-transition>
    <div v-if="showBanner" class="cookie-banner-container">
      <v-row justify="center" no-gutters>
        <v-col cols="12" md="6">
          <v-banner
            app
            sticky
            rounded
            light
            elevation="10"
            color="white"
            class="cookie-banner"
          >
            <v-row align="center" no-gutters>
              <v-col class="grow">
                <p class="cookie-message text-body-2 mb-0">
                  {{ $t('This website uses cookies to improve the services and experience of users. If you decide to continue browsing, we consider that you accept their use. You can delete and block all cookies from this website, but some parts of the website may not work. By clicking on "OK", you consent to the use of cookies.') }}
                  <a 
                    v-if="privacyPolicyUrl" 
                    :href="privacyPolicyUrl" 
                    target="_blank"
                    rel="noopener noreferrer"
                    class="privacy-link"
                  >
                    {{ $t('Privacy Policy') }}
                  </a>
                </p>
              </v-col>
              <v-col class="shrink ml-4">
                <v-btn
                  color="primary"
                  @click="acceptCookies"
                  large
                >
                  {{ $t('Ok') }}
                </v-btn>
              </v-col>
            </v-row>
          </v-banner>
        </v-col>
      </v-row>
    </div>
  </v-slide-y-reverse-transition>
</template>

<script>
export default {
  name: 'CookieBanner',
  data() {
    return {
      showBanner: false
    }
  },
  computed: {
    instanceconfig() {
      return this.$store.state.instanceconfig
    },
    isCookieBannerEnabled() {
      return this.instanceconfig?.enableCookieBanner === true
    },
    privacyPolicyUrl() {
      return this.instanceconfig?.cookiePrivacyPolicyUrl
    }
  },
  methods: {
    acceptCookies() {
      if (process.browser) {
        localStorage.setItem('cookieBannerAccepted', 'true')
        this.showBanner = false
      }
    },
    checkCookieBannerStatus() {
      if (!this.isCookieBannerEnabled) {
        this.showBanner = false
        return
      }

      if (process.browser) {
        const accepted = localStorage.getItem('cookieBannerAccepted')
        this.showBanner = !accepted
      }
    }
  },
  watch: {
    isCookieBannerEnabled: {
      immediate: true,
      handler() {
        this.checkCookieBannerStatus()
      }
    }
  },
  mounted() {
    this.checkCookieBannerStatus()
  }
}
</script>

<style scoped>
.cookie-banner-container {
  position: fixed;
  bottom: 0;
  left: 0;
  right: 0;
  z-index: 999;
  padding: 0 24px 24px 24px;
}

.cookie-banner {
  border-radius: 8px;
  box-shadow: 0 -2px 10px rgba(0, 0, 0, 0.1);
}

.cookie-banner >>> .v-banner__wrapper {
  padding: 20px 24px;
}

.cookie-banner >>> .v-banner__content {
  width: 100%;
}

.cookie-message {
  line-height: 1.6;
}

.privacy-link {
  color: #1976d2 !important;
  text-decoration: underline;
  font-weight: 500;
  white-space: nowrap;
}
</style>