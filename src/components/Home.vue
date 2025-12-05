<template>
  <v-card>
    <v-layout>
      <MainNav />

      <v-main class="bg-grey-lighten-4">
        <v-container fluid class="py-6">
          <!-- Image Carousel and Announcements -->
          <v-row>
            <v-col cols="12" md="9">
              <ImageCarousel />
            </v-col>
            <v-col cols="12" md="3" class="d-none d-md-block">
              <AnnouncementWidget />
            </v-col>
          </v-row>

          <v-row>
            <!-- Left Sidebar -->
            <v-col cols="12" md="3" class="d-none d-md-block">
              <BirthdayAnniversary />
              <StaffSearch class="mt-4" />
            </v-col>

            <!-- Main Feed -->
            <v-col cols="12" md="6">
              <v-card elevation="2">
                <v-card-title class="bg-grey-lighten-4">
                  <v-icon class="mr-2">mdi-post-outline</v-icon>
                  Activity Feed
                </v-card-title>

                <v-card-text class="pa-3">
                  <!-- Create Post Card -->
                  <v-card class="mb-4" elevation="1">
                    <v-card-text>
                      <div class="d-flex align-center">
                        <v-avatar color="primary" size="40" class="mr-3">
                          <span class="text-h6">{{ userInitials }}</span>
                        </v-avatar>
                        <v-text-field
                          v-model="newPostContent"
                          placeholder="What's on your mind?"
                          variant="outlined"
                          density="comfortable"
                          hide-details
                          @click="showPostDialog = true"
                          readonly
                        ></v-text-field>
                      </div>
                    </v-card-text>
                  </v-card>

                  <!-- Posts Feed -->
                  <PostCard
                    v-for="post in posts"
                    :key="post.id"
                    :post="post"
                  />
                </v-card-text>
              </v-card>
            </v-col>
            <!-- Right Sidebar -->
            <v-col cols="12" md="3" class="d-none d-md-block">
              <DDAChart />

              <v-card elevation="2" class="mb-4">
                <v-card-title class="bg-grey-lighten-4">
                  <v-icon class="mr-2">mdi-calendar-today</v-icon>
                  Upcoming Events
                </v-card-title>
                <v-list lines="two">
                  <v-list-item
                    v-for="(event, index) in upcomingEvents"
                    :key="index"
                  >
                    <v-list-item-title>{{ event.title }}</v-list-item-title>
                    <v-list-item-subtitle>{{ event.date }}</v-list-item-subtitle>
                  </v-list-item>
                </v-list>
              </v-card>

              <v-card elevation="2">
                <v-card-title class="bg-grey-lighten-4">
                  <v-icon class="mr-2">mdi-chart-line</v-icon>
                  Quick Stats
                </v-card-title>
                <v-list>
                  <v-list-item>
                    <v-list-item-title class="text-h4 text-primary">142</v-list-item-title>
                    <v-list-item-subtitle>Active Users</v-list-item-subtitle>
                  </v-list-item>
                  <v-list-item>
                    <v-list-item-title class="text-h4 text-success">23</v-list-item-title>
                    <v-list-item-subtitle>New This Week</v-list-item-subtitle>
                  </v-list-item>
                </v-list>
              </v-card>
            </v-col>
          </v-row>
        </v-container>
      </v-main>
    </v-layout>

    <!-- Create Post Dialog -->
    <v-dialog v-model="showPostDialog" max-width="600px">
      <v-card>
        <v-card-title>Create Post</v-card-title>
        <v-card-text>
          <v-textarea
            v-model="newPostContent"
            placeholder="What's on your mind?"
            variant="outlined"
            rows="4"
            auto-grow
          ></v-textarea>
        </v-card-text>
        <v-card-actions>
          <v-spacer></v-spacer>
          <v-btn variant="text" @click="showPostDialog = false">Cancel</v-btn>
          <v-btn color="primary" variant="flat" @click="createPost">Post</v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>
  </v-card>
</template>

<script setup>
import { ref, computed } from 'vue'
import { useAuthStore } from '@/stores/auth'
import MainNav from './MainNav.vue'
import PostCard from './Home_Feed.vue'
import AnnouncementWidget from './Home_AnnouncementWidget.vue'
import ImageCarousel from './Home_ImageCarousel.vue'
import BirthdayAnniversary from './Home_BirthdayAnniversary.vue'
import DDAChart from './Home_DDA.vue'
import StaffSearch from './Home_StaffSearch.vue'

const authStore = useAuthStore()
const showPostDialog = ref(false)
const newPostContent = ref('')

const userInitials = computed(() => {
  const name = authStore.userName || 'User'
  return name
    .split(' ')
    .map(n => n[0])
    .join('')
    .toUpperCase()
    .substring(0, 2)
})

const posts = ref([
  {
    id: 1,
    author: 'John Smith',
    department: 'IT Department',
    timestamp: new Date(Date.now() - 2 * 60 * 60 * 1000),
    content: 'Welcome to the new Intraforms platform! We\'re excited to bring you this enhanced internal communication system. Feel free to share updates, ask questions, and collaborate with your colleagues.',
    image: null,
    likes: 15,
    comments: 3,
    liked: false
  },
  {
    id: 2,
    author: 'Sarah Johnson',
    department: 'HR Department',
    timestamp: new Date(Date.now() - 5 * 60 * 60 * 1000),
    content: 'Reminder: Annual performance reviews are due by the end of this month. Please make sure to complete your self-assessments and schedule time with your manager.',
    image: null,
    likes: 8,
    comments: 2,
    liked: false
  },
  {
    id: 3,
    author: 'Mike Wilson',
    department: 'Operations',
    timestamp: new Date(Date.now() - 24 * 60 * 60 * 1000),
    content: 'Great team meeting today! Looking forward to implementing the new process improvements we discussed. Thanks everyone for your valuable input.',
    image: null,
    likes: 12,
    comments: 5,
    liked: false
  }
])

const upcomingEvents = ref([
  {
    title: 'Company All-Hands',
    date: 'Dec 15, 2:00 PM'
  },
  {
    title: 'Holiday Party',
    date: 'Dec 20, 6:00 PM'
  },
  {
    title: 'Year-End Review',
    date: 'Dec 22, 10:00 AM'
  }
])

const createPost = () => {
  if (newPostContent.value.trim()) {
    posts.value.unshift({
      id: Date.now(),
      author: authStore.userName || 'Current User',
      department: 'Your Department',
      timestamp: new Date(),
      content: newPostContent.value,
      image: null,
      likes: 0,
      comments: 0,
      liked: false
    })
    newPostContent.value = ''
    showPostDialog.value = false
  }
}
</script>

<style scoped>
</style>
