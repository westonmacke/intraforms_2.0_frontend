<template>
  <v-navigation-drawer
    expand-on-hover
    rail
    location="right"
  >
    <v-list>
      <v-list-item
        prepend-avatar="https://randomuser.me/api/portraits/men/85.jpg"
        title="John Leider"
      >
        <template v-slot:append>
          <v-btn
            icon="mdi-cog"
            variant="text"
            @click="handleSettings"
          ></v-btn>
        </template>
      </v-list-item>
    </v-list>

    <v-divider></v-divider>

    <v-list density="compact" nav>
      <v-list-item prepend-icon="mdi-file-document-multiple" title="Intraforms" value="intraforms"></v-list-item>
    </v-list>
  </v-navigation-drawer>
</template>

<script setup>
// Main Navigation Drawer Component

const handleSettings = () => {
  // TODO: Setup settings function
  console.log('Settings clicked')
}
</script>

<style scoped>
</style>
