<script setup>
import { ref, onMounted } from 'vue'
import { useUserStore } from '@/stores/user'
import familyPortalApi from '@/api/familyPortal'
import { useRouter } from 'vue-router'

const userStore = useUserStore()
const router = useRouter()
const activeAlerts = ref([])
const linkedPatients = ref([])
const loading = ref(true)

const alertLevelType = { low: 'info', medium: 'warning', high: 'danger', critical: 'danger' }
const alertLevelText = { low: '低', medium: '中', high: '高', critical: '严重' }

onMounted(async () => {
  try {
    const userId = userStore.userInfo?.userId
    const familyMemberId = userStore.userInfo?.familyMemberId
    const [alertsRes, patientsRes] = await Promise.all([
      familyPortalApi.getActiveAlerts(userId, familyMemberId),
      familyPortalApi.getLinkedPatients(userId, familyMemberId)
    ])
    activeAlerts.value = alertsRes || []
    linkedPatients.value = patientsRes || []
  } catch (e) { console.error(e) }
  finally { loading.value = false }
})
</script>

<template>
  <div class="family-home">
    <el-row :gutter="20">
      <el-col :span="16">
        <el-card>
          <template #header>
            <div class="card-header">
              <span>家人健康概览</span>
              <el-button type="primary" size="small" @click="router.push('/family/patient-info')">查看详情</el-button>
            </div>
          </template>
          <div v-if="linkedPatients.length === 0">
            <el-empty description="暂无关联患者信息" />
          </div>
          <div v-else class="patient-list">
            <div v-for="p in linkedPatients" :key="p.patient?.id" class="patient-card" @click="router.push('/family/patient-info')">
              <div class="patient-avatar">{{ p.patient?.username?.charAt(0) || '?' }}</div>
              <div class="patient-info">
                <div class="patient-name">{{ p.patient?.username || '未知' }}</div>
                <div class="patient-health">
                  <span v-if="p.latestHealth">
                    血压: {{ p.latestHealth.bloodPressure || '-' }} | 心率: {{ p.latestHealth.heartRate || '-' }}
                  </span>
                  <span v-else>暂无健康数据</span>
                </div>
              </div>
              <el-badge v-if="p.activeAlertCount > 0" :value="p.activeAlertCount" type="danger" />
            </div>
          </div>
        </el-card>
      </el-col>
      <el-col :span="8">
        <el-card>
          <template #header>
            <div class="card-header">
              <span>🚨 健康预警</span>
              <el-button type="danger" size="small" @click="router.push('/family/alert')">全部预警</el-button>
            </div>
          </template>
          <div v-if="activeAlerts.length === 0">
            <el-empty description="暂无预警" :image-size="60" />
          </div>
          <div v-else class="alert-list">
            <div v-for="a in activeAlerts.slice(0, 5)" :key="a.alertId" class="alert-item">
              <el-tag :type="alertLevelType[a.alertLevel]" size="small">{{ alertLevelText[a.alertLevel] || a.alertLevel }}</el-tag>
              <span class="alert-title">{{ a.alertTitle }}</span>
              <span class="alert-time">{{ a.createTime }}</span>
            </div>
          </div>
        </el-card>

        <el-card style="margin-top: 20px;">
          <template #header><span>快捷入口</span></template>
          <div class="quick-links">
            <el-button type="warning" @click="router.push('/family/alert')" style="width: 100%; margin-bottom: 10px;">🚨 健康预警</el-button>
            <el-button type="success" @click="router.push('/family/health-data')" style="width: 100%;">📊 健康数据</el-button>
          </div>
        </el-card>
      </el-col>
    </el-row>
  </div>
</template>

<style scoped>
.card-header { display: flex; justify-content: space-between; align-items: center; }
.patient-list { display: flex; flex-direction: column; gap: 12px; }
.patient-card { display: flex; align-items: center; gap: 12px; padding: 12px; border: 1px solid #f0f0f0; border-radius: 8px; cursor: pointer; transition: all 0.3s; }
.patient-card:hover { border-color: #ff9800; background: #fff8f0; }
.patient-avatar { width: 40px; height: 40px; border-radius: 50%; background: #ff9800; color: #fff; display: flex; align-items: center; justify-content: center; font-size: 16px; font-weight: bold; flex-shrink: 0; }
.patient-info { flex: 1; }
.patient-name { font-size: 16px; font-weight: 500; color: #333; }
.patient-health { font-size: 12px; color: #999; margin-top: 4px; }
.alert-list { display: flex; flex-direction: column; gap: 8px; }
.alert-item { display: flex; align-items: center; gap: 8px; padding: 6px 0; border-bottom: 1px solid #f5f5f5; }
.alert-title { flex: 1; font-size: 13px; color: #333; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
.alert-time { font-size: 11px; color: #999; flex-shrink: 0; }
</style>
