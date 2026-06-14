<template>
  <div class="dashboard-layout">
    <aside class="sidebar">
      <RouterLink class="brand brand--sidebar" to="/">TEAMDER</RouterLink>
      <nav class="sidebar__nav" aria-label="Navegacion principal">
        <RouterLink to="/">Dashboard</RouterLink>
        <RouterLink to="/usuarios">Usuarios</RouterLink>
        <RouterLink to="/solicitudes/crear">Solicitud</RouterLink>
        <RouterLink v-if="isStudent" to="/tutorias/agendar">Agendar tutoria</RouterLink>
        <RouterLink v-if="isTutor" to="/tutorias/administrar">Administrar tutorias</RouterLink>
        <RouterLink to="/tutorias/chat">Chat</RouterLink>
        <RouterLink to="/tutorias/calificaciones">Calificaciones</RouterLink>
        <RouterLink to="/perfil">Perfil</RouterLink>
      </nav>
    </aside>

    <div class="workspace">
      <header class="topbar">
        <div>
          <p class="eyebrow">Plataforma academica</p>
          <h1>{{ pageTitle }}</h1>
        </div>
        <div class="topbar__user">
          <NotificationBell />
          <span>{{ authStore.user?.name || 'Estudiante' }}</span>
          <BaseButton variant="ghost" @click="logout">Salir</BaseButton>
        </div>
      </header>

      <RouterView />
    </div>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import BaseButton from '@/components/ui/BaseButton.vue'
import NotificationBell from '@/modules/notifications/components/NotificationBell.vue'
import { useAuthStore } from '@/stores/authStore'

const route = useRoute()
const router = useRouter()
const authStore = useAuthStore()

const titles = {
  dashboard: 'Inicio',
  users: 'Buscar tutores y estudiantes',
  profile: 'Perfil',
  'create-tutoring-request': 'Crear solicitud',
  'schedule-tutoring': 'Agendar tutoria',
  'manage-tutoring': 'Administrar tutorias',
  'tutoring-chat': 'Chat de tutoria',
  'tutoring-ratings': 'Calificaciones de tutoria',
  notifications: 'Notificaciones'
}

const pageTitle = computed(() => titles[route.name] || 'TEAMDER')
const userRole = computed(() => String(authStore.user?.role || '').toLowerCase().trim())
const isTutor = computed(() => userRole.value === 'tutor')
const isStudent = computed(() => userRole.value !== 'tutor')

function logout() {
  authStore.logout()
  router.push({ name: 'login' })
}
</script>
