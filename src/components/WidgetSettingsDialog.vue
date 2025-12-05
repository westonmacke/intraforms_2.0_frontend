<template>
  <v-dialog v-model="dialog" max-width="600px">
    <v-card>
      <v-card-title class="bg-grey-lighten-4">
        <v-icon class="mr-2">mdi-cog</v-icon>
        Widget Visibility Settings
      </v-card-title>

      <v-card-text class="pt-4">
        <v-alert type="info" density="compact" class="mb-4">
          Configure which roles and departments can view this widget.
        </v-alert>

        <div class="mb-4">
          <h3 class="text-subtitle-1 font-weight-bold mb-2">Widget: {{ widgetName }}</h3>
        </div>

        <v-divider class="mb-4"></v-divider>

        <div class="mb-4">
          <label class="text-subtitle-2 font-weight-bold mb-2 d-block">Visible to Roles</label>
          <v-select
            v-model="selectedRoles"
            :items="availableRoles"
            item-title="name"
            item-value="id"
            multiple
            chips
            closable-chips
            variant="outlined"
            density="comfortable"
            placeholder="Select roles that can view this widget"
          ></v-select>
        </div>

        <div>
          <label class="text-subtitle-2 font-weight-bold mb-2 d-block">Visible to Departments</label>
          <v-select
            v-model="selectedDepartments"
            :items="availableDepartments"
            item-title="name"
            item-value="id"
            multiple
            chips
            closable-chips
            variant="outlined"
            density="comfortable"
            placeholder="Select departments that can view this widget"
          ></v-select>
        </div>

        <v-checkbox
          v-model="visibleToAll"
          label="Visible to all users (ignore role/department restrictions)"
          density="compact"
          class="mt-2"
        ></v-checkbox>
      </v-card-text>

      <v-card-actions>
        <v-spacer></v-spacer>
        <v-btn variant="text" @click="close">Cancel</v-btn>
        <v-btn color="primary" variant="flat" @click="save">Save</v-btn>
      </v-card-actions>
    </v-card>
  </v-dialog>
</template>

<script setup>
import { ref, watch } from 'vue'

const props = defineProps({
  modelValue: Boolean,
  widgetName: String,
  widgetId: String
})

const emit = defineEmits(['update:modelValue', 'save'])

const dialog = ref(props.modelValue)
const selectedRoles = ref([])
const selectedDepartments = ref([])
const visibleToAll = ref(true)

// Mock data - these would come from API
const availableRoles = ref([
  { id: 1, name: 'Super Admin' },
  { id: 2, name: 'Form Administrator' },
  { id: 3, name: 'Form Creator' },
  { id: 4, name: 'Form Viewer' }
])

const availableDepartments = ref([
  { id: 1, name: 'IT Department' },
  { id: 2, name: 'HR Department' },
  { id: 3, name: 'Operations' },
  { id: 4, name: 'Finance' },
  { id: 5, name: 'Marketing' },
  { id: 6, name: 'Customer Service' }
])

watch(() => props.modelValue, (newVal) => {
  dialog.value = newVal
})

watch(dialog, (newVal) => {
  emit('update:modelValue', newVal)
})

const close = () => {
  dialog.value = false
}

const save = () => {
  emit('save', {
    widgetId: props.widgetId,
    roles: selectedRoles.value,
    departments: selectedDepartments.value,
    visibleToAll: visibleToAll.value
  })
  close()
}
</script>
