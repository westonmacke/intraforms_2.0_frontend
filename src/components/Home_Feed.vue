<template>
  <v-card class="mb-4" elevation="2">
    <v-card-title class="d-flex align-center py-3">
      <v-avatar :color="post.avatar ? '' : 'primary'" size="40" class="mr-3">
        <v-img v-if="post.avatar" :src="post.avatar"></v-img>
        <span v-else class="text-h6">{{ getInitials(post.author) }}</span>
      </v-avatar>
      <div>
        <div class="text-subtitle-1 font-weight-bold">{{ post.author }}</div>
        <div class="text-caption text-grey">{{ post.department }} • {{ formatTime(post.timestamp) }}</div>
      </div>
      <v-spacer></v-spacer>
      <v-btn icon variant="text" size="small">
        <v-icon>mdi-dots-vertical</v-icon>
      </v-btn>
    </v-card-title>

    <v-card-text>
      <div class="text-body-1 mb-3">{{ post.content }}</div>
      <v-img 
        v-if="post.image" 
        :src="post.image" 
        :aspect-ratio="16/9"
        cover
        class="rounded"
      ></v-img>
    </v-card-text>

    <v-divider></v-divider>

    <v-card-actions class="px-4 py-2">
      <v-btn variant="text" size="small" @click="toggleLike">
        <v-icon :color="post.liked ? 'red' : ''" class="mr-1">
          {{ post.liked ? 'mdi-heart' : 'mdi-heart-outline' }}
        </v-icon>
        {{ post.likes }}
      </v-btn>
      <v-btn variant="text" size="small">
        <v-icon class="mr-1">mdi-comment-outline</v-icon>
        {{ post.comments }}
      </v-btn>
      <v-spacer></v-spacer>
      <v-btn variant="text" size="small">
        <v-icon>mdi-share-variant</v-icon>
      </v-btn>
    </v-card-actions>
  </v-card>
</template>

<script setup>
import { defineProps } from 'vue'

const props = defineProps({
  post: {
    type: Object,
    required: true
  }
})

const getInitials = (name) => {
  return name
    .split(' ')
    .map(n => n[0])
    .join('')
    .toUpperCase()
    .substring(0, 2)
}

const formatTime = (timestamp) => {
  const now = new Date()
  const postTime = new Date(timestamp)
  const diffMs = now - postTime
  const diffMins = Math.floor(diffMs / 60000)
  const diffHours = Math.floor(diffMs / 3600000)
  const diffDays = Math.floor(diffMs / 86400000)

  if (diffMins < 1) return 'Just now'
  if (diffMins < 60) return `${diffMins}m ago`
  if (diffHours < 24) return `${diffHours}h ago`
  if (diffDays < 7) return `${diffDays}d ago`
  return postTime.toLocaleDateString()
}

const toggleLike = () => {
  props.post.liked = !props.post.liked
  props.post.likes += props.post.liked ? 1 : -1
}
</script>

<style scoped>
</style>
