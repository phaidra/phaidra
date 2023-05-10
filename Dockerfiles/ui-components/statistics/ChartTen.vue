<template>
  <div>
    <div class="my-10">
      <div class="row">
        <div class="titletext primary--text">
          {{ $t("Objects per faculty") }}
        </div>
        <v-spacer></v-spacer>
        <div>
          <v-btn @click="exportChart" color="primary" raised>{{
            $t("Export")
          }}</v-btn>
        </div>
      </div>
    </div>
    <img v-if="chartSrc" :src="chartSrc" />
  </div>
</template>

<script>
import { commonChart } from "../../../mixins/commonChart";
export default {
  props: ["chartData"],
  data() {
    return {
      chartConfig: {
        type: "pie",
        data: {
          datasets: [
            {
              data: [],
              backgroundColor: [
                "rgb(1, 92, 162)",
                "rgb(162, 27, 65)",
                "rgb(244, 166, 29)",
                "rgb(1, 133, 117)",
                "rgb(219, 65, 37)",
                "rgb(143, 192, 72)",
              ],
            },
          ],
          labels: [],
        },
        options: {
          title: {
            text: "Objekte verteilt nach Fakultäten - UNIDAM / easyDB",
            display: true,
          },
          plugins: {
            datalabels: {
              display: false,
            },
          },
          legend: {
            position: "right",
            labels: {
              usePointStyle: true,
            },
          },
        },
      },
      chartSrc: "",
    };
  },
  mixins: [commonChart],
  methods: {
    exportChart() {
      this.generateChartUrl(this.chartConfig, 250);
    },
    getChartSrc() {
      this.chartSrc = this.generateChartSrc(this.chartConfig, 200);
      this.$store.dispatch(
        "setCharts",
        this.generateChartSrc(this.chartConfig, 250, true)
      );
    },
    populateData() {
      let objCount = {};
      let totalCount = 0;
      for (let key in this.chartData) {
        if (key && key !== "time_row") {
          if (this.chartData[key].org_units) {
            for (let u of this.chartData[key].org_units) {
              if (!objCount[u.org_unit]) {
                objCount[u.org_unit] = 0;
              }
              objCount[u.org_unit] += u.obj_count;
              totalCount += u.obj_count;
            }
          }
        }
      }
      // convert into percentage value
      let objPerCentArr = [];
      let labelsArr = [];
      for (let key in objCount) {
        let perecentValue = (objCount[key] / totalCount) * 100;
        if (Math.round(perecentValue) > 0) {
          objPerCentArr.push(perecentValue);
          labelsArr.push(Math.ceil(perecentValue) + "% " + key);
        }
      }

      this.chartConfig.data.labels = labelsArr;
      this.chartConfig.data.datasets[0].data = objPerCentArr;
    },
  },
  mounted() {
    this.populateData();
    this.getChartSrc();
  },
};
</script>

<style scoped>
h3 {
  font-size: 28px;
  margin-bottom: 6px;
}
.titletext {
  font-size: 18px;
  font-weight: 500;
  letter-spacing: 0.0125em;
}
</style>
