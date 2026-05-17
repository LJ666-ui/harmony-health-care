<script setup>
import { ref, onMounted } from 'vue'
import { useUserStore } from '@/stores/user'
import familyPortalApi from '@/api/familyPortal'
import { ElMessage } from 'element-plus'

const userStore = useUserStore()
const activeAlerts = ref([])
const allAlerts = ref([])
const total = ref(0)
const page = ref(1)
const pageSize = ref(10)
const loading = ref(false)
const showAll = ref(false)

const alertLevelType = { low: 'info', medium: 'warning', high: 'danger', critical: 'danger' }
const alertLevelText = { low: '低', medium: '中', high: '高', critical: '严重' }
const alertStatusMap = { active: '活跃', acknowledged: '已确认', resolved: '已解决', dismissed: '已忽略' }
const alertStatusType = { active: 'danger', acknowledged: 'warning', resolved: 'success', dismissed: 'info' }

const loadActiveAlerts = async () => {
  loading.value = true
  try {
    activeAlerts.value = await familyPortalApi.getActiveAlerts(userStore.userInfo?.userId, userStore.userInfo?.familyMemberId)
  } catch (e) { ElMessage.error('加载预警失败') }
  finally { loading.value = false }
}

const loadAllAlerts = async () => {
  loading.value = true
  try {
    const res = await familyPortalApi.getAlertHistory(userStore.userInfo?.userId, { page: page.value, pageSize: pageSize.value }, userStore.userInfo?.familyMemberId)
    allAlerts.value = res.records || []
    total.value = res.total || 0
  } catch (e) { ElMessage.error('加载预警历史失败') }
  finally { loading.value = false }
}

const handleAcknowledge = async (alertId) => {
  try {
    await familyPortalApi.acknowledgeAlert(alertId)
    ElMessage.success('已确认预警')
    loadActiveAlerts()
    if (showAll.value) loadAllAlerts()
  } catch (e) { ElMessage.error('操作失败') }
}

const handleResolve = async (alertId) => {
  try {
    await familyPortalApi.resolveAlert(alertId)
    ElMessage.success('已解决预警')
    loadActiveAlerts()
    if (showAll.value) loadAllAlerts()
  } catch (e) { ElMessage.error('操作失败') }
}

const toggleView = () => {
  showAll.value = !showAll.value
  if (showAll.value) loadAllAlerts()
  else loadActiveAlerts()
}

onMounted(() => { loadActiveAlerts() })
</script>

<template>
  <div class="page-container">
    <el-card>
      <template #header>
        <div class="card-header">
          <span>🚨 健康预警</span>
          <div class="filter-row">
            <el-badge :value="activeAlerts.length" type="danger" style="margin-right: 12px;">
              <el-button :type="!showAll ? 'danger' : ''" @click="toggleView">活跃预警</el-button>
            </el-badge>
            <el-button :type="showAll ? 'primary' : ''" @click="toggleView">历史记录</el-button>
          </div>
        </div>
      </template>

      <div v-if="!showAll">
        <div v-if="activeAlerts.length === 0">
          <el-empty description="暂无活跃预警，家人健康状态正常 🎉" />
        </div>
        <div v-else class="alert-cards">
          <div v-for="a in activeAlerts" :key="a.alertId" class="alert-card" :class="'level-' + (a.alertLevel || 'low')">
            <div class="alert-header">
              <el-tag :type="alertLevelType[a.alertLevel]" effect="dark">{{ alertLevelText[a.alertLevel] || a.alertLevel }}</el-tag>
              <span class="alert-time">{{ a.createTime }}</span>
            </div>
            <div class="alert-body">
              <h4>{{ a.alertTitle }}</h4>
              <p>{{ a.alertContent }}</p>
              <p v-if="a.actualValue" class="vital-value">异常值：{{ a.actualValue }} {{ a.unit ? a.unit : '' }}</p>
              <p v-if="a.thresholdValue" class="threshold-value">阈值：{{ a.thresholdValue }} {{ a.unit ? a.unit : '' }}</p>
            </div>
            <div class="alert-actions">
              <el-button type="warning" size="small" @click="handleAcknowledge(a.alertId)">确认</el-button>
              <el-button type="success" size="small" @click="handleResolve(a.alertId)">已解决</el-button>
            </div>
          </div>
        </div>
      </div>

      <div v-else>
        <el-table :data="allAlerts" v-loading="loading" stripe>
          <el-table-column label="级别" width="80">
            <template #default="{ row }"><el-tag :type="alertLevelType[row.alertLevel]" size="small">{{ alertLevelText[row.alertLevel] }}</el-tag></template>
          </el-table-column>
          <el-table-column prop="alertTitle" label="标题" min-width="150" />
          <el-table-column prop="alertContent" label="内容" min-width="200" />
          <el-table-column prop="actualValue" label="异常值" width="100" />
          <el-table-column prop="thresholdValue" label="阈值" width="100" />
          <el-table-column label="状态" width="100">
            <template #default="{ row }"><el-tag :type="alertStatusType[row.status]" size="small">{{ alertStatusMap[row.status] }}</el-tag></template>
          </el-table-column>
          <el-table-column prop="createTime" label="时间" width="170" />
        </el-table>
        <el-pagination v-model:current-page="page" v-model:page-size="pageSize" :total="total" @current-change="loadAllAlerts" layout="total, prev, pager, next" style="margin-top: 16px;" />
      </div>
    </el-card>
  </div>
</template>

<style scoped>
.card-header { display: flex; justify-content: space-between; align-items: center; }
.filter-row { display: flex; align-items: center; }
.alert-cards { display: flex; flex-direction: column; gap: 12px; }
.alert-card { border: 1px solid #f0f0f0; border-radius: 8px; padding: 16px; transition: all 0.3s; }
.alert-card.level-critical { border-left: 4px solid #f44336; background: #fff5f5; }
.alert-card.level-high { border-left: 4px solid #ff9800; background: #fffaf0; }
.alert-card.level-medium { border-left: 4px solid #ffc107; background: #fffde7; }
.alert-card.level-low { border-left: 4px solid #4caf50; background: #f1f8e9; }
.alert-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 8px; }
.alert-time { font-size: 12px; color: #999; }
.alert-body h4 { margin: 0 0 6px; font-size: 16px; color: #333; }
.alert-body p { margin: 4px 0; font-size: 13px; color: #666; }
.vital-value { color: #f44336; font-weight: 500; }
.threshold-value { color: #ff9800; }
.alert-actions { margin-top: 10px; display: flex; gap: 8px; }
</style>
