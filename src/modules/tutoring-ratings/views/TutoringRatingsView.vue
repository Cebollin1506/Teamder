<template>
  <main class="page-section">
    <section class="content-grid content-grid--two">
      <AppCard>
        <p class="eyebrow">Evaluacion</p>
        <h2>{{ formTitle }}</h2>
        <p class="muted">{{ formDescription }}</p>

        <form class="stack-form" @submit.prevent="submit">
          <label class="field">
            <span>{{ selectLabel }}</span>
            <select v-model="form.tutoria_id" class="field__control" required>
              <option value="">{{ selectPlaceholder }}</option>
              <option v-for="tutoring in rateableTutorings" :key="tutoring.id" :value="tutoring.id">
                {{ optionLabel(tutoring) }}
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
            :placeholder="commentPlaceholder"
          />

          <StatusMessage :message="error" type="error" />
          <StatusMessage :message="success" type="success" />
          <BaseButton :loading="loading" type="submit">Guardar calificacion</BaseButton>
        </form>
      </AppCard>

      <AppCard>
        <p class="eyebrow">Promedios</p>
        <h2>{{ averagesTitle }}</h2>
        <div v-if="visibleAverages.length" class="data-list data-list--compact">
          <article v-for="average in visibleAverages" :key="averageKey(average)" class="data-item">
            <div>
              <h3>{{ averageName(average) }}</h3>
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
      <h2>{{ receivedTitle }}</h2>
      <StatusMessage :message="error" type="error" />
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
      <StatusMessage v-else :message="receivedEmptyMessage" />
    </AppCard>

    <AppCard>
      <p class="eyebrow">Estudiantes</p>
      <h2>{{ studentRatingsTitle }}</h2>
      <div v-if="studentRatings.length" class="data-list">
        <article v-for="rating in studentRatings" :key="rating.id" class="data-item">
          <div>
            <div class="item-heading">
              <h3>{{ rating.alumno_name }}</h3>
              <span class="rating-stars">{{ stars(rating.calificacion) }}</span>
            </div>
            <p class="muted">Tutoria: {{ rating.tutoria_tema }}.</p>
            <p v-if="rating.comentario" class="muted">{{ rating.comentario }}</p>
          </div>
          <span class="muted">{{ rating.fecha_calificacion }}</span>
        </article>
      </div>
      <StatusMessage v-else :message="studentRatingsEmptyMessage" />
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
import { useAuthStore } from '@/stores/authStore'

const authStore = useAuthStore()
const loading = ref(false)
const error = ref('')
const success = ref('')
const tutorings = ref([])
const ratings = ref([])
const studentRatings = ref([])
const averages = ref([])
const studentAverages = ref([])

const form = reactive({
  tutoria_id: '',
  calificacion: 5,
  comentario: ''
})

const isTutor = computed(() => authStore.user?.role === 'tutor')
const ratedTutoringIds = computed(() => new Set(ratings.value.map((rating) => Number(rating.tutoria_id))))
const ratedStudentTutoringIds = computed(() =>
  new Set(studentRatings.value.map((rating) => Number(rating.tutoria_id)))
)
const rateableTutorings = computed(() =>
  tutorings.value.filter(
    (tutoring) =>
      ['finalizada', 'finalizado', ''].includes(tutoring.estado) &&
      !(isTutor.value ? ratedStudentTutoringIds.value : ratedTutoringIds.value).has(Number(tutoring.id))
  )
)
const formTitle = computed(() => (isTutor.value ? 'Calificar estudiante' : 'Calificar tutor'))
const formDescription = computed(() =>
  isTutor.value
    ? 'Solo se muestran tutorias finalizadas donde aun puedes evaluar al estudiante.'
    : 'Solo se muestran tutorias finalizadas que aun puedes evaluar.'
)
const selectLabel = computed(() => (isTutor.value ? 'Estudiante' : 'Tutoria'))
const selectPlaceholder = computed(() =>
  isTutor.value ? 'Selecciona un estudiante' : 'Selecciona una tutoria'
)
const commentPlaceholder = computed(() =>
  isTutor.value ? 'Comentario opcional sobre el estudiante.' : 'Comentario opcional sobre la tutoria.'
)
const averagesTitle = computed(() => (isTutor.value ? 'Calificacion por estudiante' : 'Calificacion por tutor'))
const visibleAverages = computed(() => (isTutor.value ? studentAverages.value : averages.value))
const receivedTitle = computed(() =>
  isTutor.value ? 'Calificaciones recibidas por tus tutorias' : 'Evaluaciones registradas'
)
const receivedEmptyMessage = computed(() =>
  isTutor.value ? 'Aun no has recibido evaluaciones de alumnos.' : 'Aun no hay evaluaciones registradas.'
)
const studentRatingsTitle = computed(() =>
  isTutor.value ? 'Evaluaciones que realizaste' : 'Calificaciones recibidas de tutores'
)
const studentRatingsEmptyMessage = computed(() =>
  isTutor.value ? 'Aun no has evaluado estudiantes.' : 'Aun no has recibido calificaciones de tutores.'
)

onMounted(loadData)

async function loadData() {
  error.value = ''

  try {
    const [tutoringsResponse, ratingsResponse] = await Promise.all([getTutorings(), getTutoringRatings()])
    tutorings.value = tutoringsResponse.data.tutorias || []
    ratings.value = ratingsResponse.data.calificaciones || []
    studentRatings.value = ratingsResponse.data.calificaciones_estudiante || []
    averages.value = ratingsResponse.data.promedios || []
    studentAverages.value = ratingsResponse.data.promedios_estudiantes || []
  } catch (requestError) {
    tutorings.value = []
    ratings.value = []
    studentRatings.value = []
    averages.value = []
    studentAverages.value = []
    error.value = requestError.userMessage || 'No se pudo cargar la informacion de tutorias.'
  }
}

async function submit() {
  loading.value = true
  error.value = ''
  success.value = ''

  try {
    await createTutoringRating(form)
    success.value = isTutor.value
      ? 'Calificacion del estudiante registrada correctamente.'
      : 'Calificacion registrada correctamente.'
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

function optionLabel(tutoring) {
  const personName = isTutor.value ? tutoring.alumno_name : tutoring.tutor_name
  return `${personName} - ${tutoring.tema} - ${tutoring.fecha}`
}

function averageKey(average) {
  return isTutor.value ? average.alumno_id : average.tutor_id
}

function averageName(average) {
  return isTutor.value ? average.alumno_name : average.tutor_name
}
</script>
