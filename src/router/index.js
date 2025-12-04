import { createRouter, createWebHistory } from 'vue-router'
import { useAuthStore } from '@/stores/auth'
import Home from '../components/Home.vue'

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    {
      path: '/login',
      name: 'login',
      component: () => import('../views/Login.vue'),
      meta: { 
        requiresAuth: false,
        hideForAuth: true // Hide login page if already authenticated
      }
    },
    {
      path: '/',
      name: 'home',
      component: Home,
      meta: { requiresAuth: true }
    },
    {
      path: '/about',
      name: 'about',
      component: () => import('../views/AboutView.vue'),
      meta: { requiresAuth: true }
    },
    {
      path: '/security',
      name: 'security',
      component: () => import('../views/SecurityAdministration.vue'),
      meta: { 
        requiresAuth: true,
        requiresRole: 'Super Admin'
      }
    }
  ]
})

// Navigation guard
router.beforeEach((to, from, next) => {
  const authStore = useAuthStore()
  const requiresAuth = to.matched.some(record => record.meta.requiresAuth)
  const hideForAuth = to.matched.some(record => record.meta.hideForAuth)
  const isAuthenticated = authStore.isAuthenticated

  // Redirect to home if trying to access login while authenticated
  if (hideForAuth && isAuthenticated) {
    next({ name: 'home' })
    return
  }

  // Redirect to login if route requires auth and user is not authenticated
  if (requiresAuth && !isAuthenticated) {
    next({ 
      name: 'login',
      query: { redirect: to.fullPath } // Save intended destination
    })
    return
  }

  // Check role requirements
  if (to.meta.requiresRole && !authStore.hasRole(to.meta.requiresRole)) {
    next({ name: 'home' })
    return
  }

  next()
})

export default router
