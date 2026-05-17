<script setup>
import { ref, onMounted } from 'vue'
import { useUserStore } from '@/stores/user'
import doctorPortalApi from '@/api/doctorPortal'
import { ElMessage, ElMessageBox } from 'element-plus'

const userStore = useUserStore()
const tableData = ref([])
const total = ref(0)
const page = ref(1)
const pageSize = ref(10)
const statusFilter = ref(null)
const doctorId = ref(null)
const loading = ref(false)

const postponeVisible = ref(false)
const postponeForm = ref({ id: null, scheduleDate: '', schedulePeriod: 1, reason: '', originalDate: '' })

const statusMap = { 0: '待确认', 1: '已同意', 2: '已拒绝', 3: '已延期', 4: '已就诊', 5: '已取消', 6: '待确认延期' }
const statusType = { 0: 'warning', 1: 'success', 2: 'danger', 3: 'info', 4: 'primary', 5: 'info', 6: 'warning' }
const periodMap = { 1: '上午', 2: '下午', 3: '晚上' }

const loadData = async () => {
  loading.value = true
  try {
    const res = await doctorPortalApi.getAppointments(doctorId.value, { page: page.value, pageSize: pageSize.value, status: statusFilter.value })
    tableData.value = res.records || []
    total.value = res.total || 0
  } catch (e) { ElMessage.error('加载预约列表失败') }
  finally { loading.value = false }
}

const handleApprove = async (row) => {
  try {
    await ElMessageBox.confirm('确认同意该预约？', '提示')
    await doctorPortalApi.approveAppointment(row.id)
    ElMessage.success('已同意预约')
    loadData()
  } catch (e) {}
}

const handleReject = async (row) => {
  try {
    const { value } = await ElMessageBox.prompt('请输入拒绝原因（可选）', '拒绝预约', {
      confirmButtonText: '确认拒绝',
      cancelButtonText: '取消',
      inputPlaceholder: '拒绝原因'
    })
    await doctorPortalApi.rejectAppointment(row.id, { reason: value || '' })
    ElMessage.success('已拒绝预约')
    loadData()
  } catch (e) {}
}

const showPostponeDialog = (row) => {
  postponeForm.value = {
    id: row.id,
    scheduleDate: '',
    schedulePeriod: row.schedulePeriod || 1,
    reason: '',
    originalDate: row.scheduleDate
  }
  postponeVisible.value = true
}

const handlePostpone = async () => {
  if (!postponeForm.value.scheduleDate) {
    ElMessage.warning('请选择新的预约日期')
    return
  }
  if (postponeForm.value.originalDate && postponeForm.value.scheduleDate < postponeForm.value.originalDate) {
    ElMessage.warning('延期日期必须在原预约日期之后')
    return
  }
  try {
    await doctorPortalApi.postponeAppointment(postponeForm.value.id, {
      scheduleDate: postponeForm.value.scheduleDate,
      schedulePeriod: postponeForm.value.schedulePeriod,
      reason: postponeForm.value.reason
    })
    ElMessage.success('已延期预约')
    postponeVisible.value = false
    loadData()
  } catch (e) {
    ElMessage.error(e.message || '延期失败')
  }
}

const handleComplete = async (row) => {
  try {
    await ElMessageBox.confirm('确认该预约已完成就诊？', '提示')
    await doctorPortalApi.approveAppointment(row.id)
    ElMessage.success('操作成功')
    loadData()
  } catch (e) {}
}

onMounted(async () => {
  try {
    const res = await doctorPortalApi.getDoctorInfo(userStore.userInfo?.userId)
    if (res && res.id) {
      doctorId.value = res.id
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
          <span>预约管理</span>
          <div class="filter-row">
            <el-select v-model="statusFilter" placeholder="状态筛选" clearable @change="loadData" style="width: 120px; margin-right: 10px;">
              <el-option label="待确认" :value="0" />
              <el-option label="已同意" :value="1" />
              <el-option label="已拒绝" :value="2" />
              <el-option label="已延期" :value="3" />
              <el-option label="已就诊" :value="4" />
              <el-option label="已取消" :value="5" />
            </el-select>
          </div>
        </div>
      </template>
      <el-table :data="tableData" v-loading="loading" stripe>
        <el-table-column prop="appointmentNo" label="就诊号" width="150" />
        <el-table-column prop="userName" label="患者" width="100" />
        <el-table-column prop="scheduleDate" label="日期" width="120" />
        <el-table-column label="时段" width="80">
          <template #default="{ row }">{{ periodMap[row.schedulePeriod] || '-' }}</template>
        </el-table-column>
        <el-table-column prop="reason" label="就诊原因" min-width="150" />
        <el-table-column label="状态" width="100">
          <template #default="{ row }"><el-tag :type="statusType[row.status]">{{ statusMap[row.status] || '未知' }}</el-tag></template>
        </el-table-column>
        <el-table-column prop="fee" label="费用" width="80" />
        <el-table-column label="操作" width="220" fixed="right">
          <template #default="{ row }">
            <el-button v-if="row.status === 0" type="success" size="small" @click="handleApprove(row)">同意</el-button>
            <el-button v-if="row.status === 0" type="danger" size="small" @click="handleReject(row)">拒绝</el-button>
            <el-button v-if="row.status === 0 || row.status === 1" type="warning" size="small" @click="showPostponeDialog(row)">延期</el-button>
          </template>
        </el-table-column>
      </el-table>
      <el-pagination v-model:current-page="page" v-model:page-size="pageSize" :total="total" @current-change="loadData" layout="total, prev, pager, next" style="margin-top: 16px;" />
    </el-card>

    <el-dialog v-model="postponeVisible" title="延期预约" width="450px">
      <el-form :model="postponeForm" label-width="100px">
        <el-form-item label="新预约日期">
          <el-date-picker v-model="postponeForm.scheduleDate" type="date" placeholder="选择新日期" value-format="YYYY-MM-DD" style="width: 100%;" />
        </el-form-item>
        <el-form-item label="新时段">
          <el-select v-model="postponeForm.schedulePeriod" style="width: 100%;">
            <el-option :value="1" label="上午" />
            <el-option :value="2" label="下午" />
            <el-option :value="3" label="晚上" />
          </el-select>
        </el-form-item>
        <el-form-item label="延期原因">
          <el-input v-model="postponeForm.reason" type="textarea" :rows="2" placeholder="请输入延期原因" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="postponeVisible = false">取消</el-button>
        <el-button type="primary" @click="handlePostpone">确认延期</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<style scoped>
.card-header { display: flex; justify-content: space-between; align-items: center; }
.filter-row { display: flex; align-items: center; }
</style>
