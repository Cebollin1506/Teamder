<template>
  <section class="chat-panel">
    <div class="section-title-row">
      <div>
        <p class="eyebrow">Chat</p>
        <h3>{{ isOpen ? 'Conversacion activa' : 'Chat cerrado' }}</h3>
      </div>
      <BaseButton variant="ghost" type="button" @click="loadMessages">Actualizar</BaseButton>
    </div>

    <StatusMessage :message="error" type="error" />

    <div class="chat-messages">
      <article
        v-for="message in messages"
        :key="message.id"
        class="chat-message"
        :class="{ 'chat-message--own': Number(message.emisor_id) === Number(authStore.user?.id) }"
      >
        <div class="chat-message__meta">
          <strong>{{ message.emisor_name }}</strong>
          <span>{{ message.fecha_creacion }}</span>
        </div>
        <p>{{ message.mensaje }}</p>
      </article>
      <StatusMessage v-if="!messages.length && !error" message="Aun no hay mensajes en este chat." />
    </div>

    <form v-if="isOpen" class="chat-form" @submit.prevent="sendMessage">
      <textarea
        v-model="draft"
        class="field__control field__control--textarea chat-form__input"
        maxlength="1000"
        placeholder="Escribe un mensaje."
        required
      ></textarea>
      <BaseButton :loading="sending" type="submit">Enviar</BaseButton>
    </form>
    <StatusMessage v-else message="El chat se cierra cuando la tutoria deja de estar confirmada." />
  </section>
</template>

<script setup>
import { computed, onBeforeUnmount, onMounted, ref, watch } from 'vue'
import BaseButton from '@/components/ui/BaseButton.vue'
import StatusMessage from '@/components/ui/StatusMessage.vue'
import { useAuthStore } from '@/stores/authStore'
import { getTutoringChat, sendTutoringMessage } from '@/modules/tutoring-schedule/services/tutoringChatService'

const props = defineProps({
  tutoring: {
    type: Object,
    required: true
  }
})

const authStore = useAuthStore()
const messages = ref([])
const draft = ref('')
const error = ref('')
const sending = ref(false)
const chatOpen = ref(false)
let refreshTimer = null

const isOpen = computed(() => normalizedStatus(props.tutoring.estado) === 'confirmada' && chatOpen.value)

onMounted(() => {
  loadMessages()
  startPolling()
})

onBeforeUnmount(stopPolling)

watch(
  () => props.tutoring.id,
  () => {
    messages.value = []
    loadMessages()
  }
)

watch(
  () => props.tutoring.estado,
  () => {
    loadMessages()
    startPolling()
  }
)

async function loadMessages() {
  error.value = ''

  try {
    const { data } = await getTutoringChat(props.tutoring.id)
    messages.value = data.mensajes || []
    chatOpen.value = Boolean(data.abierto)
  } catch (requestError) {
    messages.value = []
    chatOpen.value = false
    error.value = requestError.userMessage || 'No se pudo cargar el chat.'
  }
}

async function sendMessage() {
  const message = draft.value.trim()

  if (!message) {
    return
  }

  sending.value = true
  error.value = ''

  try {
    await sendTutoringMessage(props.tutoring.id, message)
    draft.value = ''
    await loadMessages()
  } catch (requestError) {
    error.value = requestError.userMessage || 'No se pudo enviar el mensaje.'
  } finally {
    sending.value = false
  }
}

function startPolling() {
  stopPolling()

  if (normalizedStatus(props.tutoring.estado) === 'confirmada') {
    refreshTimer = window.setInterval(loadMessages, 6000)
  }
}

function stopPolling() {
  if (refreshTimer) {
    window.clearInterval(refreshTimer)
    refreshTimer = null
  }
}

function normalizedStatus(estado) {
  return ['finalizado', ''].includes(estado) ? 'finalizada' : estado
}
</script>
