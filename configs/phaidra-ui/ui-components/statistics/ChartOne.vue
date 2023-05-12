<template>
  <div>
    <div class="my-10">
      <div class="row">
        <div class="titletext primary--text">
          {{ $t("Number of objects in repositories") }}
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
  props: ["phaidraData", "localPhaidraData", "unidamData"],
  data() {
    return {
      width: 500,
      chartConfig: {
        type: "horizontalBar",
        data: {
          labels: [],
          datasets: [
            {
              label: "Objects",
              data: [],
              backgroundColor: [],
            },
          ],
        },
        options: {
          title: {
            text: "Anzahl der Objekte in den Repositorien",
            display: true,
          },
          legend: {
            display: false,
          },
          plugins: {
            datalabels: {
              anchor: "bottom",
              align: "bottom",
              color: "black",
              formatter: (value) => {
                return new Intl.NumberFormat("de-DE").format(value);
              },
            },
          },
        },
      },
      chartSrc: "",
    };
  },
  mixins: [commonChart],
  computed: {},
  methods: {
    exportChart() {
      this.generateChartUrl(this.chartConfig, null, this.width);
    },
    getChartSrc() {
      this.chartSrc = this.generateChartSrc(
        this.chartConfig,
        null,
        null,
        this.width
      );
      this.$store.dispatch(
        "setCharts",
        this.generateChartSrc(this.chartConfig, null, true, this.width)
      );
    },
    populateData() {
      let phiadraCount = 0;
      for (let key of this.phaidraData) {
        if (
          key.model !== "LaTeXDocument" &&
          key.model !== "Zombie" &&
          key.model !== "Paper" &&
          key.model !== "Page"
        ) {
          phiadraCount = phiadraCount + key.obj_count;
        }
      }

      let unidamCount = 0;
      for (let key of this.unidamData.time_row) {
        unidamCount = unidamCount + key.obj_count;
      }

      let localPhaidraCount = 0;
      if (this.localPhaidraData && this.localPhaidraData.length) {
        for (let key of this.localPhaidraData) {
          if (
            key.model !== "LaTeXDocument" &&
            key.model !== "Zombie" &&
            key.model !== "Paper" &&
            key.model !== "Page"
          ) {
            if (key.obj_count) {
              localPhaidraCount = localPhaidraCount + key.obj_count;
            } else if (key.count) {
              localPhaidraCount = localPhaidraCount + key.count;
            }
          }
        }

        this.width = 580;
        this.chartConfig.data.datasets[0].data = [
          phiadraCount,
          localPhaidraCount,
          unidamCount,
        ];
        this.chartConfig.data.datasets[0].backgroundColor = [
          "rgb(1,92,162)",
          "rgb(143, 192, 72)",
          "rgb(243, 167, 29)",
        ];
        this.chartConfig.data.labels = [
          "Phaidra LZA",
          "Phaidra Local",
          "Unidam",
        ];
      } else {
        this.width = 550;
        this.chartConfig.data.datasets[0].data = [phiadraCount, unidamCount];
        this.chartConfig.data.datasets[0].backgroundColor = [
          "rgb(1,92,162)",
          "rgb(243, 167, 29)",
        ];
        this.chartConfig.data.labels = ["Phaidra LZA", "Unidam"];
      }
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
