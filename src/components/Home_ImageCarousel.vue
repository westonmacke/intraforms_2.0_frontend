<template>
  <v-card elevation="2" class="mb-4">
    <v-carousel
      height="267"
      cycle
      hide-delimiter-background
      show-arrows="hover"
    >
      <v-carousel-item
        v-for="(slide, index) in slides"
        :key="index"
        :src="slide.image"
        cover
      >
        <div class="carousel-overlay d-flex align-end">
          <v-container>
            <v-row>
              <v-col cols="12">
                <h2 class="text-h4 text-white mb-2">{{ slide.title }}</h2>
                <p class="text-subtitle-1 text-white">{{ slide.description }}</p>
              </v-col>
            </v-row>
          </v-container>
        </div>
      </v-carousel-item>
    </v-carousel>
  </v-card>
</template>

<script setup>
import { ref } from 'vue'

const slides = ref([
  {
    image: 'https://images.unsplash.com/photo-1497366216548-37526070297c?w=1200&h=400&fit=crop',
    title: 'Welcome to Our Intranet',
    description: 'Stay connected with your team and access important resources'
  },
  {
    image: 'https://images.unsplash.com/photo-1522071820081-009f0129c71c?w=1200&h=400&fit=crop',
    title: 'Team Collaboration',
    description: 'Work together and achieve great things'
  },
  {
    image: 'https://images.unsplash.com/photo-1517245386807-bb43f82c33c4?w=1200&h=400&fit=crop',
    title: 'Innovation & Growth',
    description: 'Empowering our team to build the future'
  }
])
</script>

<style scoped>
.carousel-overlay {
  background: linear-gradient(to top, rgba(0,0,0,0.7) 0%, rgba(0,0,0,0.3) 50%, transparent 100%);
  height: 100%;
}
</style>
