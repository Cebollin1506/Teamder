<template>
  <form class="auth-form" @submit.prevent="submit">
    <div>
      <p class="eyebrow">Crea tu espacio academico</p>
      <h1>Registro</h1>
      <p class="muted">Completa tus datos para empezar a colaborar en TEAMDER.</p>
    </div>

    <BaseInput v-model="form.name" label="Nombre completo" type="text" autocomplete="name" required />
    <BaseInput v-model="form.email" label="Correo electronico" type="email" autocomplete="email" required />
    <BaseInput v-model="form.password" label="Contrasena" type="password" autocomplete="new-password" required />

    <label class="field">
      <span>Rol</span>
      <select v-model="form.role" class="field__control">
        <option value="student">Estudiante</option>
        <option value="tutor">Tutor</option>
      </select>
    </label>

    <StatusMessage :message="authStore.error" type="error" />
    <StatusMessage :message="successMessage" type="success" />
    <BaseButton :loading="authStore.loading" type="submit">Crear cuenta</BaseButton>

    <p class="auth-switch">
      Ya tienes cuenta?
      <RouterLink to="/auth/login">Inicia sesion</RouterLink>
    </p>
  </form>
</template>

<script setup>
import { reactive, ref } from 'vue'
import { useRouter } from 'vue-router'
import BaseButton from '@/components/ui/BaseButton.vue'
import BaseInput from '@/components/ui/BaseInput.vue'
import StatusMessage from '@/components/ui/StatusMessage.vue'
import { useAuthStore } from '@/stores/authStore'

const router = useRouter()
const authStore = useAuthStore()
const successMessage = ref('')

const form = reactive({
  name: '',
  email: '',
  password: '',
  role: 'student'
})

async function submit() {
  successMessage.value = ''

  try {
    await authStore.register(form)

    if (authStore.isAuthenticated) {
      router.push({ name: 'dashboard' })
      return
    }

    successMessage.value = 'Cuenta creada. Ahora puedes iniciar sesion.'
    router.push({ name: 'login' })
  } catch {
    // El store ya expone el mensaje para la vista.
  }
}
</script>
