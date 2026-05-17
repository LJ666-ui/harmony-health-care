<script setup>
import { ref, onMounted } from 'vue'
import { useUserStore } from '@/stores/user'
import nursePortalApi from '@/api/nursePortal'
import { ElMessage, ElMessageBox } from 'element-plus'

const userStore = useUserStore()
const tableData = ref([])
const total = ref(0)
const page = ref(1)
const pageSize = ref(10)
const loading = ref(false)
const nurseId = ref(null)

const statusMap = { 0: '待执行', 1: '进行中', 2: '已完成' }
const statusType = { 0: 'danger', 1: 'warning', 2: 'success' }

const loadData = async () => {
  loading.value = true
  try {
    const res = await nursePortalApi.getMedicationForExec(nurseId.value, { page: page.value, pageSize: pageSize.value })
    tableData.value = res.records || []
    total.value = res.total || 0
  } catch (e) { ElMessage.error('加载医嘱列表失败') }
  finally { loading.value = false }
}

const executeMed = async (row) => {
  try {
    await ElMessageBox.confirm(`确认执行 ${row.drugName} 的用药医嘱？`, '执行确认')
    await nursePortalApi.executeMedication(row.id, 1)
    ElMessage.success('已执行')
    loadData()
  } catch (e) {}
}

const completeMed = async (row) => {
  try {
    await ElMessageBox.confirm(`确认完成 ${row.drugName} 的用药？`, '完成确认')
    await nursePortalApi.executeMedication(row.id, 2)
    ElMessage.success('已完成')
    loadData()
  } catch (e) {}
}

onMounted(async () => {
  try {
    const res = await nursePortalApi.getNurseInfo(userStore.userInfo?.userId)
    if (res && res.id) { nurseId.value = res.id; loadData() }
  } catch (e) { ElMessage.warning('请先完善护士信息') }
})
</script>

<template>
  <div class="page-container">
    <el-card>
      <template #header><span>执行医嘱</span></template>
      <el-table :data="tableData" v-loading="loading" stripe>
        <el-table-column prop="patientName" label="患者" width="100" />
        <el-table-column prop="drugName" label="药品名称" width="150" />
        <el-table-column prop="dosage" label="剂量" width="120" />
        <el-table-column prop="frequency" label="频次" width="120" />
        <el-table-column prop="startTime" label="开始时间" width="170" />
        <el-table-column prop="endTime" label="结束时间" width="170" />
        <el-table-column label="状态" width="100">
          <template #default="{ row }"><el-tag :type="statusType[row.status]">{{ statusMap[row.status] }}</el-tag></template>
        </el-table-column>
        <el-table-column prop="remark" label="备注" min-width="150" />
        <el-table-column label="操作" width="160" fixed="right">
          <template #default="{ row }">
            <el-button v-if="row.status === 0" type="primary" size="small" @click="executeMed(row)">执行</el-button>
            <el-button v-if="row.status === 1" type="success" size="small" @click="completeMed(row)">完成</el-button>
          </template>
        </el-table-column>
      </el-table>
      <el-pagination v-model:current-page="page" v-model:page-size="pageSize" :total="total" @current-change="loadData" layout="total, prev, pager, next" style="margin-top: 16px;" />
    </el-card>
  </div>
</template>
