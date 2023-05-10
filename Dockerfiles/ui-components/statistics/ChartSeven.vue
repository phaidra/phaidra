<template>
  <div>
    <div class="my-10">
      <div class="row">
        <div class="titletext primary--text">
          {{ $t("Objects per year cumulative") }}
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
        type: "line",
        data: {
          labels: [],
          datasets: [
            {
              data: [],
              fill: true,
              backgroundColor: "rgb(1, 92, 162)",
              borderWidth: 1,
              pointRadius: 0,
            },
          ],
        },
        options: {
          legend: {
            display: false,
          },
          title: {
            text: "Zuwachs der Objekte über die Jahre - PHAIDRA",
            display: true,
          },
          scales: {
            xAxes: [
              {
                gridLines: {
                  display: false,
                },
              },
            ],
            yAxes: [
              {
                ticks: {
                  callback: function (label) {
                    return new Intl.NumberFormat("de-DE").format(label);
                  },
                },
              },
            ],
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
      this.chartSrc = this.generateChartSrc(this.chartConfig, null, null, 520);
      this.$store.dispatch(
        "setCharts",
        this.generateChartSrc(this.chartConfig, null, true)
      );
    },
    populateData() {
      let labels = [];
      let objCount = [];
      let previousObjCount = 0;
      for (let key in this.chartData) {
        labels.push(+key);
        let keyValue = this.chartData[key];
        let count = 0;
        keyValue.forEach((element) => {
          count = count + element.obj_count;
        });
        previousObjCount = previousObjCount + count;
        objCount.push(previousObjCount);
      }
      this.chartConfig.data.labels = labels;
      this.chartConfig.data.datasets[0].data = objCount;
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
