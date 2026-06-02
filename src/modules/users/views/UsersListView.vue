<template>
  <main class="page-section">
    <AppCard>
      <div class="section-header">
        <div>
          <p class="eyebrow">Comunidad</p>
          <h2>Buscar tutores o estudiantes</h2>
        </div>
        <BaseInput v-model="search" label="Buscar" type="search" placeholder="Nombre, materia o rol" />
      </div>
    </AppCard>

    <StatusMessage v-if="loading" message="Cargando usuarios..." />
    <StatusMessage :message="error" type="error" />

    <section class="users-grid">
      <AppCard v-for="user in filteredUsers" :key="user.id || user.email || user.name" class="user-card">
        <div class="avatar">{{ initials(user.name) }}</div>
        <div>
          <h3>{{ user.name }}</h3>
          <p class="muted">{{ user.role || 'Estudiante' }}</p>
          <p>{{ user.subject || user.subjects || 'Disponible para grupos de estudio' }}</p>
        </div>
        <a class="link-button link-button--secondary" :href="`mailto:${user.email}`">Conectar</a>
      </AppCard>
    </section>
  </main>
</template>

<script setup>
import { computed, onMounted, ref } from 'vue'
import AppCard from '@/components/ui/AppCard.vue'
import BaseInput from '@/components/ui/BaseInput.vue'
import StatusMessage from '@/components/ui/StatusMessage.vue'
import { getUsers } from '@/modules/users/services/userService'

const users = ref([])
const search = ref('')
const loading = ref(false)
const error = ref('')

const fallbackUsers = [
  { id: 1, name: 'Ana Torres', email: 'ana@example.com', role: 'Tutor', subject: 'Calculo diferencial' },
  { id: 2, name: 'Luis Perez', email: 'luis@example.com', role: 'Estudiante', subject: 'Programacion en PHP' },
  { id: 3, name: 'Mariana Ruiz', email: 'mariana@example.com', role: 'Tutor', subject: 'Ingles academico' }
]

const filteredUsers = computed(() => {
  const term = search.value.toLowerCase().trim()

  if (!term) {
    return users.value
  }

  return users.value.filter((user) =>
    [user.name, user.email, user.role, user.subject, user.subjects].some((value) =>
      String(value || '').toLowerCase().includes(term)
    )
  )
})

function initials(name = 'TU') {
  return name
    .split(' ')
    .map((part) => part[0])
    .join('')
    .slice(0, 2)
    .toUpperCase()
}

onMounted(async () => {
  loading.value = true
  error.value = ''

  try {
    const { data } = await getUsers()
    users.value = Array.isArray(data) ? data : data.users || fallbackUsers
  } catch (requestError) {
    users.value = fallbackUsers
    error.value = `${requestError.userMessage || 'No se pudo conectar con users.php.'} Mostrando datos de ejemplo.`
  } finally {
    loading.value = false
  }
})
</script>
