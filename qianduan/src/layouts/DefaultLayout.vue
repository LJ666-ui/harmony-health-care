<script setup>
import { ref, computed } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { useI18n } from 'vue-i18n'
import { useUserStore } from '@/stores/user'
import { useAppStore } from '@/stores/app'

const router = useRouter()
const route = useRoute()
const { t, locale } = useI18n()
const userStore = useUserStore()
const appStore = useAppStore()

const activeMenu = computed(() => route.path)

const menuItems = [
  { path: '/admin/home', name: 'home', icon: '🏠' },
  { path: '/admin/user', name: 'userManagement', icon: '👥' },
  { path: '/admin/admin', name: 'adminManagement', icon: '🛡️' },
  { path: '/admin/doctor', name: 'doctorManagement', icon: '👨‍⚕️' },
  { path: '/admin/family', name: 'familyManagement', icon: '👨‍👩‍👧' },
  { path: '/admin/nurse', name: 'nurseManagement', icon: '👩‍⚕️' },
  { path: '/admin/article', name: 'articleManagement', icon: '📄' },
  { path: '/admin/hospital', name: 'hospitalManagement', icon: '🏥' },
  { path: '/admin/medical-record', name: 'medicalRecord', icon: '📋' },
  { path: '/admin/health-record', name: 'healthMonitoring', icon: '❤️' },
  { path: '/admin/herbal', name: 'herbalMedicine', icon: '🌿' },
  { path: '/admin/medicine', name: 'medicineManagement', icon: '💊' },
  { path: '/admin/knowledge', name: 'knowledgeGraph', icon: '🔗' },
  { path: '/admin/risk', name: 'riskAssessment', icon: '⚠️' },
  { path: '/admin/ai', name: 'aiAssistant', icon: '🤖' },
  { path: '/admin/appointment', name: 'appointmentManagement', icon: '📅' },
  { path: '/admin/transfer', name: 'transferManagement', icon: '🔄' },
  { path: '/admin/settings', name: 'systemSettings', icon: '⚙️' },
  { path: '/admin/log', name: 'operLog', icon: '📝' }
]

const handleLogout = () => {
  userStore.logout()
  router.push('/login')
}

const changeLanguage = () => {
  const newLang = locale.value === 'zh-CN' ? 'en-US' : 'zh-CN'
  locale.value = newLang
  appStore.setLanguage(newLang)
}
</script>

<template>
  <div class="layout-container">
    <aside class="sidebar" :class="{ 'collapsed': !appStore.sidebarOpened }">
      <div class="logo">
        <span class="logo-icon">🛡️</span>
        <span class="logo-text" v-if="appStore.sidebarOpened">管理后台</span>
      </div>

      <div class="admin-info" v-if="appStore.sidebarOpened">
        <div class="admin-avatar">{{ (userStore.userInfo?.realName || userStore.userInfo?.username || 'A').charAt(0) }}</div>
        <div class="admin-detail">
          <div class="admin-name">{{ userStore.userInfo?.realName || userStore.userInfo?.username }}</div>
          <div class="admin-role">系统管理员</div>
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
          <span v-if="appStore.sidebarOpened">{{ t(`sidebar.${item.name}`) || item.name }}</span>
        </el-menu-item>
      </el-menu>
    </aside>

    <main class="main-content" :class="{ 'expanded': !appStore.sidebarOpened }">
      <header class="header">
        <div class="header-left">
          <button class="menu-toggle" @click="appStore.toggleSidebar">
            <span class="icon-menu">☰</span>
          </button>
          <h2>{{ t(`sidebar.${menuItems.find(item => item.path === activeMenu)?.name}`) || 'Dashboard' }}</h2>
        </div>

        <div class="header-right">
          <button class="lang-btn" @click="changeLanguage">
            {{ locale === 'zh-CN' ? 'EN' : '中文' }}
          </button>

          <el-dropdown>
            <span class="user-info">
              <span class="user-name">{{ userStore.userInfo?.realName || userStore.userInfo?.username }}</span>
              <span class="caret">▼</span>
            </span>
            <template #dropdown>
              <el-dropdown-menu>
                <el-dropdown-item @click="handleLogout">
                  <span>{{ t('sidebar.logout') }}</span>
                </el-dropdown-item>
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
  background: #f5f7fa;
}

.sidebar {
  width: 220px;
  background: #2d3748;
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

    .logo-text, .admin-info, .admin-detail {
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
  border-bottom: 1px solid #4a5568;

  .logo-icon {
    font-size: 24px;
  }

  .logo-text {
    font-size: 18px;
    font-weight: bold;
    color: #fff;
  }
}

.admin-info {
  padding: 16px 20px;
  display: flex;
  align-items: center;
  gap: 12px;
  border-bottom: 1px solid #4a5568;

  .admin-avatar {
    width: 40px;
    height: 40px;
    border-radius: 50%;
    background: #ed8936;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 16px;
    font-weight: bold;
    flex-shrink: 0;
  }

  .admin-detail {
    .admin-name {
      font-size: 14px;
      font-weight: 500;
    }

    .admin-role {
      font-size: 12px;
      color: #a0aec0;
    }
  }
}

.sidebar-menu {
  border-right: none;
  background: transparent;
  margin-top: 10px;
  flex: 1;
  overflow-y: auto;

  .el-menu-item {
    color: #a0aec0;
    margin: 4px 10px;
    border-radius: 8px;
    height: 44px;
    line-height: 44px;

    &:hover, &.is-active {
      background: #4a5568;
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
  padding: 15px 20px;
  background: #fff;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
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
  gap: 20px;
}

.lang-btn {
  padding: 6px 12px;
  background: #f5f7fa;
  border: 1px solid #e2e8f0;
  border-radius: 6px;
  cursor: pointer;
  font-size: 12px;
  color: #666;

  &:hover {
    background: #e2e8f0;
  }
}

.user-info {
  display: flex;
  align-items: center;
  gap: 8px;
  cursor: pointer;
  padding: 6px 12px;

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
