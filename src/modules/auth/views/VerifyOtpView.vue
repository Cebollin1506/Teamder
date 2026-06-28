<template>
  <form class="auth-form" @submit.prevent="submit">
    <div>
      <p class="eyebrow">Verificacion por correo</p>
      <h1>Ingresa tu codigo</h1>
      <p class="muted">El codigo tiene seis digitos y vence en 10 minutos.</p>
    </div>
    <BaseInput v-model.trim="otp" label="Codigo OTP" inputmode="numeric" autocomplete="one-time-code" maxlength="6" required />
    <StatusMessage :message="error" type="error" />
    <BaseButton :loading="loading" type="submit">Verificar codigo</BaseButton>
    <p class="auth-switch"><RouterLink :to="{ name: 'forgot-password' }">Solicitar otro codigo</RouterLink></p>
  </form>
</template>

<script setup>
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import BaseButton from '@/components/ui/BaseButton.vue'
import BaseInput from '@/components/ui/BaseInput.vue'
import StatusMessage from '@/components/ui/StatusMessage.vue'
import { verifyOtp } from '@/modules/auth/services/authService'

const router = useRouter()
const email = sessionStorage.getItem('teamder_reset_email') || ''
const otp = ref('')
const loading = ref(false)
const error = ref('')

async function submit() {
  error.value = ''
  if (!email) return router.replace({ name: 'forgot-password' })
  if (!/^\d{6}$/.test(otp.value)) {
    error.value = 'El codigo debe contener exactamente 6 digitos.'
    return
  }
  loading.value = true
  try {
    await verifyOtp({ email, otp: otp.value })
    sessionStorage.setItem('teamder_reset_otp', otp.value)
    router.push({ name: 'reset-password' })
  } catch (requestError) {
    error.value = requestError.userMessage || 'El codigo no es valido o ya vencio.'
  } finally {
    loading.value = false
  }
}
</script>
