<script setup>
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import appointmentApi from '@/api/appointment'

const appointmentList = ref([])
const searchForm = ref({ userId: '', doctorId: '' })
const loading = ref(false)
const detailVisible = ref(false)
const detailData = ref(null)
const formVisible = ref(false)
const isEdit = ref(false)

const formData = reactive({
  id: null,
  userId: '',
  doctorId: '',
  scheduleDate: '',
  schedulePeriod: 0,
  appointmentNo: '',
  fee: '',
  status: 0
})

const statusLabel = (val) => ['待确认', '已同意', '已拒绝', '已延期', '已就诊', '已取消'][val] || '未知'
const statusTagType = (val) => ['warning', 'success', 'danger', 'info', 'primary', 'info'][val] || 'info'
const periodLabel = (val) => ['上午', '下午', '晚上'][val] || '-'

const loadAppointments = async () => {
  loading.value = true
  try {
    const res = await appointmentApi.getList({
      page: 1,
      pageSize: 50,
      userId: searchForm.value.userId || undefined,
      doctorId: searchForm.value.doctorId || undefined
    })
    appointmentList.value = res.records || res.list || res || []
  } catch (error) {
    ElMessage.error('加载预约列表失败')
  } finally {
    loading.value = false
  }
}

const handleView = async (row) => {
  try {
    const res = await appointmentApi.getDetail(row.id)
    detailData.value = res.data || res
    detailVisible.value = true
  } catch (error) {
    detailData.value = row
    detailVisible.value = true
  }
}

const handleAdd = () => {
  isEdit.value = false
  Object.assign(formData, { id: null, userId: '', doctorId: '', scheduleDate: '', schedulePeriod: 0, appointmentNo: '', fee: '', status: 0 })
  formVisible.value = true
}

const handleEdit = (row) => {
  isEdit.value = true
  Object.assign(formData, row)
  formVisible.value = true
}

const handleDelete = async (row) => {
  try {
    await ElMessageBox.confirm('确定删除该预约记录吗？', '提示', {
      confirmButtonText: '确定', cancelButtonText: '取消', type: 'warning'
    })
    await appointmentApi.delete(row.id)
    ElMessage.success('删除成功')
    loadAppointments()
  } catch (error) {
    if (error !== 'cancel') {
      ElMessage.error(error.message || '删除失败')
    }
  }
}

const handleConfirm = async (row) => {
  try {
    await appointmentApi.approve(row.id)
    ElMessage.success('已同意预约')
    loadAppointments()
  } catch (error) {
    ElMessage.error(error.message || '操作失败')
  }
}

const handleReject = async (row) => {
  try {
    const { value } = await ElMessageBox.prompt('请输入拒绝原因（可选）', '拒绝预约', {
      confirmButtonText: '确认拒绝',
      cancelButtonText: '取消',
      inputPlaceholder: '拒绝原因'
    })
    await appointmentApi.reject(row.id, { reason: value || '' })
    ElMessage.success('已拒绝预约')
    loadAppointments()
  } catch (error) {}
}

const handlePostpone = async (row) => {
  try {
    const { value: dateVal } = await ElMessageBox.prompt('请输入新的预约日期（YYYY-MM-DD）', '延期预约', {
      confirmButtonText: '确认延期',
      cancelButtonText: '取消',
      inputPlaceholder: '2025-01-01'
    })
    if (!dateVal) return
    await appointmentApi.postpone(row.id, { scheduleDate: dateVal, schedulePeriod: row.schedulePeriod || 1 })
    ElMessage.success('已延期预约')
    loadAppointments()
  } catch (error) {}
}

const handleComplete = async (row) => {
  try {
    await ElMessageBox.confirm('确认该预约已完成就诊？', '提示')
    await appointmentApi.complete(row.id)
    ElMessage.success('已标记为已就诊')
    loadAppointments()
  } catch (error) {}
}

const handleCancel = async (row) => {
  try {
    await appointmentApi.cancel(row.id)
    ElMessage.success('已取消预约')
    loadAppointments()
  } catch (error) {
    ElMessage.error(error.message || '操作失败')
  }
}

const handleSubmit = async () => {
  if (!formData.userId || !formData.doctorId || !formData.scheduleDate) {
    ElMessage.warning('请填写必填项')
    return
  }
  try {
    if (isEdit.value) {
      await appointmentApi.update(formData.id, formData)
      ElMessage.success('修改成功')
    } else {
      await appointmentApi.create(formData)
      ElMessage.success('添加成功')
    }
    formVisible.value = false
    loadAppointments()
  } catch (error) {
    ElMessage.error(error.message || '操作失败')
  }
}

onMounted(() => {
  loadAppointments()
})
</script>

<template>
  <div class="appointment-list">
    <div class="search-bar">
      <el-input v-model="searchForm.userId" placeholder="患者ID" class="search-input" @keyup.enter="loadAppointments" />
      <el-input v-model="searchForm.doctorId" placeholder="医生ID" class="search-input" @keyup.enter="loadAppointments" />
      <el-button type="primary" @click="loadAppointments">搜索</el-button>
      <el-button type="success" @click="handleAdd">添加预约</el-button>
    </div>

    <el-table :data="appointmentList" :loading="loading" border>
      <el-table-column prop="id" label="ID" width="80" />
      <el-table-column prop="userName" label="患者" width="120" />
      <el-table-column prop="doctorName" label="医生" width="120" />
      <el-table-column prop="hospitalName" label="医院" width="150" />
      <el-table-column prop="departmentName" label="科室" width="120" />
      <el-table-column prop="scheduleDate" label="预约日期" width="120" />
      <el-table-column prop="schedulePeriod" label="时间段" width="80">
        <template #default="scope">{{ periodLabel(scope.row.schedulePeriod) }}</template>
      </el-table-column>
      <el-table-column prop="appointmentNo" label="预约编号" width="150" />
      <el-table-column prop="fee" label="费用" width="80" />
      <el-table-column prop="status" label="状态" width="100">
        <template #default="scope">
          <el-tag :type="statusTagType(scope.row.status)">{{ statusLabel(scope.row.status) }}</el-tag>
        </template>
      </el-table-column>
      <el-table-column prop="createTime" label="创建时间" width="180" />
      <el-table-column label="操作" width="340">
        <template #default="scope">
          <el-button size="small" @click="handleView(scope.row)">查看</el-button>
          <el-button size="small" @click="handleEdit(scope.row)">编辑</el-button>
          <el-button v-if="scope.row.status === 0" size="small" type="success" @click="handleConfirm(scope.row)">同意</el-button>
          <el-button v-if="scope.row.status === 0" size="small" type="danger" @click="handleReject(scope.row)">拒绝</el-button>
          <el-button v-if="scope.row.status === 0 || scope.row.status === 1" size="small" type="warning" @click="handlePostpone(scope.row)">延期</el-button>
          <el-button v-if="scope.row.status === 1" size="small" type="primary" @click="handleComplete(scope.row)">完成</el-button>
          <el-button v-if="scope.row.status === 0 || scope.row.status === 1" size="small" type="info" @click="handleCancel(scope.row)">取消</el-button>
          <el-button size="small" type="danger" @click="handleDelete(scope.row)">删除</el-button>
        </template>
      </el-table-column>
    </el-table>

    <el-dialog v-model="detailVisible" title="预约详情" width="600px">
      <div v-if="detailData">
        <el-descriptions :column="2" border>
          <el-descriptions-item label="患者">{{ detailData.userName }}</el-descriptions-item>
          <el-descriptions-item label="医生">{{ detailData.doctorName }}</el-descriptions-item>
          <el-descriptions-item label="医院">{{ detailData.hospitalName }}</el-descriptions-item>
          <el-descriptions-item label="科室">{{ detailData.departmentName }}</el-descriptions-item>
          <el-descriptions-item label="预约日期">{{ detailData.scheduleDate }}</el-descriptions-item>
          <el-descriptions-item label="时间段">{{ periodLabel(detailData.schedulePeriod) }}</el-descriptions-item>
          <el-descriptions-item label="预约编号">{{ detailData.appointmentNo }}</el-descriptions-item>
          <el-descriptions-item label="费用">{{ detailData.fee }}</el-descriptions-item>
          <el-descriptions-item label="状态"><el-tag :type="statusTagType(detailData.status)">{{ statusLabel(detailData.status) }}</el-tag></el-descriptions-item>
          <el-descriptions-item label="创建时间">{{ detailData.createTime }}</el-descriptions-item>
        </el-descriptions>
      </div>
      <template #footer><el-button @click="detailVisible = false">关闭</el-button></template>
    </el-dialog>

    <el-dialog v-model="formVisible" :title="isEdit ? '编辑预约' : '添加预约'" width="500px">
      <el-form :model="formData" label-width="100px">
        <el-form-item label="患者ID"><el-input v-model="formData.userId" /></el-form-item>
        <el-form-item label="医生ID"><el-input v-model="formData.doctorId" /></el-form-item>
        <el-form-item label="预约日期"><el-input v-model="formData.scheduleDate" placeholder="如：2024-01-15" /></el-form-item>
        <el-form-item label="时间段">
          <el-select v-model="formData.schedulePeriod">
            <el-option :value="0" label="上午" />
            <el-option :value="1" label="下午" />
            <el-option :value="2" label="晚上" />
          </el-select>
        </el-form-item>
        <el-form-item label="费用"><el-input v-model="formData.fee" /></el-form-item>
        <el-form-item label="状态" v-if="isEdit">
          <el-select v-model="formData.status">
            <el-option :value="0" label="待确认" />
            <el-option :value="1" label="已同意" />
            <el-option :value="2" label="已拒绝" />
            <el-option :value="3" label="已延期" />
            <el-option :value="4" label="已就诊" />
            <el-option :value="5" label="已取消" />
          </el-select>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="formVisible = false">取消</el-button>
        <el-button type="primary" @click="handleSubmit">保存</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<style lang="scss" scoped>
.appointment-list { background: #fff; border-radius: 12px; padding: 20px; box-shadow: 0 2px 8px rgba(0,0,0,0.05); }
.search-bar { display: flex; gap: 12px; margin-bottom: 20px; flex-wrap: wrap; .search-input { width: 150px; } }
</style>
