<template>
    <div v-if="loaded && collectionTemplate" style="width:100%;">
        <runtimetemplate :template="collectionTemplate" />
    </div>
    <div v-else-if="loaded">
        <h2 class="font-weight-light">{{$t('This collection template does not exist...')}}</h2>
        <p>{{$t('Return to')}} <NuxtLink to="/">home page</NuxtLink>.</p>
    </div>
    <div v-else>
        Loading...
    </div>
</template>

<script>
export default {
    name: 'Collection',
    data() {
        return {
            templateName: null,
            collectionTemplate: null,
            loaded: false
        }
    },
    created() {
        this.templateName = this.$route.params.collection
        this.getCollection()
    },
    methods: {
        getCollection() {
            try {
                this.$axios.get(`/cms/template/${this.templateName}`).then(response => {
                    this.collectionTemplate = response?.data?.template?.templateContent
                    this.loaded = true
                })
            } catch (error) {
                this.loaded = true
            }
        }
    }
}
</script>