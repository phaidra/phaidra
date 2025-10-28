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
import { cmsTemplates } from "@/mixins/cmsTemplates";

export default {
    name: 'Collection',
    mixins: [config, cmsTemplates],
    data() {
        return {
            activetab: null, // Added for Phaidra Unipd (Padova) - PLEASE DO NOT REMOVE
            toggle: false,  // Added for Phaidra Unipd (Padova) - PLEASE DO NOT REMOVE
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
        getCollection() {
            try {
                this.$axios.get(`/cms/template/${this.templateName || 'index'}`).then(response => {
                    this.collectionTemplate = response?.data?.template?.templateContent
                    if(response?.data?.template?.templateTitle) {
                        this.templateTitle = response?.data?.template?.templateTitle
                    }
                    const title = this.templateTitle[this.$i18n.locale] || this.templateTitle.eng || 'Collection'
                    let indexCollectionObject = {
                        text: 'Collections',
                        to: '/collections'
                    }
                    if(response?.data?.template?.templateName !== 'index') {
                        this.$store.commit('addBreadcrumb', indexCollectionObject)
                        this.$store.commit('addBreadcrumb', {
                            text: title,
                            to: this.$route.name,
                            disabled: true
                        })
                    } else {
                        indexCollectionObject.disabled = true
                        this.$store.commit('addBreadcrumb', indexCollectionObject)
                    }
                    this.loaded = true
                })
            } catch (error) {
                this.loaded = true
            }
        }
    }
}
</script>