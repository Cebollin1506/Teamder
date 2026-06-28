import axios from 'axios'

const api = axios.create({
  baseURL: import.meta.env.VITE_API_BASE_URL || 'http://localhost/Teamder_Backend/api/',
  headers: {
    'Content-Type': 'application/json'
  },
  timeout: 12000
})

api.interceptors.request.use((config) => {
  const token = localStorage.getItem('teamder_token')

  if (token) {
    config.headers.Authorization = `Bearer ${token}`
    // Algunos hostings CGI eliminan Authorization antes de llegar a PHP.
    config.headers['X-Teamder-Token'] = token
  }

  return config
})

api.interceptors.response.use(
  (response) => response,
  (error) => {
    const message =
      error.response?.data?.message ||
      error.response?.data?.error ||
      error.message ||
      'Ocurrio un error al conectar con TEAMDER.'

    return Promise.reject({
      ...error,
      userMessage: message
    })
  }
)

export default api
