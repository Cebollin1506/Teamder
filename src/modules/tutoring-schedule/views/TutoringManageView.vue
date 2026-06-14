<template>
  <main class="page-section">
    <section class="content-grid content-grid--two">
      <AppCard>
        <p class="eyebrow">Administracion</p>
        <h2>Tutorias asignadas</h2>
        <p class="muted">
          Revisa las solicitudes recibidas y actualiza su estado segun tu disponibilidad.
        </p>
        <div class="status-list">
          <span class="status-pill status-pill--pendiente">Pendiente</span>
          <span class="status-pill status-pill--confirmada">Confirmada</span>
          <span class="status-pill status-pill--cancelada">Cancelada</span>
          <span class="status-pill status-pill--finalizada">Finalizada</span>
        </div>
      </AppCard>

      <AppCard>
        <p class="eyebrow">Resumen</p>
        <h2>Actividad</h2>
        <div class="data-list data-list--compact">
          <article class="data-item">
            <div>
              <h3>Pendientes</h3>
              <p class="muted">Solicitudes por aceptar o rechazar.</p>
            </div>
            <p class="metric metric--small">{{ totals.pendiente }}</p>
          </article>
          <article class="data-item">
            <div>
              <h3>Confirmadas</h3>
              <p class="muted">Tutorias proximas o en curso.</p>
            </div>
            <p class="metric metric--small">{{ totals.confirmada }}</p>
          </article>
          <article class="data-item">
            <div>
              <h3>Finalizadas</h3>
              <p class="muted">Tutorias listas para evaluacion.</p>
            </div>
            <p class="metric metric--small">{{ totals.finalizada }}</p>
          </article>
        </div>
      </AppCard>
    </section>

    <AppCard>
      <div class="section-title-row">
        <div>
          <p class="eyebrow">Solicitudes</p>
          <h2>Administrar tutorias</h2>
        </div>
        <BaseButton variant="ghost" type="button" @click="loadData">Actualizar</BaseButton>
      </div>

      <StatusMessage :message="error" type="error" />
      <StatusMessage :message="success" type="success" />

      <div v-if="tutorings.length" class="data-list">
        <article v-for="tutoring in tutorings" :key="tutoring.id" class="data-item data-item--stacked">
          <div class="item-heading">
            <h3>{{ tutoring.tema }}</h3>
            <span class="status-pill" :class="`status-pill--${normalizedStatus(tutoring.estado)}`">
              {{ statusLabels[normalizedStatus(tutoring.estado)] || tutoring.estado }}
            </span>
          </div>

          <div class="details-grid">
            <p><strong>Alumno:</strong> {{ tutoring.alumno_name }}</p>
            <p><strong>Fecha:</strong> {{ tutoring.fecha }}</p>
            <p><strong>Hora:</strong> {{ String(tutoring.hora).slice(0, 5) }}</p>
            <p><strong>Solicitada:</strong> {{ tutoring.created_at }}</p>
          </div>

          <p v-if="tutoring.descripcion" class="muted">{{ tutoring.descripcion }}</p>

          <div v-if="ratingFor(tutoring.id)" class="rating-panel">
            <div>
              <p class="eyebrow">Calificacion</p>
              <h3>{{ ratingFor(tutoring.id).calificacion }}/5</h3>
            </div>
            <p v-if="ratingFor(tutoring.id).comentario" class="muted">
              {{ ratingFor(tutoring.id).comentario }}
            </p>
          </div>

          <div class="item-actions">
            <RouterLink
              v-if="['confirmada', 'finalizada'].includes(normalizedStatus(tutoring.estado))"
              class="link-button link-button--secondary"
              :to="{ name: 'tutoring-chat', query: { tutoria_id: tutoring.id } }"
            >
              Abrir chat
            </RouterLink>
            <BaseButton
              v-if="normalizedStatus(tutoring.estado) === 'pendiente'"
              type="button"
              @click="changeStatus(tutoring.id, 'confirmada')"
            >
              Aceptar
            </BaseButton>
            <BaseButton
              v-if="normalizedStatus(tutoring.estado) === 'pendiente'"
              variant="ghost"
              type="button"
              @click="changeStatus(tutoring.id, 'cancelada')"
            >
              Rechazar
            </BaseButton>
            <BaseButton
              v-if="normalizedStatus(tutoring.estado) === 'confirmada'"
              variant="ghost"
              type="button"
              @click="changeStatus(tutoring.id, 'cancelada')"
            >
              Cancelar
            </BaseButton>
            <BaseButton
              v-if="normalizedStatus(tutoring.estado) === 'confirmada'"
              type="button"
              @click="changeStatus(tutoring.id, 'finalizada')"
            >
              Finalizar
            </BaseButton>
          </div>
        </article>
      </div>

      <StatusMessage v-else message="Aun no tienes tutorias asignadas." />
    </AppCard>
  </main>
</template>

<script setup>
import { computed, onMounted, ref } from 'vue'
import AppCard from '@/components/ui/AppCard.vue'
import BaseButton from '@/components/ui/BaseButton.vue'
import StatusMessage from '@/components/ui/StatusMessage.vue'
import { getTutorings, updateTutoring } from '@/modules/tutoring-schedule/services/tutoringScheduleService'
import { getTutoringRatings } from '@/modules/tutoring-ratings/services/tutoringRatingService'

const error = ref('')
const success = ref('')
const tutorings = ref([])
const ratings = ref([])

const statusLabels = {
  pendiente: 'Pendiente',
  confirmada: 'Confirmada',
  cancelada: 'Cancelada',
  finalizada: 'Finalizada'
}

const totals = computed(() =>
  tutorings.value.reduce(
    (accumulator, tutoring) => {
      const estado = normalizedStatus(tutoring.estado)
      if (accumulator[estado] !== undefined) {
        accumulator[estado] += 1
      }
      return accumulator
    },
    { pendiente: 0, confirmada: 0, cancelada: 0, finalizada: 0 }
  )
)

onMounted(loadData)

async function loadData() {
  error.value = ''

  try {
    const [tutoringsResponse, ratingsResponse] = await Promise.all([getTutorings(), getTutoringRatings()])
    tutorings.value = tutoringsResponse.data.tutorias || []
    ratings.value = ratingsResponse.data.calificaciones || []
  } catch (requestError) {
    tutorings.value = []
    ratings.value = []
    error.value = requestError.userMessage || 'No se pudieron cargar tus tutorias.'
  }
}

async function changeStatus(id, estado) {
  error.value = ''
  success.value = ''

  try {
    await updateTutoring(id, { estado })
    success.value = 'Tutoria actualizada correctamente.'
    await loadData()
  } catch (requestError) {
    error.value = requestError.userMessage || 'No se pudo actualizar la tutoria.'
  }
}

function normalizedStatus(estado) {
  return ['finalizado', ''].includes(estado) ? 'finalizada' : estado
}

function ratingFor(tutoriaId) {
  return ratings.value.find((rating) => Number(rating.tutoria_id) === Number(tutoriaId))
}
</script>
