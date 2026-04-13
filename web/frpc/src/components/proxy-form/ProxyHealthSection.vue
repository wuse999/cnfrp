<template>
  <ConfigSection title="健康检查" collapsible :readonly="readonly" :has-value="!!form.healthCheckType">
    <div class="field-row two-col">
      <ConfigField label="类型" type="select" v-model="form.healthCheckType"
        :options="[{ label: '已禁用', value: '' }, { label: 'TCP', value: 'tcp' }, { label: 'HTTP', value: 'http' }]" :readonly="readonly" />
      <div></div>
    </div>
    <template v-if="form.healthCheckType">
      <div class="field-row three-col">
        <ConfigField label="超时（秒）" type="number" v-model="form.healthCheckTimeoutSeconds" :min="1" :readonly="readonly" />
        <ConfigField label="最大失败次数" type="number" v-model="form.healthCheckMaxFailed" :min="1" :readonly="readonly" />
        <ConfigField label="检查间隔（秒）" type="number" v-model="form.healthCheckIntervalSeconds" :min="1" :readonly="readonly" />
      </div>
      <template v-if="form.healthCheckType === 'http'">
        <ConfigField label="路径" type="text" v-model="form.healthCheckPath" prop="healthCheckPath" placeholder="/health" :readonly="readonly" />
        <ConfigField label="HTTP 请求头" type="kv" v-model="healthCheckHeaders" key-placeholder="请求头" value-placeholder="值" :readonly="readonly" />
      </template>
    </template>
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

const healthCheckHeaders = computed({
  get() {
    return form.value.healthCheckHTTPHeaders.map((h) => ({ key: h.name, value: h.value }))
  },
  set(val: Array<{ key: string; value: string }>) {
    form.value.healthCheckHTTPHeaders = val.map((h) => ({ name: h.key, value: h.value }))
  },
})
</script>

<style scoped lang="scss">
@use '@/assets/css/form-layout';
</style>
