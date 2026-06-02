<template>
  <p v-if="message" class="status-message" :class="`status-message--${type}`">
    {{ message }}
  </p>
</template>

<script setup>
defineProps({
  message: {
    type: String,
    default: ''
  },
  type: {
    type: String,
    default: 'info'
  }
})
</script>
