<script setup>
import { ref, onMounted } from 'vue'
import { useUserStore } from '@/stores/user'
import nursePortalApi from '@/api/nursePortal'
import { ElMessage } from 'element-plus'

const userStore = useUserStore()
const stats = ref({ patientCount: 0, todayRecordCount: 0, activePlanCount: 0, pendingMedCount: 0 })
const nurseInfo = ref(null)
const loading = ref(true)

onMounted(async () => {
  try {
    const userId = userStore.userInfo?.userId
    const res = await nursePortalApi.getNurseInfo(userId)
    nurseInfo.value = res
    if (res && res.id) {
      const s = await nursePortalApi.getStatistics(res.id)
      stats.value = s
    }
  } catch (e) { console.error(e) }
  finally { loading.value = false }
})
</script>

<template>
  <div class="nurse-home">
    <el-row :gutter="20" class="stats-row">
      <el-col :span="6">
        <el-card shadow="hover" class="stat-card">
          <div class="stat-icon" style="background: #9c27b0;">👥</div>
          <div class="stat-info">
            <div class="stat-value">{{ stats.patientCount }}</div>
            <div class="stat-label">负责患者</div>
          </div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="hover" class="stat-card">
          <div class="stat-icon" style="background: #e91e63;">📝</div>
          <div class="stat-info">
            <div class="stat-value">{{ stats.todayRecordCount }}</div>
            <div class="stat-label">今日护理记录</div>
          </div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="hover" class="stat-card">
          <div class="stat-icon" style="background: #3f51b5;">📋</div>
          <div class="stat-info">
            <div class="stat-value">{{ stats.activePlanCount }}</div>
            <div class="stat-label">活跃护理计划</div>
          </div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="hover" class="stat-card">
          <div class="stat-icon" style="background: #ff5722;">💊</div>
          <div class="stat-info">
            <div class="stat-value">{{ stats.pendingMedCount }}</div>
            <div class="stat-label">待执行医嘱</div>
          </div>
        </el-card>
      </el-col>
    </el-row>

    <el-row :gutter="20" style="margin-top: 20px;">
      <el-col :span="12">
        <el-card>
          <template #header><span>护士信息</span></template>
          <div v-if="nurseInfo" class="nurse-info">
            <p><strong>姓名：</strong>{{ nurseInfo.userName || userStore.userInfo?.username || '未设置' }}</p>
            <p><strong>工号：</strong>{{ nurseInfo.nurseNo || '未设置' }}</p>
            <p><strong>科室：</strong>{{ nurseInfo.department || '未设置' }}</p>
            <p><strong>职称：</strong>{{ nurseInfo.title || '未设置' }}</p>
          </div>
          <el-empty v-else description="暂无护士信息" />
        </el-card>
      </el-col>
      <el-col :span="12">
        <el-card>
          <template #header><span>快捷操作</span></template>
          <div class="quick-actions">
            <el-button type="primary" @click="$router.push('/nurse/patients')">患者监护</el-button>
            <el-button type="success" @click="$router.push('/nurse/vital-signs')">生命体征</el-button>
            <el-button type="warning" @click="$router.push('/nurse/nursing-record')">护理记录</el-button>
            <el-button type="info" @click="$router.push('/nurse/medication-exec')">执行医嘱</el-button>
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
.nurse-info p { margin: 8px 0; font-size: 14px; color: #555; }
.quick-actions { display: flex; flex-wrap: wrap; gap: 12px; }
.quick-actions .el-button { width: calc(50% - 6px); }
</style>
