import { defineStore } from 'pinia'
import { login as loginRequest, register as registerRequest } from '@/modules/auth/services/authService'
import { getProfile } from '@/modules/users/services/userService'

const TOKEN_KEY = 'teamder_token'
const USER_KEY = 'teamder_user'

export const useAuthStore = defineStore('auth', {
  state: () => ({
    token: localStorage.getItem(TOKEN_KEY),
    user: JSON.parse(localStorage.getItem(USER_KEY) || 'null'),
    profileSynced: false,
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
      this.profileSynced = true
      localStorage.setItem(TOKEN_KEY, token)
      localStorage.setItem(USER_KEY, JSON.stringify(user))
    },

    persistUser(user) {
      this.user = user
      this.profileSynced = true
      localStorage.setItem(USER_KEY, JSON.stringify(user))
    },

    async refreshProfile() {
      if (!this.token || this.profileSynced) {
        return this.user
      }

      try {
        const { data } = await getProfile()
        this.persistUser(data)
        return data
      } catch (error) {
        this.logout()
        throw error
      }
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
      this.profileSynced = false
      localStorage.removeItem(TOKEN_KEY)
      localStorage.removeItem(USER_KEY)
    }
  }
})
