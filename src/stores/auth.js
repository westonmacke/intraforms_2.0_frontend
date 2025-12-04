import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import api from '@/services/api'

export const useAuthStore = defineStore('auth', () => {
  // State
  const token = ref(localStorage.getItem('token') || null)
  const user = ref(JSON.parse(localStorage.getItem('user') || 'null'))
  const permissions = ref(JSON.parse(localStorage.getItem('permissions') || '[]'))
  const roles = ref(JSON.parse(localStorage.getItem('roles') || '[]'))

  // Getters
  const isAuthenticated = computed(() => !!token.value)
  const userName = computed(() => {
    if (!user.value) return ''
    const firstName = user.value.First_Name || user.value.first_name || ''
    const lastName = user.value.Last_Name || user.value.last_name || ''
    return `${firstName} ${lastName}`.trim()
  })
  const userEmail = computed(() => user.value?.Email || user.value?.email || '')
  const userRoles = computed(() => roles.value.map(r => r.Name || r.name).join(', '))

  // Actions
  const setAuthData = (authData) => {
    token.value = authData.token
    user.value = authData.user
    permissions.value = authData.permissions || []
    roles.value = authData.roles || []

    // Persist to localStorage
    localStorage.setItem('token', authData.token)
    localStorage.setItem('user', JSON.stringify(authData.user))
    localStorage.setItem('permissions', JSON.stringify(authData.permissions || []))
    localStorage.setItem('roles', JSON.stringify(authData.roles || []))
  }

  const login = async (credentials) => {
    try {
      const response = await api.post('/auth/login', credentials)
      setAuthData(response.data)
      return { success: true }
    } catch (error) {
      return { 
        success: false, 
        message: error.response?.data?.message || 'Login failed' 
      }
    }
  }

  const logout = () => {
    token.value = null
    user.value = null
    permissions.value = []
    roles.value = []

    // Clear localStorage
    localStorage.removeItem('token')
    localStorage.removeItem('user')
    localStorage.removeItem('permissions')
    localStorage.removeItem('roles')

    // Optionally call backend to invalidate token
    // api.post('/auth/logout')
  }

  const refreshToken = async () => {
    try {
      const response = await api.post('/auth/refresh')
      setAuthData(response.data)
      return true
    } catch (error) {
      logout()
      return false
    }
  }

  const hasPermission = (permissionName) => {
    return permissions.value.some(p => p.name === permissionName)
  }

  const hasRole = (roleName) => {
    return roles.value.some(r => r.name === roleName)
  }

  const hasAnyPermission = (permissionNames) => {
    return permissionNames.some(p => hasPermission(p))
  }

  const hasAllPermissions = (permissionNames) => {
    return permissionNames.every(p => hasPermission(p))
  }

  return {
    // State
    token,
    user,
    permissions,
    roles,
    // Getters
    isAuthenticated,
    userName,
    userEmail,
    userRoles,
    // Actions
    login,
    logout,
    refreshToken,
    setAuthData,
    hasPermission,
    hasRole,
    hasAnyPermission,
    hasAllPermissions
  }
})
