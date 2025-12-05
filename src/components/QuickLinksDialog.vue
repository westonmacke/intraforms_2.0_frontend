<template>
  <v-dialog v-model="dialog" max-width="900px">
    <v-card>
      <v-card-title class="bg-grey-lighten-4">
        <v-icon class="mr-2">mdi-link-variant</v-icon>
        Manage Quick Links
      </v-card-title>

      <v-card-text class="pt-4">
        <v-btn
          color="primary"
          prepend-icon="mdi-plus"
          @click="openAddDialog"
          class="mb-4"
        >
          Add New Link
        </v-btn>

        <v-data-table
          :headers="headers"
          :items="links"
          :loading="loading"
          item-value="id"
          class="elevation-1"
        >
          <template v-slot:item.icon="{ item }">
            <v-icon>{{ item.icon }}</v-icon>
          </template>

          <template v-slot:item.linkType="{ item }">
            <v-chip :color="item.linkType === 'internal' ? 'primary' : 'secondary'" size="small">
              {{ item.linkType }}
            </v-chip>
          </template>

          <template v-slot:item.actions="{ item }">
            <v-btn
              icon="mdi-pencil"
              variant="text"
              size="small"
              @click="openEditDialog(item)"
            ></v-btn>
            <v-btn
              icon="mdi-delete"
              variant="text"
              size="small"
              color="error"
              @click="confirmDelete(item)"
            ></v-btn>
            <v-btn
              icon="mdi-arrow-up"
              variant="text"
              size="small"
              @click="moveUp(item)"
              :disabled="item.orderIndex === 1"
            ></v-btn>
            <v-btn
              icon="mdi-arrow-down"
              variant="text"
              size="small"
              @click="moveDown(item)"
              :disabled="item.orderIndex === links.length"
            ></v-btn>
          </template>
        </v-data-table>
      </v-card-text>

      <v-card-actions>
        <v-spacer></v-spacer>
        <v-btn variant="text" @click="close">Close</v-btn>
      </v-card-actions>
    </v-card>
  </v-dialog>

  <!-- Add/Edit Dialog -->
  <v-dialog v-model="editDialog" max-width="600px">
    <v-card>
      <v-card-title class="bg-grey-lighten-4">
        <v-icon class="mr-2">{{ editingLink.id ? 'mdi-pencil' : 'mdi-plus' }}</v-icon>
        {{ editingLink.id ? 'Edit' : 'Add' }} Quick Link
      </v-card-title>

      <v-card-text class="pt-4">
        <v-text-field
          v-model="editingLink.title"
          label="Link Title"
          variant="outlined"
          density="comfortable"
          :rules="[v => !!v || 'Title is required']"
          class="mb-3"
        ></v-text-field>

        <v-autocomplete
          v-model="editingLink.icon"
          :items="availableIcons"
          label="Material Design Icon"
          variant="outlined"
          density="comfortable"
          hint="Search for an icon or type the name directly"
          persistent-hint
          class="mb-3"
          clearable
        >
          <template v-slot:prepend-inner>
            <v-icon>{{ editingLink.icon || 'mdi-link' }}</v-icon>
          </template>
          <template v-slot:item="{ props, item }">
            <v-list-item v-bind="props">
              <template v-slot:prepend>
                <v-icon>{{ item.value }}</v-icon>
              </template>
            </v-list-item>
          </template>
        </v-autocomplete>

        <v-text-field
          v-model="editingLink.url"
          label="URL"
          variant="outlined"
          density="comfortable"
          :rules="[v => !!v || 'URL is required']"
          hint="Internal: /page-name, External: https://example.com"
          persistent-hint
          class="mb-3"
        ></v-text-field>

        <v-select
          v-model="editingLink.linkType"
          :items="linkTypes"
          label="Link Type"
          variant="outlined"
          density="comfortable"
        ></v-select>
      </v-card-text>

      <v-card-actions>
        <v-spacer></v-spacer>
        <v-btn variant="text" @click="editDialog = false">Cancel</v-btn>
        <v-btn color="primary" variant="flat" @click="saveLink" :loading="saving">Save</v-btn>
      </v-card-actions>
    </v-card>
  </v-dialog>

  <!-- Delete Confirmation Dialog -->
  <v-dialog v-model="deleteDialog" max-width="400px">
    <v-card>
      <v-card-title class="text-h6">Confirm Delete</v-card-title>
      <v-card-text>
        Are you sure you want to delete the link <strong>{{ deletingLink?.title }}</strong>?
      </v-card-text>
      <v-card-actions>
        <v-spacer></v-spacer>
        <v-btn variant="text" @click="deleteDialog = false">Cancel</v-btn>
        <v-btn color="error" variant="flat" @click="deleteLink" :loading="deleting">Delete</v-btn>
      </v-card-actions>
    </v-card>
  </v-dialog>
</template>

<script setup>
import { ref, watch } from 'vue'
import api from '@/services/api'

const props = defineProps({
  modelValue: Boolean
})

const emit = defineEmits(['update:modelValue', 'refresh'])

const dialog = ref(props.modelValue)
const editDialog = ref(false)
const deleteDialog = ref(false)
const loading = ref(false)
const saving = ref(false)
const deleting = ref(false)

const links = ref([])
const editingLink = ref({})
const deletingLink = ref(null)

const headers = [
  { title: 'Order', key: 'orderIndex', width: '80px' },
  { title: 'Icon', key: 'icon', width: '80px', sortable: false },
  { title: 'Title', key: 'title' },
  { title: 'URL', key: 'url' },
  { title: 'Type', key: 'linkType', width: '120px' },
  { title: 'Actions', key: 'actions', width: '200px', sortable: false }
]

const linkTypes = ['internal', 'external']

// Popular Material Design Icons for quick selection
const availableIcons = [
  'mdi-home',
  'mdi-link',
  'mdi-file-document',
  'mdi-folder',
  'mdi-cog',
  'mdi-account',
  'mdi-account-group',
  'mdi-calendar',
  'mdi-clock',
  'mdi-email',
  'mdi-phone',
  'mdi-chart-bar',
  'mdi-chart-line',
  'mdi-database',
  'mdi-server',
  'mdi-cloud',
  'mdi-file-pdf-box',
  'mdi-file-excel',
  'mdi-file-word',
  'mdi-file-powerpoint',
  'mdi-briefcase',
  'mdi-bank',
  'mdi-cash',
  'mdi-credit-card',
  'mdi-cart',
  'mdi-store',
  'mdi-shield-check',
  'mdi-lock',
  'mdi-key',
  'mdi-bell',
  'mdi-message',
  'mdi-forum',
  'mdi-chat',
  'mdi-help-circle',
  'mdi-information',
  'mdi-alert',
  'mdi-check-circle',
  'mdi-star',
  'mdi-heart',
  'mdi-thumbs-up',
  'mdi-bookmark',
  'mdi-flag',
  'mdi-tag',
  'mdi-map-marker',
  'mdi-compass',
  'mdi-earth',
  'mdi-printer',
  'mdi-scanner',
  'mdi-download',
  'mdi-upload',
  'mdi-share',
  'mdi-export',
  'mdi-import',
  'mdi-refresh',
  'mdi-sync',
  'mdi-backup-restore',
  'mdi-tools',
  'mdi-wrench',
  'mdi-hammer',
  'mdi-calculator',
  'mdi-clipboard',
  'mdi-notebook',
  'mdi-book-open',
  'mdi-school',
  'mdi-certificate',
  'mdi-trophy',
  'mdi-medal',
  'mdi-rocket',
  'mdi-lightbulb',
  'mdi-fire',
  'mdi-weather-sunny',
  'mdi-umbrella',
  'mdi-car',
  'mdi-truck',
  'mdi-train',
  'mdi-airplane',
  'mdi-wifi',
  'mdi-bluetooth',
  'mdi-usb',
  'mdi-power',
  'mdi-battery',
  'mdi-desktop-mac',
  'mdi-laptop',
  'mdi-tablet',
  'mdi-cellphone',
  'mdi-monitor',
  'mdi-keyboard',
  'mdi-mouse',
  'mdi-camera',
  'mdi-video',
  'mdi-microphone',
  'mdi-volume-high',
  'mdi-music',
  'mdi-play',
  'mdi-pause',
  'mdi-stop',
  'mdi-magnify',
  'mdi-filter',
  'mdi-sort',
  'mdi-menu',
  'mdi-dots-vertical',
  'mdi-dots-horizontal',
  'mdi-plus',
  'mdi-minus',
  'mdi-close',
  'mdi-check',
  'mdi-arrow-left',
  'mdi-arrow-right',
  'mdi-arrow-up',
  'mdi-arrow-down',
  'mdi-chevron-left',
  'mdi-chevron-right',
  'mdi-chevron-up',
  'mdi-chevron-down'
]

watch(() => props.modelValue, (newVal) => {
  dialog.value = newVal
  if (newVal) {
    fetchLinks()
  }
})

watch(dialog, (newVal) => {
  emit('update:modelValue', newVal)
})

const fetchLinks = async () => {
  loading.value = true
  try {
    const response = await api.get('/quicklinks')
    links.value = response.data.links || []
  } catch (error) {
    console.error('Failed to fetch quick links:', error)
  } finally {
    loading.value = false
  }
}

const openAddDialog = () => {
  editingLink.value = {
    title: '',
    icon: 'mdi-link',
    url: '',
    linkType: 'internal'
  }
  editDialog.value = true
}

const openEditDialog = (link) => {
  editingLink.value = { ...link }
  editDialog.value = true
}

const saveLink = async () => {
  if (!editingLink.value.title || !editingLink.value.url) {
    return
  }

  saving.value = true
  try {
    if (editingLink.value.id) {
      // Update existing link
      await api.put(`/quicklinks/${editingLink.value.id}`, editingLink.value)
    } else {
      // Create new link
      await api.post('/quicklinks', editingLink.value)
    }
    editDialog.value = false
    fetchLinks()
    emit('refresh')
  } catch (error) {
    console.error('Failed to save quick link:', error)
  } finally {
    saving.value = false
  }
}

const confirmDelete = (link) => {
  deletingLink.value = link
  deleteDialog.value = true
}

const deleteLink = async () => {
  if (!deletingLink.value) return

  deleting.value = true
  try {
    await api.delete(`/quicklinks/${deletingLink.value.id}`)
    deleteDialog.value = false
    fetchLinks()
    emit('refresh')
  } catch (error) {
    console.error('Failed to delete quick link:', error)
  } finally {
    deleting.value = false
  }
}

const moveUp = async (link) => {
  const currentIndex = links.value.findIndex(l => l.id === link.id)
  if (currentIndex <= 0) return

  const newLinks = [...links.value]
  ;[newLinks[currentIndex], newLinks[currentIndex - 1]] = [newLinks[currentIndex - 1], newLinks[currentIndex]]
  
  await reorderLinks(newLinks)
}

const moveDown = async (link) => {
  const currentIndex = links.value.findIndex(l => l.id === link.id)
  if (currentIndex >= links.value.length - 1) return

  const newLinks = [...links.value]
  ;[newLinks[currentIndex], newLinks[currentIndex + 1]] = [newLinks[currentIndex + 1], newLinks[currentIndex]]
  
  await reorderLinks(newLinks)
}

const reorderLinks = async (newLinks) => {
  const linkIds = newLinks.map(l => l.id)
  
  try {
    await api.post('/quicklinks/reorder', { linkIds })
    fetchLinks()
    emit('refresh')
  } catch (error) {
    console.error('Failed to reorder links:', error)
  }
}

const close = () => {
  dialog.value = false
}
</script>
