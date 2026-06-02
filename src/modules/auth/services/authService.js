import api from '@/services/api'

export function login(credentials) {
  return api.post('/login.php', credentials)
}

export function register(payload) {
  return api.post('/register.php', payload)
}
