<template>
  <div>
    <div class="mb-10">
      <div class="row">
        <div class="titletext primary--text">
          {{ $t("Objects per discipline") }}
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
              data: [65, 13, 11, 6, 6],
              backgroundColor: [
                "rgb(1, 92, 162)",
                "rgb(162, 27, 65)",
                "rgb(244, 166, 29)",
                "rgb(1, 133, 117)",
                "rgb(219, 65, 37)",
              ],
            },
          ],
          labels: [
            "Digital Humanities",
            "MINT Fächer",
            "Sozialwissenschaften",
            "Lebenswissenschaften",
            "Rest",
          ],
        },
        options: {
          title: {
            text: "Objekte verteilt nach Disziplinen - PHAIDRA",
            display: true,
          },
          plugins: {
            datalabels: {
              color: "white",
              formatter: (value) => {
                return value + "%";
              },
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
      this.generateChartUrl(this.chartConfig, 230);
    },
    getChartSrc() {
      this.chartSrc = this.generateChartSrc(this.chartConfig, 230);
      this.$store.dispatch(
        "setCharts",
        this.generateChartSrc(this.chartConfig, 230, true)
      );
    },
    populateData() {
      let labels = [];
      let objCount = [];
      let totalCount = 0;
      for (let key in this.chartData) {
        let keyValue = this.chartData[key];
        totalCount = totalCount + keyValue;
        if (keyValue) {
          objCount.push(keyValue);
          if (key == "DigHum") {
            labels.push("Digital Humanities");
          } else if (key == "LeWi") {
            labels.push("Lebenswissenschaften");
          } else if (key == "MINT") {
            labels.push("MINT Fächer");
          } else if (key == "SoWi") {
            labels.push("Sozialwissenschaften");
          } else {
            labels.push(key);
          }
        }
      }
      // convert into percentage value
      let objPerCentArr = [];
      let labelsArr = [];
      objCount.forEach((elem, index) => {
        let perecentValue = (elem / totalCount) * 100;
        if (Math.round(perecentValue) > 0) {
          objPerCentArr.push(Math.round(perecentValue));
          labelsArr.push(labels[index]);
        }
      });

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
