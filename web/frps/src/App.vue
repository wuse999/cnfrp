<template>
  <div id="app">
    <header class="header">
      <div class="header-content">
        <div class="brand-section">
          <button
            v-if="isMobile"
            class="hamburger-btn"
            @click="toggleSidebar"
            aria-label="切换菜单"
          >
            <span class="hamburger-icon">&#9776;</span>
          </button>
          <div class="logo-wrapper">
            <LogoIcon class="logo-icon" />
          </div>
          <span class="divider">/</span>
          <span class="brand-name">cnfrp</span>
          <span class="badge server-badge">服务端</span>
        </div>

        <div class="header-controls">
          <a
            class="header-link"
            href="https://www.frpnat.com"
            target="_blank"
            rel="noreferrer"
            aria-label="FRPNAT 官网"
            title="FRPNAT 官网"
          >
            <span class="header-link-badge" aria-hidden="true">F</span>
          </a>
          <a
            class="header-link"
            href="https://gitee.com/frpnat/cnfrp"
            target="_blank"
            rel="noreferrer"
            aria-label="Gitee 仓库"
            title="Gitee 仓库"
          >
            <img
              class="header-link-image"
              src="https://gitee.com/favicon.ico"
              alt="Gitee"
            />
          </a>
          <a
            class="header-link"
            href="https://github.com/wuse999/cnfrp"
            target="_blank"
            rel="noreferrer"
            aria-label="GitHub 仓库"
            title="GitHub 仓库"
          >
            <GitHubIcon class="header-link-icon" />
          </a>
          <el-switch
            v-model="isDark"
            inline-prompt
            :active-icon="Moon"
            :inactive-icon="Sunny"
            class="theme-switch"
          />
        </div>
      </div>
    </header>

    <div class="layout">
      <div
        v-if="isMobile && sidebarOpen"
        class="sidebar-overlay"
        @click="closeSidebar"
      />

      <aside
        class="sidebar"
        :class="{ 'mobile-open': isMobile && sidebarOpen }"
      >
        <nav class="sidebar-nav">
          <router-link
            to="/"
            class="sidebar-link"
            :class="{ active: route.path === '/' }"
            @click="closeSidebar"
          >
            概览
          </router-link>
          <router-link
            to="/clients"
            class="sidebar-link"
            :class="{ active: route.path.startsWith('/clients') }"
            @click="closeSidebar"
          >
            客户端
          </router-link>
          <router-link
            to="/proxies"
            class="sidebar-link"
            :class="{
              active:
                route.path.startsWith('/proxies') ||
                route.path.startsWith('/proxy'),
            }"
            @click="closeSidebar"
          >
            代理
          </router-link>
        </nav>
      </aside>

      <main id="content">
        <router-view></router-view>
      </main>
    </div>

    <footer class="app-footer">
      <span class="app-footer-label">汉化技术支持：</span>
      <a
        class="app-footer-link"
        href="https://www.frpnat.com"
        target="_blank"
        rel="noreferrer"
      >
        FRPNAT
      </a>
    </footer>
  </div>
</template>

<script setup lang="ts">
import { ref, watch } from 'vue'
import { useRoute } from 'vue-router'
import { useDark } from '@vueuse/core'
import { Moon, Sunny } from '@element-plus/icons-vue'
import GitHubIcon from './assets/icons/github.svg?component'
import LogoIcon from './assets/icons/logo.svg?component'
import { useResponsive } from './composables/useResponsive'

const route = useRoute()
const isDark = useDark()
const { isMobile } = useResponsive()

const sidebarOpen = ref(false)

const toggleSidebar = () => {
  sidebarOpen.value = !sidebarOpen.value
}

const closeSidebar = () => {
  sidebarOpen.value = false
}

watch(
  () => route.path,
  () => {
    if (isMobile.value) {
      closeSidebar()
    }
  },
)
</script>

<style>
:root {
  --header-height: 50px;
  --sidebar-width: 200px;
  --header-bg: #ffffff;
  --header-border: #e4e7ed;
  --sidebar-bg: #ffffff;
  --text-primary: #303133;
  --text-secondary: #606266;
  --text-muted: #909399;
  --hover-bg: #efefef;
  --content-bg: #f9f9f9;
}

html.dark {
  --header-bg: #1e1e2e;
  --header-border: #3a3d5c;
  --sidebar-bg: #1e1e2e;
  --text-primary: #e5e7eb;
  --text-secondary: #b0b0b0;
  --text-muted: #888888;
  --hover-bg: #2a2a3e;
  --content-bg: #181825;
}

body {
  margin: 0;
  font-family:
    ui-sans-serif, -apple-system, system-ui, Segoe UI, Helvetica, Arial,
    sans-serif;
}

*,
:after,
:before {
  box-sizing: border-box;
  -webkit-tap-highlight-color: transparent;
}

html,
body {
  height: 100%;
  overflow: hidden;
}

#app {
  height: 100vh;
  height: 100dvh;
  display: flex;
  flex-direction: column;
  background-color: var(--content-bg);
}

.header {
  flex-shrink: 0;
  background: var(--header-bg);
  border-bottom: 1px solid var(--header-border);
  height: var(--header-height);
}

.header-content {
  display: flex;
  align-items: center;
  justify-content: space-between;
  height: 100%;
  padding: 0 20px;
}

.brand-section {
  display: flex;
  align-items: center;
  gap: 12px;
}

.logo-wrapper {
  display: flex;
  align-items: center;
}

.logo-icon {
  width: 28px;
  height: 28px;
}

.divider {
  color: var(--header-border);
  font-size: 22px;
  font-weight: 200;
}

.brand-name {
  font-weight: 600;
  font-size: 18px;
  color: var(--text-primary);
  letter-spacing: -0.5px;
}

.badge {
  font-size: 11px;
  font-weight: 500;
  color: var(--text-muted);
  background: var(--hover-bg);
  padding: 2px 8px;
  border-radius: 4px;
}

.badge.server-badge {
  background: linear-gradient(135deg, #3b82f6 0%, #06b6d4 100%);
  color: white;
  border: none;
  font-weight: 500;
}

html.dark .badge.server-badge {
  background: linear-gradient(135deg, #60a5fa 0%, #22d3ee 100%);
}

.header-controls {
  display: flex;
  align-items: center;
  gap: 16px;
}

.header-link {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 28px;
  height: 28px;
  border-radius: 6px;
  color: var(--text-secondary);
  transition: all 0.15s ease;
  text-decoration: none;
}

.header-link:hover {
  background: var(--hover-bg);
  color: var(--text-primary);
}

.header-link-icon {
  width: 18px;
  height: 18px;
}

.header-link-image {
  width: 18px;
  height: 18px;
  display: block;
  border-radius: 4px;
}

.header-link-badge {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 18px;
  height: 18px;
  border-radius: 5px;
  background: linear-gradient(135deg, #7cc7ff 0%, #0d47b8 100%);
  color: #ffffff;
  font-size: 12px;
  font-weight: 700;
  line-height: 1;
  font-family:
    ui-sans-serif, -apple-system, system-ui, Segoe UI, Helvetica, Arial,
    sans-serif;
  box-shadow: inset 0 0 0 1px rgba(255, 255, 255, 0.18);
}

.theme-switch {
  --el-switch-on-color: #2c2c3a;
  --el-switch-off-color: #f2f2f2;
  --el-switch-border-color: var(--header-border);
}

html.dark .theme-switch {
  --el-switch-off-color: #333;
}

.theme-switch .el-switch__core .el-switch__inner .el-icon {
  color: #909399 !important;
}

.layout {
  flex: 1;
  display: flex;
  overflow: hidden;
}

.app-footer {
  flex-shrink: 0;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  min-height: 42px;
  padding: 10px 16px;
  border-top: 1px solid var(--header-border);
  background: var(--header-bg);
  color: var(--text-muted);
  font-size: 13px;
}

.app-footer-label {
  color: var(--text-muted);
  font-weight: 600;
  letter-spacing: 0.04em;
}

.app-footer-link {
  text-decoration: none;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  min-width: 96px;
  min-height: 30px;
  padding: 0 14px;
  border-radius: 999px;
  background: linear-gradient(135deg, #7cc7ff 0%, #0d47b8 100%);
  color: #fff;
  font-size: 13px;
  font-weight: 800;
  letter-spacing: 0.08em;
  box-shadow:
    0 6px 18px rgba(13, 71, 184, 0.25),
    inset 0 0 0 1px rgba(255, 255, 255, 0.18);
  animation: frpnat-support-glow 2.6s ease-in-out infinite;
  transition:
    transform 0.15s ease,
    box-shadow 0.15s ease,
    filter 0.15s ease;
}

.app-footer-link:hover {
  text-decoration: none;
  transform: translateY(-1px);
  filter: brightness(1.03);
  box-shadow:
    0 10px 24px rgba(13, 71, 184, 0.32),
    inset 0 0 0 1px rgba(255, 255, 255, 0.24);
}

@keyframes frpnat-support-glow {
  0%,
  100% {
    box-shadow:
      0 6px 18px rgba(13, 71, 184, 0.24),
      inset 0 0 0 1px rgba(255, 255, 255, 0.18);
    transform: translateY(0);
  }

  50% {
    box-shadow:
      0 10px 26px rgba(13, 71, 184, 0.34),
      0 0 0 6px rgba(124, 199, 255, 0.12),
      inset 0 0 0 1px rgba(255, 255, 255, 0.22);
    transform: translateY(-1px);
  }
}

.sidebar {
  width: var(--sidebar-width);
  flex-shrink: 0;
  background: var(--sidebar-bg);
  border-right: 1px solid var(--header-border);
  padding: 16px 12px;
  overflow-y: auto;
  display: flex;
  flex-direction: column;
}

.sidebar-nav {
  display: flex;
  flex-direction: column;
  gap: 2px;
}

.sidebar-link {
  display: block;
  text-decoration: none;
  font-size: 15px;
  color: var(--text-secondary);
  padding: 10px 12px;
  border-radius: 6px;
  transition: all 0.15s ease;
}

.sidebar-link:hover {
  color: var(--text-primary);
  background: var(--hover-bg);
}

.sidebar-link.active {
  color: var(--text-primary);
  background: var(--hover-bg);
  font-weight: 500;
}

.hamburger-btn {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 36px;
  height: 36px;
  border: none;
  border-radius: 6px;
  background: transparent;
  cursor: pointer;
  padding: 0;
  transition: background 0.15s ease;
}

.hamburger-btn:hover {
  background: var(--hover-bg);
}

.hamburger-icon {
  font-size: 20px;
  line-height: 1;
  color: var(--text-primary);
}

.sidebar-overlay {
  position: fixed;
  inset: 0;
  background: rgba(0, 0, 0, 0.5);
  z-index: 99;
}

#content {
  flex: 1;
  min-width: 0;
  overflow-y: auto;
  padding: 40px;
}

#content > * {
  max-width: 1024px;
  margin: 0 auto;
}

.page-title {
  font-size: 20px;
  font-weight: 600;
  color: var(--color-text-primary, var(--text-primary));
  margin: 0;
}

.page-subtitle {
  font-size: 14px;
  color: var(--color-text-muted, var(--text-muted));
  margin: 8px 0 0;
}

.el-button {
  font-weight: 500;
}

.el-tag {
  font-weight: 500;
}

.el-switch {
  --el-switch-on-color: #606266;
  --el-switch-off-color: #dcdfe6;
}

html.dark .el-switch {
  --el-switch-on-color: #b0b0b0;
  --el-switch-off-color: #3a3d5c;
}

.el-form-item {
  margin-bottom: 16px;
}

.el-loading-mask {
  border-radius: 8px;
}

.el-select__wrapper {
  border-radius: 8px !important;
  box-shadow: 0 0 0 1px var(--color-border-light, #e4e7ed) inset !important;
  transition: all 0.15s ease;
}

.el-select__wrapper:hover {
  box-shadow: 0 0 0 1px var(--color-border, #dcdfe6) inset !important;
}

.el-select__wrapper.is-focused {
  box-shadow: 0 0 0 1px var(--color-border, #dcdfe6) inset !important;
}

.el-select-dropdown {
  border-radius: 12px !important;
  border: 1px solid var(--color-border-light, #e4e7ed) !important;
  box-shadow:
    0 10px 25px -5px rgba(0, 0, 0, 0.1),
    0 8px 10px -6px rgba(0, 0, 0, 0.1) !important;
  padding: 4px !important;
}

.el-select-dropdown__item {
  border-radius: 6px;
  margin: 2px 0;
  transition: background 0.15s ease;
}

.el-select-dropdown__item.is-selected {
  color: var(--color-text-primary, var(--text-primary));
  font-weight: 500;
}

.el-input__wrapper {
  border-radius: 8px !important;
  box-shadow: 0 0 0 1px var(--color-border-light, #e4e7ed) inset !important;
  transition: all 0.15s ease;
}

.el-input__wrapper:hover {
  box-shadow: 0 0 0 1px var(--color-border, #dcdfe6) inset !important;
}

.el-input__wrapper.is-focus {
  box-shadow: 0 0 0 1px var(--color-border, #dcdfe6) inset !important;
}

.el-card {
  border-radius: 12px;
  border: 1px solid var(--color-border-light, #e4e7ed);
  transition: all 0.2s ease;
}

::-webkit-scrollbar {
  width: 6px;
  height: 6px;
}

::-webkit-scrollbar-track {
  background: transparent;
}

::-webkit-scrollbar-thumb {
  background: #d1d1d1;
  border-radius: 3px;
}

@media (max-width: 767px) {
  .header-content {
    padding: 0 16px;
  }

  .header-controls {
    gap: 10px;
  }

  .sidebar {
    position: fixed;
    top: var(--header-height);
    left: 0;
    bottom: 0;
    z-index: 100;
    background: var(--sidebar-bg);
    transform: translateX(-100%);
    transition: transform 0.25s cubic-bezier(0.4, 0, 0.2, 1);
    border-right: 1px solid var(--header-border);
  }

  .sidebar.mobile-open {
    transform: translateX(0);
  }

  #content {
    width: 100%;
    padding: 20px;
  }

  .app-footer {
    padding: 10px 12px;
    text-align: center;
  }
}
</style>
