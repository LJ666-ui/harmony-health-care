<script setup>
import { ref, onMounted, watch } from 'vue'
import { useUserStore } from '@/stores/user'
import familyPortalApi from '@/api/familyPortal'
import { ElMessage } from 'element-plus'

const userStore = useUserStore()
const patientList = ref([])
const selectedPatientId = ref(null)
const patientDetail = ref(null)
const loading = ref(true)

const loadPatients = async () => {
  try {
    const userId = userStore.userInfo?.userId
    const familyMemberId = userStore.userInfo?.familyMemberId
    patientList.value = await familyPortalApi.getLinkedPatients(userId, familyMemberId)
    if (patientList.value.length > 0 && !selectedPatientId.value) {
      selectedPatientId.value = patientList.value[0].patient?.id
    }
  } catch (e) { console.error(e) }
  finally { loading.value = false }
}

const loadPatientDetail = async () => {
  if (!selectedPatientId.value) return
  loading.value = true
  try {
    patientDetail.value = await familyPortalApi.getPatientInfo(selectedPatientId.value)
  } catch (e) { ElMessage.error('加载患者信息失败') }
  finally { loading.value = false }
}

watch(selectedPatientId, () => { loadPatientDetail() })

onMounted(() => { loadPatients() })
</script>

<template>
  <div class="page-container" v-loading="loading">
    <el-card style="margin-bottom: 20px;">
      <template #header>
        <div class="card-header">
          <span>关联患者</span>
          <el-select v-model="selectedPatientId" placeholder="选择患者" style="width: 200px;" @change="loadPatientDetail">
            <el-option v-for="p in patientList" :key="p.patient?.id" :label="p.patient?.username || `患者${p.patient?.id}`" :value="p.patient?.id" />
          </el-select>
        </div>
      </template>
      <el-row :gutter="20" v-if="patientList.length > 0">
        <el-col :span="6" v-for="p in patientList" :key="p.patient?.id">
          <el-card shadow="hover" :class="{ 'patient-card-active': selectedPatientId === p.patient?.id }" class="patient-card" @click="selectedPatientId = p.patient?.id">
            <div class="patient-name">{{ p.patient?.username || '未知' }}</div>
            <div class="patient-status">
              <el-tag v-if="p.activeAlertCount > 0" type="danger" size="small">{{ p.activeAlertCount }}条预警</el-tag>
              <el-tag v-else type="success" size="small">健康正常</el-tag>
            </div>
            <div v-if="p.latestHealth" class="patient-vitals">
              <span>血压: {{ p.latestHealth.bloodPressure || '-' }}</span>
              <span>心率: {{ p.latestHealth.heartRate || '-' }}</span>
            </div>
          </el-card>
        </el-col>
      </el-row>
      <el-empty v-else description="暂无关联患者" />
    </el-card>

    <el-row :gutter="20" v-if="selectedPatientId && patientDetail">
      <el-col :span="8">
        <el-card>
          <template #header><span>患者信息</span></template>
          <div v-if="patientDetail?.user" class="info-section">
            <p><strong>姓名：</strong>{{ patientDetail.user.username }}</p>
            <p><strong>手机：</strong>{{ patientDetail.user.phone || '未设置' }}</p>
            <p><strong>年龄：</strong>{{ patientDetail.user.age || '未设置' }}</p>
          </div>
          <el-empty v-else description="暂无信息" />
        </el-card>
      </el-col>
      <el-col :span="16">
        <el-card>
          <template #header><span>最近健康记录</span></template>
          <el-table :data="patientDetail?.recentHealthRecords || []" size="small" stripe>
            <el-table-column prop="bloodPressure" label="血压" width="100" />
            <el-table-column prop="bloodSugar" label="血糖" width="80" />
            <el-table-column prop="heartRate" label="心率" width="80" />
            <el-table-column prop="weight" label="体重" width="80" />
            <el-table-column prop="stepCount" label="步数" width="80" />
            <el-table-column prop="sleepDuration" label="睡眠" width="80" />
            <el-table-column prop="recordTime" label="时间" min-width="150" />
          </el-table>
        </el-card>

        <el-card style="margin-top: 20px;">
          <template #header><span>当前用药</span></template>
          <el-table :data="patientDetail?.currentMedications || []" size="small" stripe>
            <el-table-column prop="drugName" label="药品" width="150" />
            <el-table-column prop="dosage" label="剂量" width="120" />
            <el-table-column prop="frequency" label="频次" width="120" />
            <el-table-column prop="startTime" label="开始时间" width="170" />
            <el-table-column prop="endTime" label="结束时间" min-width="170" />
          </el-table>
          <el-empty v-if="!patientDetail?.currentMedications?.length" description="暂无用药记录" />
        </el-card>
      </el-col>
    </el-row>
  </div>
</template>

<style scoped>
.card-header { display: flex; justify-content: space-between; align-items: center; }
.info-section p { margin: 10px 0; font-size: 14px; color: #555; }
.patient-card { cursor: pointer; text-align: center; margin-bottom: 10px; transition: all 0.3s; }
.patient-card:hover { transform: translateY(-2px); }
.patient-card-active { border-color: #409eff; box-shadow: 0 0 8px rgba(64, 158, 255, 0.3); }
.patient-name { font-size: 16px; font-weight: bold; margin-bottom: 8px; }
.patient-status { margin-bottom: 8px; }
.patient-vitals { font-size: 12px; color: #999; display: flex; justify-content: space-around; }
</style>
