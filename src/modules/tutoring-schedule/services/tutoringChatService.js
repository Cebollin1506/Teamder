import api from '@/services/api'

export function getTutoringChat(tutoriaId) {
  return api.get('/mensajes_tutoria.php', { params: { tutoria_id: tutoriaId } })
}

export function sendTutoringMessage(tutoriaId, mensaje) {
  return api.post('/mensajes_tutoria.php', { tutoria_id: tutoriaId, mensaje })
}
