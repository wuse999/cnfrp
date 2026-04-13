<template>
  <ConfigSection title="认证" :readonly="readonly">
    <template v-if="['http', 'tcpmux'].includes(form.type)">
      <div class="field-row three-col">
        <ConfigField label="HTTP 用户" type="text" v-model="form.httpUser" :readonly="readonly" />
        <ConfigField label="HTTP 密码" type="password" v-model="form.httpPassword" :readonly="readonly" />
        <ConfigField label="按 HTTP 用户路由" type="text" v-model="form.routeByHTTPUser" :readonly="readonly" />
      </div>
    </template>
    <template v-if="['stcp', 'sudp', 'xtcp'].includes(form.type)">
      <div class="field-row two-col">
        <ConfigField label="密钥" type="password" v-model="form.secretKey" prop="secretKey" :readonly="readonly" />
        <ConfigField label="允许用户" type="tags" v-model="form.allowUsers" placeholder="输入允许访问的用户名" :readonly="readonly" />
      </div>
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
</script>

<style scoped lang="scss">
@use '@/assets/css/form-layout';
</style>
