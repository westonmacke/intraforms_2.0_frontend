import { defineStore } from 'pinia'
import { ref } from 'vue'

export const useWidgetSettingsStore = defineStore('widgetSettings', () => {
  // State - stores widget visibility configuration
  const widgetSettings = ref(JSON.parse(localStorage.getItem('widgetSettings') || '{}'))

  // Save widget settings
  const saveSettings = (widgetId, settings) => {
    widgetSettings.value[widgetId] = settings
    localStorage.setItem('widgetSettings', JSON.stringify(widgetSettings.value))
    // TODO: Also save to backend API
  }

  // Get settings for a specific widget
  const getSettings = (widgetId) => {
    return widgetSettings.value[widgetId] || null
  }

  // Check if a widget is visible for the current user
  const isWidgetVisible = (widgetId, userRole, userDepartment) => {
    const settings = getSettings(widgetId)
    
    // If no settings exist or visibleToAll is true, show the widget
    if (!settings || settings.visibleToAll) {
      return true
    }

    // Check if user's role is in the allowed roles
    const hasRole = settings.roles && settings.roles.length > 0
      ? settings.roles.some(roleId => {
          // Compare role IDs or role names
          return roleId === userRole || roleId.toString() === userRole.toString()
        })
      : false // If no roles specified, role check fails

    // Check if user's department is in the allowed departments
    const hasDepartment = settings.departments && settings.departments.length > 0
      ? settings.departments.some(deptId => {
          return deptId === userDepartment || deptId.toString() === userDepartment.toString()
        })
      : false // If no departments specified, department check fails

    // Show widget if user matches ANY role OR ANY department (OR logic)
    return hasRole || hasDepartment
  }

  // Clear all settings
  const clearAllSettings = () => {
    widgetSettings.value = {}
    localStorage.removeItem('widgetSettings')
  }

  return {
    widgetSettings,
    saveSettings,
    getSettings,
    isWidgetVisible,
    clearAllSettings
  }
})
