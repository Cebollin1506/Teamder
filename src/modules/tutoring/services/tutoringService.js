import api from '@/services/api'

export function createTutoringRequest(payload) {
  return api.post('/tutoring_requests.php', payload)
}

export function getTutoringRequests() {
  return api.get('/tutoring_requests.php')
}
