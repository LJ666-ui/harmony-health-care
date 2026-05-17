<template>
  <div class="digital-twin">
    <div class="twin-main">
      <div class="body-model">
        <div class="human-body">
          <div v-for="organ in organs" :key="organ.key"
               :class="['organ-point', organ.level]"
               :style="{ top: organ.y + '%', left: organ.x + '%' }"
               @mouseenter="hoverOrgan = organ"
               @mouseleave="hoverOrgan = null">
            <div class="organ-pulse"></div>
            <span class="organ-icon">{{ organ.icon }}</span>
          </div>

          <svg class="body-outline" viewBox="0 0 200 400" xmlns="http://www.w3.org/2000/svg">
            <ellipse cx="100" cy="40" rx="25" ry="30" fill="none" stroke="#ddd" stroke-width="1.5"/>
            <line x1="100" y1="70" x2="100" y2="200" stroke="#ddd" stroke-width="1.5"/>
            <line x1="100" y1="90" x2="50" y2="160" stroke="#ddd" stroke-width="1.5"/>
            <line x1="100" y1="90" x2="150" y2="160" stroke="#ddd" stroke-width="1.5"/>
            <line x1="100" y1="200" x2="70" y2="340" stroke="#ddd" stroke-width="1.5"/>
            <line x1="100" y1="200" x2="130" y2="340" stroke="#ddd" stroke-width="1.5"/>
            <ellipse cx="100" cy="140" rx="40" ry="50" fill="none" stroke="#ddd" stroke-width="1" stroke-dasharray="4"/>
          </svg>

          <div v-if="hoverOrgan" class="organ-tooltip" :style="tooltipStyle">
            <div class="tooltip-header">
              <span>{{ hoverOrgan.icon }} {{ hoverOrgan.name }}</span>
              <el-tag :type="tagType(hoverOrgan.level)" size="small">{{ hoverOrgan.score }}分</el-tag>
            </div>
            <p>{{ hoverOrgan.tips }}</p>
          </div>
        </div>
      </div>

      <div class="health-dashboard">
        <div class="score-ring">
          <el-progress type="dashboard" :percentage="healthScore" :color="scoreColor" :width="160">
            <template #default="{ percentage }">
              <div class="score-text">
                <div class="score-number">{{ percentage }}</div>
                <div class="score-label">健康评分</div>
              </div>
            </template>
          </el-progress>
        </div>

        <div class="vitals-grid">
          <div v-for="v in vitals" :key="v.label" class="vital-card">
            <div class="vital-icon">{{ v.icon }}</div>
            <div class="vital-info">
              <span class="vital-value">{{ v.value }}</span>
              <span class="vital-label">{{ v.label }}</span>
            </div>
            <div class="vital-status" :class="v.status"></div>
          </div>
        </div>

        <div class="vitals-grid extra-vitals" v-if="extraVitals.some(e => e.value !== '--')">
          <div v-for="v in extraVitals" :key="v.label" class="vital-card vital-card-sm">
            <div class="vital-icon">{{ v.icon }}</div>
            <div class="vital-info">
              <span class="vital-value">{{ v.value }}</span>
              <span class="vital-label">{{ v.label }}</span>
            </div>
          </div>
        </div>
      </div>
    </div>

    <div class="trend-section">
      <el-card>
        <template #header>
          <div class="section-header">
            <span>📈 健康趋势</span>
            <el-radio-group v-model="trendType" size="small">
              <el-radio-button label="heartRate">心率</el-radio-button>
              <el-radio-button label="bloodSugar">血糖</el-radio-button>
              <el-radio-button label="weight">体重</el-radio-button>
            </el-radio-group>
          </div>
        </template>
        <div ref="trendChartRef" style="height: 280px;"></div>
      </el-card>
    </div>

    <div class="bottom-section">
      <el-card class="disease-card">
        <template #header><span>🏥 疾病记录</span></template>
        <el-table :data="diseases" size="small" stripe>
          <el-table-column prop="name" label="疾病名称" />
          <el-table-column prop="date" label="诊断日期" width="120" />
          <el-table-column prop="status" label="状态" width="100">
            <template #default="{ row }">
              <el-tag :type="row.status === 1 ? 'success' : 'warning'" size="small">
                {{ row.status === 1 ? '已治愈' : '治疗中' }}
              </el-tag>
            </template>
          </el-table-column>
        </el-table>
      </el-card>

      <el-card class="ai-card">
        <template #header><span>🤖 AI健康分析</span></template>
        <div v-if="aiAnalysis" class="ai-content" v-html="formatAI(aiAnalysis)"></div>
        <div v-else class="ai-placeholder">
          <el-button type="primary" @click="getAIAnalysis" :loading="aiLoading">
            生成AI健康分析报告
          </el-button>
        </div>
      </el-card>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, watch, nextTick } from 'vue'
import request from '@/utils/request'
import * as echarts from 'echarts'

const healthScore = ref(75)
const hoverOrgan = ref(null)
const trendType = ref('heartRate')
const trendChartRef = ref(null)
const aiAnalysis = ref('')
const aiLoading = ref(false)
const diseases = ref([])
const trendData = ref([])

const vitals = ref([
  { icon: '❤️', label: '心率', value: '--', status: 'normal', key: 'heartRate', unit: 'bpm' },
  { icon: '🩸', label: '血压', value: '--', status: 'normal', key: 'bloodPressure', unit: '' },
  { icon: '🍬', label: '血糖', value: '--', status: 'normal', key: 'bloodSugar', unit: 'mmol/L' },
  { icon: '🌡️', label: '体温', value: '--', status: 'normal', key: 'temperature', unit: '°C' },
  { icon: '⚖️', label: '体重', value: '--', status: 'normal', key: 'weight', unit: 'kg' },
  { icon: '💨', label: '血氧', value: '--', status: 'normal', key: 'oxygenSaturation', unit: '%' }
])

const extraVitals = ref([
  { icon: '📏', label: '身高', value: '--', key: 'height', unit: 'cm' },
  { icon: '👟', label: '今日步数', value: '--', key: 'stepCount', unit: '步' },
  { icon: '😴', label: '睡眠时长', value: '--', key: 'sleepDuration', unit: '小时' },
  { icon: '📊', label: 'BMI指数', value: '--', key: 'bmi', unit: '' }
])

const organs = ref([
  { key: 'heart', name: '心脏', icon: '❤️', x: 44, y: 28, score: 85, level: 'good', tips: '心血管状态良好' },
  { key: 'lung', name: '肺部', icon: '🫁', x: 56, y: 26, score: 90, level: 'good', tips: '呼吸系统状态良好' },
  { key: 'liver', name: '肝脏', icon: '🫘', x: 58, y: 36, score: 75, level: 'warning', tips: '建议定期检查肝功能' },
  { key: 'stomach', name: '胃', icon: '🫄', x: 46, y: 38, score: 80, level: 'good', tips: '消化系统正常' },
  { key: 'kidney', name: '肾脏', icon: '🫘', x: 55, y: 42, score: 82, level: 'good', tips: '肾功能正常' },
  { key: 'brain', name: '大脑', icon: '🧠', x: 50, y: 8, score: 88, level: 'good', tips: '神经系统状态良好' },
  { key: 'spine', name: '脊柱', icon: '🦴', x: 50, y: 50, score: 70, level: 'warning', tips: '注意坐姿，预防腰椎问题' },
  { key: 'eyes', name: '眼睛', icon: '👁️', x: 38, y: 8, score: 78, level: 'good', tips: '注意用眼卫生' }
])

const tooltipStyle = computed(() => {
  if (!hoverOrgan.value) return {}
  return {
    top: hoverOrgan.value.y < 30 ? (hoverOrgan.value.y + 10) + '%' : (hoverOrgan.value.y - 20) + '%',
    left: hoverOrgan.value.x > 50 ? (hoverOrgan.value.x - 25) + '%' : (hoverOrgan.value.x + 5) + '%'
  }
})

const scoreColor = computed(() => {
  if (healthScore.value >= 80) return '#67c23a'
  if (healthScore.value >= 60) return '#e6a23c'
  return '#f56c6c'
})

function tagType(level) {
  if (level === 'good') return 'success'
  if (level === 'warning') return 'warning'
  return 'danger'
}

let chart = null

onMounted(() => {
  loadHealthData()
})

watch(trendType, () => {
  renderChart()
})

async function loadHealthData() {
  try {
    const user = JSON.parse(localStorage.getItem('medical_user_info') || '{}')
    const userId = user.userId || user.id || 1
    const res = await request.get(`/digital-twin/${userId}/portrait`)
    if (res && res.vitals) {
      const v = res.vitals
      const fmt = (val, decimals) => val != null ? Number(val).toFixed(decimals) : '--'
      vitals.value = [
        { icon: '❤️', label: '心率', value: v.heartRate ? v.heartRate + ' bpm' : '--', status: (v.heartRate > 100 || v.heartRate < 60) ? 'warning' : 'normal', key: 'heartRate', unit: 'bpm' },
        { icon: '🩸', label: '血压', value: v.bloodPressureSys ? v.bloodPressureSys + '/' + fmt(v.bloodPressureDia, 0) : (v.bloodPressure || '--'), status: v.bloodPressureSys > 140 ? 'warning' : 'normal', key: 'bloodPressure', unit: '' },
        { icon: '🍬', label: '血糖', value: v.bloodSugar ? fmt(v.bloodSugar, 1) + ' mmol/L' : '--', status: v.bloodSugar > 7 ? 'warning' : 'normal', key: 'bloodSugar', unit: 'mmol/L' },
        { icon: '🌡️', label: '体温', value: v.temperature ? fmt(v.temperature, 1) + '°C' : '--', status: v.temperature > 37.3 ? 'warning' : 'normal', key: 'temperature', unit: '°C' },
        { icon: '⚖️', label: '体重', value: v.weight ? fmt(v.weight, 1) + ' kg' : '--', status: 'normal', key: 'weight', unit: 'kg' },
        { icon: '💨', label: '血氧', value: v.oxygenSaturation ? v.oxygenSaturation + '%' : '--', status: v.oxygenSaturation < 95 ? 'warning' : 'normal', key: 'oxygenSaturation', unit: '%' }
      ]
      extraVitals.value = [
        { icon: '📏', label: '身高', value: v.height ? fmt(v.height, 0) + ' cm' : '--', key: 'height', unit: 'cm' },
        { icon: '👟', label: '今日步数', value: v.stepCount ? v.stepCount.toLocaleString() + ' 步' : '--', key: 'stepCount', unit: '步' },
        { icon: '😴', label: '睡眠时长', value: v.sleepDuration ? fmt(v.sleepDuration, 1) + ' 小时' : '--', key: 'sleepDuration', unit: '小时' },
        { icon: '📊', label: 'BMI指数', value: v.bmi ? String(v.bmi) : '--', key: 'bmi', unit: '' }
      ]
    } else {
      applyMockVitals()
    }

    if (res && res.organStatus) {
      const organMap = { heart: '心脏', lung: '肺部', liver: '肝脏', stomach: '胃', kidney: '肾脏', brain: '大脑', spine: '脊柱', eyes: '眼睛' }
      const iconMap = { heart: '❤️', lung: '🫁', liver: '🫘', stomach: '🫄', kidney: '🫘', brain: '🧠', spine: '🦴', eyes: '👁️' }
      const posMap = { heart: {x:44,y:28}, lung: {x:56,y:26}, liver: {x:58,y:36}, stomach: {x:46,y:38}, kidney: {x:55,y:42}, brain: {x:50,y:8}, spine: {x:50,y:50}, eyes: {x:38,y:8} }
      organs.value = Object.entries(res.organStatus).map(([key, data]) => ({
        key,
        name: organMap[key] || key,
        icon: iconMap[key] || '🔍',
        ...posMap[key],
        score: data.score || 75,
        level: data.level || 'good',
        tips: data.tips || '暂无数据'
      }))
    } else {
      applyMockOrgans()
    }

    if (res.healthScore) healthScore.value = res.healthScore
    if (res.trends && res.trends.length > 0) {
      trendData.value = res.trends
    } else {
      applyMockTrends()
    }
    if (res.diseases && res.diseases.length > 0) {
      diseases.value = res.diseases
    } else {
      applyMockDiseases()
    }

    await nextTick()
    renderChart()
  } catch (e) {
    console.error('加载健康数据失败:', e)
    applyMockVitals()
    applyMockOrgans()
    applyMockTrends()
    applyMockDiseases()
    await nextTick()
    renderChart()
  }
}

function applyMockVitals() {
  vitals.value = [
    { icon: '❤️', label: '心率', value: '72 bpm', status: 'normal', key: 'heartRate', unit: 'bpm' },
    { icon: '🩸', label: '血压', value: '118/78', status: 'normal', key: 'bloodPressure', unit: '' },
    { icon: '🍬', label: '血糖', value: '5.3 mmol/L', status: 'normal', key: 'bloodSugar', unit: 'mmol/L' },
    { icon: '🌡️', label: '体温', value: '36.6°C', status: 'normal', key: 'temperature', unit: '°C' },
    { icon: '⚖️', label: '体重', value: '65.0 kg', status: 'normal', key: 'weight', unit: 'kg' },
    { icon: '💨', label: '血氧', value: '98%', status: 'normal', key: 'oxygenSaturation', unit: '%' }
  ]
  extraVitals.value = [
    { icon: '📏', label: '身高', value: '170 cm', key: 'height', unit: 'cm' },
    { icon: '👟', label: '今日步数', value: '8,532 步', key: 'stepCount', unit: '步' },
    { icon: '😴', label: '睡眠时长', value: '7.5 小时', key: 'sleepDuration', unit: '小时' },
    { icon: '📊', label: 'BMI指数', value: '22.5', key: 'bmi', unit: '' }
  ]
}

function applyMockOrgans() {
  organs.value = [
    { key: 'heart', name: '心脏', icon: '❤️', x: 44, y: 28, score: 88, level: 'good', tips: '心血管状态良好，心率血压正常' },
    { key: 'lung', name: '肺部', icon: '🫁', x: 56, y: 26, score: 92, level: 'good', tips: '呼吸系统功能正常，血氧饱和度良好' },
    { key: 'liver', name: '肝脏', icon: '🫘', x: 58, y: 36, score: 82, level: 'good', tips: '肝功能指标正常，建议定期复查' },
    { key: 'stomach', name: '胃', icon: '🫄', x: 46, y: 38, score: 85, level: 'good', tips: '消化系统状态正常' },
    { key: 'kidney', name: '肾脏', icon: '🫘', x: 55, y: 42, score: 86, level: 'good', tips: '肾功能指标在正常范围' },
    { key: 'brain', name: '大脑', icon: '🧠', x: 50, y: 8, score: 90, level: 'good', tips: '神经系统状态良好' },
    { key: 'spine', name: '脊柱', icon: '🦴', x: 50, y: 50, score: 72, level: 'warning', tips: '注意坐姿，预防腰椎问题，建议适当运动' },
    { key: 'eyes', name: '眼睛', icon: '👁️', x: 38, y: 8, score: 80, level: 'good', tips: '注意用眼卫生，避免长时间看屏幕' }
  ]
  healthScore.value = 84
}

function applyMockTrends() {
  const now = new Date()
  trendData.value = Array.from({ length: 14 }, (_, i) => {
    const d = new Date(now)
    d.setDate(d.getDate() - (13 - i))
    return {
      date: d.toISOString(),
      heartRate: Math.round(68 + Math.random() * 12),
      bloodSugar: Math.round((4.8 + Math.random() * 1.2) * 10) / 10,
      weight: Math.round((64 + Math.random() * 2) * 10) / 10
    }
  })
}

function applyMockDiseases() {
  diseases.value = [
    { name: '轻度高血压（已控制）', date: '2025-03-15', status: 0 },
    { name: '过敏性鼻炎', date: '2024-11-20', status: 1 }
  ]
}

function renderChart() {
  if (!trendChartRef.value) return
  if (!chart) chart = echarts.init(trendChartRef.value)

  const data = trendData.value
  const typeMap = { heartRate: '心率', bloodSugar: '血糖', weight: '体重' }

  chart.setOption({
    tooltip: { trigger: 'axis' },
    grid: { left: 50, right: 20, top: 20, bottom: 30 },
    xAxis: {
      type: 'category',
      data: data.map(d => d.date ? new Date(d.date).toLocaleDateString() : ''),
      axisLabel: { fontSize: 11 }
    },
    yAxis: { type: 'value', name: typeMap[trendType.value] },
    series: [{
      data: data.map(d => d[trendType.value] || 0),
      type: 'line',
      smooth: true,
      areaStyle: {
        color: new echarts.graphic.LinearGradient(0, 0, 0, 1, [
          { offset: 0, color: 'rgba(102, 126, 234, 0.4)' },
          { offset: 1, color: 'rgba(102, 126, 234, 0.05)' }
        ])
      },
      lineStyle: { color: '#667eea', width: 2 },
      itemStyle: { color: '#667eea' }
    }]
  })
}

async function getAIAnalysis() {
  aiLoading.value = true
  try {
    const user = JSON.parse(localStorage.getItem('medical_user_info') || '{}')
    const userId = user.userId || user.id || 1
    const res = await request.post(`/digital-twin/${userId}/ai-analysis`, {})
    if (res) aiAnalysis.value = res
  } catch (e) {
    aiAnalysis.value = 'AI分析暂时不可用，请稍后再试。'
  } finally {
    aiLoading.value = false
  }
}

function formatAI(text) {
  return (text || '').replace(/\n/g, '<br>')
}
</script>

<style scoped>
.digital-twin { padding: 20px; }

.twin-main {
  display: flex;
  gap: 24px;
  margin-bottom: 20px;
}

.body-model {
  flex: 0 0 320px;
  background: #fff;
  border-radius: 12px;
  padding: 20px;
  box-shadow: 0 2px 12px rgba(0,0,0,0.08);
  position: relative;
}

.human-body {
  position: relative;
  width: 200px;
  height: 400px;
  margin: 0 auto;
}

.body-outline { width: 100%; height: 100%; }

.organ-point {
  position: absolute;
  width: 32px;
  height: 32px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  z-index: 2;
  transition: all 0.3s;
}

.organ-point.good { background: rgba(103, 194, 58, 0.2); border: 2px solid #67c23a; }
.organ-point.warning { background: rgba(230, 162, 60, 0.2); border: 2px solid #e6a23c; }
.organ-point.danger { background: rgba(245, 108, 108, 0.2); border: 2px solid #f56c6c; }

.organ-point:hover { transform: scale(1.3); z-index: 10; }

.organ-icon { font-size: 14px; }

.organ-pulse {
  position: absolute;
  width: 100%;
  height: 100%;
  border-radius: 50%;
  animation: pulse 2s infinite;
}

.organ-point.good .organ-pulse { border: 2px solid rgba(103, 194, 58, 0.3); }
.organ-point.warning .organ-pulse { border: 2px solid rgba(230, 162, 60, 0.3); }
.organ-point.danger .organ-pulse { border: 2px solid rgba(245, 108, 108, 0.3); }

@keyframes pulse {
  0% { transform: scale(1); opacity: 1; }
  100% { transform: scale(2); opacity: 0; }
}

.organ-tooltip {
  position: absolute;
  background: #fff;
  border-radius: 8px;
  padding: 10px 14px;
  box-shadow: 0 4px 16px rgba(0,0,0,0.15);
  z-index: 100;
  min-width: 180px;
}

.tooltip-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 6px;
  font-weight: bold;
}

.organ-tooltip p { margin: 0; font-size: 12px; color: #666; }

.health-dashboard {
  flex: 1;
  background: #fff;
  border-radius: 12px;
  padding: 20px;
  box-shadow: 0 2px 12px rgba(0,0,0,0.08);
}

.score-ring {
  display: flex;
  justify-content: center;
  margin-bottom: 20px;
}

.score-text { text-align: center; }
.score-number { font-size: 36px; font-weight: bold; color: #333; }
.score-label { font-size: 12px; color: #999; }

.vitals-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 12px;
}

.vital-card {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 12px;
  background: #f8f9fa;
  border-radius: 10px;
  transition: all 0.3s;
}

.vital-card:hover { transform: translateY(-2px); box-shadow: 0 4px 12px rgba(0,0,0,0.1); }

.vital-icon { font-size: 24px; }

.vital-info { flex: 1; }
.vital-value { display: block; font-size: 16px; font-weight: bold; color: #333; }
.vital-label { display: block; font-size: 11px; color: #999; }

.vital-status {
  width: 8px;
  height: 8px;
  border-radius: 50%;
}

.vital-status.normal { background: #67c23a; }
.vital-status.warning { background: #e6a23c; }

.trend-section { margin-bottom: 20px; }

.section-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.bottom-section {
  display: flex;
  gap: 20px;
}

.disease-card { flex: 1; }
.ai-card { flex: 1; }

.ai-content {
  line-height: 1.8;
  color: #333;
  font-size: 14px;
  max-height: 300px;
  overflow-y: auto;
}

.ai-placeholder {
  text-align: center;
  padding: 40px;
  color: #999;
}
</style>