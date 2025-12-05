<template>
  <v-card elevation="2" class="mb-4">
    <v-card-title class="bg-grey-lighten-4 d-flex align-center">
      <v-icon class="mr-2">mdi-chart-bar</v-icon>
      Branch DDA
      <v-spacer></v-spacer>
      <v-btn
        v-if="isSystemAdmin"
        icon="mdi-cog"
        variant="text"
        size="small"
        density="compact"
        @click="showSettings = true"
      ></v-btn>
    </v-card-title>
    <WidgetSettingsDialog
      v-model="showSettings"
      widget-name="Branch DDA"
      widget-id="home_dda"
      @save="saveWidgetSettings"
    />
    <v-card-text>
      <canvas ref="chartCanvas"></canvas>
    </v-card-text>
    <v-divider></v-divider>
    <v-card-text class="py-2">
      <v-row dense align="center" justify="center" class="text-center">
        <v-col cols="6">
          <div class="text-caption text-grey">DDA Total</div>
          <div class="text-h6 font-weight-bold" :class="ddaTotal >= 0 ? 'text-success' : 'text-error'">
            {{ ddaTotal >= 0 ? '+' : '' }}{{ ddaTotal }}
          </div>
        </v-col>
        <v-col cols="6">
          <div class="text-caption text-grey">Guardian DDA Total</div>
          <div class="text-h6 font-weight-bold" :class="guardianTotal >= 0 ? 'text-success' : 'text-error'">
            {{ guardianTotal >= 0 ? '+' : '' }}{{ guardianTotal }}
          </div>
        </v-col>
      </v-row>
    </v-card-text>
  </v-card>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { Chart, registerables } from 'chart.js'
import { useAuthStore } from '@/stores/auth'
import WidgetSettingsDialog from './WidgetSettingsDialog.vue'

Chart.register(...registerables)

const authStore = useAuthStore()
const showSettings = ref(false)

const isSystemAdmin = computed(() => {
  return authStore.userRole === 'Super Admin'
})

const saveWidgetSettings = (settings) => {
  console.log('Widget settings saved:', settings)
  // TODO: Save to API
}

const chartCanvas = ref(null)
const ddaData = [45, -12, 38, -8, 22, 31]
const guardianData = [18, 25, -5, 14, -3, 19]

const ddaTotal = computed(() => ddaData.reduce((sum, val) => sum + val, 0))
const guardianTotal = computed(() => guardianData.reduce((sum, val) => sum + val, 0))

onMounted(() => {
  const ctx = chartCanvas.value.getContext('2d')
  
  new Chart(ctx, {
    type: 'bar',
    data: {
      labels: ['Downtown', 'Westside', 'Northgate', 'Southpoint', 'Eastview', 'Midtown'],
      datasets: [
        {
          label: 'DDA',
          data: ddaData,
          backgroundColor: 'rgba(25, 118, 210, 0.8)',
          borderColor: 'rgba(25, 118, 210, 1)',
          borderWidth: 1
        },
        {
          label: 'Guardian DDA',
          data: guardianData,
          backgroundColor: 'rgba(156, 39, 176, 0.8)',
          borderColor: 'rgba(156, 39, 176, 1)',
          borderWidth: 1
        }
      ]
    },
    options: {
      responsive: true,
      maintainAspectRatio: true,
      aspectRatio: 2,
      indexAxis: 'y',
      scales: {
        x: {
          beginAtZero: true,
          display: false,
          grid: {
            display: true,
            drawOnChartArea: true,
            color: function(context) {
              if (context.tick.value === 0) {
                return 'rgba(0, 0, 0, 0.5)';
              }
              return 'transparent';
            },
            lineWidth: function(context) {
              if (context.tick.value === 0) {
                return 2;
              }
              return 0;
            }
          }
        },
        y: {
          grid: {
            display: false
          }
        }
      },
      plugins: {
        legend: {
          display: true,
          position: 'top'
        },
        tooltip: {
          callbacks: {
            label: function(context) {
              const value = context.parsed.x;
              const sign = value >= 0 ? '+' : '';
              return context.dataset.label + ': ' + sign + value + ' accounts';
            }
          }
        },
        datalabels: {
          anchor: 'end',
          align: function(context) {
            return context.dataset.data[context.dataIndex] >= 0 ? 'end' : 'start';
          },
          offset: 4,
          formatter: function(value) {
            const sign = value >= 0 ? '+' : '';
            return sign + value;
          },
          color: '#000',
          font: {
            weight: 'bold',
            size: 10
          }
        }
      }
    },
    plugins: [{
      id: 'customLabels',
      afterDatasetsDraw(chart) {
        const ctx = chart.ctx;
        
        // Draw zero line
        const yAxis = chart.scales.y;
        const xAxis = chart.scales.x;
        const zeroX = xAxis.getPixelForValue(0);
        
        ctx.save();
        ctx.strokeStyle = 'rgba(0, 0, 0, 0.5)';
        ctx.lineWidth = 2;
        ctx.beginPath();
        ctx.moveTo(zeroX, yAxis.top);
        ctx.lineTo(zeroX, yAxis.bottom);
        ctx.stroke();
        ctx.restore();
        
        // Draw labels
        chart.data.datasets.forEach((dataset, datasetIndex) => {
          const meta = chart.getDatasetMeta(datasetIndex);
          meta.data.forEach((bar, index) => {
            const value = dataset.data[index];
            const sign = value >= 0 ? '+' : '';
            const label = sign + value;
            
            ctx.save();
            ctx.font = 'bold 10px sans-serif';
            ctx.fillStyle = '#000';
            ctx.textAlign = value >= 0 ? 'left' : 'right';
            ctx.textBaseline = 'middle';
            
            const xPos = value >= 0 ? bar.x + 4 : bar.x - 4;
            const yPos = bar.y;
            
            ctx.fillText(label, xPos, yPos);
            ctx.restore();
          });
        });
      }
    }]
  })
})
</script>

<style scoped>
</style>
