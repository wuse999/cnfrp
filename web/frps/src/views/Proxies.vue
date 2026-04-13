<template>
  <div class="proxies-page">
    <div class="page-header">
      <div class="header-top">
        <div class="title-section">
          <h1 class="page-title">代理</h1>
          <p class="page-subtitle">查看并管理全部代理配置</p>
        </div>

        <div class="actions-section">
          <ActionButton variant="outline" size="small" @click="fetchData">
            刷新
          </ActionButton>

          <ActionButton
            variant="outline"
            size="small"
            danger
            @click="showClearDialog = true"
          >
            清理离线代理
          </ActionButton>
        </div>
      </div>

      <div class="filter-section">
        <div class="search-row">
          <el-input
            v-model="searchText"
            placeholder="搜索代理..."
            :prefix-icon="Search"
            clearable
            class="main-search"
          />

          <PopoverMenu
            :model-value="selectedClientKey"
            :width="220"
            placement="bottom-end"
            selectable
            filterable
            filter-placeholder="搜索客户端..."
            :display-value="selectedClientLabel"
            clearable
            class="client-filter"
            @update:model-value="onClientFilterChange($event as string)"
          >
            <template #default="{ filterText }">
              <PopoverMenuItem value="">{{ allClientsLabel }}</PopoverMenuItem>
              <PopoverMenuItem
                v-if="clientIDFilter && !selectedClientInList"
                :value="selectedClientKey"
              >
                {{ userFilter ? userFilter + '.' : '' }}{{ clientIDFilter }}（未找到）
              </PopoverMenuItem>
              <PopoverMenuItem
                v-for="client in filteredClientOptions(filterText)"
                :key="client.key"
                :value="client.key"
              >
                {{ client.label }}
              </PopoverMenuItem>
            </template>
          </PopoverMenu>
        </div>

        <div class="type-tabs">
          <button
            v-for="t in proxyTypes"
            :key="t.value"
            class="type-tab"
            :class="{ active: activeType === t.value }"
            @click="activeType = t.value"
          >
            {{ t.label }}
          </button>
        </div>
      </div>
    </div>

    <div v-loading="loading" class="proxies-content">
      <div v-if="filteredProxies.length > 0" class="proxies-list">
        <ProxyCard
          v-for="proxy in filteredProxies"
          :key="proxy.name"
          :proxy="proxy"
        />
      </div>
      <div v-else-if="!loading" class="empty-state">
        <el-empty description="未找到代理" />
      </div>
    </div>

    <ConfirmDialog
      v-model="showClearDialog"
      title="清理离线代理"
      message="确认清理全部离线代理吗？"
      confirm-text="清理"
      danger
      @confirm="handleClearConfirm"
    />
  </div>
</template>

<script setup lang="ts">
import { ref, computed, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { Search } from '@element-plus/icons-vue'
import ActionButton from '@shared/components/ActionButton.vue'
import ConfirmDialog from '@shared/components/ConfirmDialog.vue'
import PopoverMenu from '@shared/components/PopoverMenu.vue'
import PopoverMenuItem from '@shared/components/PopoverMenuItem.vue'
import {
  BaseProxy,
  TCPProxy,
  UDPProxy,
  HTTPProxy,
  HTTPSProxy,
  TCPMuxProxy,
  STCPProxy,
  SUDPProxy,
} from '../utils/proxy'
import ProxyCard from '../components/ProxyCard.vue'
import {
  getProxiesByType,
  clearOfflineProxies as apiClearOfflineProxies,
} from '../api/proxy'
import { getServerInfo } from '../api/server'
import { getClients } from '../api/client'
import { Client } from '../utils/client'

const route = useRoute()
const router = useRouter()

const allClientsLabel = '全部客户端'

const proxyTypes = [
  { label: 'TCP', value: 'tcp' },
  { label: 'UDP', value: 'udp' },
  { label: 'HTTP', value: 'http' },
  { label: 'HTTPS', value: 'https' },
  { label: 'TCPMUX', value: 'tcpmux' },
  { label: 'STCP', value: 'stcp' },
  { label: 'SUDP', value: 'sudp' },
]

const activeType = ref((route.params.type as string) || 'tcp')
const proxies = ref<BaseProxy[]>([])
const clients = ref<Client[]>([])
const loading = ref(false)
const searchText = ref('')
const showClearDialog = ref(false)
const clientIDFilter = ref((route.query.clientID as string) || '')
const userFilter = ref((route.query.user as string) || '')

const clientOptions = computed(() => {
  return clients.value
    .map((c) => ({
      key: c.key,
      clientID: c.clientID,
      user: c.user,
      label: c.user ? `${c.user}.${c.clientID}` : c.clientID,
    }))
    .sort((a, b) => a.label.localeCompare(b.label))
})

const selectedClientKey = computed(() => {
  if (!clientIDFilter.value) return ''
  const client = clientOptions.value.find(
    (c) => c.clientID === clientIDFilter.value && c.user === userFilter.value,
  )
  return client?.key || `${userFilter.value}:${clientIDFilter.value}`
})

const selectedClientLabel = computed(() => {
  if (!clientIDFilter.value) return allClientsLabel
  const client = clientOptions.value.find(
    (c) => c.clientID === clientIDFilter.value && c.user === userFilter.value,
  )
  return (
    client?.label ||
    `${userFilter.value ? userFilter.value + '.' : ''}${clientIDFilter.value}`
  )
})

const filteredClientOptions = (filterText: string) => {
  if (!filterText) return clientOptions.value
  const search = filterText.toLowerCase()
  return clientOptions.value.filter((c) =>
    c.label.toLowerCase().includes(search),
  )
}

const selectedClientInList = computed(() => {
  if (!clientIDFilter.value) return true
  return clientOptions.value.some(
    (c) => c.clientID === clientIDFilter.value && c.user === userFilter.value,
  )
})

const filteredProxies = computed(() => {
  let result = proxies.value

  if (clientIDFilter.value) {
    result = result.filter(
      (p) => p.clientID === clientIDFilter.value && p.user === userFilter.value,
    )
  }

  if (searchText.value) {
    const search = searchText.value.toLowerCase()
    result = result.filter((p) => p.name.toLowerCase().includes(search))
  }

  return result
})

const onClientFilterChange = (key: string) => {
  if (key) {
    const client = clientOptions.value.find((c) => c.key === key)
    if (client) {
      router.replace({
        query: { ...route.query, clientID: client.clientID, user: client.user },
      })
    }
  } else {
    const query = { ...route.query }
    delete query.clientID
    delete query.user
    router.replace({ query })
  }
}

const fetchClients = async () => {
  try {
    const json = await getClients()
    clients.value = json.map((data) => new Client(data))
  } catch {
    // 忽略客户端筛选数据加载失败。
  }
}

let serverInfo: {
  vhostHTTPPort: number
  vhostHTTPSPort: number
  tcpmuxHTTPConnectPort: number
  subdomainHost: string
} | null = null

const fetchServerInfo = async () => {
  if (serverInfo) return serverInfo
  const res = await getServerInfo()
  serverInfo = res
  return serverInfo
}

const fetchData = async () => {
  loading.value = true
  proxies.value = []

  try {
    const type = activeType.value
    const json = await getProxiesByType(type)

    if (type === 'tcp') {
      proxies.value = json.proxies.map((p: any) => new TCPProxy(p))
    } else if (type === 'udp') {
      proxies.value = json.proxies.map((p: any) => new UDPProxy(p))
    } else if (type === 'http') {
      const info = await fetchServerInfo()
      if (info && info.vhostHTTPPort) {
        proxies.value = json.proxies.map(
          (p: any) => new HTTPProxy(p, info.vhostHTTPPort, info.subdomainHost),
        )
      }
    } else if (type === 'https') {
      const info = await fetchServerInfo()
      if (info && info.vhostHTTPSPort) {
        proxies.value = json.proxies.map(
          (p: any) =>
            new HTTPSProxy(p, info.vhostHTTPSPort, info.subdomainHost),
        )
      }
    } else if (type === 'tcpmux') {
      const info = await fetchServerInfo()
      if (info && info.tcpmuxHTTPConnectPort) {
        proxies.value = json.proxies.map(
          (p: any) =>
            new TCPMuxProxy(p, info.tcpmuxHTTPConnectPort, info.subdomainHost),
        )
      }
    } else if (type === 'stcp') {
      proxies.value = json.proxies.map((p: any) => new STCPProxy(p))
    } else if (type === 'sudp') {
      proxies.value = json.proxies.map((p: any) => new SUDPProxy(p))
    }
  } catch (error: any) {
    ElMessage({
      showClose: true,
      message: '获取代理失败：' + error.message,
      type: 'error',
    })
  } finally {
    loading.value = false
  }
}

const handleClearConfirm = async () => {
  showClearDialog.value = false
  await clearOfflineProxies()
}

const clearOfflineProxies = async () => {
  try {
    await apiClearOfflineProxies()
    ElMessage({
      message: '离线代理已清理',
      type: 'success',
    })
    fetchData()
  } catch (err: any) {
    ElMessage({
      message: '清理离线代理失败：' + err.message,
      type: 'warning',
    })
  }
}

watch(activeType, (newType) => {
  router.replace({ params: { type: newType }, query: route.query })
  fetchData()
})

watch(
  () => [route.query.clientID, route.query.user],
  ([newClientID, newUser]) => {
    clientIDFilter.value = (newClientID as string) || ''
    userFilter.value = (newUser as string) || ''
  },
)

fetchData()
fetchClients()
</script>

<style scoped>
.proxies-page {
  display: flex;
  flex-direction: column;
  gap: 24px;
}

.page-header {
  display: flex;
  flex-direction: column;
  gap: 24px;
}

.header-top {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  gap: 20px;
}

.title-section {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.page-title {
  font-size: 28px;
  font-weight: 600;
  color: var(--el-text-color-primary);
  margin: 0;
  line-height: 1.2;
}

.page-subtitle {
  font-size: 14px;
  color: var(--el-text-color-secondary);
  margin: 0;
}

.actions-section {
  display: flex;
  gap: 12px;
}

.filter-section {
  display: flex;
  flex-direction: column;
  gap: 20px;
  margin-top: 8px;
}

.search-row {
  display: flex;
  gap: 16px;
  width: 100%;
  align-items: center;
}

.main-search {
  flex: 1;
}

.main-search :deep(.el-input__wrapper),
.client-filter :deep(.el-input__wrapper) {
  height: 32px;
  border-radius: 8px;
}

.client-filter {
  width: 240px;
}

.type-tabs {
  display: flex;
  gap: 8px;
  overflow-x: auto;
  padding-bottom: 4px;
}

.type-tab {
  padding: 6px 16px;
  border: 1px solid var(--el-border-color-lighter);
  border-radius: 12px;
  background: var(--el-bg-color);
  color: var(--el-text-color-regular);
  font-size: 13px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.2s;
  text-transform: uppercase;
}

.type-tab:hover {
  background: var(--el-fill-color-light);
}

.type-tab.active {
  background: var(--el-fill-color-darker);
  color: var(--el-text-color-primary);
  border-color: var(--el-fill-color-darker);
}

.proxies-content {
  min-height: 200px;
}

.proxies-list {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.empty-state {
  padding: 60px 0;
}

@media (max-width: 768px) {
  .search-row {
    flex-direction: column;
  }

  .client-filter {
    width: 100%;
  }
}
</style>
