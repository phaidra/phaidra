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
            loaded: false,
            templateTitle: {
                eng: 'Collection',
                deu: 'Sammlung',
                ita: 'Collezione'
            }
        }
    },
    watch: {
        '$i18n.locale': {
            handler() {
                this.updateQueryParams()
            }
        }
    },
    metaInfo() {
        let metaInfo = {
        title: this.templateTitle[this.$i18n.locale] + ' - ' + this.$t(this.instanceconfig.title) + ' - ' + this.$t(this.instanceconfig.institution),
        };
        return metaInfo;
    },
    created() {
        this.templateName = this.$route.params.collection
        this.getCollection()
    },
    methods: {
        updateQueryParams() {
            this.$router.push({ query: { ...this.$route.query, title: this.templateTitle[this.$i18n.locale] } })
        },
        getCollection() {
            try {
                this.$axios.get(`/cms/template/${this.templateName || 'index'}`).then(response => {
                    this.collectionTemplate = response?.data?.template?.templateContent
                    if(response?.data?.template?.templateTitle) {
                        this.templateTitle = response?.data?.template?.templateTitle
                    }
                    this.updateQueryParams()
                    this.loaded = true
                })
            } catch (error) {
                this.loaded = true
            }
        }
    }
}
</script>