<script setup>
import { ref, onMounted } from 'vue'
import { useUserStore } from '@/stores/user'
import doctorPortalApi from '@/api/doctorPortal'
import hospitalApi from '@/api/hospital'
import { ElMessage, ElMessageBox } from 'element-plus'

const userStore = useUserStore()
const tableData = ref([])
const total = ref(0)
const page = ref(1)
const pageSize = ref(10)
const loading = ref(false)
const doctorId = ref(null)

const createVisible = ref(false)
const submitting = ref(false)
const patients = ref([])
const hospitals = ref([])
const hospitalDoctors = ref([])

const createForm = ref({
  userId: null,
  fromHospitalId: null,
  toHospitalId: null,
  toDoctorId: null,
  fromDoctorId: null,
  applyReason: ''
})

const statusMap = { 0: '待审批', 1: '已通过', 2: '已拒绝', 3: '已取消' }
const statusType = { 0: 'warning', 1: 'success', 2: 'danger', 3: 'info' }

const loadData = async () => {
  loading.value = true
  try {
    const res = await doctorPortalApi.getTransfers(userStore.userInfo?.userId, { page: page.value, pageSize: pageSize.value })
    tableData.value = res.records || []
    total.value = res.total || 0
  } catch (e) { ElMessage.error('加载转诊列表失败') }
  finally { loading.value = false }
}

const loadPatients = async () => {
  if (!doctorId.value) return
  try {
    const res = await doctorPortalApi.getPatients(doctorId.value, { page: 1, pageSize: 100 })
    patients.value = res.records || res || []
  } catch (e) { console.error(e) }
}

const loadHospitals = async (keyword) => {
  try {
    const res = await hospitalApi.getPage({ page: 1, size: 50, keyword })
    hospitals.value = res.records || res.list || res || []
  } catch (e) { console.error(e) }
}

const onToHospitalChange = async (hospitalId) => {
  createForm.value.toDoctorId = null
  hospitalDoctors.value = []
  if (!hospitalId) return
  try {
    const res = await doctorPortalApi.getHospitalDoctors(hospitalId)
    hospitalDoctors.value = res || []
  } catch (e) { console.error(e) }
}

const showCreateDialog = async () => {
  createForm.value = { userId: null, fromHospitalId: null, toHospitalId: null, toDoctorId: null, fromDoctorId: doctorId.value, applyReason: '' }
  hospitalDoctors.value = []
  createVisible.value = true
  await loadHospitals('')
}

const onPatientChange = async (patientId) => {
  createForm.value.fromHospitalId = null
  if (!patientId) return
  try {
    const patient = patients.value.find(p => (p.userId || p.id) === patientId)
    if (patient && patient.hospitalId) {
      createForm.value.fromHospitalId = patient.hospitalId
    }
  } catch (e) { console.error(e) }
}

const handleCreate = async () => {
  if (!createForm.value.userId) { ElMessage.warning('请选择患者'); return }
  if (!createForm.value.toHospitalId) { ElMessage.warning('请选择转入医院'); return }
  if (!createForm.value.toDoctorId) { ElMessage.warning('请选择转入医生'); return }
  if (!createForm.value.applyReason) { ElMessage.warning('请输入申请原因'); return }
  submitting.value = true
  try {
    await doctorPortalApi.createTransfer(createForm.value)
    ElMessage.success('转诊申请创建成功')
    createVisible.value = false
    loadData()
  } catch (e) {
    ElMessage.error(e.message || '创建失败')
  } finally {
    submitting.value = false
  }
}

const handleCancel = async (row) => {
  try {
    await ElMessageBox.confirm('确认取消此转诊申请？取消后该记录将被删除。', '提示')
    await doctorPortalApi.cancelTransfer(row.id)
    ElMessage.success('已取消转诊')
    loadData()
  } catch (e) {}
}

const handleApprove = async (row) => {
  try {
    await ElMessageBox.confirm('确认接受此转诊申请？', '提示')
    await doctorPortalApi.approveTransfer(row.id)
    ElMessage.success('已接受转诊')
    loadData()
  } catch (e) {}
}

const handleReject = async (row) => {
  try {
    const { value } = await ElMessageBox.prompt('请输入拒绝原因', '拒绝转诊', {
      confirmButtonText: '确认拒绝',
      cancelButtonText: '取消',
      inputPlaceholder: '拒绝原因（必填）',
      inputValidator: (v) => v && v.trim() ? true : '请输入拒绝原因'
    })
    await doctorPortalApi.rejectTransfer(row.id, { rejectReason: value })
    ElMessage.success('已拒绝')
    loadData()
  } catch (e) {}
}

const isFromMe = (row) => {
  return row.fromDoctorId === doctorId.value
}

onMounted(async () => {
  try {
    const res = await doctorPortalApi.getDoctorInfo(userStore.userInfo?.userId)
    if (res && res.id) {
      doctorId.value = res.id
      loadPatients()
    }
  } catch (e) {}
  loadData()
})
</script>

<template>
  <div class="page-container">
    <el-card>
      <template #header>
        <div class="card-header">
          <span>转诊管理</span>
          <el-button type="primary" @click="showCreateDialog">创建转诊</el-button>
        </div>
      </template>
      <el-table :data="tableData" v-loading="loading" stripe>
        <el-table-column prop="userName" label="患者" width="100" />
        <el-table-column prop="fromHospital" label="转出医院" min-width="130" />
        <el-table-column prop="fromDoctorName" label="转出医生" width="100" />
        <el-table-column prop="toHospital" label="转入医院" min-width="130" />
        <el-table-column prop="toDoctorName" label="转入医生" width="100" />
        <el-table-column prop="applyReason" label="申请原因" min-width="150" />
        <el-table-column label="状态" width="100">
          <template #default="{ row }"><el-tag :type="statusType[row.status]">{{ statusMap[row.status] }}</el-tag></template>
        </el-table-column>
        <el-table-column prop="rejectReason" label="拒绝原因" width="120">
          <template #default="{ row }">{{ row.rejectReason || '-' }}</template>
        </el-table-column>
        <el-table-column prop="applyTime" label="申请时间" width="170" />
        <el-table-column label="操作" width="180" fixed="right">
          <template #default="{ row }">
            <el-button v-if="row.status === 0 && isFromMe(row)" type="warning" size="small" @click="handleCancel(row)">取消</el-button>
            <el-button v-if="row.status === 0 && !isFromMe(row)" type="success" size="small" @click="handleApprove(row)">接受</el-button>
            <el-button v-if="row.status === 0 && !isFromMe(row)" type="danger" size="small" @click="handleReject(row)">拒绝</el-button>
          </template>
        </el-table-column>
      </el-table>
      <el-pagination v-model:current-page="page" v-model:page-size="pageSize" :total="total" @current-change="loadData" layout="total, prev, pager, next" style="margin-top: 16px;" />
    </el-card>

    <el-dialog v-model="createVisible" title="创建转诊申请" width="550px">
      <el-form :model="createForm" label-width="100px">
        <el-form-item label="选择患者">
          <el-select v-model="createForm.userId" placeholder="请选择名下患者" filterable style="width: 100%;" @change="onPatientChange">
            <el-option v-for="p in patients" :key="p.userId || p.id" :label="p.realName || p.userName || p.name || `患者#${p.userId || p.id}`" :value="p.userId || p.id" />
          </el-select>
        </el-form-item>
        <el-form-item label="转出医院">
          <el-select v-model="createForm.fromHospitalId" placeholder="当前所在医院（可修改）" filterable style="width: 100%;" @focus="loadHospitals('')">
            <el-option v-for="h in hospitals" :key="h.id" :label="h.name" :value="h.id" />
          </el-select>
        </el-form-item>
        <el-form-item label="转入医院">
          <el-select v-model="createForm.toHospitalId" placeholder="请选择转入医院" filterable style="width: 100%;" @change="onToHospitalChange" @focus="loadHospitals('')">
            <el-option v-for="h in hospitals" :key="h.id" :label="h.name" :value="h.id" />
          </el-select>
        </el-form-item>
        <el-form-item label="转入医生">
          <el-select v-model="createForm.toDoctorId" placeholder="请先选择转入医院" filterable style="width: 100%;" :disabled="!createForm.toHospitalId">
            <el-option v-for="d in hospitalDoctors" :key="d.id" :label="`${d.name || '未知'} - ${d.department || ''} ${d.title || ''}`" :value="d.id" />
          </el-select>
        </el-form-item>
        <el-form-item label="申请原因">
          <el-input v-model="createForm.applyReason" type="textarea" :rows="3" placeholder="请输入转诊原因" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="createVisible = false">取消</el-button>
        <el-button type="primary" :loading="submitting" @click="handleCreate">提交申请</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<style scoped>
.card-header { display: flex; justify-content: space-between; align-items: center; }
</style>
