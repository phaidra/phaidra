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
import { config } from '../../mixins/config';

export default {
    name: 'Collection',
    mixins: [config],
    data() {
        return {
            templateName: null,
            collectionTemplate: null,
            loaded: false
        }
    },
    metaInfo() {
        let metaInfo = {
        title: this.$t(this.templateName || 'Collection') + ' - ' + this.$t(this.instanceconfig.title) + ' - ' + this.$t(this.instanceconfig.institution),
        };
        return metaInfo;
    },
    created() {
        this.templateName = this.$route.params.collection
        this.getCollection()
    },
    methods: {
        getCollection() {
            try {
                this.$axios.get(`/cms/template/${this.templateName || 'index'}`).then(response => {
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