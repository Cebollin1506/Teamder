<template>
  <main class="page-section">
    <AppCard>
      <p class="eyebrow">Tutorias</p>
      <h2>Publicar solicitud de tutoria</h2>
      <p class="muted">Describe que necesitas estudiar para que otros usuarios puedan ayudarte.</p>

      <form class="stack-form" @submit.prevent="submit">
        <BaseInput v-model="form.subject" label="Materia" type="text" placeholder="Ej. Algebra lineal" required />
        <BaseInput v-model="form.title" label="Titulo" type="text" placeholder="Necesito repasar matrices" required />
        <BaseTextarea
          v-model="form.description"
          label="Descripcion"
          rows="5"
          placeholder="Cuenta el tema, horario tentativo y modalidad."
          required
        />

        <label class="field">
          <span>Modalidad</span>
          <select v-model="form.modality" class="field__control">
            <option value="online">Online</option>
            <option value="presencial">Presencial</option>
            <option value="mixta">Mixta</option>
          </select>
        </label>

        <StatusMessage :message="error" type="error" />
        <StatusMessage :message="success" type="success" />
        <BaseButton :loading="loading" type="submit">Publicar solicitud</BaseButton>
      </form>
    </AppCard>
  </main>
</template>

<script setup>
import { reactive, ref } from 'vue'
import AppCard from '@/components/ui/AppCard.vue'
import BaseButton from '@/components/ui/BaseButton.vue'
import BaseInput from '@/components/ui/BaseInput.vue'
import BaseTextarea from '@/components/ui/BaseTextarea.vue'
import StatusMessage from '@/components/ui/StatusMessage.vue'
import { createTutoringRequest } from '@/modules/tutoring/services/tutoringService'

const loading = ref(false)
const error = ref('')
const success = ref('')

const form = reactive({
  subject: '',
  title: '',
  description: '',
  modality: 'online'
})

async function submit() {
  loading.value = true
  error.value = ''
  success.value = ''

  try {
    await createTutoringRequest(form)
    success.value = 'Solicitud publicada correctamente.'
    form.subject = ''
    form.title = ''
    form.description = ''
    form.modality = 'online'
  } catch (requestError) {
    error.value = requestError.userMessage || 'No se pudo publicar la solicitud.'
  } finally {
    loading.value = false
  }
}
</script>
