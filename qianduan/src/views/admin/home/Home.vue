<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useUserStore } from '@/stores/user'
import userApi from '@/api/user'

const router = useRouter()
const userStore = useUserStore()

const adminInfo = ref(null)

const quickLinks = [
  { name: '用户管理', icon: '👥', path: '/admin/user', color: '#667eea' },
  { name: '医生管理', icon: '👨‍⚕️', path: '/admin/doctor', color: '#48bb78' },
  { name: '护士管理', icon: '👩‍⚕️', path: '/admin/nurse', color: '#ed8936' },
  { name: '医院管理', icon: '🏥', path: '/admin/hospital', color: '#f56565' },
  { name: '文章管理', icon: '📄', path: '/admin/article', color: '#9f7aea' },
  { name: '预约管理', icon: '📅', path: '/admin/appointment', color: '#38b2ac' },
  { name: '转诊管理', icon: '🔄', path: '/admin/transfer', color: '#e53e3e' },
  { name: '系统设置', icon: '⚙️', path: '/admin/settings', color: '#718096' }
]

const loadAdminInfo = async () => {
  try {
    const userId = userStore.userInfo?.userId || userStore.userInfo?.id
    if (userId) {
      const res = await userApi.getUserDetail(userId)
      adminInfo.value = res
    }
  } catch (e) {
    adminInfo.value = null
  }
}

const formatDate = (dateStr) => {
  if (!dateStr) return '-'
  const d = new Date(dateStr)
  return d.toLocaleString('zh-CN', { year: 'numeric', month: '2-digit', day: '2-digit', hour: '2-digit', minute: '2-digit' })
}

onMounted(() => {
  loadAdminInfo()
})
</script>

<template>
  <div class="admin-home">
    <div class="welcome-section">
      <div class="welcome-text">
        <h1>欢迎回来，{{ userStore.userInfo?.realName || userStore.userInfo?.username || '管理员' }}</h1>
        <p>智慧医疗管理系统 — 管理后台</p>
      </div>
    </div>

    <div class="quick-links">
      <div
        v-for="link in quickLinks"
        :key="link.name"
        class="quick-card"
        @click="router.push(link.path)"
      >
        <div class="card-icon" :style="{ backgroundColor: link.color + '15' }">
          <span :style="{ color: link.color }">{{ link.icon }}</span>
        </div>
        <span class="card-name">{{ link.name }}</span>
      </div>
    </div>

    <div class="content-row">
      <div class="content-panel">
        <div class="panel-header">
          <h3>管理员信息</h3>
        </div>
        <div class="info-grid" v-if="adminInfo || userStore.userInfo">
          <div class="info-item">
            <span class="info-label">用户名</span>
            <span class="info-value">{{ adminInfo?.username || userStore.userInfo?.username || '-' }}</span>
          </div>
          <div class="info-item">
            <span class="info-label">真实姓名</span>
            <span class="info-value">{{ adminInfo?.realName || userStore.userInfo?.realName || '-' }}</span>
          </div>
          <div class="info-item">
            <span class="info-label">手机号</span>
            <span class="info-value">{{ adminInfo?.phone || userStore.userInfo?.phone || '-' }}</span>
          </div>
          <div class="info-item">
            <span class="info-label">邮箱</span>
            <span class="info-value">{{ adminInfo?.email || userStore.userInfo?.email || '-' }}</span>
          </div>
          <div class="info-item">
            <span class="info-label">角色</span>
            <span class="info-value"><el-tag type="warning">系统管理员</el-tag></span>
          </div>
          <div class="info-item">
            <span class="info-label">账号状态</span>
            <span class="info-value"><el-tag type="success">启用</el-tag></span>
          </div>
          <div class="info-item">
            <span class="info-label">注册时间</span>
            <span class="info-value">{{ formatDate(adminInfo?.createTime || userStore.userInfo?.createTime) }}</span>
          </div>
          <div class="info-item">
            <span class="info-label">最后登录</span>
            <span class="info-value">{{ formatDate(adminInfo?.lastLoginTime || userStore.userInfo?.lastLoginTime) }}</span>
          </div>
        </div>
      </div>

      <div class="content-panel">
        <div class="panel-header">
          <h3>系统概况</h3>
        </div>
        <div class="system-info">
          <div class="sys-item">
            <span class="sys-icon" style="background-color: #667eea15; color: #667eea;">🛡️</span>
            <div class="sys-detail">
              <span class="sys-label">系统名称</span>
              <span class="sys-value">和美医疗管理系统</span>
            </div>
          </div>
          <div class="sys-item">
            <span class="sys-icon" style="background-color: #48bb7815; color: #48bb78;">📊</span>
            <div class="sys-detail">
              <span class="sys-label">系统版本</span>
              <span class="sys-value">v1.0.0</span>
            </div>
          </div>
          <div class="sys-item">
            <span class="sys-icon" style="background-color: #ed893615; color: #ed8936;">🌐</span>
            <div class="sys-detail">
              <span class="sys-label">运行环境</span>
              <span class="sys-value">生产环境</span>
            </div>
          </div>
          <div class="sys-item">
            <span class="sys-icon" style="background-color: #9f7aea15; color: #9f7aea;">🔒</span>
            <div class="sys-detail">
              <span class="sys-label">安全等级</span>
              <span class="sys-value">高</span>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<style lang="scss" scoped>
.admin-home {
  max-width: 1200px;
  margin: 0 auto;
}

.welcome-section {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border-radius: 16px;
  padding: 32px;
  color: #fff;
  margin-bottom: 24px;

  h1 {
    font-size: 24px;
    margin: 0 0 8px;
  }

  p {
    font-size: 14px;
    opacity: 0.85;
    margin: 0;
  }
}

.quick-links {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 16px;
  margin-bottom: 24px;

  @media (max-width: 768px) {
    grid-template-columns: repeat(2, 1fr);
  }
}

.quick-card {
  background: #fff;
  border-radius: 12px;
  padding: 20px;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 10px;
  cursor: pointer;
  transition: all 0.3s;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);

  &:hover {
    transform: translateY(-4px);
    box-shadow: 0 8px 24px rgba(0, 0, 0, 0.1);
  }

  .card-icon {
    width: 48px;
    height: 48px;
    border-radius: 12px;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 24px;
  }

  .card-name {
    font-size: 14px;
    color: #333;
  }
}

.content-row {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 20px;

  @media (max-width: 768px) {
    grid-template-columns: 1fr;
  }
}

.content-panel {
  background: #fff;
  border-radius: 12px;
  padding: 20px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
}

.panel-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;

  h3 {
    font-size: 16px;
    color: #333;
    margin: 0;
  }
}

.info-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 16px;
}

.info-item {
  display: flex;
  flex-direction: column;
  gap: 4px;

  .info-label {
    font-size: 12px;
    color: #999;
  }

  .info-value {
    font-size: 14px;
    color: #333;
  }
}

.system-info {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.sys-item {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 12px;
  background: #f5f7fa;
  border-radius: 10px;

  .sys-icon {
    width: 40px;
    height: 40px;
    border-radius: 10px;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 18px;
    flex-shrink: 0;
  }

  .sys-detail {
    display: flex;
    flex-direction: column;
    gap: 2px;

    .sys-label {
      font-size: 12px;
      color: #999;
    }

    .sys-value {
      font-size: 14px;
      color: #333;
      font-weight: 500;
    }
  }
}
</style>
