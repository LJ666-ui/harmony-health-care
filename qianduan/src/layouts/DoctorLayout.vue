<script setup>
import { ref, computed } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { useUserStore } from '@/stores/user'
import { useAppStore } from '@/stores/app'

const router = useRouter()
const route = useRoute()
const userStore = useUserStore()
const appStore = useAppStore()

const activeMenu = computed(() => route.path)

const menuItems = [
  { path: '/doctor/home', name: '工作台', icon: '🏠' },
  { path: '/doctor/appointment', name: '预约管理', icon: '📅' },
  { path: '/doctor/transfer', name: '转诊管理', icon: '🔄' },
  { path: '/doctor/medical-record', name: '病历管理', icon: '📋' },
  { path: '/doctor/medication', name: '用药管理', icon: '💊' },
  { path: '/doctor/patients', name: '患者管理', icon: '👥' },
  { path: '/doctor/consultation', name: '在线问诊', icon: '💬' },
  { path: '/doctor/digital-twin', name: '健康画像', icon: '🫀' },
  { path: '/doctor/ar-rehab', name: 'AR康复', icon: '🏋️' },
  { path: '/doctor/knowledge-qa', name: '图谱问答', icon: '🔬' },
  { path: '/doctor/emotion', name: '情感分析', icon: '💭' },
  { path: '/doctor/virtual-ward', name: '虚拟病房', icon: '🏥' },
  { path: '/doctor/drug-interaction', name: '药物检测', icon: '💊' },
  { path: '/doctor/dialect', name: '方言问诊', icon: '🗣️' },
  { path: '/doctor/profile', name: '个人设置', icon: '👤' },
  { path: '/doctor/settings', name: '系统设置', icon: '⚙️' }
]

const handleLogout = () => {
  userStore.logout()
  router.push('/login')
}
</script>

<template>
  <div class="layout-container">
    <aside class="sidebar" :class="{ 'collapsed': !appStore.sidebarOpened }">
      <div class="logo">
        <span class="logo-icon">🩺</span>
        <span class="logo-text" v-if="appStore.sidebarOpened">医生工作台</span>
      </div>
      <div class="user-info" v-if="appStore.sidebarOpened">
        <div class="user-avatar">{{ (userStore.userInfo?.realName || userStore.userInfo?.username || 'D').charAt(0) }}</div>
        <div class="user-detail">
          <div class="user-name">{{ userStore.userInfo?.realName || userStore.userInfo?.username }}</div>
          <div class="user-role">医生</div>
        </div>
      </div>
      <el-menu :default-active="activeMenu" class="sidebar-menu" mode="vertical" @select="(key) => router.push(key)">
        <el-menu-item v-for="item in menuItems" :key="item.path" :index="item.path">
          <span class="menu-icon">{{ item.icon }}</span>
          <span v-if="appStore.sidebarOpened">{{ item.name }}</span>
        </el-menu-item>
      </el-menu>
    </aside>
    <main class="main-content" :class="{ 'expanded': !appStore.sidebarOpened }">
      <header class="header">
        <div class="header-left">
          <button class="menu-toggle" @click="appStore.toggleSidebar"><span class="icon-menu">☰</span></button>
          <h2>{{ menuItems.find(item => item.path === activeMenu)?.name || '工作台' }}</h2>
        </div>
        <div class="header-right">
          <el-dropdown>
            <span class="user-info-header">
              <span class="user-avatar-sm">{{ (userStore.userInfo?.realName || userStore.userInfo?.username || 'D').charAt(0) }}</span>
              <span class="user-name">{{ userStore.userInfo?.realName || userStore.userInfo?.username }}</span>
              <span class="caret">▼</span>
            </span>
            <template #dropdown>
              <el-dropdown-menu>
                <el-dropdown-item @click="router.push('/doctor/profile')">个人设置</el-dropdown-item>
                <el-dropdown-item divided @click="handleLogout">退出登录</el-dropdown-item>
              </el-dropdown-menu>
            </template>
          </el-dropdown>
        </div>
      </header>
      <div class="content-wrapper"><router-view /></div>
    </main>
  </div>
</template>

<style lang="scss" scoped>
.layout-container { display: flex; min-height: 100vh; background: #f0f2f5; }
.sidebar { width: 220px; background: linear-gradient(180deg, #1a3a2e 0%, #162e1e 100%); color: #fff; transition: width 0.3s; position: fixed; left: 0; top: 0; bottom: 0; z-index: 100; display: flex; flex-direction: column;
  &.collapsed { width: 64px; .logo-text, .user-info, .user-detail { display: none; } .el-menu-item span:last-child { display: none; } .menu-icon { font-size: 20px; } }
}
.logo { padding: 20px; display: flex; align-items: center; gap: 10px; border-bottom: 1px solid rgba(255,255,255,0.1);
  .logo-icon { font-size: 24px; } .logo-text { font-size: 18px; font-weight: bold; color: #fff; }
}
.user-info { padding: 16px 20px; display: flex; align-items: center; gap: 12px; border-bottom: 1px solid rgba(255,255,255,0.1);
  .user-avatar { width: 40px; height: 40px; border-radius: 50%; background: #4caf50; display: flex; align-items: center; justify-content: center; font-size: 16px; font-weight: bold; flex-shrink: 0; }
  .user-detail { .user-name { font-size: 14px; font-weight: 500; } .user-role { font-size: 12px; color: rgba(255,255,255,0.6); } }
}
.sidebar-menu { border-right: none; background: transparent; margin-top: 10px; flex: 1; overflow-y: auto; overflow-x: hidden;
  &::-webkit-scrollbar { width: 4px; }
  &::-webkit-scrollbar-track { background: rgba(255,255,255,0.05); border-radius: 2px; }
  &::-webkit-scrollbar-thumb { background: rgba(255,255,255,0.2); border-radius: 2px; &:hover { background: rgba(255,255,255,0.3); } }
  .el-menu-item { color: rgba(255,255,255,0.7); margin: 4px 10px; border-radius: 8px; height: 44px; line-height: 44px;
    &:hover, &.is-active { background: rgba(76,175,80,0.3); color: #fff; }
    .menu-icon { font-size: 18px; margin-right: 8px; }
  }
}
.main-content { flex: 1; margin-left: 220px; transition: margin-left 0.3s; &.expanded { margin-left: 64px; } }
.header { display: flex; justify-content: space-between; align-items: center; padding: 15px 24px; background: #fff; box-shadow: 0 1px 4px rgba(0,0,0,0.08); position: sticky; top: 0; z-index: 50; }
.header-left { display: flex; align-items: center; gap: 15px; h2 { font-size: 18px; color: #333; margin: 0; } }
.menu-toggle { background: none; border: none; font-size: 20px; cursor: pointer; color: #666; &:hover { color: #4caf50; } }
.header-right { display: flex; align-items: center; }
.user-info-header { display: flex; align-items: center; gap: 8px; cursor: pointer; padding: 6px 12px;
  .user-avatar-sm { width: 32px; height: 32px; border-radius: 50%; background: #4caf50; color: #fff; display: flex; align-items: center; justify-content: center; font-size: 14px; font-weight: bold; }
  .user-name { font-size: 14px; color: #333; } .caret { font-size: 12px; color: #999; }
}
.content-wrapper { padding: 20px; }
</style>
