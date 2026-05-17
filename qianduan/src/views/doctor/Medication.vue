<script setup>
import { ref, onMounted } from 'vue'
import { useUserStore } from '@/stores/user'
import doctorPortalApi from '@/api/doctorPortal'
import { ElMessage } from 'element-plus'

const userStore = useUserStore()
const tableData = ref([])
const total = ref(0)
const page = ref(1)
const pageSize = ref(10)
const loading = ref(false)
const dialogVisible = ref(false)
const doctorId = ref(null)
const patientList = ref([])
const selectedPatientId = ref(null)
const form = ref({ patientId: null, drugName: '', dosage: '', frequency: '', startTime: '', endTime: '', status: 0, remark: '' })

const statusMap = { 0: '待执行', 1: '进行中', 2: '已完成' }
const statusType = { 0: 'info', 1: 'warning', 2: 'success' }

const loadPatients = async () => {
  try {
    const res = await doctorPortalApi.getPatients(doctorId.value, { page: 1, pageSize: 100 })
    patientList.value = (res.records || []).map(p => ({ id: p.id, name: p.username || `患者${p.id}` }))
  } catch (e) { console.error(e) }
}

const loadData = async () => {
  if (!selectedPatientId.value) return
  loading.value = true
  try {
    const res = await doctorPortalApi.getMedicationRecords(selectedPatientId.value, { page: page.value, pageSize: pageSize.value })
    tableData.value = res.records || []
    total.value = res.total || 0
  } catch (e) { ElMessage.error('加载用药记录失败') }
  finally { loading.value = false }
}

const openCreate = () => {
  form.value = { patientId: selectedPatientId.value, drugName: '', dosage: '', frequency: '', startTime: '', endTime: '', status: 0, remark: '' }
  dialogVisible.value = true
}

const handleCreate = async () => {
  if (!form.value.patientId || !form.value.drugName) { ElMessage.warning('请填写必填项'); return }
  try {
    await doctorPortalApi.createMedicationRecord(form.value)
    ElMessage.success('用药记录创建成功')
    dialogVisible.value = false
    loadData()
  } catch (e) { ElMessage.error('创建失败') }
}

onMounted(async () => {
  try {
    const res = await doctorPortalApi.getDoctorInfo(userStore.userInfo?.userId)
    if (res && res.id) {
      doctorId.value = res.id
      loadPatients()
    }
  } catch (e) { ElMessage.warning('请先完善医生信息') }
})
</script>

<template>
  <div class="page-container">
    <el-card>
      <template #header>
        <div class="card-header">
          <span>用药管理</span>
          <div class="filter-row">
            <el-select v-model="selectedPatientId" placeholder="选择患者" style="width: 200px; margin-right: 10px;" @change="loadData">
              <el-option v-for="p in patientList" :key="p.id" :label="p.name" :value="p.id" />
            </el-select>
            <el-button type="success" @click="openCreate" :disabled="!selectedPatientId">新增用药</el-button>
          </div>
        </div>
      </template>
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
      </el-table>
      <el-pagination v-model:current-page="page" v-model:page-size="pageSize" :total="total" @current-change="loadData" layout="total, prev, pager, next" style="margin-top: 16px;" />
    </el-card>

    <el-dialog v-model="dialogVisible" title="新增用药记录" width="600px">
      <el-form :model="form" label-width="80px">
        <el-form-item label="患者">
          <el-select v-model="form.patientId" style="width: 100%;">
            <el-option v-for="p in patientList" :key="p.id" :label="p.name" :value="p.id" />
          </el-select>
        </el-form-item>
        <el-form-item label="药品名称" required><el-input v-model="form.drugName" /></el-form-item>
        <el-form-item label="剂量"><el-input v-model="form.dosage" placeholder="如 10mg/片" /></el-form-item>
        <el-form-item label="频次"><el-input v-model="form.frequency" placeholder="如 每日3次" /></el-form-item>
        <el-form-item label="开始时间"><el-input v-model="form.startTime" type="datetime-local" /></el-form-item>
        <el-form-item label="结束时间"><el-input v-model="form.endTime" type="datetime-local" /></el-form-item>
        <el-form-item label="备注"><el-input v-model="form.remark" type="textarea" :rows="2" /></el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleCreate">确定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<style scoped>
.card-header { display: flex; justify-content: space-between; align-items: center; }
.filter-row { display: flex; align-items: center; }
</style>
