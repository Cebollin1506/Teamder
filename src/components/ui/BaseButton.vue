<template>
  <button class="base-button" :class="variantClass" :disabled="disabled || loading">
    <span v-if="loading" class="button-spinner" aria-hidden="true"></span>
    <slot />
  </button>
</template>

<script setup>
import { computed } from 'vue'

const props = defineProps({
  variant: {
    type: String,
    default: 'primary'
  },
  loading: {
    type: Boolean,
    default: false
  },
  disabled: {
    type: Boolean,
    default: false
  }
})

const variantClass = computed(() => `base-button--${props.variant}`)
</script>
