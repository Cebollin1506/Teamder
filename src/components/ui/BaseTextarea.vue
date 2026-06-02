<template>
  <label class="field">
    <span>{{ label }}</span>
    <textarea
      v-bind="$attrs"
      :value="modelValue"
      class="field__control field__control--textarea"
      @input="$emit('update:modelValue', $event.target.value)"
    ></textarea>
  </label>
</template>

<script setup>
defineProps({
  label: {
    type: String,
    required: true
  },
  modelValue: {
    type: String,
    default: ''
  }
})

defineEmits(['update:modelValue'])
</script>
