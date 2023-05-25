<template>
  <div>
    <div>
      <div class="row">
        <div class="titletext primary--text">
          {{ $t("Storage per object type") }}
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
                "rgb(102, 102, 102)",
                "rgb(107, 33, 133)",
                "rgb(238, 130, 238)",
                "rgb(255, 153, 153)",
                "rgb(233,150,122)",
              ],
            },
          ],
          labels: [],
        },
        options: {
          title: {
            text: "Objekte verteilt nach Speicherbedarf - PHAIDRA",
            display: true,
          },
          plugins: {
            legend: false,
            outlabels: {
              text: "%l %p",
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
      this.generateChartUrl(this.chartConfig, 450);
    },
    getChartSrc() {
      this.chartSrc = this.generateChartSrc(this.chartConfig, 450);
      this.$store.dispatch(
        "setCharts",
        this.generateChartSrc(this.chartConfig, 450, true)
      );
    },
    populateData() {
      let labels = [];
      let size = [];
      let totalCount = 0;
      for (let key in this.chartData) {
        if (
          key !== "LaTeXDocument" &&
          key !== "Paper" &&
          key !== "Zombie" &&
          key !== "Collection" &&
          key !== "Container"
        ) {
          let keyValue = this.chartData[key];
          let count = 0;
          keyValue.forEach((element) => {
            count = count + element.size;
          });
          totalCount = totalCount + count;
          if (count) {
            size.push(count);
            labels.push(key);
          }
        }
      }

      let bookIndex = labels.findIndex((elem) => elem == "Book");
      let pageIndex = labels.findIndex((elem) => elem == "Page");
      size[bookIndex] = +size[bookIndex] + size[pageIndex];
      size.splice(pageIndex, 1);
      labels = labels.filter((elem) => elem !== "Page");
      this.chartConfig.data.labels = labels;
      this.chartConfig.data.datasets[0].data = size;

      // convert into percentage value
      let objPerCentArr = [];
      let labelsArr = [];
      size.forEach((elem, index) => {
        let perecentValue = (elem / totalCount) * 100;
        if (Math.round(perecentValue) > 0) {
          objPerCentArr.push(perecentValue);
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
