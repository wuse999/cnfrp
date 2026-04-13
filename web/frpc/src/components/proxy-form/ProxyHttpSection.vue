<template>
  <ConfigSection title="HTTP 选项" collapsible :readonly="readonly"
    :has-value="form.locations.length > 0 || !!form.hostHeaderRewrite || form.requestHeaders.length > 0 || form.responseHeaders.length > 0">
    <ConfigField label="路由路径" type="tags" v-model="form.locations" placeholder="/path" :readonly="readonly" />
    <ConfigField label="Host Header 重写" type="text" v-model="form.hostHeaderRewrite" :readonly="readonly" />
    <ConfigField label="请求头" type="kv" v-model="form.requestHeaders" key-placeholder="请求头" value-placeholder="值" :readonly="readonly" />
    <ConfigField label="响应头" type="kv" v-model="form.responseHeaders" key-placeholder="响应头" value-placeholder="值" :readonly="readonly" />
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
