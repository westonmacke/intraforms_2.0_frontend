<template>
  <v-navigation-drawer
    expand-on-hover
    rail
    location="right"
    permanent
  >
    <v-list>
      <v-list-item
        :prepend-avatar="userAvatar"
        :title="authStore.userName || 'User'"
        :subtitle="authStore.userRoles"
      >
        <template v-slot:append>
          <v-menu>
            <template v-slot:activator="{ props }">
              <v-btn
                icon="mdi-cog"
                variant="text"
                v-bind="props"
              ></v-btn>
            </template>
            <v-list>
              <v-list-item @click="handleSettings">
                <v-list-item-title>
                  <v-icon size="small" class="mr-2">mdi-cog</v-icon>
                  Settings
                </v-list-item-title>
              </v-list-item>
              <v-list-item @click="handleProfile">
                <v-list-item-title>
                  <v-icon size="small" class="mr-2">mdi-account</v-icon>
                  Profile
                </v-list-item-title>
              </v-list-item>
              <v-divider></v-divider>
              <v-list-item @click="handleLogout">
                <v-list-item-title class="text-error">
                  <v-icon size="small" class="mr-2">mdi-logout</v-icon>
                  Logout
                </v-list-item-title>
              </v-list-item>
            </v-list>
          </v-menu>
        </template>
      </v-list-item>
      <v-list-item 
        prepend-icon="mdi-logout"
        title="Logout" 
        @click="handleLogout"
        class="text-error"
      ></v-list-item>
    </v-list>

    <v-divider></v-divider>

    <v-list density="compact" nav>
      <v-list-subheader class="text-subtitle-2 font-weight-bold d-flex align-center justify-space-between px-4">
        <span>Quick Links</span>
        <v-btn
          v-if="isSystemAdmin"
          icon="mdi-pencil"
          variant="text"
          size="x-small"
          density="compact"
          @click="showQuickLinksDialog = true"
          class="ml-2"
        ></v-btn>
      </v-list-subheader>

      <v-list-item
        v-for="link in quickLinks"
        :key="link.id"
        :prepend-icon="link.icon"
        :title="link.title"
        :value="link.title.toLowerCase()"
        @click="handleLinkClick(link)"
      ></v-list-item>

      <v-divider class="my-2"></v-divider>

      <v-list-subheader class="text-subtitle-2 font-weight-bold d-flex justify-space-between align-center">
        <span>Department Links</span>
        <v-btn
          v-if="isSystemAdmin"
          icon="mdi-pencil"
          variant="text"
          size="x-small"
          density="compact"
          @click="showDepartmentLinksDialog = true"
          class="ml-2"
        ></v-btn>
      </v-list-subheader>

      <v-list-item
        v-for="link in departmentLinks"
        :key="link.id"
        :prepend-icon="link.icon"
        :title="link.title"
        :value="link.title.toLowerCase()"
        @click="handleLinkClick(link)"
      ></v-list-item>
    </v-list>

    <QuickLinksDialog
      v-model="showQuickLinksDialog"
      @refresh="fetchQuickLinks"
    />
    
    <DepartmentLinksDialog
      v-model="showDepartmentLinksDialog"
      @refresh="fetchDepartmentLinks"
    />
  </v-navigation-drawer>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'
import QuickLinksDialog from './QuickLinksDialog.vue'
import DepartmentLinksDialog from './DepartmentLinksDialog.vue'
import api from '@/services/api'

const router = useRouter()
const authStore = useAuthStore()

const quickLinks = ref([])
const departmentLinks = ref([])
const showQuickLinksDialog = ref(false)
const showDepartmentLinksDialog = ref(false)

const isSystemAdmin = computed(() => {
  return authStore.userRole === 'Super Admin'
})

const fetchQuickLinks = async () => {
  try {
    const response = await api.get('/quicklinks')
    quickLinks.value = response.data.links || []
  } catch (error) {
    console.error('Failed to fetch quick links:', error)
  }
}

const fetchDepartmentLinks = async () => {
  try {
    const response = await api.get('/departmentlinks')
    departmentLinks.value = response.data.links || []
  } catch (error) {
    console.error('Failed to fetch department links:', error)
  }
}

const handleLinkClick = (link) => {
  if (link.linkType === 'external') {
    window.open(link.url, '_blank')
  } else {
    router.push(link.url)
  }
}

onMounted(() => {
  fetchQuickLinks()
  fetchDepartmentLinks()
})

// Generate avatar URL based on user name
const userAvatar = computed(() => {
  if (authStore.user) {
    // Using UI Avatars service for dynamic avatar generation
    const firstName = authStore.user.First_Name || authStore.user.first_name || ''
    const lastName = authStore.user.Last_Name || authStore.user.last_name || ''
    const name = `${firstName}+${lastName}`.trim()
    return `https://ui-avatars.com/api/?name=${name}&background=1976D2&color=fff&size=128`
  }
  return 'https://ui-avatars.com/api/?name=User&background=1976D2&color=fff&size=128'
})

const handleSettings = () => {
  // TODO: Navigate to settings page
  console.log('Settings clicked')
}

const handleProfile = () => {
  // TODO: Navigate to profile page
  console.log('Profile clicked')
}

const handleLogout = () => {
  authStore.logout()
  router.push('/login')
}
</script>

<style scoped>
</style>
