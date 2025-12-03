<template>
  <v-app>
    <v-app-bar app color="primary" dark>
      <v-app-bar-title>Intraforms</v-app-bar-title>
      <v-spacer></v-spacer>
      <v-btn icon to="/">
        <v-icon>mdi-home</v-icon>
      </v-btn>
    </v-app-bar>

    <v-main>
      <router-view />
    </v-main>
  </v-app>
</template>

<script setup>
// Main App Component
</script>

<style scoped>
</style>
