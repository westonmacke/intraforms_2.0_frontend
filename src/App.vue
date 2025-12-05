<template>
  <v-app>
    <v-app-bar app color="white" elevation="1">
      <v-app-bar-title>
        <img 
          src="https://www.ucbbanks.com/images/logos/small/multi-logo.png" 
          alt="UCB Banks Logo" 
          style="height: 40px; vertical-align: middle;"
        />
      </v-app-bar-title>
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
