<template>
  <ConfigSection title="元数据" collapsible :readonly="readonly" :has-value="form.metadatas.length > 0 || form.annotations.length > 0">
    <ConfigField label="元数据" type="kv" v-model="form.metadatas" key-placeholder="键" value-placeholder="值" :readonly="readonly" />
    <ConfigField label="注解" type="kv" v-model="form.annotations" key-placeholder="键" value-placeholder="值" :readonly="readonly" />
  </ConfigSection>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import type { ProxyFormData } from '../../types'
import ConfigSection from '../ConfigSection.vue'
import ConfigField from '../ConfigField.vue'

const props = withDefaults(defineProps<{
  modelValue: ProxyFormData
  readonly?: boolean
}>(), { readonly: false })

const emit = defineEmits<{ 'update:modelValue': [value: ProxyFormData] }>()

const form = computed({
  get: () => props.modelValue,
  set: (val) => emit('update:modelValue', val),
})
</script>

<style scoped lang="scss">
@use '@/assets/css/form-layout';
</style>
