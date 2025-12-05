<template>
  <v-card elevation="2" class="mb-4" height="267" style="display: flex; flex-direction: column;">
    <v-card-title class="bg-grey-lighten-4 py-2 d-flex align-center">
      <v-icon class="mr-2">mdi-bullhorn</v-icon>
      Announcements
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
      widget-name="Announcements"
      widget-id="home_announcements"
      @save="saveWidgetSettings"
    />
    <v-list lines="two" style="flex: 1; overflow: hidden;" density="compact" class="py-0">
      <v-list-item
        v-for="(announcement, index) in announcements.slice(0, 3)"
        :key="index"
        :prepend-icon="announcement.icon"
        class="py-1"
      >
        <v-list-item-title>{{ announcement.title }}</v-list-item-title>
        <v-list-item-subtitle>{{ announcement.date }}</v-list-item-subtitle>
      </v-list-item>
    </v-list>
    <v-card-actions class="justify-end px-3 py-1">
      <v-btn variant="text" color="primary" @click="viewAllAnnouncements">
        View All
        <v-icon>mdi-chevron-right</v-icon>
      </v-btn>
    </v-card-actions>
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

const announcements = ref([
  {
    icon: 'mdi-calendar',
    title: 'Annual Meeting - Dec 15th',
    date: '2 days ago'
  },
  {
    icon: 'mdi-file-document',
    title: 'New Policy Update',
    date: '1 week ago'
  },
  {
    icon: 'mdi-party-popper',
    title: 'Holiday Party - Dec 20th',
    date: '1 week ago'
  }
])

const viewAllAnnouncements = () => {
  // TODO: Navigate to announcements page
  console.log('View all announcements clicked')
}
</script>

<style scoped>
</style>
