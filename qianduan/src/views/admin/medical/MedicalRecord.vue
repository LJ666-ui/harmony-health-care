<script setup>
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import medicalRecordApi from '@/api/medicalRecord'

const recordList = ref([])
const searchForm = ref({ userId: '', hospitalId: '' })
const loading = ref(false)
const detailVisible = ref(false)
const detailData = ref(null)
const formVisible = ref(false)
const isEdit = ref(false)

const formData = reactive({
  id: null,
  userId: '',
  hospitalId: '',
  doctorId: '',
  diagnosis: '',
  treatment: '',
  prescription: '',
  recordTime: ''
})

const loadRecords = async () => {
  loading.value = true
  try {
    const res = await medicalRecordApi.getList({
      pageNum: 1,
      pageSize: 50,
      userId: searchForm.value.userId,
      hospitalId: searchForm.value.hospitalId
    })
    recordList.value = res.records || res.list || res || []
  } catch (error) {
    ElMessage.error('加载病历列表失败')
  } finally {
    loading.value = false
  }
}

const handleView = async (row) => {
  try {
    const res = await medicalRecordApi.getDesensitized(row.id)
    detailData.value = res.data || res
    detailVisible.value = true
  } catch (error) {
    detailData.value = row
    detailVisible.value = true
  }
}

const handleAdd = () => {
  isEdit.value = false
  Object.assign(formData, { id: null, userId: '', hospitalId: '', doctorId: '', diagnosis: '', treatment: '', prescription: '', recordTime: '' })
  formVisible.value = true
}

const handleEdit = (row) => {
  isEdit.value = true
  Object.assign(formData, row)
  formVisible.value = true
}

const handleDelete = async (row) => {
  try {
    await ElMessageBox.confirm('确定删除该病历记录吗？', '提示', {
      confirmButtonText: '确定', cancelButtonText: '取消', type: 'warning'
    })
    await medicalRecordApi.delete(row.id)
    ElMessage.success('删除成功')
    loadRecords()
  } catch (error) {
    if (error !== 'cancel') {
      ElMessage.error(error.message || '删除失败')
    }
  }
}

const handleSubmit = async () => {
  if (!formData.diagnosis) {
    ElMessage.warning('请输入诊断信息')
    return
  }
  try {
    if (isEdit.value) {
      await medicalRecordApi.update(formData)
      ElMessage.success('修改成功')
    } else {
      await medicalRecordApi.add(formData)
      ElMessage.success('添加成功')
    }
    formVisible.value = false
    loadRecords()
  } catch (error) {
    ElMessage.error(error.message || '操作失败')
  }
}

onMounted(() => {
  loadRecords()
})
</script>

<template>
  <div class="medical-record">
    <div class="search-bar">
      <el-input v-model="searchForm.userId" placeholder="患者ID" class="search-input" @keyup.enter="loadRecords" />
      <el-input v-model="searchForm.hospitalId" placeholder="医院ID" class="search-input" @keyup.enter="loadRecords" />
      <el-button type="primary" @click="loadRecords">搜索</el-button>
      <el-button type="success" @click="handleAdd">添加病历</el-button>
    </div>

    <el-table :data="recordList" :loading="loading" border>
      <el-table-column prop="id" label="ID" width="80" />
      <el-table-column prop="userName" label="患者" width="120" />
      <el-table-column prop="hospitalName" label="医院" width="150" />
      <el-table-column prop="doctorName" label="医生" width="120" />
      <el-table-column prop="diagnosis" label="诊断" />
      <el-table-column prop="recordTime" label="记录时间" width="180" />
      <el-table-column prop="isDesensitized" label="脱敏状态" width="100">
        <template #default="scope">
          <el-tag :type="scope.row.isDesensitized === 1 ? 'success' : 'warning'">
            {{ scope.row.isDesensitized === 1 ? '已脱敏' : '未脱敏' }}
          </el-tag>
        </template>
      </el-table-column>
      <el-table-column label="操作" width="200">
        <template #default="scope">
          <el-button size="small" @click="handleView(scope.row)">查看</el-button>
          <el-button size="small" @click="handleEdit(scope.row)">编辑</el-button>
          <el-button size="small" type="danger" @click="handleDelete(scope.row)">删除</el-button>
        </template>
      </el-table-column>
    </el-table>

    <el-dialog v-model="detailVisible" title="病历详情" width="600px">
      <div v-if="detailData">
        <el-descriptions :column="1" border>
          <el-descriptions-item label="患者">{{ detailData.userName }}</el-descriptions-item>
          <el-descriptions-item label="医院">{{ detailData.hospitalName }}</el-descriptions-item>
          <el-descriptions-item label="医生">{{ detailData.doctorName }}</el-descriptions-item>
          <el-descriptions-item label="诊断">{{ detailData.diagnosis }}</el-descriptions-item>
          <el-descriptions-item label="治疗方案">{{ detailData.treatment }}</el-descriptions-item>
          <el-descriptions-item label="处方">{{ detailData.prescription }}</el-descriptions-item>
          <el-descriptions-item label="记录时间">{{ detailData.recordTime }}</el-descriptions-item>
        </el-descriptions>
      </div>
      <template #footer><el-button @click="detailVisible = false">关闭</el-button></template>
    </el-dialog>

    <el-dialog v-model="formVisible" :title="isEdit ? '编辑病历' : '添加病历'" width="600px">
      <el-form :model="formData" label-width="100px">
        <el-form-item label="患者ID"><el-input v-model="formData.userId" /></el-form-item>
        <el-form-item label="医院ID"><el-input v-model="formData.hospitalId" /></el-form-item>
        <el-form-item label="医生ID"><el-input v-model="formData.doctorId" /></el-form-item>
        <el-form-item label="诊断"><el-input v-model="formData.diagnosis" type="textarea" :rows="3" /></el-form-item>
        <el-form-item label="治疗方案"><el-input v-model="formData.treatment" type="textarea" :rows="3" /></el-form-item>
        <el-form-item label="处方"><el-input v-model="formData.prescription" type="textarea" :rows="3" /></el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="formVisible = false">取消</el-button>
        <el-button type="primary" @click="handleSubmit">保存</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<style lang="scss" scoped>
.medical-record { background: #fff; border-radius: 12px; padding: 20px; box-shadow: 0 2px 8px rgba(0,0,0,0.05); }
.search-bar { display: flex; gap: 12px; margin-bottom: 20px; flex-wrap: wrap; .search-input { width: 150px; } }
</style>
