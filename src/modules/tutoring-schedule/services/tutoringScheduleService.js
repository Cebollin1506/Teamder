import api from '@/services/api'

export function createTutoring(payload) {
  return api.post('/tutorias.php', payload)
}

export function getTutorings() {
  return api.get('/tutorias.php')
}

export function updateTutoring(id, payload) {
  return api.patch('/tutorias.php', { id, ...payload })
}
