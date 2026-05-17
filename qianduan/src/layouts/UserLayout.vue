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
  { path: '/user/home', name: '首页', icon: '🏠' },
  { path: '/user/appointment', name: '预约挂号', icon: '📅' },
  { path: '/user/article', name: '健康文章', icon: '📄' },
  { path: '/user/hospital', name: '医院查询', icon: '🏥' },
  { path: '/user/medical-record', name: '我的病历', icon: '📋' },
  { path: '/user/health-record', name: '健康监测', icon: '❤️' },
  { path: '/user/medical-team', name: '我的医护', icon: '🩺' },
  { path: '/user/knowledge', name: '知识图谱', icon: '🔗' },
  { path: '/user/ai', name: 'AI助手', icon: '🤖' },
  { path: '/user/risk', name: '风险评估', icon: '⚠️' },
  { path: '/user/herbal', name: '中药材百科', icon: '🌿' },
  { path: '/user/doctor-search', name: '医生查询', icon: '🔍' },
  { path: '/user/consultation', name: '在线问诊', icon: '💬' },
  { path: '/user/profile', name: '个人设置', icon: '👤' },
  { path: '/user/settings', name: '系统设置', icon: '⚙️' }
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
        <span class="logo-icon">🏥</span>
        <span class="logo-text" v-if="appStore.sidebarOpened">智慧医疗</span>
      </div>

      <div class="user-info" v-if="appStore.sidebarOpened">
        <div class="user-avatar">{{ (userStore.userInfo?.realName || userStore.userInfo?.username || 'U').charAt(0) }}</div>
        <div class="user-detail">
          <div class="user-name">{{ userStore.userInfo?.realName || userStore.userInfo?.username }}</div>
          <div class="user-role">普通用户</div>
        </div>
      </div>

      <el-menu
        :default-active="activeMenu"
        class="sidebar-menu"
        mode="vertical"
        @select="(key) => router.push(key)"
      >
        <el-menu-item
          v-for="item in menuItems"
          :key="item.path"
          :index="item.path"
        >
          <span class="menu-icon">{{ item.icon }}</span>
          <span v-if="appStore.sidebarOpened">{{ item.name }}</span>
        </el-menu-item>
      </el-menu>
    </aside>

    <main class="main-content" :class="{ 'expanded': !appStore.sidebarOpened }">
      <header class="header">
        <div class="header-left">
          <button class="menu-toggle" @click="appStore.toggleSidebar">
            <span class="icon-menu">☰</span>
          </button>
          <h2>{{ menuItems.find(item => item.path === activeMenu)?.name || '首页' }}</h2>
        </div>

        <div class="header-right">
          <el-dropdown>
            <span class="user-info-header">
              <span class="user-avatar-sm">{{ (userStore.userInfo?.realName || userStore.userInfo?.username || 'U').charAt(0) }}</span>
              <span class="user-name">{{ userStore.userInfo?.realName || userStore.userInfo?.username }}</span>
              <span class="caret">▼</span>
            </span>
            <template #dropdown>
              <el-dropdown-menu>
                <el-dropdown-item @click="router.push('/user/profile')">个人设置</el-dropdown-item>
                <el-dropdown-item divided @click="handleLogout">退出登录</el-dropdown-item>
              </el-dropdown-menu>
            </template>
          </el-dropdown>
        </div>
      </header>

      <div class="content-wrapper">
        <router-view />
      </div>
    </main>
  </div>
</template>

<style lang="scss" scoped>
.layout-container {
  display: flex;
  min-height: 100vh;
  background: #f0f2f5;
}

.sidebar {
  width: 220px;
  background: linear-gradient(180deg, #1a1a2e 0%, #16213e 100%);
  color: #fff;
  transition: width 0.3s;
  position: fixed;
  left: 0;
  top: 0;
  bottom: 0;
  z-index: 100;
  display: flex;
  flex-direction: column;

  &.collapsed {
    width: 64px;

    .logo-text, .user-info, .user-detail {
      display: none;
    }

    .el-menu-item span:last-child {
      display: none;
    }

    .menu-icon {
      font-size: 20px;
    }
  }
}

.logo {
  padding: 20px;
  display: flex;
  align-items: center;
  gap: 10px;
  border-bottom: 1px solid rgba(255, 255, 255, 0.1);

  .logo-icon {
    font-size: 24px;
  }

  .logo-text {
    font-size: 18px;
    font-weight: bold;
    color: #fff;
  }
}

.user-info {
  padding: 16px 20px;
  display: flex;
  align-items: center;
  gap: 12px;
  border-bottom: 1px solid rgba(255, 255, 255, 0.1);

  .user-avatar {
    width: 40px;
    height: 40px;
    border-radius: 50%;
    background: #667eea;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 16px;
    font-weight: bold;
    flex-shrink: 0;
  }

  .user-detail {
    .user-name {
      font-size: 14px;
      font-weight: 500;
    }

    .user-role {
      font-size: 12px;
      color: rgba(255, 255, 255, 0.6);
    }
  }
}

.sidebar-menu {
  border-right: none;
  background: transparent;
  margin-top: 10px;
  flex: 1;

  .el-menu-item {
    color: rgba(255, 255, 255, 0.7);
    margin: 4px 10px;
    border-radius: 8px;
    height: 44px;
    line-height: 44px;

    &:hover, &.is-active {
      background: rgba(102, 126, 234, 0.3);
      color: #fff;
    }

    .menu-icon {
      font-size: 18px;
      margin-right: 8px;
    }
  }
}

.main-content {
  flex: 1;
  margin-left: 220px;
  transition: margin-left 0.3s;

  &.expanded {
    margin-left: 64px;
  }
}

.header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 15px 24px;
  background: #fff;
  box-shadow: 0 1px 4px rgba(0, 0, 0, 0.08);
  position: sticky;
  top: 0;
  z-index: 50;
}

.header-left {
  display: flex;
  align-items: center;
  gap: 15px;

  h2 {
    font-size: 18px;
    color: #333;
    margin: 0;
  }
}

.menu-toggle {
  background: none;
  border: none;
  font-size: 20px;
  cursor: pointer;
  color: #666;

  &:hover {
    color: #667eea;
  }
}

.header-right {
  display: flex;
  align-items: center;
}

.user-info-header {
  display: flex;
  align-items: center;
  gap: 8px;
  cursor: pointer;
  padding: 6px 12px;

  .user-avatar-sm {
    width: 32px;
    height: 32px;
    border-radius: 50%;
    background: #667eea;
    color: #fff;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 14px;
    font-weight: bold;
  }

  .user-name {
    font-size: 14px;
    color: #333;
  }

  .caret {
    font-size: 12px;
    color: #999;
  }
}

.content-wrapper {
  padding: 20px;
}
</style>
