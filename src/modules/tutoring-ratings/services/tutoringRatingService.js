import api from '@/services/api'

export function createTutoringRating(payload) {
  return api.post('/calificaciones_tutoria.php', payload)
}

export function getTutoringRatings() {
  return api.get('/calificaciones_tutoria.php')
}
