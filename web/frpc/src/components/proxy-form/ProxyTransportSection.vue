<template>
  <ConfigSection title="传输选项" collapsible :readonly="readonly"
    :has-value="form.useEncryption || form.useCompression || !!form.bandwidthLimit || (!!form.bandwidthLimitMode && form.bandwidthLimitMode !== 'client') || !!form.proxyProtocolVersion">
    <div class="field-row two-col">
      <ConfigField label="启用加密" type="switch" v-model="form.useEncryption" :readonly="readonly" />
      <ConfigField label="启用压缩" type="switch" v-model="form.useCompression" :readonly="readonly" />
    </div>
    <div class="field-row three-col">
      <ConfigField label="带宽限制" type="text" v-model="form.bandwidthLimit" placeholder="1MB" tip="例如：1MB、500KB" :readonly="readonly" />
      <ConfigField label="带宽限制模式" type="select" v-model="form.bandwidthLimitMode"
        :options="[{ label: '客户端', value: 'client' }, { label: '服务端', value: 'server' }]" :readonly="readonly" />
      <ConfigField label="代理协议版本" type="select" v-model="form.proxyProtocolVersion"
        :options="[{ label: '无', value: '' }, { label: 'v1', value: 'v1' }, { label: 'v2', value: 'v2' }]" :readonly="readonly" />
    </div>
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
