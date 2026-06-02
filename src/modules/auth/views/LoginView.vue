<template>
  <form class="auth-form" @submit.prevent="submit">
    <div>
      <p class="eyebrow">Bienvenido de vuelta</p>
      <h1>Inicia sesion</h1>
      <p class="muted">Entra para buscar tutores, publicar solicitudes y conectar con tu comunidad.</p>
    </div>

    <BaseInput v-model="form.email" label="Correo electronico" type="email" autocomplete="email" required />
    <BaseInput v-model="form.password" label="Contrasena" type="password" autocomplete="current-password" required />

    <StatusMessage :message="authStore.error" type="error" />
    <BaseButton :loading="authStore.loading" type="submit">Entrar</BaseButton>

    <p class="auth-switch">
      No tienes cuenta?
      <RouterLink to="/auth/registro">Registrate</RouterLink>
    </p>
  </form>
</template>

<script setup>
import { reactive } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import BaseButton from '@/components/ui/BaseButton.vue'
import BaseInput from '@/components/ui/BaseInput.vue'
import StatusMessage from '@/components/ui/StatusMessage.vue'
import { useAuthStore } from '@/stores/authStore'

const router = useRouter()
const route = useRoute()
const authStore = useAuthStore()

const form = reactive({
  email: '',
  password: ''
})

async function submit() {
  try {
    await authStore.login(form)
    router.push(route.query.redirect || { name: 'dashboard' })
  } catch {
    // El store ya expone el mensaje para la vista.
  }
}
</script>
