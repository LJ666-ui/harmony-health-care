<script setup>
import { ref, onMounted } from 'vue'
import { useUserStore } from '@/stores/user'
import appointmentApi from '@/api/appointment'
import doctorApi from '@/api/doctor'
import { ElMessage } from 'element-plus'

const userStore = useUserStore()
const loading = ref(false)
const doctors = ref([])
const myAppointments = ref([])
const showForm = ref(false)
const submitting = ref(false)

const form = ref({
  doctorId: null,
  scheduleDate: '',
  schedulePeriod: 1,
  reason: ''
})

const statusMap = { 0: '待确认', 1: '已同意', 2: '已拒绝', 3: '已延期', 4: '已就诊', 5: '已取消', 6: '待确认延期' }
const statusType = { 0: 'warning', 1: 'success', 2: 'danger', 3: 'info', 4: 'primary', 5: 'info', 6: 'warning' }
const periodMap = { 1: '上午', 2: '下午', 3: '晚上' }

const loadDoctors = async () => {
  try {
    const res = await doctorApi.getList({ page: 1, size: 100 })
    doctors.value = res.records || res.list || res || []
  } catch (e) {
    console.error(e)
  }
}

const loadMyAppointments = async () => {
  loading.value = true
  try {
    const res = await appointmentApi.getList({ page: 1, pageSize: 50, userId: userStore.userInfo?.userId })
    myAppointments.value = res.records || []
  } catch (e) {
    console.error(e)
  } finally {
    loading.value = false
  }
}

const handleCreateAppointment = async () => {
  if (!form.value.doctorId) { ElMessage.warning('请选择医生'); return }
  if (!form.value.scheduleDate) { ElMessage.warning('请选择预约日期'); return }
  submitting.value = true
  try {
    await appointmentApi.create({
      userId: userStore.userInfo?.userId,
      doctorId: form.value.doctorId,
      scheduleDate: form.value.scheduleDate,
      schedulePeriod: form.value.schedulePeriod,
      reason: form.value.reason,
      status: 0
    })
    ElMessage.success('预约提交成功，等待医生确认')
    showForm.value = false
    form.value = { doctorId: null, scheduleDate: '', schedulePeriod: 1, reason: '' }
    loadMyAppointments()
  } catch (e) {
    ElMessage.error(e.message || '预约提交失败')
  } finally {
    submitting.value = false
  }
}

const handleCancel = async (row) => {
  try {
    await appointmentApi.cancel(row.id)
    ElMessage.success('已取消预约')
    loadMyAppointments()
  } catch (e) {
    ElMessage.error(e.message || '取消失败')
  }
}

const handleConfirmPostpone = async (row) => {
  try {
    await appointmentApi.confirmPostpone(row.id)
    ElMessage.success('已同意延期')
    loadMyAppointments()
  } catch (e) {
    ElMessage.error(e.message || '操作失败')
  }
}

const handleRejectPostpone = async (row) => {
  try {
    await appointmentApi.rejectPostpone(row.id)
    ElMessage.success('已拒绝延期')
    loadMyAppointments()
  } catch (e) {
    ElMessage.error(e.message || '操作失败')
  }
}

const getDoctorName = (doctorId) => {
  const doc = doctors.value.find(d => d.id === doctorId)
  return doc ? (doc.userName || doc.name || `医生#${doctorId}`) : `医生#${doctorId}`
}

onMounted(() => {
  loadDoctors()
  loadMyAppointments()
})
</script>

<template>
  <div class="appointment-page">
    <el-card>
      <template #header>
        <div class="card-header">
          <span>预约挂号</span>
          <el-button type="primary" @click="showForm = true">发起预约</el-button>
        </div>
      </template>

      <el-table :data="myAppointments" v-loading="loading" stripe>
        <el-table-column prop="appointmentNo" label="预约编号" width="160" />
        <el-table-column label="医生" width="120">
          <template #default="{ row }">{{ row.doctorName || getDoctorName(row.doctorId) }}</template>
        </el-table-column>
        <el-table-column prop="hospitalName" label="医院" width="150" />
        <el-table-column prop="departmentName" label="科室" width="120" />
        <el-table-column prop="scheduleDate" label="预约日期" width="120" />
        <el-table-column label="时段" width="80">
          <template #default="{ row }">{{ periodMap[row.schedulePeriod] || '-' }}</template>
        </el-table-column>
        <el-table-column prop="reason" label="就诊原因" min-width="150" />
        <el-table-column label="状态" width="100">
          <template #default="{ row }">
            <el-tag :type="statusType[row.status]">{{ statusMap[row.status] || '未知' }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="220" fixed="right">
          <template #default="{ row }">
            <el-button v-if="row.status === 0 || row.status === 1" type="danger" size="small" @click="handleCancel(row)">取消</el-button>
            <el-button v-if="row.status === 6" type="success" size="small" @click="handleConfirmPostpone(row)">同意延期</el-button>
            <el-button v-if="row.status === 6" type="danger" size="small" @click="handleRejectPostpone(row)">拒绝延期</el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-card>

    <el-dialog v-model="showForm" title="发起预约" width="500px">
      <el-form :model="form" label-width="100px">
        <el-form-item label="选择医生">
          <el-select v-model="form.doctorId" placeholder="请选择医生" filterable style="width: 100%;">
            <el-option v-for="doc in doctors" :key="doc.id" :label="`${doc.userName || doc.name || '医生'} - ${doc.department || ''} ${doc.hospitalName || ''}`" :value="doc.id" />
          </el-select>
        </el-form-item>
        <el-form-item label="预约日期">
          <el-date-picker v-model="form.scheduleDate" type="date" placeholder="选择日期" value-format="YYYY-MM-DD" style="width: 100%;" />
        </el-form-item>
        <el-form-item label="时段">
          <el-select v-model="form.schedulePeriod" style="width: 100%;">
            <el-option :value="1" label="上午" />
            <el-option :value="2" label="下午" />
            <el-option :value="3" label="晚上" />
          </el-select>
        </el-form-item>
        <el-form-item label="就诊原因">
          <el-input v-model="form.reason" type="textarea" :rows="3" placeholder="请简要描述就诊原因" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="showForm = false">取消</el-button>
        <el-button type="primary" :loading="submitting" @click="handleCreateAppointment">提交预约</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<style scoped>
.card-header { display: flex; justify-content: space-between; align-items: center; }
</style>
