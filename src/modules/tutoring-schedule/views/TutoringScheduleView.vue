<template>
  <main class="page-section">
    <section class="content-grid content-grid--two">
      <AppCard>
        <p class="eyebrow">Agenda</p>
        <h2>Solicitar tutoria</h2>
        <p class="muted">Selecciona tutor, fecha, hora y el tema que quieres trabajar.</p>

        <form class="stack-form" @submit.prevent="submit">
          <label class="field">
            <span>Tutor</span>
            <select v-model="form.tutor_id" class="field__control" required>
              <option value="">Selecciona un tutor</option>
              <option v-for="tutor in tutors" :key="tutor.id" :value="tutor.id">
                {{ tutor.name }} - {{ tutor.subject || 'Tutor general' }}
              </option>
            </select>
          </label>

          <BaseInput v-model="form.tema" label="Tema" type="text" placeholder="Ej. Integrales" required />
          <BaseTextarea
            v-model="form.descripcion"
            label="Descripcion"
            rows="4"
            placeholder="Agrega el motivo o dudas principales."
          />
          <div class="form-row">
            <BaseInput v-model="form.fecha" label="Fecha" type="date" required />
            <BaseInput v-model="form.hora" label="Hora" type="time" required />
          </div>

          <StatusMessage :message="error" type="error" />
          <StatusMessage :message="success" type="success" />
          <BaseButton :loading="loading" type="submit">Agendar tutoria</BaseButton>
        </form>
      </AppCard>

      <AppCard>
        <p class="eyebrow">Disponibilidad</p>
        <h2>Validacion de horario</h2>
        <p class="muted">
          El sistema evita empalmes para el tutor y para el alumno cuando ya existe una tutoria pendiente o confirmada.
        </p>
        <div class="status-list">
          <span class="status-pill status-pill--pendiente">Pendiente</span>
          <span class="status-pill status-pill--confirmada">Confirmada</span>
          <span class="status-pill status-pill--cancelada">Cancelada</span>
          <span class="status-pill status-pill--finalizada">Finalizada</span>
        </div>
      </AppCard>
    </section>

    <AppCard>
      <div class="section-title-row">
        <div>
          <p class="eyebrow">Historial</p>
          <h2>Tutorias agendadas</h2>
        </div>
        <BaseButton variant="ghost" type="button" @click="loadData">Actualizar</BaseButton>
      </div>

      <StatusMessage :message="historyError" type="error" />

      <div v-if="tutorings.length" class="data-list">
        <article v-for="tutoring in tutorings" :key="tutoring.id" class="data-item data-item--stacked">
          <div>
            <div class="item-heading">
              <h3>{{ tutoring.tema }}</h3>
              <span class="status-pill" :class="`status-pill--${tutoring.estado}`">
                {{ statusLabels[tutoring.estado] || tutoring.estado }}
              </span>
            </div>
            <p class="muted">
              {{ tutoring.fecha }} a las {{ tutoring.hora }} con {{ tutoring.tutor_name }}.
            </p>
            <p v-if="tutoring.descripcion" class="muted">{{ tutoring.descripcion }}</p>
          </div>

          <div class="item-actions">
            <RouterLink
              v-if="['confirmada', 'finalizada'].includes(normalizedStatus(tutoring.estado))"
              class="link-button link-button--secondary"
              :to="{ name: 'tutoring-chat', query: { tutoria_id: tutoring.id } }"
            >
              Abrir chat
            </RouterLink>
            <label class="field field--compact">
              <span>Estado</span>
              <select
                :value="tutoring.estado"
                class="field__control"
                @change="changeStatus(tutoring.id, $event.target.value)"
              >
                <option value="pendiente">Pendiente</option>
                <option value="confirmada">Confirmada</option>
                <option value="cancelada">Cancelada</option>
                <option value="finalizada">Finalizada</option>
              </select>
            </label>
            <label class="field field--compact">
              <span>Fecha</span>
              <input
                :value="draftFor(tutoring).fecha"
                class="field__control"
                type="date"
                @input="draftFor(tutoring).fecha = $event.target.value"
              />
            </label>
            <label class="field field--compact">
              <span>Hora</span>
              <input
                :value="draftFor(tutoring).hora"
                class="field__control"
                type="time"
                @input="draftFor(tutoring).hora = $event.target.value"
              />
            </label>
            <BaseButton variant="ghost" type="button" @click="changeSchedule(tutoring.id)">
              Guardar horario
            </BaseButton>
          </div>
        </article>
      </div>
      <StatusMessage v-else message="Aun no hay tutorias agendadas." />
    </AppCard>
  </main>
</template>

<script setup>
import { computed, onMounted, reactive, ref } from 'vue'
import AppCard from '@/components/ui/AppCard.vue'
import BaseButton from '@/components/ui/BaseButton.vue'
import BaseInput from '@/components/ui/BaseInput.vue'
import BaseTextarea from '@/components/ui/BaseTextarea.vue'
import StatusMessage from '@/components/ui/StatusMessage.vue'
import { getUsers } from '@/modules/users/services/userService'
import {
  createTutoring,
  getTutorings,
  updateTutoring
} from '@/modules/tutoring-schedule/services/tutoringScheduleService'

const loading = ref(false)
const error = ref('')
const historyError = ref('')
const success = ref('')
const users = ref([])
const tutorings = ref([])
const scheduleDrafts = reactive({})

const form = reactive({
  tutor_id: '',
  tema: '',
  descripcion: '',
  fecha: '',
  hora: ''
})

const statusLabels = {
  pendiente: 'Pendiente',
  confirmada: 'Confirmada',
  cancelada: 'Cancelada',
  finalizada: 'Finalizada'
}

const tutors = computed(() =>
  users.value.filter((user) => String(user.role || '').toLowerCase().trim() === 'tutor')
)

onMounted(loadData)

async function loadData() {
  historyError.value = ''

  try {
    const usersResponse = await getUsers()
    users.value = usersResponse.data.users || []
  } catch (requestError) {
    error.value = requestError.userMessage || 'No se pudo cargar la lista de tutores.'
  }

  try {
    const tutoringsResponse = await getTutorings()
    tutorings.value = tutoringsResponse.data.tutorias || []
    tutorings.value.forEach((tutoring) => {
      scheduleDrafts[tutoring.id] = {
        fecha: tutoring.fecha,
        hora: String(tutoring.hora).slice(0, 5)
      }
    })
  } catch (requestError) {
    tutorings.value = []
    historyError.value = requestError.userMessage || 'No se pudo cargar el historial de tutorias.'
  }
}

async function submit() {
  loading.value = true
  error.value = ''
  success.value = ''

  try {
    await createTutoring(form)
    success.value = 'Tutoria agendada correctamente.'
    form.tutor_id = ''
    form.tema = ''
    form.descripcion = ''
    form.fecha = ''
    form.hora = ''
    await loadData()
  } catch (requestError) {
    error.value = requestError.userMessage || 'No se pudo agendar la tutoria.'
  } finally {
    loading.value = false
  }
}

async function changeStatus(id, estado) {
  error.value = ''
  success.value = ''

  try {
    await updateTutoring(id, { estado })
    success.value = 'Estado actualizado correctamente.'
    await loadData()
  } catch (requestError) {
    error.value = requestError.userMessage || 'No se pudo actualizar la tutoria.'
  }
}

function draftFor(tutoring) {
  if (!scheduleDrafts[tutoring.id]) {
    scheduleDrafts[tutoring.id] = {
      fecha: tutoring.fecha,
      hora: String(tutoring.hora).slice(0, 5)
    }
  }

  return scheduleDrafts[tutoring.id]
}

async function changeSchedule(id) {
  error.value = ''
  success.value = ''

  try {
    await updateTutoring(id, scheduleDrafts[id])
    success.value = 'Horario actualizado correctamente.'
    await loadData()
  } catch (requestError) {
    error.value = requestError.userMessage || 'No se pudo actualizar el horario.'
  }
}

function normalizedStatus(estado) {
  return ['finalizado', ''].includes(estado) ? 'finalizada' : estado
}
</script>
