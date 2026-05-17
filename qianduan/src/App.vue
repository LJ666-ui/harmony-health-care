<script setup>
import { useAppStore } from '@/stores/app'

const appStore = useAppStore()
</script>

<template>
  <div :class="['app-container', { 'mobile': appStore.isMobile }]">
    <router-view v-slot="{ Component }">
      <transition name="fade" mode="out-in">
        <component :is="Component" />
      </transition>
    </router-view>
  </div>
</template>

<style lang="scss">
* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

body {
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
  font-size: 14px;
  background-color: #f5f7fa;
  color: #333;
}

.app-container {
  min-height: 100vh;
}

.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.3s ease;
}

.fade-enter-from,
.fade-leave-to {
  opacity: 0;
}

.el-table {
  --el-table-header-text-color: #606266;
  --el-table-row-hover-bg-color: #f5f7fa;
}
</style>
