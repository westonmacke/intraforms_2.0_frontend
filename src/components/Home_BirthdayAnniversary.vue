<template>
  <v-card elevation="2" class="mb-4">
    <v-card-title class="bg-grey-lighten-4">
      <v-icon class="mr-2">mdi-cake-variant</v-icon>
      Birthdays & Anniversaries
    </v-card-title>
    
    <!-- Birthdays Section -->
    <div class="pa-3">
      <div class="text-subtitle-2 font-weight-bold mb-2">Birthdays This Week</div>
      <v-list density="compact" class="py-0">
        <v-list-item
          v-for="(birthday, index) in birthdays"
          :key="index"
          class="px-0"
        >
          <template v-slot:prepend>
            <v-avatar color="pink-lighten-4" size="32">
              <v-icon color="pink">mdi-cake</v-icon>
            </v-avatar>
          </template>
          <v-list-item-title class="text-body-2">{{ birthday.name }}</v-list-item-title>
          <v-list-item-subtitle class="text-caption">{{ birthday.date }}</v-list-item-subtitle>
        </v-list-item>
      </v-list>
    </div>

    <v-divider></v-divider>

    <!-- Anniversaries Section -->
    <div class="pa-3">
      <div class="text-subtitle-2 font-weight-bold mb-2">Work Anniversaries</div>
      <v-list density="compact" class="py-0">
        <v-list-item
          v-for="(anniversary, index) in anniversaries"
          :key="index"
          class="px-0"
        >
          <template v-slot:prepend>
            <v-avatar color="blue-lighten-4" size="32">
              <v-icon color="blue">mdi-briefcase</v-icon>
            </v-avatar>
          </template>
          <v-list-item-title class="text-body-2">{{ anniversary.name }}</v-list-item-title>
          <v-list-item-subtitle class="text-caption">{{ anniversary.years }} years • {{ anniversary.date }}</v-list-item-subtitle>
        </v-list-item>
      </v-list>
    </div>
  </v-card>
</template>

<script setup>
import { ref } from 'vue'

const birthdays = ref([
  {
    name: 'Jessica Brown',
    date: 'Dec 5'
  },
  {
    name: 'Michael Chen',
    date: 'Dec 7'
  },
  {
    name: 'Amanda Davis',
    date: 'Dec 9'
  }
])

const anniversaries = ref([
  {
    name: 'Robert Martinez',
    years: 10,
    date: 'Dec 6'
  },
  {
    name: 'Lisa Anderson',
    years: 5,
    date: 'Dec 8'
  }
])
</script>

<style scoped>
</style>
