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
      <v-list-item 
        prepend-icon="mdi-file-document-multiple" 
        title="Intraforms" 
        value="intraforms"
        v-if="authStore.hasAnyPermission(['forms.read', 'forms.create'])"
      ></v-list-item>
      
      <v-list-item 
        prepend-icon="mdi-shield-lock" 
        title="Security Administration" 
        value="security"
        @click="router.push('/security')"
        v-if="authStore.hasRole('Super Admin')"
      ></v-list-item>
    </v-list>
  </v-navigation-drawer>
</template>

<script setup>
import { computed } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'

const router = useRouter()
const authStore = useAuthStore()

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
