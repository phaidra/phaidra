<template>
  <div
    v-if="
      phaidraData.length && localPhaidraData && unidamData && disciplinesData
    "
  >
    <ExtStatisticsChartOne
      v-if="localPhaidraData"
      :phaidraData="phaidraData"
      :localPhaidraData="localPhaidraData"
      :unidamData="unidamData"
    />
    <div class="row">
      <h3 class="text-h4 font-weight-light primary--text mt-12">PHAIDRA LZA</h3>
    </div>
    <ExtStatisticsChartTwo :chartData="groupedbyYear" />
    <ExtStatisticsChartFour :chartData="groupedbyObjects" />
    <ExtStatisticsChartFive :chartData="groupedbyObjects" />
    <ExtStatisticsChartSix :chartData="disciplinesData" />
    <ExtStatisticsChartSeven :chartData="groupedbyYear" />
    <ExtStatisticsChartEight :chartData="groupedbyYear" />
    <div class="row">
      <h3 class="text-h4 font-weight-light primary--text mt-12">
        UNIDAM / easyDB
      </h3>
    </div>
    <ExtStatisticsChartThree :chartData="unidamGroupedbyYear" />
    <ExtStatisticsChartNine :chartData="unidamData" />
    <ExtStatisticsChartTen :chartData="unidamData" />
    <ExtStatisticsChartEleven :chartData="unidamGroupedbyYear" />
    <v-btn class="my-5" @click="exporCharts" color="primary" raised>{{
      $t("Export All")
    }}</v-btn>
  </div>
</template>

<script>
import configjs from "../../../config/phaidra-ui";
import axios from "axios";
const { jsPDF } = require("jspdf");
export default {
  middleware: "auth",
  data() {
    return {
      allCharts: [],
      phaidraData: [],
      localPhaidraData: null,
      unidamData: null,
      disciplinesData: null,
      groupedbyYear: {},
      groupedbyObjects: {},
      unidamGroupedbyYear: {},
      phaidraLocalUrl:
        "https://services.phaidra-temp.univie.ac.at/api/stats/aggregates",
      unidamUrl:
        "https://services.phaidra.univie.ac.at/api/statistics/unidam_easydb.json",
      disciplinesUrl:
        "https://services.phaidra.univie.ac.at/api/stats/disciplines",
    };
  },
  methods: {
    exporCharts() {
      this.allCharts = this.$store.state.chartsUrl;
      var doc = new jsPDF("p", "mm", [1400, 215]);
      let yAxis = 30;
      this.allCharts.forEach((elem, index) => {
        var img = new Image();
        img.src = elem;
        img.crossOrigin = "";

        if (index == 3) {
          doc.addImage(img, "JPEG", 10, yAxis, 160, 155);
          yAxis = yAxis + 150;
        } else if (index == 4) {
          doc.addImage(img, "JPEG", 10, yAxis, 180, 155);
          yAxis = yAxis + 150;
        } else if (index == 5) {
          doc.addImage(img, "JPEG", 10, yAxis, 185, 90);
          yAxis = yAxis + 115;
        } else if (index == 8) {
          doc.addImage(img, "JPEG", 10, yAxis, 190, 115);
          yAxis = yAxis + 125;
        } else if (index == 9) {
          doc.addImage(img, "JPEG", 10, yAxis, 170, 80);
          yAxis = yAxis + 110;
        } else {
          doc.addImage(img, "JPEG", 10, yAxis, 180, 100);
          yAxis = yAxis + 120;
        }
      });

      window.open(doc.output("bloburl"), "_blank");
    },

    groupbyYear(data) {
      const group = data.reduce((r, a) => {
        r[a.upload_date] = [...(r[a.upload_date] || []), a];
        return r;
      }, {});
      return group;
    },

    groupbyObjects(data) {
      const group = data.reduce((r, a) => {
        r[a.model] = [...(r[a.model] || []), a];
        return r;
      }, {});
      return group;
    },

    groupbyOrgUnit(data) {
      const group = data.reduce((r, a) => {
        r[a.org_unit] = [...(r[a.org_unit] || []), a];
        return r;
      }, {});
      return group;
    },

    async getDisciplinesData() {
      try {
        let res = await axios.get(this.disciplinesUrl);
        if (res.data && res.data.disciplines) {
          this.disciplinesData = res.data.disciplines;
        }
      } catch (err) {
        this.disciplinesData = {};
      }
    },

    async getUnidamData() {
      try {
        let res = await axios.get(this.unidamUrl);
        if (res && res.data) {
          this.unidamData = res.data;
          if (res.data.time_row) {
            this.unidamGroupedbyYear = this.groupbyYear(res.data.time_row);
          }
        }
      } catch (err) {
        this.unidamData = [];
      }
    },

    async getLocalPhaidraData() {
      try {
        let res = await axios.get(this.phaidraLocalUrl);
        if (res.data && res.data.stats) {
          this.localPhaidraData = res.data.stats;
        }
        this.$store.commit("setLoading", false);
      } catch (err) {
        this.localPhaidraData = [];
        this.$store.commit("setLoading", false);
      }
    },

    async getPhaidraData() {
      try {
        this.$store.commit("setLoading", true);
        let res = await axios.get(
          configjs.instances[configjs.defaultinstance].api + "/stats/aggregates"
        );
        if (res.status == 200) {
          this.phaidraData = res.data.stats;
          //groupbyYear
          this.groupedbyYear = this.groupbyYear(this.phaidraData);
          this.groupedbyObjects = this.groupbyObjects(this.phaidraData);
        }
      } catch (err) {
        this.$store.commit("setLoading", false);
      }
    },
  },
  mounted() {
    this.getPhaidraData();
    this.getLocalPhaidraData();
    this.getDisciplinesData();
    this.getUnidamData();
  },
};
</script>
