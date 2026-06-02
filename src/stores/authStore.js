import { defineStore } from 'pinia'
import { login as loginRequest, register as registerRequest } from '@/modules/auth/services/authService'

const TOKEN_KEY = 'teamder_token'
const USER_KEY = 'teamder_user'

export const useAuthStore = defineStore('auth', {
  state: () => ({
    token: localStorage.getItem(TOKEN_KEY),
    user: JSON.parse(localStorage.getItem(USER_KEY) || 'null'),
    loading: false,
    error: null
  }),

  getters: {
    isAuthenticated: (state) => Boolean(state.token)
  },

  actions: {
    persistSession(token, user) {
      this.token = token
      this.user = user
      localStorage.setItem(TOKEN_KEY, token)
      localStorage.setItem(USER_KEY, JSON.stringify(user))
    },

    async login(credentials) {
      this.loading = true
      this.error = null

      try {
        const { data } = await loginRequest(credentials)
        const token = data.token
        const user = data.user || {
          name: data.name || credentials.email,
          email: credentials.email,
          role: data.role || 'Estudiante'
        }

        if (!token) {
          throw new Error('La API no devolvio un token.')
        }

        this.persistSession(token, user)
        return data
      } catch (error) {
        this.error = error.userMessage || error.message
        throw error
      } finally {
        this.loading = false
      }
    },

    async register(payload) {
      this.loading = true
      this.error = null

      try {
        const { data } = await registerRequest(payload)

        if (data.token) {
          this.persistSession(data.token, data.user || payload)
        }

        return data
      } catch (error) {
        this.error = error.userMessage || error.message
        throw error
      } finally {
        this.loading = false
      }
    },

    logout() {
      this.token = null
      this.user = null
      localStorage.removeItem(TOKEN_KEY)
      localStorage.removeItem(USER_KEY)
    }
  }
})
