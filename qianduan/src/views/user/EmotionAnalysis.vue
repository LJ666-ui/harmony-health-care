<template>
  <div class="emotion-engine">
    <div class="emotion-top">
      <el-card class="realtime-card">
        <template #header><span>💭 实时情感分析</span></template>
        <div class="realtime-input">
          <el-input
            v-model="inputText"
            type="textarea"
            :rows="3"
            placeholder="输入患者或医生的对话文本，实时分析情感状态..."
            @input="debouncedAnalyze"
          />
        </div>
        <div v-if="realtimeResult" class="realtime-result">
          <div class="emotion-badge" :class="realtimeResult.emotion">
            {{ emotionLabel(realtimeResult.emotion) }}
          </div>
          <div class="score-bars">
            <div class="bar-item">
              <label>焦虑</label>
              <el-progress :percentage="realtimeResult.anxietyScore * 100" :color="'#e6a23c'" :stroke-width="12" />
            </div>
            <div class="bar-item">
              <label>抑郁</label>
              <el-progress :percentage="realtimeResult.depressionScore * 100" :color="'#f56c6c'" :stroke-width="12" />
            </div>
            <div class="bar-item">
              <label>愤怒</label>
              <el-progress :percentage="realtimeResult.angerScore * 100" :color="'#f56c6c'" :stroke-width="12" />
            </div>
            <div class="bar-item">
              <label>积极</label>
              <el-progress :percentage="realtimeResult.positiveScore * 100" :color="'#67c23a'" :stroke-width="12" />
            </div>
          </div>
          <div v-if="realtimeResult.keywords && realtimeResult.keywords.length" class="detected-keywords">
            <span class="kw-label">检测到关键词：</span>
            <el-tag v-for="kw in realtimeResult.keywords" :key="kw" size="small" type="warning">{{ kw }}</el-tag>
          </div>
          <div v-if="realtimeResult.alert" class="alert-box">
            <el-alert :title="realtimeResult.alertMessage" type="warning" :closable="false" show-icon>
              <template #default>
                <p>{{ realtimeResult.suggestion }}</p>
              </template>
            </el-alert>
          </div>
        </div>
      </el-card>

      <el-card class="empathy-card">
        <template #header><span>🤝 AI共情建议</span></template>
        <div v-if="empathySuggestion" class="empathy-content" v-html="formatText(empathySuggestion)"></div>
        <div v-else class="empathy-placeholder">
          <p>在左侧输入患者对话后，点击获取AI共情建议</p>
          <el-button type="primary" @click="getEmpathy" :disabled="!inputText.trim()" :loading="empathyLoading">
            获取共情建议
          </el-button>
        </div>
      </el-card>
    </div>

    <div class="emotion-bottom">
      <el-card class="consultation-emotion-card">
        <template #header>
          <div class="section-header">
            <span>📊 问诊情感分析</span>
            <div class="header-controls">
              <el-input v-model="consultationId" placeholder="问诊ID" size="small" style="width:120px" />
              <el-button type="primary" size="small" @click="analyzeConsultation" :loading="consultLoading">
                分析
              </el-button>
            </div>
          </div>
        </template>

        <div v-if="consultResult" class="consult-result">
          <div class="emotion-overview">
            <div class="overview-item">
              <h4>患者整体情绪</h4>
              <div class="emotion-badge" :class="consultResult.patientOverall?.emotion">
                {{ emotionLabel(consultResult.patientOverall?.emotion) }}
              </div>
              <div class="overview-scores">
                <span>焦虑: {{ (consultResult.patientOverall?.avgAnxiety * 100).toFixed(0) }}%</span>
                <span>抑郁: {{ (consultResult.patientOverall?.avgDepression * 100).toFixed(0) }}%</span>
              </div>
            </div>
            <div class="overview-item">
              <h4>医生整体情绪</h4>
              <div class="emotion-badge" :class="consultResult.doctorOverall?.emotion">
                {{ emotionLabel(consultResult.doctorOverall?.emotion) }}
              </div>
              <div class="overview-scores">
                <span>焦虑: {{ (consultResult.doctorOverall?.avgAnxiety * 100).toFixed(0) }}%</span>
                <span>积极: {{ (consultResult.doctorOverall?.avgPositive * 100).toFixed(0) }}%</span>
              </div>
            </div>
            <div class="overview-item">
              <h4>心理风险</h4>
              <div class="risk-badge" :class="consultResult.riskAlert?.level">
                {{ riskLabel(consultResult.riskAlert?.level) }}
              </div>
              <div v-if="consultResult.riskAlert?.factors?.length" class="risk-factors">
                <el-tag v-for="f in consultResult.riskAlert.factors" :key="f" size="small" type="danger">{{ f }}</el-tag>
              </div>
            </div>
          </div>

          <div ref="emotionChartRef" style="height: 280px; margin-top: 20px;"></div>
        </div>

        <div v-else class="consult-placeholder">
          <p>输入问诊ID，分析整个问诊过程的情感变化趋势</p>
        </div>
      </el-card>
    </div>
  </div>
</template>

<script setup>
import { ref, nextTick } from 'vue'
import request from '@/utils/request'
import * as echarts from 'echarts'

const inputText = ref('')
const realtimeResult = ref(null)
const empathySuggestion = ref('')
const empathyLoading = ref(false)
const consultationId = ref('')
const consultLoading = ref(false)
const consultResult = ref(null)
const emotionChartRef = ref(null)

let debounceTimer = null
let emotionChart = null

function debouncedAnalyze() {
  clearTimeout(debounceTimer)
  debounceTimer = setTimeout(() => {
    if (inputText.value.trim()) {
      analyzeRealtime()
    } else {
      realtimeResult.value = null
    }
  }, 500)
}

async function analyzeRealtime() {
  try {
    const res = await request.post('/emotion/realtime', {
      text: inputText.value,
      consultationId: consultationId.value || null
    })
    if (res) realtimeResult.value = res
  } catch (e) {
    console.error('情感分析失败:', e)
  }
}

async function getEmpathy() {
  if (!inputText.value.trim()) return
  empathyLoading.value = true
  try {
    const emotion = realtimeResult.value?.emotion || 'neutral'
    const res = await request.post('/emotion/ai-empathy', {
      patientText: inputText.value,
      emotion
    })
    if (res) empathySuggestion.value = res
  } catch (e) {
    empathySuggestion.value = '共情建议暂时不可用'
  } finally {
    empathyLoading.value = false
  }
}

async function analyzeConsultation() {
  if (!consultationId.value) return
  consultLoading.value = true
  try {
    const res = await request.get(`/emotion/consultation/${consultationId.value}/analysis`)
    if (res) {
      consultResult.value = res
      await nextTick()
      renderEmotionChart(res)
    }
  } catch (e) {
    console.error('问诊情感分析失败:', e)
  } finally {
    consultLoading.value = false
  }
}

function renderEmotionChart(data) {
  if (!emotionChartRef.value) return
  if (!emotionChart) emotionChart = echarts.init(emotionChartRef.value)

  const patientData = (data.patientEmotions || []).map((e, i) => ({
    index: i + 1,
    anxiety: (e.anxietyScore || 0) * 100,
    depression: (e.depressionScore || 0) * 100,
    positive: (e.positiveScore || 0) * 100
  }))

  emotionChart.setOption({
    tooltip: { trigger: 'axis' },
    legend: { data: ['焦虑指数', '抑郁指数', '积极指数'] },
    grid: { left: 50, right: 20, top: 40, bottom: 30 },
    xAxis: {
      type: 'category',
      data: patientData.map(d => '消息' + d.index),
      axisLabel: { fontSize: 11 }
    },
    yAxis: { type: 'value', max: 100, name: '指数(%)' },
    series: [
      {
        name: '焦虑指数',
        type: 'line',
        data: patientData.map(d => d.anxiety),
        smooth: true,
        lineStyle: { color: '#e6a23c' },
        itemStyle: { color: '#e6a23c' },
        areaStyle: { color: 'rgba(230, 162, 60, 0.1)' }
      },
      {
        name: '抑郁指数',
        type: 'line',
        data: patientData.map(d => d.depression),
        smooth: true,
        lineStyle: { color: '#f56c6c' },
        itemStyle: { color: '#f56c6c' },
        areaStyle: { color: 'rgba(245, 108, 108, 0.1)' }
      },
      {
        name: '积极指数',
        type: 'line',
        data: patientData.map(d => d.positive),
        smooth: true,
        lineStyle: { color: '#67c23a' },
        itemStyle: { color: '#67c23a' },
        areaStyle: { color: 'rgba(103, 194, 58, 0.1)' }
      }
    ]
  })
}

function emotionLabel(emotion) {
  const map = {
    anxiety: '😰 焦虑',
    depression: '😔 抑郁',
    anger: '😠 愤怒',
    distress: '😟 不安',
    positive: '😊 积极',
    neutral: '😐 平静'
  }
  return map[emotion] || '😐 平静'
}

function riskLabel(level) {
  const map = { low: '🟢 低风险', medium: '🟡 中风险', high: '🔴 高风险' }
  return map[level] || '🟢 低风险'
}

function formatText(text) {
  return (text || '').replace(/\n/g, '<br>')
}
</script>

<style scoped>
.emotion-engine { padding: 20px; }

.emotion-top {
  display: flex;
  gap: 20px;
  margin-bottom: 20px;
}

.realtime-card { flex: 1; }
.empathy-card { flex: 1; }

.realtime-result { margin-top: 16px; }

.emotion-badge {
  display: inline-block;
  padding: 6px 16px;
  border-radius: 20px;
  font-weight: bold;
  font-size: 14px;
  margin-bottom: 12px;
}

.emotion-badge.anxiety { background: #fdf6ec; color: #e6a23c; }
.emotion-badge.depression { background: #fef0f0; color: #f56c6c; }
.emotion-badge.anger { background: #fef0f0; color: #f56c6c; }
.emotion-badge.distress { background: #fdf6ec; color: #e6a23c; }
.emotion-badge.positive { background: #f0f9eb; color: #67c23a; }
.emotion-badge.neutral { background: #f4f4f5; color: #909399; }

.score-bars { margin-bottom: 12px; }

.bar-item {
  display: flex;
  align-items: center;
  gap: 10px;
  margin-bottom: 8px;
}

.bar-item label {
  min-width: 40px;
  font-size: 13px;
  color: #666;
}

.bar-item .el-progress { flex: 1; }

.detected-keywords {
  display: flex;
  align-items: center;
  gap: 6px;
  flex-wrap: wrap;
  margin-bottom: 12px;
}

.kw-label { font-size: 13px; color: #666; }

.alert-box { margin-top: 12px; }

.empathy-content {
  line-height: 1.8;
  font-size: 14px;
  max-height: 300px;
  overflow-y: auto;
}

.empathy-placeholder {
  text-align: center;
  padding: 40px;
  color: #999;
}

.section-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.header-controls {
  display: flex;
  gap: 8px;
}

.consult-result { padding: 10px 0; }

.emotion-overview {
  display: flex;
  gap: 20px;
  justify-content: center;
}

.overview-item {
  flex: 1;
  text-align: center;
  padding: 16px;
  background: #f8f9fa;
  border-radius: 12px;
}

.overview-item h4 { margin: 0 0 10px; color: #333; font-size: 14px; }

.overview-scores {
  margin-top: 8px;
  font-size: 12px;
  color: #999;
}

.overview-scores span { margin: 0 6px; }

.risk-badge {
  display: inline-block;
  padding: 6px 16px;
  border-radius: 20px;
  font-weight: bold;
  font-size: 14px;
}

.risk-badge.low { background: #f0f9eb; color: #67c23a; }
.risk-badge.medium { background: #fdf6ec; color: #e6a23c; }
.risk-badge.high { background: #fef0f0; color: #f56c6c; }

.risk-factors {
  margin-top: 8px;
  display: flex;
  gap: 6px;
  justify-content: center;
  flex-wrap: wrap;
}

.consult-placeholder {
  text-align: center;
  padding: 40px;
  color: #999;
}
</style>