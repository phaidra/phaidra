<template>
  <div>
    <div class="my-10">
      <div class="row">
        <div class="titletext primary--text">
          {{ $t("Objects per object type") }}
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
        type: "outlabeledPie",
        data: {
          datasets: [
            {
              data: [],
              backgroundColor: [
                "rgb(1, 92, 162)",
                "rgb(244, 166, 29)",
                "rgb(148, 193, 84)",
                "rgb(167, 28, 73)",
                "rgb(107, 33, 133)",
                "rgb(244, 166, 29)",
                "rgb(1, 92, 162)",
                "rgb(255, 153, 153)",
                "rgb(233,150,122)",
                "rgb(219, 65, 37)",
              ],
            },
          ],
          labels: [],
        },
        options: {
          title: {
            text: "Objekte verteilt nach Objekttypen - UNIDAM / easyDB",
            display: true,
          },
          plugins: {
            legend: false,
            outlabels: {
              color: "white",
              stretch: 25,
              font: {
                resizable: true,
                minSize: 8,
                maxSize: 8,
              },
            },
          },
          legend: {
            position: "bottom",
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
      this.generateChartUrl(this.chartConfig);
    },
    getChartSrc() {
      this.chartSrc = this.generateChartSrc(this.chartConfig);
      this.$store.dispatch(
        "setCharts",
        this.generateChartSrc(this.chartConfig, null, true)
      );
    },
    populateData() {
      let objCount = {};
      let totalCount = 0;
      for (let key in this.chartData) {
        if (key && key !== "time_row") {
          if (this.chartData[key].models) {
            for (let m of this.chartData[key].models) {
              if (!objCount[m.model]) {
                objCount[m.model] = 0;
              }
              objCount[m.model] += m.obj_count;
              totalCount += m.obj_count;
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
          labelsArr.push(key);
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
