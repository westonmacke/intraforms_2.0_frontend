<template>
  <v-card>
    <v-layout>
      <MainNav />

      <v-main style="height: 100vh">
        <v-container fluid>
          <h1>Main Content Area</h1>
          <p>This is where your main content will go.</p>
        </v-container>
      </v-main>
    </v-layout>
  </v-card>
</template>

<script setup>
import MainNav from './MainNav.vue'
</script>

<style scoped>
</style>
