<script setup>
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import healthRecordApi from '@/api/healthRecord'

const recordList = ref([])
const searchForm = reactive({ userId: '' })
const loading = ref(false)
const modalVisible = ref(false)
const isEdit = ref(false)
const detailVisible = ref(false)
const detailData = ref(null)

const formData = reactive({
  id: '',
  userId: 1,
  bloodPressure: '',
  bloodSugar: '',
  heartRate: '',
  weight: '',
  height: '',
  stepCount: '',
  sleepDuration: ''
})

const loadRecords = async () => {
  loading.value = true
  try {
    const userId = searchForm.userId || 1
    const res = await healthRecordApi.getPage(1, 50, userId)
    recordList.value = res.records || res || []
  } catch (error) {
    ElMessage.error('获取数据失败: ' + (error.message || ''))
  } finally {
    loading.value = false
  }
}

const handleAdd = () => {
  isEdit.value = false
  Object.assign(formData, { id: '', userId: searchForm.userId || 1, bloodPressure: '', bloodSugar: '', heartRate: '', weight: '', height: '', stepCount: '', sleepDuration: '' })
  modalVisible.value = true
}

const handleEdit = (row) => {
  isEdit.value = true
  Object.assign(formData, row)
  modalVisible.value = true
}

const handleDelete = async (row) => {
  try {
    await ElMessageBox.confirm('确定删除该健康记录吗？', '提示', {
      confirmButtonText: '确定', cancelButtonText: '取消', type: 'warning'
    })
    await healthRecordApi.delete(row.id)
    ElMessage.success('删除成功')
    loadRecords()
  } catch (error) {
    if (error !== 'cancel') {
      ElMessage.error(error.message || '删除失败')
    }
  }
}

const handleView = (row) => {
  detailData.value = row
  detailVisible.value = true
}

const handleSubmit = async () => {
  try {
    if (isEdit.value) {
      await healthRecordApi.update(formData.id, formData)
      ElMessage.success('修改成功')
    } else {
      await healthRecordApi.add(formData)
      ElMessage.success('添加成功')
    }
    modalVisible.value = false
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
  <div class="health-record">
    <div class="search-bar">
      <el-input v-model="searchForm.userId" placeholder="用户ID" class="search-input" @keyup.enter="loadRecords" />
      <el-button type="primary" @click="loadRecords">搜索</el-button>
      <el-button type="success" @click="handleAdd">添加记录</el-button>
    </div>

    <el-table :data="recordList" :loading="loading" border>
      <el-table-column prop="id" label="ID" width="80" />
      <el-table-column prop="userId" label="用户ID" width="80" />
      <el-table-column prop="bloodPressure" label="血压" width="120" />
      <el-table-column prop="bloodSugar" label="血糖" width="100" />
      <el-table-column prop="heartRate" label="心率" width="100" />
      <el-table-column prop="weight" label="体重" width="80" />
      <el-table-column prop="height" label="身高" width="80" />
      <el-table-column prop="stepCount" label="步数" width="100" />
      <el-table-column prop="sleepDuration" label="睡眠" width="80" />
      <el-table-column prop="recordTime" label="记录时间" width="180" />
      <el-table-column label="操作" width="200">
        <template #default="scope">
          <el-button size="small" @click="handleView(scope.row)">查看</el-button>
          <el-button size="small" @click="handleEdit(scope.row)">编辑</el-button>
          <el-button size="small" type="danger" @click="handleDelete(scope.row)">删除</el-button>
        </template>
      </el-table-column>
    </el-table>

    <el-dialog v-model="detailVisible" title="健康记录详情" width="500px">
      <div v-if="detailData">
        <el-descriptions :column="2" border>
          <el-descriptions-item label="血压">{{ detailData.bloodPressure }}</el-descriptions-item>
          <el-descriptions-item label="血糖">{{ detailData.bloodSugar }}</el-descriptions-item>
          <el-descriptions-item label="心率">{{ detailData.heartRate }}</el-descriptions-item>
          <el-descriptions-item label="体重">{{ detailData.weight }} kg</el-descriptions-item>
          <el-descriptions-item label="身高">{{ detailData.height }} cm</el-descriptions-item>
          <el-descriptions-item label="步数">{{ detailData.stepCount }}</el-descriptions-item>
          <el-descriptions-item label="睡眠">{{ detailData.sleepDuration }} 小时</el-descriptions-item>
          <el-descriptions-item label="记录时间">{{ detailData.recordTime }}</el-descriptions-item>
        </el-descriptions>
      </div>
      <template #footer><el-button @click="detailVisible = false">关闭</el-button></template>
    </el-dialog>

    <el-dialog v-model="modalVisible" :title="isEdit ? '编辑健康记录' : '添加健康记录'" width="500px">
      <el-form :model="formData" label-width="100px">
        <el-form-item label="用户ID"><el-input-number v-model="formData.userId" :min="1" controls-position="right" /></el-form-item>
        <el-form-item label="血压"><el-input v-model="formData.bloodPressure" placeholder="如：120/80" /></el-form-item>
        <el-form-item label="血糖"><el-input v-model="formData.bloodSugar" placeholder="如：5.5" /></el-form-item>
        <el-form-item label="心率"><el-input v-model="formData.heartRate" placeholder="如：72" /></el-form-item>
        <el-form-item label="体重(kg)"><el-input-number v-model="formData.weight" :min="0" :precision="1" controls-position="right" /></el-form-item>
        <el-form-item label="身高(cm)"><el-input-number v-model="formData.height" :min="0" :precision="1" controls-position="right" /></el-form-item>
        <el-form-item label="步数"><el-input-number v-model="formData.stepCount" :min="0" controls-position="right" /></el-form-item>
        <el-form-item label="睡眠(h)"><el-input-number v-model="formData.sleepDuration" :min="0" :precision="1" controls-position="right" /></el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="modalVisible = false">取消</el-button>
        <el-button type="primary" @click="handleSubmit">保存</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<style lang="scss" scoped>
.health-record { background: #fff; border-radius: 12px; padding: 20px; box-shadow: 0 2px 8px rgba(0,0,0,0.05); }
.search-bar { display: flex; gap: 12px; margin-bottom: 20px; flex-wrap: wrap; .search-input { width: 150px; } }
</style>
