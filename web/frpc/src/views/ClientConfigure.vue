<template>
  <div class="configure-page">
    <div class="page-header">
      <div class="title-section">
        <h1 class="page-title">配置</h1>
      </div>
    </div>

    <div class="editor-header">
      <div class="header-left">
        <a
          href="https://www.frpnat.com"
          target="_blank"
          class="docs-link"
        >
          <el-icon><Link /></el-icon>
          文档
        </a>
      </div>
      <div class="header-actions">
        <ActionButton @click="handleUpload">更新并重载</ActionButton>
      </div>
    </div>

    <div class="editor-wrapper">
      <el-input
        v-model="configContent"
        type="textarea"
        :autosize="false"
        placeholder="# 在此填写 frpc 配置文件内容...

serverAddr = &quot;127.0.0.1&quot;
serverPort = 7000

[store]
path = &quot;./frpc_store.json&quot;"
        class="code-editor"
      ></el-input>
    </div>

    <ConfirmDialog
      v-model="confirmVisible"
      title="确认更新"
      message="该操作会更新当前 frpc 配置并立即重载，确认继续吗？"
      confirm-text="更新"
      :loading="uploading"
      :is-mobile="isMobile"
      @confirm="doUpload"
    />
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { ElMessage } from 'element-plus'
import { Link } from '@element-plus/icons-vue'
import { useClientStore } from '../stores/client'
import ActionButton from '@shared/components/ActionButton.vue'
import ConfirmDialog from '@shared/components/ConfirmDialog.vue'
import { useResponsive } from '../composables/useResponsive'

const { isMobile } = useResponsive()
const clientStore = useClientStore()
const configContent = ref('')

const fetchData = async () => {
  try {
    await clientStore.fetchConfig()
    configContent.value = clientStore.config
  } catch (err: any) {
    ElMessage({
      showClose: true,
      message: '获取配置失败：' + err.message,
      type: 'warning',
    })
  }
}

const confirmVisible = ref(false)
const uploading = ref(false)

const handleUpload = () => {
  confirmVisible.value = true
}

const doUpload = async () => {
  if (!configContent.value.trim()) {
    ElMessage.warning('配置内容不能为空')
    return
  }

  uploading.value = true
  try {
    await clientStore.saveConfig(configContent.value)
    await clientStore.reload()
    ElMessage.success('配置已更新并完成重载')
    confirmVisible.value = false
  } catch (err: any) {
    ElMessage.error('更新失败：' + err.message)
  } finally {
    uploading.value = false
  }
}

fetchData()
</script>

<style scoped lang="scss">
.configure-page {
  height: 100%;
  overflow: hidden;
  padding: $spacing-xl 40px;
  max-width: 960px;
  margin: 0 auto;
  @include flex-column;
  gap: $spacing-sm;
}

.editor-wrapper {
  flex: 1;
  min-height: 0;
  overflow: hidden;
}

.page-header {
  @include flex-column;
  gap: $spacing-sm;
  margin-bottom: $spacing-sm;
}

.editor-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.header-left {
  display: flex;
  align-items: center;
}

.header-actions {
  display: flex;
  align-items: center;
  gap: $spacing-sm;
}

.docs-link {
  display: flex;
  align-items: center;
  gap: $spacing-xs;
  color: $color-text-muted;
  text-decoration: none;
  font-size: $font-size-sm;
  transition: color $transition-fast;

  &:hover {
    color: $color-text-primary;
  }
}

.code-editor {
  height: 100%;

  :deep(.el-textarea__inner) {
    height: 100% !important;
    overflow-y: auto;
    font-family: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, monospace;
    font-size: $font-size-sm;
    line-height: 1.6;
    padding: $spacing-lg;
    border-radius: $radius-md;
    background: $color-bg-tertiary;
    border: 1px solid $color-border-light;
    resize: none;

    &:focus {
      border-color: $color-text-light;
      box-shadow: none;
    }
  }
}

@include mobile {
  .configure-page {
    padding: $spacing-xl $spacing-lg;
  }

  .header-left {
    justify-content: space-between;
  }

  .header-actions {
    justify-content: flex-end;
  }
}
</style>
