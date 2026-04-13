<template>
  <ConfigSection title="连接配置" :readonly="readonly">
    <div class="field-row two-col">
      <ConfigField
        label="服务端名称"
        type="text"
        v-model="form.serverName"
        prop="serverName"
        placeholder="要访问的代理名称"
        :readonly="readonly"
      />
      <ConfigField
        label="服务端用户"
        type="text"
        v-model="form.serverUser"
        placeholder="留空表示使用同一用户"
        :readonly="readonly"
      />
    </div>
    <ConfigField
      label="密钥"
      type="password"
      v-model="form.secretKey"
      placeholder="共享密钥"
      :readonly="readonly"
    />
    <div class="field-row two-col">
      <ConfigField label="绑定地址" type="text" v-model="form.bindAddr"
        placeholder="127.0.0.1" :readonly="readonly" />
      <ConfigField label="绑定端口" type="number" v-model="form.bindPort"
        :min="bindPortMin" :max="65535" prop="bindPort" :readonly="readonly" />
    </div>
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

const bindPortMin = computed(() => (form.value.type === 'sudp' ? 1 : undefined))
</script>

<style scoped lang="scss">
@use '@/assets/css/form-layout';
</style>
