<template>
  <v-card elevation="2" class="mb-4">
    <v-card-title class="bg-grey-lighten-4 d-flex align-center">
      <v-icon class="mr-2">mdi-server-network</v-icon>
      Systems Status
      <v-spacer></v-spacer>
      <v-btn
        v-if="isSystemAdmin"
        icon="mdi-pencil"
        variant="text"
        size="small"
        density="compact"
        @click="showEditDialog = true"
        class="mr-1"
      ></v-btn>
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
      widget-name="Systems Status"
      widget-id="home_systems_status"
      @save="saveWidgetSettings"
    />
    
    <!-- Edit Systems Status Dialog -->
    <v-dialog v-model="showEditDialog" max-width="700px">
      <v-card>
        <v-card-title class="bg-grey-lighten-4">
          <v-icon class="mr-2">mdi-pencil</v-icon>
          Edit Systems Status
        </v-card-title>

        <v-card-text class="pt-4">
          <v-alert type="info" density="compact" class="mb-4">
            Manually update system status until automation is implemented.
          </v-alert>

          <v-list>
            <v-list-item
              v-for="(system, index) in systems"
              :key="index"
              class="px-0 mb-3"
            >
              <v-row align="center">
                <v-col cols="5">
                  <div class="text-subtitle-2 font-weight-bold">{{ system.name }}</div>
                </v-col>
                <v-col cols="4">
                  <v-select
                    v-model="system.status"
                    :items="statusOptions"
                    variant="outlined"
                    density="compact"
                    hide-details
                  ></v-select>
                </v-col>
                <v-col cols="3">
                  <v-chip
                    :color="getStatusColor(system.status)"
                    size="small"
                    variant="flat"
                  >
                    {{ system.status }}
                  </v-chip>
                </v-col>
              </v-row>
            </v-list-item>
          </v-list>

          <v-divider class="my-4"></v-divider>

          <div class="mb-3">
            <label class="text-subtitle-2 font-weight-bold d-block mb-2">Scheduled Maintenance</label>
            <v-checkbox
              v-model="maintenanceScheduled"
              label="Show maintenance notification"
              density="compact"
              hide-details
              class="mb-2"
            ></v-checkbox>
            <v-textarea
              v-if="maintenanceScheduled"
              v-model="maintenanceMessage"
              label="Maintenance Message"
              variant="outlined"
              density="compact"
              rows="2"
              hide-details
            ></v-textarea>
          </div>
        </v-card-text>

        <v-card-actions>
          <v-spacer></v-spacer>
          <v-btn variant="text" @click="cancelEdit">Cancel</v-btn>
          <v-btn color="primary" variant="flat" @click="saveSystemStatus">Save Changes</v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>

    <v-card-text class="pa-3">
      <v-list density="compact" class="py-0">
        <v-list-item
          v-for="(system, index) in systems"
          :key="index"
          class="px-0 mb-1"
        >
          <template v-slot:prepend>
            <v-icon 
              :color="getStatusColor(system.status)"
              size="small"
            >
              {{ getStatusIcon(system.status) }}
            </v-icon>
          </template>
          
          <v-list-item-title class="text-body-2">
            {{ system.name }}
          </v-list-item-title>
          
          <template v-slot:append>
            <v-chip
              :color="getStatusColor(system.status)"
              size="x-small"
              variant="flat"
            >
              {{ system.status }}
            </v-chip>
          </template>
        </v-list-item>
      </v-list>

      <v-divider class="my-3"></v-divider>

      <!-- Maintenance Notice -->
      <v-alert
        v-if="maintenanceScheduled"
        type="warning"
        density="compact"
        variant="tonal"
        class="text-caption"
      >
        <template v-slot:prepend>
          <v-icon size="small">mdi-wrench</v-icon>
        </template>
        <strong>Scheduled Maintenance:</strong><br>
        {{ maintenanceMessage }}
      </v-alert>

      <!-- All Systems Operational -->
      <v-alert
        v-else-if="allSystemsOperational"
        type="success"
        density="compact"
        variant="tonal"
        class="text-caption"
      >
        <template v-slot:prepend>
          <v-icon size="small">mdi-check-circle</v-icon>
        </template>
        All systems operational
      </v-alert>
    </v-card-text>
  </v-card>
</template>

<script setup>
import { ref, computed } from 'vue'
import { useAuthStore } from '@/stores/auth'
import WidgetSettingsDialog from './WidgetSettingsDialog.vue'

const authStore = useAuthStore()
const showSettings = ref(false)
const showEditDialog = ref(false)

const isSystemAdmin = computed(() => {
  return authStore.userRole === 'Super Admin'
})

const saveWidgetSettings = (settings) => {
  console.log('Widget settings saved:', settings)
  // TODO: Save to API
}

const statusOptions = ['Operational', 'Degraded', 'Down']

// Mock system status data
const systems = ref([
  {
    name: 'Core Banking System',
    status: 'Operational',
    uptime: '99.9%'
  },
  {
    name: 'Online Banking Portal',
    status: 'Operational',
    uptime: '99.8%'
  },
  {
    name: 'Mobile App API',
    status: 'Operational',
    uptime: '99.7%'
  },
  {
    name: 'Email Services',
    status: 'Operational',
    uptime: '100%'
  },
  {
    name: 'Document Management',
    status: 'Operational',
    uptime: '99.5%'
  },
  {
    name: 'Intranet Portal',
    status: 'Operational',
    uptime: '99.9%'
  }
])

const maintenanceScheduled = ref(false)
const maintenanceMessage = ref('Network upgrade on Dec 15, 2:00 AM - 4:00 AM EST')

// Store original values for cancel functionality
let originalSystems = JSON.parse(JSON.stringify(systems.value))
let originalMaintenance = maintenanceScheduled.value
let originalMaintenanceMsg = maintenanceMessage.value

const allSystemsOperational = computed(() => {
  return systems.value.every(system => system.status === 'Operational')
})

const cancelEdit = () => {
  // Restore original values
  systems.value = JSON.parse(JSON.stringify(originalSystems))
  maintenanceScheduled.value = originalMaintenance
  maintenanceMessage.value = originalMaintenanceMsg
  showEditDialog.value = false
}

const saveSystemStatus = () => {
  // Update original values
  originalSystems = JSON.parse(JSON.stringify(systems.value))
  originalMaintenance = maintenanceScheduled.value
  originalMaintenanceMsg = maintenanceMessage.value
  
  console.log('System status updated:', {
    systems: systems.value,
    maintenanceScheduled: maintenanceScheduled.value,
    maintenanceMessage: maintenanceMessage.value
  })
  // TODO: Save to API
  showEditDialog.value = false
}

const getStatusColor = (status) => {
  switch (status) {
    case 'Operational':
      return 'success'
    case 'Degraded':
      return 'warning'
    case 'Down':
      return 'error'
    default:
      return 'grey'
  }
}

const getStatusIcon = (status) => {
  switch (status) {
    case 'Operational':
      return 'mdi-check-circle'
    case 'Degraded':
      return 'mdi-alert'
    case 'Down':
      return 'mdi-close-circle'
    default:
      return 'mdi-help-circle'
  }
}
</script>

<style scoped>
.v-list-item {
  min-height: 36px;
}
</style>
