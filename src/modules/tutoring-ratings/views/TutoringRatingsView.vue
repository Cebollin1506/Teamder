<template>
  <main class="page-section">
    <section class="content-grid content-grid--two">
      <AppCard>
        <p class="eyebrow">Evaluacion</p>
        <h2>Calificar tutoria finalizada</h2>
        <p class="muted">Solo se muestran tutorias finalizadas que aun puedes evaluar.</p>

        <form class="stack-form" @submit.prevent="submit">
          <label class="field">
            <span>Tutoria</span>
            <select v-model="form.tutoria_id" class="field__control" required>
              <option value="">Selecciona una tutoria</option>
              <option v-for="tutoring in rateableTutorings" :key="tutoring.id" :value="tutoring.id">
                {{ tutoring.tema }} - {{ tutoring.fecha }} - {{ tutoring.tutor_name }}
              </option>
            </select>
          </label>

          <label class="field">
            <span>Calificacion</span>
            <select v-model.number="form.calificacion" class="field__control" required>
              <option v-for="score in [5, 4, 3, 2, 1]" :key="score" :value="score">
                {{ score }} estrellas
              </option>
            </select>
          </label>

          <BaseTextarea
            v-model="form.comentario"
            label="Comentario"
            rows="4"
            placeholder="Comentario opcional sobre la tutoria."
          />

          <StatusMessage :message="error" type="error" />
          <StatusMessage :message="success" type="success" />
          <BaseButton :loading="loading" type="submit">Guardar calificacion</BaseButton>
        </form>
      </AppCard>

      <AppCard>
        <p class="eyebrow">Promedios</p>
        <h2>Calificacion por tutor</h2>
        <div v-if="averages.length" class="data-list data-list--compact">
          <article v-for="average in averages" :key="average.tutor_id" class="data-item">
            <div>
              <h3>{{ average.tutor_name }}</h3>
              <p class="muted">{{ Number(average.promedio).toFixed(1) }} de 5 en {{ average.total }} evaluaciones.</p>
            </div>
            <p class="metric metric--small">{{ Number(average.promedio).toFixed(1) }}</p>
          </article>
        </div>
        <StatusMessage v-else message="Aun no hay promedios disponibles." />
      </AppCard>
    </section>

    <AppCard>
      <p class="eyebrow">Historial</p>
      <h2>Evaluaciones registradas</h2>
      <div v-if="ratings.length" class="data-list">
        <article v-for="rating in ratings" :key="rating.id" class="data-item">
          <div>
            <div class="item-heading">
              <h3>{{ rating.tutoria_tema }}</h3>
              <span class="rating-stars">{{ stars(rating.calificacion) }}</span>
            </div>
            <p class="muted">Tutor: {{ rating.tutor_name }}. Alumno: {{ rating.alumno_name }}.</p>
            <p v-if="rating.comentario" class="muted">{{ rating.comentario }}</p>
          </div>
          <span class="muted">{{ rating.fecha_calificacion }}</span>
        </article>
      </div>
      <StatusMessage v-else message="Aun no hay evaluaciones registradas." />
    </AppCard>
  </main>
</template>

<script setup>
import { computed, onMounted, reactive, ref } from 'vue'
import AppCard from '@/components/ui/AppCard.vue'
import BaseButton from '@/components/ui/BaseButton.vue'
import BaseTextarea from '@/components/ui/BaseTextarea.vue'
import StatusMessage from '@/components/ui/StatusMessage.vue'
import { getTutorings } from '@/modules/tutoring-schedule/services/tutoringScheduleService'
import {
  createTutoringRating,
  getTutoringRatings
} from '@/modules/tutoring-ratings/services/tutoringRatingService'

const loading = ref(false)
const error = ref('')
const success = ref('')
const tutorings = ref([])
const ratings = ref([])
const averages = ref([])

const form = reactive({
  tutoria_id: '',
  calificacion: 5,
  comentario: ''
})

const ratedTutoringIds = computed(() => new Set(ratings.value.map((rating) => Number(rating.tutoria_id))))
const rateableTutorings = computed(() =>
  tutorings.value.filter(
    (tutoring) => tutoring.estado === 'finalizada' && !ratedTutoringIds.value.has(Number(tutoring.id))
  )
)

onMounted(loadData)

async function loadData() {
  const [tutoringsResponse, ratingsResponse] = await Promise.all([getTutorings(), getTutoringRatings()])
  tutorings.value = tutoringsResponse.data.tutorias || []
  ratings.value = ratingsResponse.data.calificaciones || []
  averages.value = ratingsResponse.data.promedios || []
}

async function submit() {
  loading.value = true
  error.value = ''
  success.value = ''

  try {
    await createTutoringRating(form)
    success.value = 'Calificacion registrada correctamente.'
    form.tutoria_id = ''
    form.calificacion = 5
    form.comentario = ''
    await loadData()
  } catch (requestError) {
    error.value = requestError.userMessage || 'No se pudo registrar la calificacion.'
  } finally {
    loading.value = false
  }
}

function stars(score) {
  return `${score}/5`
}
</script>
