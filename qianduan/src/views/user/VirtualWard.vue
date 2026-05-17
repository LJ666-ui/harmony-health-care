<template>
  <div class="virtual-ward">
    <el-card class="dashboard-card">
      <div class="dashboard-stats">
        <div class="stat-item total">
          <span class="stat-value">{{ dashboard.totalPatients || 0 }}</span>
          <span class="stat-label">在院患者</span>
        </div>
        <div class="stat-item normal">
          <span class="stat-value">{{ dashboard.normalCount || 0 }}</span>
          <span class="stat-label">正常</span>
        </div>
        <div class="stat-item warning">
          <span class="stat-value">{{ dashboard.warningCount || 0 }}</span>
          <span class="stat-label">预警</span>
        </div>
        <div class="stat-item critical">
          <span class="stat-value">{{ dashboard.criticalCount || 0 }}</span>
          <span class="stat-label">危急</span>
        </div>
        <div class="stat-item alert">
          <span class="stat-value">{{ dashboard.unhandledAlerts || 0 }}</span>
          <span class="stat-label">未处理预警</span>
        </div>
      </div>
    </el-card>

    <div class="ward-content">
      <el-card class="ward-list-card">
        <template #header><span>🏥 病区选择</span></template>
        <div class="ward-list">
          <div v-for="ward in wards" :key="ward.id"
               :class="['ward-item', { active: selectedWard === ward.id }]"
               @click="selectWard(ward.id)">
            <div class="ward-name">{{ ward.name }}</div>
            <div class="ward-info">{{ ward.location }} | {{ ward.bedCount }}床</div>
            <div class="ward-doctor">{{ ward.headDoctor }}</div>
          </div>
        </div>
      </el-card>

      <el-card class="monitor-card">
        <template #header>
          <div class="monitor-header">
            <span>📊 实时监护大屏</span>
            <el-button size="small" @click="refreshData" :loading="refreshing" round>🔄 刷新</el-button>
          </div>
        </template>

        <div class="patient-grid">
          <div v-for="patient in patients" :key="patient.patientId"
               :class="['patient-card', patient.status]"
               @click="selectPatient(patient)">
            <div class="patient-header">
              <span class="bed-no">{{ patient.bedNo }}</span>
              <span :class="['status-badge', patient.status]">
                {{ statusText(patient.status) }}
              </span>
            </div>
            <div class="patient-name">{{ patient.patientName }}</div>
            <div class="vitals-grid" v-if="patient.vitals">
              <div class="vital-item">
                <span class="vital-icon">❤️</span>
                <span class="vital-value">{{ patient.vitals.heartRate }}</span>
                <span class="vital-unit">bpm</span>
              </div>
              <div class="vital-item">
                <span class="vital-icon">🩸</span>
                <span class="vital-value">{{ patient.vitals.bloodPressureSys }}/{{ patient.vitals.bloodPressureDia }}</span>
                <span class="vital-unit">mmHg</span>
              </div>
              <div class="vital-item">
                <span class="vital-icon">🫁</span>
                <span class="vital-value">{{ patient.vitals.oxygenSaturation }}</span>
                <span class="vital-unit">%</span>
              </div>
              <div class="vital-item">
                <span class="vital-icon">🌡️</span>
                <span class="vital-value">{{ patient.vitals.temperature?.toFixed(1) }}</span>
                <span class="vital-unit">℃</span>
              </div>
              <div class="vital-item">
                <span class="vital-icon">🍬</span>
                <span class="vital-value">{{ patient.vitals.bloodSugar?.toFixed(1) }}</span>
                <span class="vital-unit">mmol/L</span>
              </div>
              <div class="vital-item">
                <span class="vital-icon">💨</span>
                <span class="vital-value">{{ patient.vitals.respiratoryRate }}</span>
                <span class="vital-unit">次/分</span>
              </div>
            </div>
          </div>
        </div>
      </el-card>
    </div>

    <div class="bottom-area">
      <el-card class="alert-card">
        <template #header>
          <div class="alert-header">
            <span>🚨 预警中心</span>
            <el-tag type="danger">{{ unhandledAlerts.length }} 条未处理</el-tag>
          </div>
        </template>
        <div class="alert-list">
          <div v-for="alert in alerts" :key="alert.id"
               :class="['alert-item', alert.level, { handled: alert.handled }]">
            <div class="alert-left">
              <span class="alert-level-icon">{{ alert.level === 'critical' ? '🔴' : alert.level === 'warning' ? '🟡' : '🔵' }}</span>
              <div class="alert-info">
                <div class="alert-message">{{ alert.message }}</div>
                <div class="alert-meta">
                  {{ alert.patientName }} | {{ alert.bedNo }} | {{ formatTime(alert.time) }}
                </div>
              </div>
            </div>
            <el-button v-if="!alert.handled" size="small" type="danger" @click="handleAlert(alert.id)">
              处理
            </el-button>
            <el-tag v-else type="success" size="small">已处理</el-tag>
          </div>
          <el-empty v-if="!alerts.length" description="暂无预警" />
        </div>
      </el-card>
    </div>

    <el-drawer v-model="patientDrawer" :title="selectedPatientData?.patientName + ' - 详细监护'" size="500px">
      <div v-if="selectedPatientData" class="patient-detail">
        <div class="detail-header">
          <span class="detail-bed">{{ selectedPatientData.bedNo }}</span>
          <span :class="['detail-status', selectedPatientData.status]">
            {{ statusText(selectedPatientData.status) }}
          </span>
        </div>

        <div class="detail-vitals" v-if="selectedPatientData.vitals">
          <h4>生命体征</h4>
          <div class="vital-detail-grid">
            <div class="vital-detail-item" v-for="vital in vitalList" :key="vital.key">
              <span class="vital-detail-icon">{{ vital.icon }}</span>
              <span class="vital-detail-name">{{ vital.name }}</span>
              <span class="vital-detail-value">
                {{ formatVital(selectedPatientData.vitals, vital.key, vital.suffix) }}
              </span>
              <span :class="['vital-detail-status', checkVitalStatus(vital.key, selectedPatientData.vitals)]">
                {{ checkVitalStatus(vital.key, selectedPatientData.vitals) === 'normal' ? '正常' :
                   checkVitalStatus(vital.key, selectedPatientData.vitals) === 'warning' ? '偏高' : '异常' }}
              </span>
            </div>
          </div>
        </div>

        <div class="detail-actions">
          <h4>快捷操作</h4>
          <el-button type="danger" @click="createAlertForPatient" round>🚨 发送预警</el-button>
          <el-button type="primary" @click="createNurseTask" round>📋 护理任务</el-button>
          <el-button @click="refreshPatientVitals" round>🔄 刷新数据</el-button>
        </div>
      </div>
    </el-drawer>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onBeforeUnmount } from 'vue'
import request from '@/utils/request'
import { ElMessage } from 'element-plus'

const dashboard = ref({})
const wards = ref([])
const selectedWard = ref('')
const patients = ref([])
const alerts = ref([])
const refreshing = ref(false)
const patientDrawer = ref(false)
const selectedPatientData = ref(null)
let refreshInterval = null

const vitalList = [
  { key: 'heartRate', name: '心率', icon: '❤️', suffix: 'bpm' },
  { key: 'bloodPressureSys', name: '收缩压', icon: '🩸', suffix: 'mmHg' },
  { key: 'bloodPressureDia', name: '舒张压', icon: '🩸', suffix: 'mmHg' },
  { key: 'oxygenSaturation', name: '血氧饱和度', icon: '🫁', suffix: '%' },
  { key: 'temperature', name: '体温', icon: '🌡️', suffix: '℃' },
  { key: 'bloodSugar', name: '血糖', icon: '🍬', suffix: 'mmol/L' },
  { key: 'respiratoryRate', name: '呼吸频率', icon: '💨', suffix: '次/分' }
]

const unhandledAlerts = computed(() => alerts.value.filter(a => !a.handled))

onMounted(() => {
  loadDashboard()
  loadWards()
  loadAlerts()
  refreshInterval = setInterval(() => { refreshData() }, 30000)
})

onBeforeUnmount(() => clearInterval(refreshInterval))

async function loadDashboard() {
  try {
    const res = await request.get('/virtual-ward/dashboard')
    if (res) dashboard.value = res
  } catch (e) { console.error(e) }
}

async function loadWards() {
  try {
    const res = await request.get('/virtual-ward/wards')
    wards.value = res || []
    if (wards.value.length) selectWard(wards.value[0].id)
  } catch (e) { console.error(e) }
}

async function selectWard(wardId) {
  selectedWard.value = wardId
  try {
    const res = await request.get(`/virtual-ward/ward/${wardId}/patients`)
    patients.value = res || []
  } catch (e) { patients.value = [] }
}

async function loadAlerts() {
  try {
    const res = await request.get('/virtual-ward/alerts')
    alerts.value = res || []
  } catch (e) { alerts.value = [] }
}

async function refreshData() {
  refreshing.value = true
  try {
    await Promise.all([loadDashboard(), selectWard(selectedWard.value), loadAlerts()])
  } finally { refreshing.value = false }
}

function selectPatient(patient) {
  selectedPatientData.value = patient
  patientDrawer.value = true
}

async function handleAlert(alertId) {
  try {
    await request.post(`/virtual-ward/alert/${alertId}/handle`)
    ElMessage.success('预警已处理')
    loadAlerts()
    loadDashboard()
  } catch (e) { ElMessage.error('处理失败') }
}

async function createAlertForPatient() {
  if (!selectedPatientData.value) return
  try {
    await request.post(`/virtual-ward/alert/${selectedPatientData.value.patientId}`, {
      patientName: selectedPatientData.value.patientName,
      type: 'manual',
      level: 'warning',
      message: `${selectedPatientData.value.bedNo} ${selectedPatientData.value.patientName} 需要关注`,
      wardId: selectedWard.value,
      bedNo: selectedPatientData.value.bedNo
    })
    ElMessage.success('预警已发送')
    loadAlerts()
  } catch (e) { ElMessage.error('发送失败') }
}

async function createNurseTask() {
  if (!selectedPatientData.value) return
  try {
    await request.post('/virtual-ward/nurse-task', {
      patientId: selectedPatientData.value.patientId,
      patientName: selectedPatientData.value.patientName,
      bedNo: selectedPatientData.value.bedNo,
      taskType: 'check',
      description: '查看患者状况',
      priority: 'normal'
    })
    ElMessage.success('护理任务已创建')
  } catch (e) { ElMessage.error('创建失败') }
}

async function refreshPatientVitals() {
  if (!selectedPatientData.value) return
  try {
    const res = await request.get(`/virtual-ward/patient/${selectedPatientData.value.patientId}/vitals`)
    if (res) selectedPatientData.value.vitals = res
    ElMessage.success('数据已刷新')
  } catch (e) { ElMessage.error('刷新失败') }
}

function statusText(status) {
  return { normal: '正常', warning: '预警', critical: '危急' }[status] || '未知'
}

function formatTime(time) {
  if (!time) return ''
  return new Date(time).toLocaleString('zh-CN')
}

function formatVital(vitals, key, suffix) {
  const val = vitals[key]
  if (val === undefined || val === null) return '--'
  return (typeof val === 'number' && val % 1 !== 0) ? val.toFixed(1) + ' ' + suffix : val + ' ' + suffix
}

function checkVitalStatus(key, vitals) {
  if (!vitals) return 'normal'
  const val = vitals[key]
  if (val === undefined) return 'normal'
  const checks = {
    heartRate: v => v > 100 || v < 55 ? (v > 120 || v < 50 ? 'critical' : 'warning') : 'normal',
    bloodPressureSys: v => v > 140 ? (v > 160 ? 'critical' : 'warning') : v < 90 ? 'warning' : 'normal',
    bloodPressureDia: v => v > 90 ? 'warning' : v < 60 ? 'warning' : 'normal',
    oxygenSaturation: v => v < 95 ? (v < 90 ? 'critical' : 'warning') : 'normal',
    temperature: v => v > 37.5 ? (v > 38.5 ? 'critical' : 'warning') : v < 35.5 ? 'warning' : 'normal',
    bloodSugar: v => v > 7.0 ? 'warning' : v < 3.9 ? 'warning' : 'normal',
    respiratoryRate: v => v > 20 ? 'warning' : v < 12 ? 'warning' : 'normal'
  }
  return checks[key] ? checks[key](val) : 'normal'
}
</script>

<style scoped>
.virtual-ward { padding: 20px; }

.dashboard-stats {
  display: flex;
  gap: 20px;
  justify-content: space-around;
}

.stat-item {
  text-align: center;
  padding: 16px 24px;
  border-radius: 12px;
  min-width: 120px;
}

.stat-value { display: block; font-size: 36px; font-weight: bold; }
.stat-label { display: block; font-size: 13px; margin-top: 4px; }

.stat-item.total { background: #f0f0ff; color: #667eea; }
.stat-item.normal { background: #f0f9eb; color: #67c23a; }
.stat-item.warning { background: #fdf6ec; color: #e6a23c; }
.stat-item.critical { background: #fef0f0; color: #f56c6c; }
.stat-item.alert { background: #fef0f0; color: #f56c6c; }

.ward-content {
  display: flex;
  gap: 20px;
  margin-top: 20px;
}

.ward-list-card { width: 280px; flex-shrink: 0; }
.monitor-card { flex: 1; }

.ward-list { display: flex; flex-direction: column; gap: 8px; }

.ward-item {
  padding: 12px;
  border: 2px solid #e2e8f0;
  border-radius: 10px;
  cursor: pointer;
  transition: all 0.3s;
}
.ward-item:hover { border-color: #667eea; }
.ward-item.active { border-color: #667eea; background: #f0f0ff; }
.ward-name { font-weight: bold; font-size: 15px; }
.ward-info { font-size: 12px; color: #999; margin-top: 4px; }
.ward-doctor { font-size: 12px; color: #667eea; margin-top: 2px; }

.monitor-header { display: flex; justify-content: space-between; align-items: center; }

.patient-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(220px, 1fr));
  gap: 14px;
}

.patient-card {
  padding: 14px;
  border-radius: 12px;
  border: 2px solid #e2e8f0;
  cursor: pointer;
  transition: all 0.3s;
}
.patient-card:hover { transform: translateY(-2px); box-shadow: 0 4px 12px rgba(0,0,0,0.1); }
.patient-card.normal { border-left: 4px solid #67c23a; }
.patient-card.warning { border-left: 4px solid #e6a23c; background: #fffbf0; }
.patient-card.critical { border-left: 4px solid #f56c6c; background: #fff5f5; animation: pulse 2s infinite; }

@keyframes pulse { 0%, 100% { opacity: 1; } 50% { opacity: 0.85; } }

.patient-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 8px; }
.bed-no { font-weight: bold; color: #333; }
.status-badge { padding: 2px 8px; border-radius: 10px; font-size: 11px; font-weight: bold; }
.status-badge.normal { background: #f0f9eb; color: #67c23a; }
.status-badge.warning { background: #fdf6ec; color: #e6a23c; }
.status-badge.critical { background: #fef0f0; color: #f56c6c; }

.patient-name { font-size: 14px; color: #666; margin-bottom: 10px; }

.vitals-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 6px;
}

.vital-item { display: flex; align-items: center; gap: 4px; font-size: 12px; }
.vital-icon { font-size: 14px; }
.vital-value { font-weight: bold; color: #333; }
.vital-unit { color: #999; font-size: 10px; }

.bottom-area { margin-top: 20px; }
.alert-header { display: flex; justify-content: space-between; align-items: center; }

.alert-list { max-height: 300px; overflow-y: auto; }

.alert-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 10px 14px;
  border-radius: 8px;
  margin-bottom: 8px;
}
.alert-item.critical { background: #fef0f0; }
.alert-item.warning { background: #fdf6ec; }
.alert-item.info { background: #f0f9eb; }
.alert-item.handled { opacity: 0.5; }

.alert-left { display: flex; align-items: center; gap: 10px; }
.alert-level-icon { font-size: 18px; }
.alert-message { font-size: 14px; font-weight: 500; }
.alert-meta { font-size: 12px; color: #999; margin-top: 2px; }

.patient-detail { padding: 10px; }
.detail-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; }
.detail-bed { font-size: 20px; font-weight: bold; }
.detail-status { padding: 4px 12px; border-radius: 12px; font-weight: bold; }
.detail-status.normal { background: #f0f9eb; color: #67c23a; }
.detail-status.warning { background: #fdf6ec; color: #e6a23c; }
.detail-status.critical { background: #fef0f0; color: #f56c6c; }

.vital-detail-grid { display: flex; flex-direction: column; gap: 10px; }
.vital-detail-item {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 10px;
  background: #f5f7fa;
  border-radius: 8px;
}
.vital-detail-icon { font-size: 20px; }
.vital-detail-name { flex: 1; color: #666; }
.vital-detail-value { font-weight: bold; color: #333; }
.vital-detail-status { padding: 2px 8px; border-radius: 8px; font-size: 11px; }
.vital-detail-status.normal { background: #f0f9eb; color: #67c23a; }
.vital-detail-status.warning { background: #fdf6ec; color: #e6a23c; }
.vital-detail-status.critical { background: #fef0f0; color: #f56c6c; }

.detail-actions { margin-top: 24px; display: flex; gap: 10px; flex-wrap: wrap; }
</style>