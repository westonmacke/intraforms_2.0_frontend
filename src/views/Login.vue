<template>
  <v-container fluid class="fill-height login-container">
    <v-row align="center" justify="center">
      <v-col cols="12" sm="8" md="5" lg="4">
        <v-card elevation="12" class="pa-4">
          <v-card-title class="text-center text-h4 mb-4">
            <v-icon size="48" color="primary" class="mr-2">mdi-file-document-multiple</v-icon>
            <div>Intraforms</div>
          </v-card-title>

          <v-card-subtitle class="text-center mb-4">
            Sign in to your account
          </v-card-subtitle>

          <v-card-text>
            <v-form ref="loginForm" v-model="valid" @submit.prevent="handleLogin">
              <v-text-field
                v-model="username"
                label="Username"
                prepend-inner-icon="mdi-account"
                :rules="usernameRules"
                variant="outlined"
                required
                autofocus
                class="mb-2"
              ></v-text-field>

              <v-text-field
                v-model="password"
                label="Password"
                prepend-inner-icon="mdi-lock"
                :append-inner-icon="showPassword ? 'mdi-eye' : 'mdi-eye-off'"
                :type="showPassword ? 'text' : 'password'"
                :rules="passwordRules"
                variant="outlined"
                required
                @click:append-inner="showPassword = !showPassword"
                class="mb-2"
              ></v-text-field>

              <v-checkbox
                v-model="rememberMe"
                label="Remember me"
                color="primary"
                hide-details
                class="mb-4"
              ></v-checkbox>

              <v-alert
                v-if="errorMessage"
                type="error"
                variant="tonal"
                closable
                class="mb-4"
                @click:close="errorMessage = ''"
              >
                {{ errorMessage }}
              </v-alert>

              <v-btn
                type="submit"
                color="primary"
                size="large"
                block
                :loading="loading"
                :disabled="!valid"
              >
                Sign In
              </v-btn>
            </v-form>
          </v-card-text>

          <v-divider class="my-4"></v-divider>

          <v-card-text class="text-center">
            <p class="text-caption text-medium-emphasis">
              Test Accounts (Password: Admin123!)
            </p>
            <v-chip
              size="small"
              class="ma-1"
              @click="fillCredentials('admin')"
            >
              admin
            </v-chip>
            <v-chip
              size="small"
              class="ma-1"
              @click="fillCredentials('formadmin')"
            >
              formadmin
            </v-chip>
            <v-chip
              size="small"
              class="ma-1"
              @click="fillCredentials('creator')"
            >
              creator
            </v-chip>
            <v-chip
              size="small"
              class="ma-1"
              @click="fillCredentials('viewer')"
            >
              viewer
            </v-chip>
          </v-card-text>
        </v-card>
      </v-col>
    </v-row>
  </v-container>
</template>

<script setup>
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'

const router = useRouter()
const authStore = useAuthStore()

// Form state
const valid = ref(false)
const username = ref('')
const password = ref('')
const showPassword = ref(false)
const rememberMe = ref(false)
const loading = ref(false)
const errorMessage = ref('')
const loginForm = ref(null)

// Validation rules
const usernameRules = [
  v => !!v || 'Username is required',
  v => v.length >= 3 || 'Username must be at least 3 characters'
]

const passwordRules = [
  v => !!v || 'Password is required',
  v => v.length >= 6 || 'Password must be at least 6 characters'
]

// Handle login
const handleLogin = async () => {
  if (!valid.value) return

  loading.value = true
  errorMessage.value = ''

  try {
    const result = await authStore.login({
      username: username.value,
      password: password.value
    })

    if (result.success) {
      // Redirect to home or intended route
      const redirect = router.currentRoute.value.query.redirect || '/'
      router.push(redirect)
    } else {
      errorMessage.value = result.message || 'Login failed. Please check your credentials.'
    }
  } catch (error) {
    errorMessage.value = 'An error occurred during login. Please try again.'
    console.error('Login error:', error)
  } finally {
    loading.value = false
  }
}

// Quick fill credentials for testing
const fillCredentials = (user) => {
  username.value = user
  password.value = 'Admin123!'
}
</script>

<style scoped>
.login-container {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  min-height: 100vh;
}

.v-card {
  border-radius: 12px;
}
</style>
