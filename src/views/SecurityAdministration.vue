<template>
  <div>
    <MainNav />
    <v-container fluid>
      <v-row>
        <v-col cols="12">
          <v-card>
          <v-card-title>
            <v-row align="center">
              <v-col cols="auto">
                <v-icon class="mr-2">mdi-shield-lock</v-icon>
                Security Administration
              </v-col>
              <v-spacer></v-spacer>
              <v-col cols="12" sm="6" md="4">
                <v-text-field
                  v-model="search"
                  density="compact"
                  label="Search"
                  prepend-inner-icon="mdi-magnify"
                  variant="outlined"
                  hide-details
                  single-line
                ></v-text-field>
              </v-col>
            </v-row>
          </v-card-title>

          <v-data-table
            :headers="headers"
            :items="users"
            :search="search"
            :loading="loading"
            class="elevation-1"
          >
            <template v-slot:top>
              <v-toolbar flat>
                <v-toolbar-title>Users</v-toolbar-title>
                <v-divider class="mx-4" inset vertical></v-divider>
                <v-spacer></v-spacer>
                <v-dialog v-model="dialog" max-width="500px">
                  <template v-slot:activator="{ props }">
                    <v-btn color="primary" dark v-bind="props">
                      <v-icon left>mdi-plus</v-icon>
                      New User
                    </v-btn>
                  </template>
                  <v-card>
                    <v-card-title>
                      <span class="text-h5">{{ formTitle }}</span>
                    </v-card-title>

                    <v-card-text>
                      <v-container>
                        <v-row>
                          <v-col cols="12" sm="6">
                            <v-text-field
                              v-model="editedItem.username"
                              label="Username"
                              :disabled="editedIndex !== -1"
                            ></v-text-field>
                          </v-col>
                          <v-col cols="12" sm="6">
                            <v-text-field
                              v-model="editedItem.email"
                              label="Email"
                              type="email"
                            ></v-text-field>
                          </v-col>
                          <v-col cols="12" sm="6">
                            <v-text-field
                              v-model="editedItem.first_name"
                              label="First Name"
                            ></v-text-field>
                          </v-col>
                          <v-col cols="12" sm="6">
                            <v-text-field
                              v-model="editedItem.last_name"
                              label="Last Name"
                            ></v-text-field>
                          </v-col>
                          <v-col cols="12" v-if="editedIndex === -1">
                            <v-text-field
                              v-model="editedItem.password"
                              label="Password"
                              type="password"
                            ></v-text-field>
                          </v-col>
                          <v-col cols="12">
                            <v-select
                              v-model="editedItem.selectedRoles"
                              :items="availableRoles"
                              item-title="name"
                              item-value="id"
                              label="Roles"
                              multiple
                              chips
                              closable-chips
                            ></v-select>
                          </v-col>
                          <v-col cols="12">
                            <v-switch
                              v-model="editedItem.active"
                              label="Active"
                              color="primary"
                            ></v-switch>
                          </v-col>
                        </v-row>
                      </v-container>
                    </v-card-text>

                    <v-card-actions>
                      <v-spacer></v-spacer>
                      <v-btn color="blue-darken-1" variant="text" @click="close">
                        Cancel
                      </v-btn>
                      <v-btn color="blue-darken-1" variant="text" @click="save">
                        Save
                      </v-btn>
                    </v-card-actions>
                  </v-card>
                </v-dialog>
                <v-dialog v-model="dialogDelete" max-width="500px">
                  <v-card>
                    <v-card-title class="text-h5">Are you sure you want to delete this user?</v-card-title>
                    <v-card-actions>
                      <v-spacer></v-spacer>
                      <v-btn color="blue-darken-1" variant="text" @click="closeDelete">Cancel</v-btn>
                      <v-btn color="blue-darken-1" variant="text" @click="deleteItemConfirm">OK</v-btn>
                      <v-spacer></v-spacer>
                    </v-card-actions>
                  </v-card>
                </v-dialog>
              </v-toolbar>
            </template>

            <template v-slot:item.active="{ item }">
              <v-chip :color="item.active ? 'green' : 'red'" dark small>
                {{ item.active ? 'Active' : 'Inactive' }}
              </v-chip>
            </template>

            <template v-slot:item.roles="{ item }">
              {{ item.roles || '' }}
            </template>

            <template v-slot:item.actions="{ item }">
              <v-icon size="small" class="me-2" @click="editItem(item)">
                mdi-pencil
              </v-icon>
              <v-icon size="small" @click="deleteItem(item)">
                mdi-delete
              </v-icon>
            </template>

            <template v-slot:no-data>
              <v-btn color="primary" @click="initialize">
                Reset
              </v-btn>
            </template>
          </v-data-table>
        </v-card>
      </v-col>
    </v-row>
  </v-container>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, watch, nextTick } from 'vue'
import api from '@/services/api'
import MainNav from '@/components/MainNav.vue'

const dialog = ref(false)
const dialogDelete = ref(false)
const search = ref('')
const loading = ref(false)
const headers = [
  { title: 'Username', key: 'username', align: 'start' },
  { title: 'Email', key: 'email' },
  { title: 'First Name', key: 'first_name' },
  { title: 'Last Name', key: 'last_name' },
  { title: 'Roles', key: 'roles', sortable: false },
  { title: 'Status', key: 'active' },
  { title: 'Actions', key: 'actions', sortable: false }
]

const users = ref([])
const availableRoles = ref([])
const editedIndex = ref(-1)
const editedItem = ref({
  id: 0,
  username: '',
  email: '',
  first_name: '',
  last_name: '',
  password: '',
  active: true,
  roles: [],
  selectedRoles: []
})

const defaultItem = {
  id: 0,
  username: '',
  email: '',
  first_name: '',
  last_name: '',
  password: '',
  active: true,
  roles: [],
  selectedRoles: []
}

const formTitle = computed(() => {
  return editedIndex.value === -1 ? 'New User' : 'Edit User'
})

watch(dialog, (val) => {
  val || close()
})

watch(dialogDelete, (val) => {
  val || closeDelete()
})

onMounted(() => {
  initialize()
  fetchRoles()
})

async function initialize() {
  loading.value = true
  try {
    const response = await api.get('/users')
    console.log('Full API Response:', response)
    console.log('Response data:', response.data)
    users.value = response.data.users || response.data || []
    console.log('Users array:', users.value)
    console.log('First user roles:', users.value[0]?.roles)
  } catch (error) {
    console.error('Failed to load users:', error)
  } finally {
    loading.value = false
  }
}

async function fetchRoles() {
  try {
    const response = await api.get('/roles')
    availableRoles.value = response.data.roles || response.data || []
  } catch (error) {
    console.error('Failed to load roles:', error)
  }
}

async function editItem(item) {
  editedIndex.value = users.value.indexOf(item)
  
  // Fetch full user details including role IDs
  try {
    const response = await api.get(`/users/${item.id}`)
    const userData = response.data.data || response.data
    
    editedItem.value = {
      ...item,
      selectedRoles: userData.roles?.map(r => r.id || r.Id) || []
    }
  } catch (error) {
    console.error('Failed to load user details:', error)
    editedItem.value = Object.assign({}, item, { selectedRoles: [] })
  }
  
  dialog.value = true
}

function deleteItem(item) {
  editedIndex.value = users.value.indexOf(item)
  editedItem.value = Object.assign({}, item)
  dialogDelete.value = true
}

async function deleteItemConfirm() {
  try {
    await api.delete(`/users/${editedItem.value.id}`)
    users.value.splice(editedIndex.value, 1)
  } catch (error) {
    console.error('Failed to delete user:', error)
  }
  closeDelete()
}

function close() {
  dialog.value = false
  nextTick(() => {
    editedItem.value = Object.assign({}, defaultItem)
    editedIndex.value = -1
  })
}

function closeDelete() {
  dialogDelete.value = false
  nextTick(() => {
    editedItem.value = Object.assign({}, defaultItem)
    editedIndex.value = -1
  })
}

async function save() {
  try {
    if (editedIndex.value > -1) {
      // Update existing user
      const response = await api.put(`/users/${editedItem.value.id}`, editedItem.value)
      Object.assign(users.value[editedIndex.value], response.data)
    } else {
      // Create new user
      const response = await api.post('/users', editedItem.value)
      users.value.push(response.data)
    }
  } catch (error) {
    console.error('Failed to save user:', error)
  }
  close()
}

function getRoleColor(roleName) {
  const colors = {
    'Super Admin': 'red-darken-2',
    'Form Administrator': 'purple',
    'Form Creator': 'blue',
    'Form Viewer': 'teal',
    'Basic User': 'grey'
  }
  return colors[roleName] || 'primary'
}
</script>

<style scoped>
</style>
