<template>
  <form class="auth-form" @submit.prevent="submit">
    <div>
      <p class="eyebrow">Recuperacion de acceso</p>
      <h1>Recupera tu cuenta</h1>
      <p class="muted">Ingresa tu correo y te enviaremos un codigo de seis digitos.</p>
    </div>
    <BaseInput v-model.trim="email" label="Correo electronico" type="email" autocomplete="email" required />
    <StatusMessage :message="error" type="error" />
    <StatusMessage :message="success" type="success" />
    <BaseButton :loading="loading" type="submit">Enviar instrucciones</BaseButton>
    <p class="auth-switch"><RouterLink :to="{ name: 'login' }">Volver al inicio de sesion</RouterLink></p>
  </form>
</template>

<script setup>
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import BaseButton from '@/components/ui/BaseButton.vue'
import BaseInput from '@/components/ui/BaseInput.vue'
import StatusMessage from '@/components/ui/StatusMessage.vue'
import { forgotPassword } from '@/modules/auth/services/authService'

const router = useRouter()
const email = ref('')
const loading = ref(false)
const error = ref('')
const success = ref('')
const genericMessage = 'Si el correo está registrado, recibirás instrucciones para recuperar tu cuenta.'

async function submit() {
  error.value = ''
  success.value = ''
  if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email.value)) {
    error.value = 'Ingresa un correo electronico valido.'
    return
  }
  loading.value = true
  try {
    await forgotPassword({ email: email.value })
    success.value = genericMessage
    sessionStorage.setItem('teamder_reset_email', email.value.toLowerCase())
    setTimeout(() => router.push({ name: 'verify-otp' }), 1200)
  } catch {
    error.value = 'No pudimos procesar la solicitud. Intenta nuevamente.'
  } finally {
    loading.value = false
  }
}
</script>
