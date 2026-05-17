<script setup>
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import transferApi from '@/api/transfer'

const transferList = ref([])
const searchForm = ref({ userId: '' })
const loading = ref(false)
const detailVisible = ref(false)
const detailData = ref(null)
const formVisible = ref(false)
const isEdit = ref(false)

const formData = reactive({
  id: null,
  userId: '',
  fromHospitalId: '',
  toHospitalId: '',
  applyReason: '',
  status: 0
})

const statusLabel = (val) => ['待审核', '已通过', '已拒绝'][val] || '未知'
const statusTagType = (val) => ['warning', 'success', 'danger'][val] || 'info'

const loadTransfers = async () => {
  loading.value = true
  try {
    const res = await transferApi.getAllList({
      page: 1,
      pageSize: 50,
      userId: searchForm.value.userId || undefined
    })
    transferList.value = res.records || res.list || res || []
  } catch (error) {
    ElMessage.error('加载转诊列表失败')
  } finally {
    loading.value = false
  }
}

const handleView = async (row) => {
  try {
    const res = await transferApi.getApplyDetail(row.id)
    detailData.value = res.data || res
    detailVisible.value = true
  } catch (error) {
    detailData.value = row
    detailVisible.value = true
  }
}

const handleAdd = () => {
  isEdit.value = false
  Object.assign(formData, { id: null, userId: '', fromHospitalId: '', toHospitalId: '', applyReason: '', status: 0 })
  formVisible.value = true
}

const handleApprove = async (row) => {
  try {
    await ElMessageBox.confirm('确定通过该转诊申请吗？', '提示', {
      confirmButtonText: '确定', cancelButtonText: '取消', type: 'warning'
    })
    await transferApi.approveApply(row.id)
    ElMessage.success('已通过转诊申请')
    loadTransfers()
  } catch (error) {
    if (error !== 'cancel') {
      ElMessage.error(error.message || '操作失败')
    }
  }
}

const handleReject = async (row) => {
  try {
    await ElMessageBox.confirm('确定拒绝该转诊申请吗？', '提示', {
      confirmButtonText: '确定', cancelButtonText: '取消', type: 'warning'
    })
    await transferApi.rejectApply(row.id, { remark: '管理员拒绝' })
    ElMessage.success('已拒绝转诊申请')
    loadTransfers()
  } catch (error) {
    if (error !== 'cancel') {
      ElMessage.error(error.message || '操作失败')
    }
  }
}

const handleDelete = async (row) => {
  try {
    await ElMessageBox.confirm('确定删除该转诊记录吗？', '提示', {
      confirmButtonText: '确定', cancelButtonText: '取消', type: 'warning'
    })
    await transferApi.deleteApply(row.id)
    ElMessage.success('删除成功')
    loadTransfers()
  } catch (error) {
    if (error !== 'cancel') {
      ElMessage.error(error.message || '删除失败')
    }
  }
}

const handleSubmit = async () => {
  if (!formData.userId || !formData.applyReason) {
    ElMessage.warning('请填写必填项')
    return
  }
  try {
    await transferApi.addApply(formData)
    ElMessage.success('添加成功')
    formVisible.value = false
    loadTransfers()
  } catch (error) {
    ElMessage.error(error.message || '操作失败')
  }
}

onMounted(() => {
  loadTransfers()
})
</script>

<template>
  <div class="transfer-list">
    <div class="search-bar">
      <el-input v-model="searchForm.userId" placeholder="患者ID" class="search-input" @keyup.enter="loadTransfers" />
      <el-button type="primary" @click="loadTransfers">搜索</el-button>
      <el-button type="success" @click="handleAdd">添加转诊</el-button>
    </div>

    <el-table :data="transferList" :loading="loading" border>
      <el-table-column prop="id" label="ID" width="80" />
      <el-table-column prop="userName" label="患者" width="120" />
      <el-table-column prop="fromHospital" label="转出医院" width="150" />
      <el-table-column prop="toHospital" label="转入医院" width="150" />
      <el-table-column prop="applyReason" label="转诊原因" />
      <el-table-column prop="applyTime" label="申请时间" width="180" />
      <el-table-column prop="status" label="状态" width="100">
        <template #default="scope">
          <el-tag :type="statusTagType(scope.row.status)">{{ statusLabel(scope.row.status) }}</el-tag>
        </template>
      </el-table-column>
      <el-table-column prop="approveTime" label="审核时间" width="180" />
      <el-table-column prop="approverName" label="审核人" width="120" />
      <el-table-column label="操作" width="240">
        <template #default="scope">
          <el-button size="small" @click="handleView(scope.row)">查看</el-button>
          <el-button size="small" type="success" @click="handleApprove(scope.row)" :disabled="scope.row.status !== 0">通过</el-button>
          <el-button size="small" type="danger" @click="handleReject(scope.row)" :disabled="scope.row.status !== 0">拒绝</el-button>
        </template>
      </el-table-column>
    </el-table>

    <el-dialog v-model="detailVisible" title="转诊详情" width="600px">
      <div v-if="detailData">
        <el-descriptions :column="1" border>
          <el-descriptions-item label="患者">{{ detailData.userName }}</el-descriptions-item>
          <el-descriptions-item label="转出医院">{{ detailData.fromHospital }}</el-descriptions-item>
          <el-descriptions-item label="转入医院">{{ detailData.toHospital }}</el-descriptions-item>
          <el-descriptions-item label="转诊原因">{{ detailData.applyReason }}</el-descriptions-item>
          <el-descriptions-item label="申请时间">{{ detailData.applyTime }}</el-descriptions-item>
          <el-descriptions-item label="状态"><el-tag :type="statusTagType(detailData.status)">{{ statusLabel(detailData.status) }}</el-tag></el-descriptions-item>
          <el-descriptions-item label="审核时间">{{ detailData.approveTime }}</el-descriptions-item>
          <el-descriptions-item label="审核人">{{ detailData.approverName }}</el-descriptions-item>
        </el-descriptions>
      </div>
      <template #footer><el-button @click="detailVisible = false">关闭</el-button></template>
    </el-dialog>

    <el-dialog v-model="formVisible" title="添加转诊申请" width="500px">
      <el-form :model="formData" label-width="100px">
        <el-form-item label="患者ID"><el-input v-model="formData.userId" /></el-form-item>
        <el-form-item label="转出医院ID"><el-input v-model="formData.fromHospitalId" /></el-form-item>
        <el-form-item label="转入医院ID"><el-input v-model="formData.toHospitalId" /></el-form-item>
        <el-form-item label="转诊原因"><el-input v-model="formData.applyReason" type="textarea" :rows="3" /></el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="formVisible = false">取消</el-button>
        <el-button type="primary" @click="handleSubmit">提交</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<style lang="scss" scoped>
.transfer-list { background: #fff; border-radius: 12px; padding: 20px; box-shadow: 0 2px 8px rgba(0,0,0,0.05); }
.search-bar { display: flex; gap: 12px; margin-bottom: 20px; flex-wrap: wrap; .search-input { width: 150px; } }
</style>
