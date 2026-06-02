<template>
  <label class="field">
    <span>{{ label }}</span>
    <input
      v-bind="$attrs"
      :value="modelValue"
      class="field__control"
      @input="$emit('update:modelValue', $event.target.value)"
    />
  </label>
</template>

<script setup>
defineProps({
  label: {
    type: String,
    required: true
  },
  modelValue: {
    type: [String, Number],
    default: ''
  }
})

defineEmits(['update:modelValue'])
</script>
