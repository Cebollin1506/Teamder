<template>
  <RouterLink class="notification-bell" to="/notificaciones" aria-label="Ver notificaciones">
    <span class="notification-bell__icon" aria-hidden="true"></span>
    <span v-if="unreadCount" class="notification-bell__badge">{{ unreadCount }}</span>
  </RouterLink>
</template>

<script setup>
import { computed, onMounted, ref } from 'vue'
import { getNotifications } from '@/modules/notifications/services/notificationService'

const notifications = ref([])

const unreadCount = computed(() =>
  notifications.value.filter((notification) => Number(notification.leida) === 0).length
)

onMounted(async () => {
  try {
    const response = await getNotifications()
    notifications.value = response.data.notifications || []
  } catch {
    notifications.value = []
  }
})
</script>
