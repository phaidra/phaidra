import qs from "qs";

export default {
    data() {
        return {
            typeHeaders: [
                {
                    text: "Object types",
                    align: "start",
                    sortable: false,
                    value: "objectType",
                },
            ],
            newTypeHeaders: [
                {
                    text: "New object types",
                    align: "start",
                    sortable: false,
                    value: "objectType",
                },
            ],
            cmodelHeaders: [
                {
                    text: "Content models",
                    align: "start",
                    sortable: false,
                    value: "cmodel",
                },
            ],
            cmodelStorageHeaders: [
                {
                    text: "Storage approx. (GB)",
                    align: "start",
                    sortable: false,
                    value: "cmodel",
                }
            ],
            ownerHeaders: [
                {
                    text: "Owner",
                    align: "start",
                    sortable: false,
                    value: "owner",
                },
            ],
            typeItems: [],
            newTypeItems: [],
            cmodelItems: [],
            cmodelStorageItems: [],
            ownerItems: [],
            yearsTotal: [],
            newTypesFilter: {
                "https://pid.phaidra.org/vocabulary/9E94-E3F8": true,
                "https://pid.phaidra.org/vocabulary/P2YP-BMND": true,
                "https://pid.phaidra.org/vocabulary/1PHE-7VMS": true,
                "https://pid.phaidra.org/vocabulary/ST05-F6SP": true,
                "https://pid.phaidra.org/vocabulary/9ZSV-CVJH": true,
            },
            total: 0,
        };
    },
    methods: {
        async fetchStats() {
            this.typeItems = [];
            this.cmodelItems = [];
            this.cmodelStorageItems = [];
            let fromYear = parseInt(new Date().getFullYear());
            console.log('mixin this.instanceconfig.since', this.instanceconfig.since)
            if (this.instanceconfig.since) {
                fromYear = this.instanceconfig.since.substring(0, 4);
            }
            let toYear = new Date().getFullYear();
            for (let i = fromYear; i <= toYear; i++) {
                this.typeHeaders.push({ text: i.toString(), value: i.toString() });
                this.newTypeHeaders.push({ text: i.toString(), value: i.toString() });
                this.cmodelHeaders.push({ text: i.toString(), value: i.toString() });
                this.cmodelStorageHeaders.push({
                    text: i.toString(),
                    value: i.toString(),
                });
                this.ownerHeaders.push({ text: i.toString(), value: i.toString() });
            }
            this.typeHeaders.push({ text: "Total", value: "total" });
            this.newTypeHeaders.push({ text: "Total", value: "total" });
            this.cmodelHeaders.push({ text: "Total", value: "total" });
            this.cmodelStorageHeaders.push({ text: "Total", value: "total" });
            for (let term of this.$store.state.vocabulary.vocabularies["objecttypeuwm"].terms) {
                let params = {
                    q: "*:*",
                    fq: 'object_type_id:"' + term["@id"] + '"',
                    facet: "on",
                    rows: 0,
                    "facet.range": "tcreated",
                    "f.tcreated.facet.range.start": fromYear + "-01-01T00:00:00Z",
                    "f.tcreated.facet.range.end": "NOW",
                    "f.tcreated.facet.range.gap": "+1YEAR",
                    defType: "edismax",
                    wt: "json",
                };
                let query = qs.stringify(params, {
                    encodeValuesOnly: true,
                    indices: false,
                });
                try {
                    let response = await this.$axios.get(
                        "/search/select?" + query
                    );
                    if (response.data.facet_counts.facet_ranges.tcreated.counts) {
                        let a = response.data.facet_counts.facet_ranges.tcreated.counts;
                        let stats = { total: 0 };
                        let hasValue = false;
                        for (let j = 0; j < a.length; j = j + 2) {
                            if (a[j + 1] > 0) {
                                hasValue = true;
                            }
                            stats.objectType = this.getLocalizedTermLabel(
                                "objecttypeuwm",
                                term["@id"]
                            );
                            stats[a[j].substring(0, 4)] = a[j + 1];
                            stats.total += a[j + 1]
                        }
                        if (hasValue) {
                            console.log('SET this.typeItems', stats)
                            this.typeItems.push(stats);
                        }
                    }
                } catch (error) {
                    console.log(error);
                }
            }
            for (let term of this.$store.state.vocabulary.vocabularies["objecttype"].terms) {
                let params = {
                    q: "*:*",
                    fq: 'object_type_id:"' + term["@id"] + '"',
                    facet: "on",
                    rows: 0,
                    "facet.range": "tcreated",
                    "f.tcreated.facet.range.start": fromYear + "-01-01T00:00:00Z",
                    "f.tcreated.facet.range.end": "NOW",
                    "f.tcreated.facet.range.gap": "+1YEAR",
                    defType: "edismax",
                    wt: "json",
                };
                let query = qs.stringify(params, {
                    encodeValuesOnly: true,
                    indices: false,
                });
                try {
                    let response = await this.$axios.get(
                        "/search/select?" + query
                    );
                    if (response.data.facet_counts.facet_ranges.tcreated.counts) {
                        let a = response.data.facet_counts.facet_ranges.tcreated.counts;
                        let stats = { total: 0 };
                        let hasValue = false;
                        for (let j = 0; j < a.length; j = j + 2) {
                            if (a[j + 1] > 0) {
                                hasValue = true;
                            }
                            stats.objectType = this.getLocalizedTermLabel(
                                "objecttype",
                                term["@id"]
                            );
                            stats[a[j].substring(0, 4)] = a[j + 1];
                            stats.total += a[j + 1]
                        }
                        if (hasValue) {
                            this.newTypeItems.push(stats);
                        }
                    }
                } catch (error) {
                    console.log(error);
                }
            }
            for (let term of this.$store.state.vocabulary.vocabularies["cmodels"].terms) {
                let params = {
                    q: "*:*",
                    fq: 'cmodel:"' + term["@id"] + '"',
                    facet: "on",
                    rows: 0,
                    "facet.range": "tcreated",
                    "f.tcreated.facet.range.start": fromYear + "-01-01T00:00:00Z",
                    "f.tcreated.facet.range.end": "NOW",
                    "f.tcreated.facet.range.gap": "+1YEAR",
                    defType: "edismax",
                    wt: "json",
                };
                let query = qs.stringify(params, {
                    encodeValuesOnly: true,
                    indices: false,
                });
                try {
                    let response = await this.$axios.get(
                        "/search/select?" + query
                    );
                    if (response.data.facet_counts.facet_ranges.tcreated.counts) {
                        let a = response.data.facet_counts.facet_ranges.tcreated.counts;
                        let stats = { total: 0 };
                        let hasValue = false;
                        for (let j = 0; j < a.length; j = j + 2) {
                            if (a[j + 1] > 0) {
                                hasValue = true;
                            }
                            stats.cmodel = this.getLocalizedTermLabel("cmodels", term["@id"]);
                            stats[a[j].substring(0, 4)] = a[j + 1];
                            stats.total += a[j + 1]
                        }
                        if (hasValue) {
                            this.cmodelItems.push(stats);
                        }
                    }
                } catch (error) {
                    console.log(error);
                }
            }

            for (let term of this.$store.state.vocabulary.vocabularies["cmodels"].terms) {
                let cmodel = term["@id"]

                let stats = {
                    cmodel,
                    total: 0
                };

                for (let i = fromYear; i <= toYear; i++) {

                    try {
                        let year = i

                        let params = {
                            q: '*:*',
                            stats: true,
                            'stats.field': 'size',
                            fq: 'cmodel:' + cmodel + ' AND tcreated:[' + year + '-01-01T00:00:00Z TO ' + year + '-12-31T23:59:59Z]',//AND -ismemberof:["" TO *]
                            rows: 0
                        }
                        if (cmodel === 'Page') {
                            params.core = 'phaidra_pages'
                        }
                        let query = qs.stringify(params, {
                            encodeValuesOnly: true,
                            indices: false,
                        });
                        let res = await this.$axios.get(
                            "/search/select?" + query
                        );
                        if (res.status == 200) {
                            let gb = res.data.stats.stats_fields.size.sum / 1000000000
                            stats.total += res.data.stats.stats_fields.size.sum
                            stats[year] = gb > 0 ? this.tofixed(gb) : 0
                        }
                    } catch (error) {
                        console.log(error);
                    }

                }
                stats.total = stats.total > 0 ? this.tofixed(stats.total / 1000000000) : 0
                this.cmodelStorageItems.push(stats)
            }
        },
        tofixed(x) {
            return Number.parseFloat(x).toFixed(3);
        }
    },
}