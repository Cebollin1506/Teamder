import api from '@/services/api'

export function getTutoringChat(tutoriaId) {
  return api.get('/chat_tutorias.php', { params: { tutoria_id: tutoriaId } })
}

export function sendTutoringMessage(tutoriaId, mensaje) {
  return api.post('/chat_tutorias.php', { tutoria_id: tutoriaId, mensaje })
}

