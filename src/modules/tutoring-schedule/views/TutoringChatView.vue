<template>
  <main class="page-section">
    <section class="content-grid chat-layout">
      <AppCard>
        <div class="section-title-row">
          <div>
            <p class="eyebrow">Chats</p>
            <h2>Tutorias con conversacion</h2>
          </div>
          <BaseButton variant="ghost" type="button" @click="loadTutorings">Actualizar</BaseButton>
        </div>

        <StatusMessage :message="error" type="error" />

        <div v-if="chatTutorings.length" class="data-list">
          <button
            v-for="tutoring in chatTutorings"
            :key="tutoring.id"
            class="chat-thread"
            :class="{ 'chat-thread--active': Number(selectedId) === Number(tutoring.id) }"
            type="button"
            @click="selectedId = tutoring.id"
          >
            <span>
              <strong>{{ tutoring.tema }}</strong>
              <small>{{ partnerName(tutoring) }}</small>
            </span>
            <span class="status-pill" :class="`status-pill--${normalizedStatus(tutoring.estado)}`">
              {{ statusLabels[normalizedStatus(tutoring.estado)] }}
            </span>
          </button>
        </div>
        <StatusMessage v-else message="Aun no tienes chats disponibles." />
      </AppCard>

      <AppCard>
        <div v-if="selectedTutoring" class="chat-detail">
          <div>
            <p class="eyebrow">Conversacion</p>
            <h2>{{ selectedTutoring.tema }}</h2>
            <p class="muted">
              {{ selectedTutoring.fecha }} a las {{ String(selectedTutoring.hora).slice(0, 5) }} con
              {{ partnerName(selectedTutoring) }}.
            </p>
          </div>
          <TutoringChat :tutoring="selectedTutoring" />
        </div>
        <StatusMessage v-else message="Selecciona una tutoria para abrir el chat." />
      </AppCard>
    </section>
  </main>
</template>

<script setup>
import { computed, onMounted, ref, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import AppCard from '@/components/ui/AppCard.vue'
import BaseButton from '@/components/ui/BaseButton.vue'
import StatusMessage from '@/components/ui/StatusMessage.vue'
import TutoringChat from '@/modules/tutoring-schedule/components/TutoringChat.vue'
import { getTutorings } from '@/modules/tutoring-schedule/services/tutoringScheduleService'
import { useAuthStore } from '@/stores/authStore'

const route = useRoute()
const router = useRouter()
const authStore = useAuthStore()
const tutorings = ref([])
const selectedId = ref(route.query.tutoria_id || '')
const error = ref('')

const statusLabels = {
  confirmada: 'Activa',
  finalizada: 'Cerrada'
}

const chatTutorings = computed(() =>
  tutorings.value.filter((tutoring) => ['confirmada', 'finalizada'].includes(normalizedStatus(tutoring.estado)))
)
const selectedTutoring = computed(() =>
  chatTutorings.value.find((tutoring) => Number(tutoring.id) === Number(selectedId.value))
)

onMounted(loadTutorings)

watch(selectedId, (id) => {
  router.replace({ name: 'tutoring-chat', query: id ? { tutoria_id: id } : {} })
})

async function loadTutorings() {
  error.value = ''

  try {
    const { data } = await getTutorings()
    tutorings.value = data.tutorias || []

    if (!selectedTutoring.value && chatTutorings.value.length) {
      selectedId.value = chatTutorings.value[0].id
    }
  } catch (requestError) {
    tutorings.value = []
    error.value = requestError.userMessage || 'No se pudieron cargar tus chats.'
  }
}

function partnerName(tutoring) {
  return authStore.user?.role === 'tutor' ? tutoring.alumno_name : tutoring.tutor_name
}

function normalizedStatus(estado) {
  return ['finalizado', ''].includes(estado) ? 'finalizada' : estado
}
</script>
