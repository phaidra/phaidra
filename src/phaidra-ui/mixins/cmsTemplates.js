export const cmsTemplates = {
  data() {
    return {
      cmsTemplates: []
    }
  },
  methods: {
    async fetchCmsTemplates(self) {
      try {
        let response = await self.$axios.get(
          "/cms/template/all"
        );
        this.cmsTemplates = response?.data?.templates;
      } catch (error) {
        console.log(error);
      }
    }
  },
  async mounted() {
    await this.fetchCmsTemplates(this);
  }
}


