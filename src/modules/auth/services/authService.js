import api from '@/services/api'

export function login(credentials) {
  return api.post('/login.php', credentials)
}

export function register(payload) {
  return api.post('/register.php', payload)
}

export function forgotPassword(payload) {
  return api.post('/forgot-password.php', payload)
}

export function verifyOtp(payload) {
  return api.post('/verify-otp.php', payload)
}

export function resetPassword(payload) {
  return api.post('/reset-password.php', payload)
}
