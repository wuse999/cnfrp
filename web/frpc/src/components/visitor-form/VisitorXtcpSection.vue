<template>
  <ConfigSection title="XTCP 选项" collapsible :readonly="readonly"
    :has-value="form.protocol !== 'quic' || form.keepTunnelOpen || form.maxRetriesAnHour != null || form.minRetryInterval != null || !!form.fallbackTo || form.fallbackTimeoutMs != null">
    <ConfigField label="协议" type="select" v-model="form.protocol"
      :options="[{ label: 'QUIC', value: 'quic' }, { label: 'KCP', value: 'kcp' }]" :readonly="readonly" />
    <ConfigField label="保持隧道常开" type="switch" v-model="form.keepTunnelOpen" :readonly="readonly" />
    <div class="field-row two-col">
      <ConfigField label="每小时最大重试次数" type="number" v-model="form.maxRetriesAnHour" :min="0" :readonly="readonly" />
      <ConfigField label="最小重试间隔（秒）" type="number" v-model="form.minRetryInterval" :min="0" :readonly="readonly" />
    </div>
    <div class="field-row two-col">
      <ConfigField label="回退访问端" type="text" v-model="form.fallbackTo" placeholder="回退访问端名称" :readonly="readonly" />
      <ConfigField label="回退超时（毫秒）" type="number" v-model="form.fallbackTimeoutMs" :min="0" :readonly="readonly" />
    </div>
  </ConfigSection>

  <ConfigSection title="NAT 穿透" collapsible :readonly="readonly"
    :has-value="form.natTraversalDisableAssistedAddrs">
    <ConfigField label="禁用辅助地址" type="switch" v-model="form.natTraversalDisableAssistedAddrs"
      tip="仅使用 STUN 探测出的公网地址" :readonly="readonly" />
  </ConfigSection>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import type { VisitorFormData } from '../../types'
import ConfigSection from '../ConfigSection.vue'
import ConfigField from '../ConfigField.vue'

const props = withDefaults(defineProps<{
  modelValue: VisitorFormData
  readonly?: boolean
}>(), { readonly: false })

const emit = defineEmits<{ 'update:modelValue': [value: VisitorFormData] }>()

const form = computed({
  get: () => props.modelValue,
  set: (val) => emit('update:modelValue', val),
})
</script>

<style scoped lang="scss">
@use '@/assets/css/form-layout';
</style>
