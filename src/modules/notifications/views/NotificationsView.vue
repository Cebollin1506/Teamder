<template>
  <main class="page-section">
    <AppCard>
      <div class="section-title-row">
        <div>
          <p class="eyebrow">Notificaciones</p>
          <h2>Historial de actividad</h2>
          <p class="muted">Revisa avisos sobre tutorias, cambios de estado y evaluaciones.</p>
        </div>
        <BaseButton variant="ghost" type="button" @click="markAll">Marcar todas como leidas</BaseButton>
      </div>

      <StatusMessage :message="error" type="error" />
      <StatusMessage :message="success" type="success" />

      <div v-if="notifications.length" class="data-list">
        <article
          v-for="notification in notifications"
          :key="notification.id"
          class="data-item"
          :class="{ 'data-item--unread': Number(notification.leida) === 0 }"
        >
          <div>
            <div class="item-heading">
              <h3>{{ notification.titulo }}</h3>
              <span class="status-pill">{{ notification.tipo }}</span>
            </div>
            <p class="muted">{{ notification.mensaje }}</p>
            <p class="muted">{{ notification.fecha_creacion }}</p>
          </div>
          <BaseButton
            v-if="Number(notification.leida) === 0"
            variant="ghost"
            type="button"
            @click="markOne(notification.id)"
          >
            Marcar leida
          </BaseButton>
        </article>
      </div>
      <StatusMessage v-else message="No tienes notificaciones." />
    </AppCard>
  </main>
</template>

<script setup>
import { onMounted, ref } from 'vue'
import AppCard from '@/components/ui/AppCard.vue'
import BaseButton from '@/components/ui/BaseButton.vue'
import StatusMessage from '@/components/ui/StatusMessage.vue'
import {
  getNotifications,
  markAllNotificationsAsRead,
  markNotificationAsRead
} from '@/modules/notifications/services/notificationService'

const notifications = ref([])
const error = ref('')
const success = ref('')

onMounted(loadNotifications)

async function loadNotifications() {
  const response = await getNotifications()
  notifications.value = response.data.notifications || []
}

async function markOne(id) {
  error.value = ''
  success.value = ''

  try {
    await markNotificationAsRead(id)
    success.value = 'Notificacion marcada como leida.'
    await loadNotifications()
  } catch (requestError) {
    error.value = requestError.userMessage || 'No se pudo actualizar la notificacion.'
  }
}

async function markAll() {
  error.value = ''
  success.value = ''

  try {
    await markAllNotificationsAsRead()
    success.value = 'Notificaciones marcadas como leidas.'
    await loadNotifications()
  } catch (requestError) {
    error.value = requestError.userMessage || 'No se pudieron actualizar las notificaciones.'
  }
}
</script>
