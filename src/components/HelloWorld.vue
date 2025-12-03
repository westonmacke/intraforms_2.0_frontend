<template>
  <v-card>
    <v-card-title>{{ title }}</v-card-title>
    <v-card-text>
      <p>{{ message }}</p>
      <v-btn color="primary" @click="count++">
        Count: {{ count }}
      </v-btn>
    </v-card-text>
  </v-card>
</template>

<script setup>
import { ref } from 'vue'

const props = defineProps({
  title: {
    type: String,
    default: 'Hello World'
  },
  message: {
    type: String,
    default: 'Welcome to your Vue.js App'
  }
})

const count = ref(0)
</script>

<style scoped>
</style>
