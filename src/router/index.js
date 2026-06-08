import { createRouter, createWebHistory } from 'vue-router'
import { useAuthStore } from '@/stores/authStore'
import AuthLayout from '@/layouts/AuthLayout.vue'
import DashboardLayout from '@/layouts/DashboardLayout.vue'
import LoginView from '@/modules/auth/views/LoginView.vue'
import RegisterView from '@/modules/auth/views/RegisterView.vue'
import DashboardView from '@/views/DashboardView.vue'
import ProfileView from '@/modules/users/views/ProfileView.vue'
import UsersListView from '@/modules/users/views/UsersListView.vue'
import TutoringRequestView from '@/modules/tutoring/views/TutoringRequestView.vue'
import TutoringScheduleView from '@/modules/tutoring-schedule/views/TutoringScheduleView.vue'
import TutoringRatingsView from '@/modules/tutoring-ratings/views/TutoringRatingsView.vue'
import NotificationsView from '@/modules/notifications/views/NotificationsView.vue'

const routes = [
  {
    path: '/',
    component: DashboardLayout,
    meta: { requiresAuth: true },
    children: [
      { path: '', name: 'dashboard', component: DashboardView },
      { path: 'perfil', name: 'profile', component: ProfileView },
      { path: 'usuarios', name: 'users', component: UsersListView },
      { path: 'solicitudes/crear', name: 'create-tutoring-request', component: TutoringRequestView },
      { path: 'tutorias/agendar', name: 'schedule-tutoring', component: TutoringScheduleView },
      { path: 'tutorias/calificaciones', name: 'tutoring-ratings', component: TutoringRatingsView },
      { path: 'notificaciones', name: 'notifications', component: NotificationsView }
    ]
  },
  {
    path: '/auth',
    component: AuthLayout,
    meta: { guestOnly: true },
    children: [
      { path: 'login', name: 'login', component: LoginView },
      { path: 'registro', name: 'register', component: RegisterView }
    ]
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

router.beforeEach((to) => {
  const authStore = useAuthStore()

  if (to.meta.requiresAuth && !authStore.isAuthenticated) {
    return { name: 'login', query: { redirect: to.fullPath } }
  }

  if (to.meta.guestOnly && authStore.isAuthenticated) {
    return { name: 'dashboard' }
  }

  return true
})

export default router
