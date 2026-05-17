<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useUserStore } from '@/stores/user'
import articleApi from '@/api/article'
import hospitalApi from '@/api/hospital'
import healthRecordApi from '@/api/healthRecord'

const router = useRouter()
const userStore = useUserStore()

const recentArticles = ref([])
const recentHospitals = ref([])
const healthSummary = ref(null)
const loading = ref(false)

const quickLinks = [
  { name: '健康文章', icon: '📄', path: '/user/article', color: '#667eea' },
  { name: '医院查询', icon: '🏥', path: '/user/hospital', color: '#48bb78' },
  { name: '我的病历', icon: '📋', path: '/user/medical-record', color: '#ed8936' },
  { name: '健康监测', icon: '❤️', path: '/user/health-record', color: '#f56565' },
  { name: '知识图谱', icon: '🔗', path: '/user/knowledge', color: '#9f7aea' },
  { name: 'AI助手', icon: '🤖', path: '/user/ai', color: '#38b2ac' },
  { name: '风险评估', icon: '⚠️', path: '/user/risk', color: '#e53e3e' },
  { name: '系统设置', icon: '⚙️', path: '/user/settings', color: '#718096' }
]

const loadHomeData = async () => {
  loading.value = true
  try {
    const [articlesRes, hospitalsRes] = await Promise.allSettled([
      articleApi.getPage({ page: 1, pageSize: 5 }),
      hospitalApi.getPage({ page: 1, size: 5 })
    ])
    if (articlesRes.status === 'fulfilled') {
      recentArticles.value = articlesRes.value.list || articlesRes.value.records || []
    }
    if (hospitalsRes.status === 'fulfilled') {
      const hData = hospitalsRes.value
      recentHospitals.value = hData.records || hData.list || []
    }
  } catch (error) {
    console.error(error)
  } finally {
    loading.value = false
  }
}

onMounted(() => {
  loadHomeData()
})
</script>

<template>
  <div class="user-home">
    <div class="welcome-section">
      <div class="welcome-text">
        <h1>欢迎回来，{{ userStore.userInfo?.username || '用户' }}</h1>
        <p>智慧医疗系统 — 您的健康管理助手</p>
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
          <h3>最新健康文章</h3>
          <el-button text type="primary" @click="router.push('/user/article')">查看更多</el-button>
        </div>
        <div class="article-list">
          <div v-for="article in recentArticles" :key="article.id" class="article-item">
            <div class="article-info">
              <h4>{{ article.title }}</h4>
              <p>{{ article.author }} · {{ article.publishTime }}</p>
            </div>
          </div>
          <el-empty v-if="recentArticles.length === 0" description="暂无文章" />
        </div>
      </div>

      <div class="content-panel">
        <div class="panel-header">
          <h3>推荐医院</h3>
          <el-button text type="primary" @click="router.push('/user/hospital')">查看更多</el-button>
        </div>
        <div class="hospital-list">
          <div v-for="hospital in recentHospitals" :key="hospital.id" class="hospital-item">
            <div class="hospital-info">
              <h4>{{ hospital.name }}</h4>
              <p>{{ hospital.level }} · {{ hospital.address }}</p>
            </div>
          </div>
          <el-empty v-if="recentHospitals.length === 0" description="暂无医院数据" />
        </div>
      </div>
    </div>
  </div>
</template>

<style lang="scss" scoped>
.user-home {
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

.article-item, .hospital-item {
  padding: 12px 0;
  border-bottom: 1px solid #f0f0f0;

  &:last-child {
    border-bottom: none;
  }

  h4 {
    font-size: 14px;
    color: #333;
    margin: 0 0 4px;
  }

  p {
    font-size: 12px;
    color: #999;
    margin: 0;
  }
}
</style>
