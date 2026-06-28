<template>
  <form class="auth-form" @submit.prevent="submit">
    <div>
      <p class="eyebrow">Nueva contrasena</p>
      <h1>Restablece tu acceso</h1>
      <p class="muted">Usa al menos 8 caracteres, una mayuscula, una minuscula y un numero.</p>
    </div>
    <BaseInput v-model="password" label="Nueva contrasena" type="password" autocomplete="new-password" required />
    <BaseInput v-model="confirmation" label="Confirmar contrasena" type="password" autocomplete="new-password" required />
    <StatusMessage :message="error" type="error" />
    <StatusMessage :message="success" type="success" />
    <BaseButton :loading="loading" type="submit">Guardar contrasena</BaseButton>
  </form>
</template>

<script setup>
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import BaseButton from '@/components/ui/BaseButton.vue'
import BaseInput from '@/components/ui/BaseInput.vue'
import StatusMessage from '@/components/ui/StatusMessage.vue'
import { resetPassword } from '@/modules/auth/services/authService'

const router = useRouter()
const email = sessionStorage.getItem('teamder_reset_email') || ''
const otp = sessionStorage.getItem('teamder_reset_otp') || ''
const password = ref('')
const confirmation = ref('')
const loading = ref(false)
const error = ref('')
const success = ref('')

async function submit() {
  error.value = ''
  if (!email || !otp) return router.replace({ name: 'forgot-password' })
  if (!/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{8,}$/.test(password.value)) {
    error.value = 'La contrasena no cumple los requisitos de seguridad.'
    return
  }
  if (password.value !== confirmation.value) {
    error.value = 'Las contrasenas no coinciden.'
    return
  }
  loading.value = true
  try {
    await resetPassword({ email, otp, password: password.value })
    success.value = 'Contrasena actualizada. Te redirigiremos al inicio de sesion.'
    sessionStorage.removeItem('teamder_reset_email')
    sessionStorage.removeItem('teamder_reset_otp')
    setTimeout(() => router.replace({ name: 'login' }), 1200)
  } catch (requestError) {
    error.value = requestError.userMessage || 'No pudimos actualizar la contrasena.'
  } finally {
    loading.value = false
  }
}
</script>
