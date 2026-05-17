<script setup>
import { ref, onMounted } from 'vue'
import { useUserStore } from '@/stores/user'
import nursePortalApi from '@/api/nursePortal'
import { ElMessage } from 'element-plus'

const userStore = useUserStore()
const nurseId = ref(null)
const patientList = ref([])
const selectedPatientId = ref(null)
const tableData = ref([])
const total = ref(0)
const page = ref(1)
const pageSize = ref(10)
const loading = ref(false)

const loadPatients = async () => {
  try {
    const res = await nursePortalApi.getPatients(nurseId.value, { page: 1, pageSize: 100 })
    patientList.value = (res.records || []).map(p => ({ id: p.id, name: p.username || `患者${p.id}` }))
  } catch (e) { console.error(e) }
}

const loadData = async () => {
  if (!selectedPatientId.value) { ElMessage.warning('请选择患者'); return }
  loading.value = true
  try {
    const res = await nursePortalApi.getVitalSigns(selectedPatientId.value, { page: page.value, pageSize: pageSize.value })
    tableData.value = res.records || []
    total.value = res.total || 0
  } catch (e) { ElMessage.error('加载生命体征数据失败') }
  finally { loading.value = false }
}

onMounted(async () => {
  try {
    const res = await nursePortalApi.getNurseInfo(userStore.userInfo?.userId)
    if (res && res.id) {
      nurseId.value = res.id
      loadPatients()
    }
  } catch (e) { ElMessage.warning('请先完善护士信息') }
})
</script>

<template>
  <div class="page-container">
    <el-card>
      <template #header>
        <div class="card-header">
          <span>生命体征监测</span>
          <div class="filter-row">
            <el-select v-model="selectedPatientId" placeholder="选择患者" style="width: 200px; margin-right: 10px;" @change="loadData">
              <el-option v-for="p in patientList" :key="p.id" :label="p.name" :value="p.id" />
            </el-select>
          </div>
        </div>
      </template>
      <el-table :data="tableData" v-loading="loading" stripe>
        <el-table-column prop="bloodPressure" label="血压(mmHg)" width="120" />
        <el-table-column prop="bloodSugar" label="血糖(mmol/L)" width="120" />
        <el-table-column prop="heartRate" label="心率(次/分)" width="120" />
        <el-table-column prop="weight" label="体重(kg)" width="100" />
        <el-table-column prop="height" label="身高(cm)" width="100" />
        <el-table-column prop="stepCount" label="步数" width="80" />
        <el-table-column prop="sleepDuration" label="睡眠(h)" width="80" />
        <el-table-column prop="recordTime" label="记录时间" min-width="170" />
      </el-table>
      <el-pagination v-model:current-page="page" v-model:page-size="pageSize" :total="total" @current-change="loadData" layout="total, prev, pager, next" style="margin-top: 16px;" />
    </el-card>
  </div>
</template>

<style scoped>
.card-header { display: flex; justify-content: space-between; align-items: center; }
.filter-row { display: flex; align-items: center; }
</style>
