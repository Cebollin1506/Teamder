import api from '@/services/api'

export function getNotifications() {
  return api.get('/notificaciones.php')
}

export function markNotificationAsRead(id) {
  return api.patch('/notificaciones.php', { id, leida: true })
}

export function markAllNotificationsAsRead() {
  return api.patch('/notificaciones.php', { all: true, leida: true })
}
