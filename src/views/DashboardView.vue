<template>
  <main class="content-grid">
    <AppCard class="hero-card">
      <div>
        <p class="eyebrow">Resumen</p>
        <h2>Organiza tus tutorias y grupos de estudio</h2>
        <p class="muted">Encuentra personas con objetivos compatibles, publica solicitudes y mantente conectado.</p>
      </div>
      <RouterLink class="link-button" to="/solicitudes/crear">Nueva solicitud</RouterLink>
    </AppCard>

    <AppCard>
      <p class="metric">3</p>
      <h3>Solicitudes activas</h3>
      <p class="muted">Publicaciones abiertas para recibir ayuda academica.</p>
    </AppCard>

    <AppCard>
      <p class="metric">12</p>
      <h3>Usuarios disponibles</h3>
      <p class="muted">Tutores y estudiantes listos para colaborar.</p>
    </AppCard>

    <AppCard>
      <p class="metric">4</p>
      <h3>Materias sugeridas</h3>
      <p class="muted">Matematicas, programacion, ingles y fisica.</p>
    </AppCard>
  </main>
</template>

<script setup>
import AppCard from '@/components/ui/AppCard.vue'
</script>
