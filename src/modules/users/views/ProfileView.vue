<template>
  <main class="page-section">
    <AppCard>
      <p class="eyebrow">Mi cuenta</p>
      <h2>{{ authStore.user?.name || 'Usuario TEAMDER' }}</h2>
      <div class="profile-list">
        <p><strong>Correo:</strong> {{ authStore.user?.email || 'Sin correo guardado' }}</p>
        <p><strong>Rol:</strong> {{ authStore.user?.role || 'Estudiante' }}</p>
      </div>
    </AppCard>

    <AppCard>
      <h3>Datos desde API</h3>
      <StatusMessage v-if="loading" message="Cargando perfil..." />
      <StatusMessage :message="error" type="error" />
      <pre v-if="profile" class="json-preview">{{ profile }}</pre>
    </AppCard>
  </main>
</template>

<script setup>
import { onMounted, ref } from 'vue'
import AppCard from '@/components/ui/AppCard.vue'
import StatusMessage from '@/components/ui/StatusMessage.vue'
import { useAuthStore } from '@/stores/authStore'
import { getProfile } from '@/modules/users/services/userService'

const authStore = useAuthStore()
const profile = ref(null)
const loading = ref(false)
const error = ref('')

onMounted(async () => {
  loading.value = true
  error.value = ''

  try {
    const { data } = await getProfile()
    profile.value = data
  } catch (requestError) {
    error.value = requestError.userMessage || 'No se pudo cargar el perfil desde la API.'
  } finally {
    loading.value = false
  }
})
</script>
