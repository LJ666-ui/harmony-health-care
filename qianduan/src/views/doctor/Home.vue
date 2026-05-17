<script setup>
import { ref, onMounted } from 'vue'
import { useUserStore } from '@/stores/user'
import doctorPortalApi from '@/api/doctorPortal'

const userStore = useUserStore()
const stats = ref({ patientCount: 0, appointmentCount: 0, todayAppointment: 0, recordCount: 0 })
const doctorInfo = ref(null)
const loading = ref(true)

onMounted(async () => {
  try {
    const userId = userStore.userInfo?.userId
    const res = await doctorPortalApi.getDoctorInfo(userId)
    doctorInfo.value = res
    if (res && res.id) {
      const s = await doctorPortalApi.getStatistics(res.id)
      stats.value = s
    }
  } catch (e) {
    console.error(e)
  } finally {
    loading.value = false
  }
})
</script>

<template>
  <div class="doctor-home">
    <el-row :gutter="20" class="stats-row">
      <el-col :span="6">
        <el-card shadow="hover" class="stat-card">
          <div class="stat-icon" style="background: #4caf50;">👥</div>
          <div class="stat-info">
            <div class="stat-value">{{ stats.patientCount }}</div>
            <div class="stat-label">我的患者</div>
          </div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="hover" class="stat-card">
          <div class="stat-icon" style="background: #2196f3;">📅</div>
          <div class="stat-info">
            <div class="stat-value">{{ stats.appointmentCount }}</div>
            <div class="stat-label">预约总数</div>
          </div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="hover" class="stat-card">
          <div class="stat-icon" style="background: #ff9800;">📋</div>
          <div class="stat-info">
            <div class="stat-value">{{ stats.recordCount }}</div>
            <div class="stat-label">病历数</div>
          </div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="hover" class="stat-card">
          <div class="stat-icon" style="background: #9c27b0;">💊</div>
          <div class="stat-info">
            <div class="stat-value">{{ stats.todayAppointment }}</div>
            <div class="stat-label">今日预约</div>
          </div>
        </el-card>
      </el-col>
    </el-row>

    <el-row :gutter="20" style="margin-top: 20px;">
      <el-col :span="12">
        <el-card>
          <template #header><span>医生信息</span></template>
          <div v-if="doctorInfo" class="doctor-info">
            <p><strong>姓名：</strong>{{ doctorInfo.userName || userStore.userInfo?.username || '未设置' }}</p>
            <p><strong>科室：</strong>{{ doctorInfo.department || '未设置' }}</p>
            <p><strong>职称：</strong>{{ doctorInfo.title || '未设置' }}</p>
            <p><strong>专长：</strong>{{ doctorInfo.specialty || '未设置' }}</p>
            <p><strong>医院：</strong>{{ doctorInfo.hospitalName || doctorInfo.hospital || '未设置' }}</p>
            <p><strong>评分：</strong>{{ doctorInfo.rating || '暂无' }}</p>
          </div>
          <el-empty v-else description="暂无医生信息" />
        </el-card>
      </el-col>
      <el-col :span="12">
        <el-card>
          <template #header><span>快捷操作</span></template>
          <div class="quick-actions">
            <el-button type="primary" @click="$router.push('/doctor/appointment')">查看预约</el-button>
            <el-button type="success" @click="$router.push('/doctor/medical-record')">写病历</el-button>
            <el-button type="warning" @click="$router.push('/doctor/medication')">用药管理</el-button>
            <el-button type="info" @click="$router.push('/doctor/transfer')">转诊管理</el-button>
          </div>
        </el-card>
      </el-col>
    </el-row>
  </div>
</template>

<style scoped>
.stats-row { margin-bottom: 20px; }
.stat-card { display: flex; align-items: center; padding: 20px; }
.stat-card .stat-icon { width: 60px; height: 60px; border-radius: 12px; display: flex; align-items: center; justify-content: center; font-size: 28px; color: #fff; margin-right: 16px; flex-shrink: 0; }
.stat-info { flex: 1; }
.stat-value { font-size: 28px; font-weight: bold; color: #333; }
.stat-label { font-size: 14px; color: #999; margin-top: 4px; }
.doctor-info p { margin: 8px 0; font-size: 14px; color: #555; }
.quick-actions { display: flex; flex-wrap: wrap; gap: 12px; }
.quick-actions .el-button { width: calc(50% - 6px); }
</style>
