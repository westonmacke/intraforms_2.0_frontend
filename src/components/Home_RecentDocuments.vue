<template>
  <v-card elevation="2" class="mt-4">
    <v-card-title class="bg-grey-lighten-4 d-flex align-center">
      <v-icon class="mr-2">mdi-file-document-outline</v-icon>
      Recent Documents
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
      widget-name="Recent Documents"
      widget-id="home_recent_documents"
      @save="saveWidgetSettings"
    />

    <v-card-text class="pa-3">
      <v-list density="compact" class="py-0">
        <v-list-item
          v-for="(doc, index) in recentDocuments"
          :key="index"
          class="px-0 mb-2"
          @click="openDocument(doc)"
          style="cursor: pointer;"
        >
          <template v-slot:prepend>
            <v-avatar :color="getFileTypeColor(doc.type)" size="32">
              <v-icon size="small" color="white">
                {{ getFileTypeIcon(doc.type) }}
              </v-icon>
            </v-avatar>
          </template>
          
          <v-list-item-title class="text-body-2 font-weight-medium">
            {{ doc.name }}
          </v-list-item-title>
          
          <v-list-item-subtitle class="text-caption">
            {{ doc.type }} • {{ formatTime(doc.lastAccessed) }}
          </v-list-item-subtitle>

          <template v-slot:append>
            <v-btn
              icon="mdi-open-in-new"
              variant="text"
              size="x-small"
              density="compact"
              @click.stop="openDocument(doc)"
            ></v-btn>
          </template>
        </v-list-item>
      </v-list>

      <v-divider class="my-2"></v-divider>

      <div class="text-center">
        <v-btn
          variant="text"
          color="primary"
          size="small"
          @click="viewAllDocuments"
        >
          View All Documents
          <v-icon size="small" class="ml-1">mdi-chevron-right</v-icon>
        </v-btn>
      </div>
    </v-card-text>
  </v-card>
</template>

<script setup>
import { ref, computed } from 'vue'
import { useAuthStore } from '@/stores/auth'
import WidgetSettingsDialog from './WidgetSettingsDialog.vue'

const authStore = useAuthStore()
const showSettings = ref(false)

const isSystemAdmin = computed(() => {
  return authStore.userRole === 'Super Admin'
})

const saveWidgetSettings = (settings) => {
  console.log('Widget settings saved:', settings)
  // TODO: Save to API
}

// Mock recent documents data
const recentDocuments = ref([
  {
    id: 1,
    name: 'Q4 Financial Report.xlsx',
    type: 'Excel',
    lastAccessed: new Date(Date.now() - 30 * 60 * 1000), // 30 minutes ago
    url: '#'
  },
  {
    id: 2,
    name: 'Employee Handbook 2024.pdf',
    type: 'PDF',
    lastAccessed: new Date(Date.now() - 2 * 60 * 60 * 1000), // 2 hours ago
    url: '#'
  },
  {
    id: 3,
    name: 'Marketing Strategy.pptx',
    type: 'PowerPoint',
    lastAccessed: new Date(Date.now() - 4 * 60 * 60 * 1000), // 4 hours ago
    url: '#'
  },
  {
    id: 4,
    name: 'Project Proposal.docx',
    type: 'Word',
    lastAccessed: new Date(Date.now() - 1 * 24 * 60 * 60 * 1000), // 1 day ago
    url: '#'
  },
  {
    id: 5,
    name: 'Meeting Notes.docx',
    type: 'Word',
    lastAccessed: new Date(Date.now() - 2 * 24 * 60 * 60 * 1000), // 2 days ago
    url: '#'
  }
])

const formatTime = (timestamp) => {
  const now = new Date()
  const docTime = new Date(timestamp)
  const diffMs = now - docTime
  const diffMins = Math.floor(diffMs / 60000)
  const diffHours = Math.floor(diffMs / 3600000)
  const diffDays = Math.floor(diffMs / 86400000)

  if (diffMins < 1) return 'Just now'
  if (diffMins < 60) return `${diffMins}m ago`
  if (diffHours < 24) return `${diffHours}h ago`
  if (diffDays === 1) return 'Yesterday'
  if (diffDays < 7) return `${diffDays} days ago`
  return docTime.toLocaleDateString()
}

const getFileTypeIcon = (type) => {
  switch (type) {
    case 'PDF':
      return 'mdi-file-pdf-box'
    case 'Word':
      return 'mdi-file-word-box'
    case 'Excel':
      return 'mdi-file-excel-box'
    case 'PowerPoint':
      return 'mdi-file-powerpoint-box'
    default:
      return 'mdi-file-document'
  }
}

const getFileTypeColor = (type) => {
  switch (type) {
    case 'PDF':
      return 'red'
    case 'Word':
      return 'blue'
    case 'Excel':
      return 'green'
    case 'PowerPoint':
      return 'orange'
    default:
      return 'grey'
  }
}

const openDocument = (doc) => {
  console.log('Opening document:', doc.name)
  // TODO: Implement document opening logic
  // window.open(doc.url, '_blank')
}

const viewAllDocuments = () => {
  console.log('View all documents')
  // TODO: Navigate to documents page
}
</script>

<style scoped>
.v-list-item:hover {
  background-color: rgba(0, 0, 0, 0.04);
}
</style>
