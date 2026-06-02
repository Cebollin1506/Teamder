import api from '@/services/api'

export function getUsers(params = {}) {
  return api.get('/users.php', { params })
}

export function getProfile() {
  return api.get('/users.php', { params: { me: true } })
}
