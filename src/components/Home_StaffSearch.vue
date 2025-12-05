<template>
  <v-card>
    <v-card-title class="bg-grey-lighten-4 d-flex align-center pe-2">
      <v-icon icon="mdi-account-group" class="me-2"></v-icon>
      Staff Directory
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
      widget-name="Staff Directory"
      widget-id="home_staff_search"
      @save="saveWidgetSettings"
    />

    <v-divider></v-divider>

    <v-card-text class="pa-0">
      <v-text-field
        v-model="search"
        density="compact"
        placeholder="Search staff..."
        prepend-inner-icon="mdi-magnify"
        variant="solo"
        flat
        hide-details
        single-line
        class="ma-2"
      ></v-text-field>

      <v-divider></v-divider>

      <v-list
        density="compact"
        class="staff-list"
      >
        <v-list-item
          v-for="(staff, index) in filteredStaff"
          :key="index"
          :prepend-avatar="staff.avatar"
          :title="staff.name"
          :subtitle="staff.position"
        >
          <template v-slot:append>
            <v-btn
              icon="mdi-phone"
              variant="text"
              size="small"
              density="compact"
            ></v-btn>
            <v-btn
              icon="mdi-email"
              variant="text"
              size="small"
              density="compact"
            ></v-btn>
          </template>
        </v-list-item>
      </v-list>
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

const search = ref('')

const staffMembers = ref([
  {
    name: 'John Smith',
    position: 'Branch Manager - Main Street',
    avatar: 'https://i.pravatar.cc/150?img=12',
    phone: '555-0101',
    email: 'jsmith@ucbbanks.com'
  },
  {
    name: 'Sarah Johnson',
    position: 'Loan Officer - Downtown',
    avatar: 'https://i.pravatar.cc/150?img=47',
    phone: '555-0102',
    email: 'sjohnson@ucbbanks.com'
  },
  {
    name: 'Michael Davis',
    position: 'IT Director',
    avatar: 'https://i.pravatar.cc/150?img=33',
    phone: '555-0103',
    email: 'mdavis@ucbbanks.com'
  },
  {
    name: 'Emily Brown',
    position: 'HR Manager',
    avatar: 'https://i.pravatar.cc/150?img=48',
    phone: '555-0104',
    email: 'ebrown@ucbbanks.com'
  },
  {
    name: 'David Wilson',
    position: 'Senior Teller - West Branch',
    avatar: 'https://i.pravatar.cc/150?img=51',
    phone: '555-0105',
    email: 'dwilson@ucbbanks.com'
  },
  {
    name: 'Jennifer Martinez',
    position: 'Customer Service Rep',
    avatar: 'https://i.pravatar.cc/150?img=36',
    phone: '555-0106',
    email: 'jmartinez@ucbbanks.com'
  },
  {
    name: 'Robert Taylor',
    position: 'Compliance Officer',
    avatar: 'https://i.pravatar.cc/150?img=68',
    phone: '555-0107',
    email: 'rtaylor@ucbbanks.com'
  },
  {
    name: 'Lisa Anderson',
    position: 'Marketing Director',
    avatar: 'https://i.pravatar.cc/150?img=41',
    phone: '555-0108',
    email: 'landerson@ucbbanks.com'
  },
  {
    name: 'James Thomas',
    position: 'Operations Manager',
    avatar: 'https://i.pravatar.cc/150?img=15',
    phone: '555-0109',
    email: 'jthomas@ucbbanks.com'
  },
  {
    name: 'Patricia Garcia',
    position: 'Personal Banker',
    avatar: 'https://i.pravatar.cc/150?img=24',
    phone: '555-0110',
    email: 'pgarcia@ucbbanks.com'
  }
])

const filteredStaff = computed(() => {
  if (!search.value) {
    return staffMembers.value
  }
  const searchLower = search.value.toLowerCase()
  return staffMembers.value.filter(staff =>
    staff.name.toLowerCase().includes(searchLower) ||
    staff.position.toLowerCase().includes(searchLower)
  )
})
</script>

<style scoped>
.staff-list {
  max-height: 400px;
  overflow-y: auto;
}
</style>
