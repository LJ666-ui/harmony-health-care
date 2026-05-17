<script setup>
import { ref, onMounted, watch } from 'vue'
import { useUserStore } from '@/stores/user'
import familyPortalApi from '@/api/familyPortal'
import { ElMessage } from 'element-plus'

const userStore = useUserStore()
const patientList = ref([])
const selectedPatientId = ref(null)
const tableData = ref([])
const total = ref(0)
const page = ref(1)
const pageSize = ref(10)
const loading = ref(false)
const dateRange = ref([])

const loadPatients = async () => {
  try {
    const userId = userStore.userInfo?.userId
    const familyMemberId = userStore.userInfo?.familyMemberId
    patientList.value = await familyPortalApi.getLinkedPatients(userId, familyMemberId)
    if (patientList.value.length > 0 && !selectedPatientId.value) {
      selectedPatientId.value = patientList.value[0].patient?.id
    }
  } catch (e) { console.error(e) }
}

const loadData = async () => {
  if (!selectedPatientId.value) return
  loading.value = true
  try {
    const params = { page: page.value, pageSize: pageSize.value }
    if (dateRange.value && dateRange.value.length === 2) {
      params.startDate = dateRange.value[0]
      params.endDate = dateRange.value[1]
    }
    const res = await familyPortalApi.getHealthData(selectedPatientId.value, params)
    tableData.value = res.records || []
    total.value = res.total || 0
  } catch (e) { ElMessage.error('加载健康数据失败') }
  finally { loading.value = false }
}

watch(selectedPatientId, () => { if (selectedPatientId.value) loadData() })

const getBloodPressureStatus = (bp) => {
  if (!bp) return ''
  const match = bp.match(/(\d+)\/(\d+)/)
  if (!match) return ''
  const sys = parseInt(match[1])
  const dia = parseInt(match[2])
  if (sys >= 140 || dia >= 90) return 'danger'
  if (sys >= 130 || dia >= 85) return 'warning'
  return 'success'
}

const getHeartRateStatus = (hr) => {
  if (!hr) return ''
  if (hr > 100 || hr < 60) return 'danger'
  if (hr > 90 || hr < 65) return 'warning'
  return 'success'
}

const getBloodSugarStatus = (bs) => {
  if (!bs) return ''
  if (bs > 11.1 || bs < 3.9) return 'danger'
  if (bs > 7.8 || bs < 4.2) return 'warning'
  return 'success'
}

onMounted(() => { loadPatients() })
</script>

<template>
  <div class="page-container">
    <el-card>
      <template #header>
        <div class="card-header">
          <span>📊 健康数据</span>
          <div class="filter-row">
            <el-select v-model="selectedPatientId" placeholder="选择患者" style="width: 200px; margin-right: 10px;">
              <el-option v-for="p in patientList" :key="p.patient?.id" :label="p.patient?.username || `患者${p.patient?.id}`" :value="p.patient?.id" />
            </el-select>
            <el-date-picker v-model="dateRange" type="daterange" range-separator="至" start-placeholder="开始日期" end-placeholder="结束日期" value-format="YYYY-MM-DD" style="margin-right: 10px;" />
            <el-button type="primary" @click="loadData">查询</el-button>
          </div>
        </div>
      </template>
      <el-table :data="tableData" v-loading="loading" stripe>
        <el-table-column prop="recordTime" label="记录时间" width="170" />
        <el-table-column label="血压" width="110">
          <template #default="{ row }">
            <span :class="'status-' + getBloodPressureStatus(row.bloodPressure)">{{ row.bloodPressure || '-' }}</span>
          </template>
        </el-table-column>
        <el-table-column label="血糖(mmol/L)" width="120">
          <template #default="{ row }">
            <span :class="'status-' + getBloodSugarStatus(row.bloodSugar)">{{ row.bloodSugar || '-' }}</span>
          </template>
        </el-table-column>
        <el-table-column label="心率(次/分)" width="120">
          <template #default="{ row }">
            <span :class="'status-' + getHeartRateStatus(row.heartRate)">{{ row.heartRate || '-' }}</span>
          </template>
        </el-table-column>
        <el-table-column prop="weight" label="体重(kg)" width="100" />
        <el-table-column prop="stepCount" label="步数" width="80" />
        <el-table-column prop="sleepDuration" label="睡眠(h)" width="80" />
        <el-table-column prop="calories" label="卡路里" width="80" />
      </el-table>
      <el-pagination v-model:current-page="page" v-model:page-size="pageSize" :total="total" @current-change="loadData" layout="total, prev, pager, next" style="margin-top: 16px;" />

      <div class="legend" style="margin-top: 16px; display: flex; gap: 20px; font-size: 12px; color: #999;">
        <span><span style="color: #67c23a;">●</span> 正常</span>
        <span><span style="color: #e6a23c;">●</span> 偏高/偏低</span>
        <span><span style="color: #f56c6c;">●</span> 异常</span>
      </div>
    </el-card>
  </div>
</template>

<style scoped>
.card-header { display: flex; justify-content: space-between; align-items: center; }
.filter-row { display: flex; align-items: center; }
.status-success { color: #67c23a; font-weight: 500; }
.status-warning { color: #e6a23c; font-weight: 500; }
.status-danger { color: #f56c6c; font-weight: bold; }
</style>
