<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import * as echarts from 'echarts'
import statisticsApi from '@/api/statistics'
import userApi from '@/api/user'
import articleApi from '@/api/article'
import hospitalApi from '@/api/hospital'

const router = useRouter()

const stats = ref([
  { label: '今日访问', value: 0, icon: '👁', color: '#667eea' },
  { label: '总用户数', value: 0, icon: '👥', color: '#48bb78' },
  { label: '文章数量', value: 0, icon: '📄', color: '#ed8936' },
  { label: '医院数量', value: 0, icon: '🏥', color: '#9f7aea' }
])

const chartRef = ref(null)
let chartInstance = null

const loadStats = async () => {
  try {
    const overview = await statisticsApi.getOverview()
    if (overview) {
      stats.value[0].value = overview.todayVisits || 0
      stats.value[1].value = overview.totalUsers || 0
      stats.value[2].value = overview.totalArticles || 0
      stats.value[3].value = overview.totalHospitals || 0
    }
  } catch (error) {
    try {
      const [userRes, articleRes, hospitalRes] = await Promise.allSettled([
        userApi.getUserList({ page: 1, pageSize: 1 }),
        articleApi.getPage({ page: 1, pageSize: 1 }),
        hospitalApi.getPage({ page: 1, size: 1 })
      ])
      if (userRes.status === 'fulfilled') stats.value[1].value = userRes.value.total || 0
      if (articleRes.status === 'fulfilled') stats.value[2].value = articleRes.value.total || 0
      if (hospitalRes.status === 'fulfilled') stats.value[3].value = hospitalRes.value.total || 0
    } catch (e) {
      console.error(e)
    }
  }
}

const initChart = () => {
  if (chartRef.value) {
    chartInstance = echarts.init(chartRef.value)
    const option = {
      title: { text: '健康数据趋势', left: 'center', textStyle: { fontSize: 16, color: '#333' } },
      tooltip: { trigger: 'axis' },
      legend: { data: ['血压', '血糖', '心率'], bottom: 10 },
      grid: { left: '3%', right: '4%', bottom: '15%', top: '15%', containLabel: true },
      xAxis: { type: 'category', boundaryGap: false, data: ['周一', '周二', '周三', '周四', '周五', '周六', '周日'] },
      yAxis: { type: 'value' },
      series: [
        { name: '血压', type: 'line', smooth: true, data: [120, 125, 118, 130, 122, 128, 124] },
        { name: '血糖', type: 'line', smooth: true, data: [5.2, 5.5, 4.8, 5.8, 5.1, 5.3, 4.9] },
        { name: '心率', type: 'line', smooth: true, data: [72, 75, 70, 78, 74, 76, 71] }
      ]
    }
    chartInstance.setOption(option)
  }
}

const recentActivities = ref([])

const loadRecentActivities = async () => {
  try {
    const res = await statisticsApi.getRecentActivities(10)
    recentActivities.value = (res || []).map(item => ({
      id: item.id,
      type: item.type || '操作',
      user: item.user || '未知',
      desc: item.desc || '',
      time: formatTime(item.time)
    }))
  } catch (e) {
    recentActivities.value = []
  }
}

const formatTime = (time) => {
  if (!time) return ''
  const date = new Date(time)
  const now = new Date()
  const diff = now - date
  if (diff < 60000) return '刚刚'
  if (diff < 3600000) return Math.floor(diff / 60000) + '分钟前'
  if (diff < 86400000) return Math.floor(diff / 3600000) + '小时前'
  if (diff < 604800000) return Math.floor(diff / 86400000) + '天前'
  return date.toLocaleDateString()
}

const quickActions = [
  { name: '添加文章', icon: '📝', path: '/admin/article' },
  { name: '添加医院', icon: '🏥', path: '/admin/hospital' },
  { name: '查看病历', icon: '📋', path: '/admin/medical-record' },
  { name: '健康监测', icon: '❤️', path: '/admin/health-record' }
]

onMounted(() => {
  loadStats()
  initChart()
  loadRecentActivities()
  window.addEventListener('resize', () => chartInstance?.resize())
})
</script>

<template>
  <div class="dashboard">
    <div class="stats-grid">
      <div v-for="stat in stats" :key="stat.label" class="stat-card" :style="{ borderLeftColor: stat.color }">
        <div class="stat-icon" :style="{ backgroundColor: stat.color + '15' }">
          <span :style="{ color: stat.color }">{{ stat.icon }}</span>
        </div>
        <div class="stat-content">
          <p class="stat-value">{{ stat.value.toLocaleString() }}</p>
          <p class="stat-label">{{ stat.label }}</p>
        </div>
      </div>
    </div>

    <div class="chart-section">
      <div ref="chartRef" class="chart"></div>
    </div>

    <div class="bottom-row">
      <div class="activity-panel">
        <h3>最近活动</h3>
        <el-timeline>
          <el-timeline-item v-for="activity in recentActivities" :key="activity.id" :timestamp="activity.time">
            {{ activity.user }} 进行了 {{ activity.type }} 操作<span v-if="activity.desc"> - {{ activity.desc }}</span>
          </el-timeline-item>
          <el-timeline-item v-if="recentActivities.length === 0">
            暂无活动记录
          </el-timeline-item>
        </el-timeline>
      </div>

      <div class="quick-panel">
        <h3>快捷操作</h3>
        <div class="quick-grid">
          <button v-for="action in quickActions" :key="action.name" class="quick-btn" @click="router.push(action.path)">
            <span class="quick-icon">{{ action.icon }}</span>
            <span>{{ action.name }}</span>
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<style lang="scss" scoped>
.dashboard { padding: 20px; }
.stats-grid {
  display: grid; grid-template-columns: repeat(4, 1fr); gap: 20px; margin-bottom: 20px;
  @media (max-width: 1200px) { grid-template-columns: repeat(2, 1fr); }
  @media (max-width: 768px) { grid-template-columns: 1fr; }
}
.stat-card {
  background: #fff; padding: 20px; border-radius: 12px; box-shadow: 0 2px 8px rgba(0,0,0,0.05);
  border-left: 4px solid; display: flex; align-items: center; gap: 15px;
}
.stat-icon {
  width: 48px; height: 48px; border-radius: 12px; display: flex; align-items: center;
  justify-content: center; font-size: 20px;
}
.stat-content {
  .stat-value { font-size: 24px; font-weight: bold; color: #333; margin: 0; }
  .stat-label { font-size: 14px; color: #999; margin: 4px 0 0; }
}
.chart-section {
  background: #fff; border-radius: 12px; padding: 20px; box-shadow: 0 2px 8px rgba(0,0,0,0.05); margin-bottom: 20px;
  .chart { height: 300px; width: 100%; }
}
.bottom-row {
  display: grid; grid-template-columns: 1fr 320px; gap: 20px;
  @media (max-width: 1200px) { grid-template-columns: 1fr; }
}
.activity-panel, .quick-panel {
  background: #fff; border-radius: 12px; padding: 20px; box-shadow: 0 2px 8px rgba(0,0,0,0.05);
  h3 { font-size: 16px; color: #333; margin: 0 0 20px; }
}
.quick-grid { display: grid; grid-template-columns: repeat(2, 1fr); gap: 10px; }
.quick-btn {
  display: flex; flex-direction: column; align-items: center; gap: 8px; padding: 15px;
  background: #f5f7fa; border: none; border-radius: 10px; cursor: pointer; transition: all 0.3s;
  &:hover { background: #e2e8f0; transform: translateY(-2px); }
  .quick-icon { font-size: 24px; }
  span:last-child { font-size: 13px; color: #666; }
}
</style>
