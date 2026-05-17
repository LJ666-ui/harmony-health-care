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
const form = ref({ userId: null, hospitalId: null, doctorId: null, diagnosis: '', treatment: '', recordTime: '' })

const loadPatients = async () => {
  try {
    const res = await doctorPortalApi.getPatients(doctorId.value, { page: 1, pageSize: 100 })
    patientList.value = (res.records || []).map(p => ({ id: p.id, name: p.username || `患者${p.id}` }))
  } catch (e) { console.error(e) }
}

const loadData = async () => {
  loading.value = true
  try {
    const res = await doctorPortalApi.getMedicalRecords(doctorId.value, { page: page.value, pageSize: pageSize.value })
    tableData.value = res.records || []
    total.value = res.total || 0
  } catch (e) { ElMessage.error('加载病历列表失败') }
  finally { loading.value = false }
}

const openCreate = () => {
  form.value = { userId: null, hospitalId: null, doctorId: doctorId.value, diagnosis: '', treatment: '', recordTime: new Date().toISOString().slice(0, 16) }
  dialogVisible.value = true
}

const handleCreate = async () => {
  if (!form.value.userId || !form.value.diagnosis) { ElMessage.warning('请填写必填项'); return }
  try {
    await doctorPortalApi.createMedicalRecord(form.value)
    ElMessage.success('病历创建成功')
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
      loadData()
    }
  } catch (e) { ElMessage.warning('请先完善医生信息') }
})
</script>

<template>
  <div class="page-container">
    <el-card>
      <template #header>
        <div class="card-header">
          <span>病历管理</span>
          <el-button type="primary" @click="openCreate">新增病历</el-button>
        </div>
      </template>
      <el-table :data="tableData" v-loading="loading" stripe>
        <el-table-column prop="userName" label="患者" width="100" />
        <el-table-column prop="hospitalName" label="医院" width="150" />
        <el-table-column prop="doctorName" label="医生" width="100" />
        <el-table-column prop="diagnosis" label="诊断" min-width="200" />
        <el-table-column prop="treatment" label="治疗方案" min-width="200" />
        <el-table-column prop="recordTime" label="记录时间" width="170" />
      </el-table>
      <el-pagination v-model:current-page="page" v-model:page-size="pageSize" :total="total" @current-change="loadData" layout="total, prev, pager, next" style="margin-top: 16px;" />
    </el-card>

    <el-dialog v-model="dialogVisible" title="新增病历" width="600px">
      <el-form :model="form" label-width="80px">
        <el-form-item label="患者" required>
          <el-select v-model="form.userId" placeholder="选择患者" style="width: 100%;">
            <el-option v-for="p in patientList" :key="p.id" :label="p.name" :value="p.id" />
          </el-select>
        </el-form-item>
        <el-form-item label="诊断" required><el-input v-model="form.diagnosis" type="textarea" :rows="3" /></el-form-item>
        <el-form-item label="治疗方案"><el-input v-model="form.treatment" type="textarea" :rows="3" /></el-form-item>
        <el-form-item label="记录时间"><el-input v-model="form.recordTime" type="datetime-local" /></el-form-item>
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
</style>
