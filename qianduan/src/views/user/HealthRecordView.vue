<script setup>
import { ref, reactive, onMounted } from 'vue'
import { useUserStore } from '@/stores/user'
import { ElMessage } from 'element-plus'
import healthRecordApi from '@/api/healthRecord'

const userStore = useUserStore()
const recordList = ref([])
const loading = ref(false)
const addVisible = ref(false)
const formData = reactive({
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
    const userId = userStore.userInfo?.userId || 1
    const res = await healthRecordApi.getPage(1, 20, userId)
    recordList.value = res.records || res || []
  } catch (error) {
    ElMessage.error('加载健康记录失败')
  } finally {
    loading.value = false
  }
}

const handleAdd = () => {
  addVisible.value = true
}

const handleSubmit = async () => {
  try {
    const userId = userStore.userInfo?.userId || 1
    await healthRecordApi.add({
      userId,
      ...formData
    })
    ElMessage.success('添加成功')
    addVisible.value = false
    Object.keys(formData).forEach(key => formData[key] = '')
    loadRecords()
  } catch (error) {
    ElMessage.error(error.message || '添加失败')
  }
}

onMounted(() => {
  loadRecords()
})
</script>

<template>
  <div class="health-record-view">
    <div class="page-header">
      <h3>我的健康监测</h3>
      <el-button type="primary" @click="handleAdd">添加记录</el-button>
    </div>

    <el-table :data="recordList" :loading="loading" border>
      <el-table-column prop="bloodPressure" label="血压" width="120" />
      <el-table-column prop="bloodSugar" label="血糖" width="100" />
      <el-table-column prop="heartRate" label="心率" width="100" />
      <el-table-column prop="weight" label="体重(kg)" width="100" />
      <el-table-column prop="height" label="身高(cm)" width="100" />
      <el-table-column prop="stepCount" label="步数" width="100" />
      <el-table-column prop="sleepDuration" label="睡眠(h)" width="100" />
      <el-table-column prop="recordTime" label="记录时间" width="180" />
    </el-table>

    <el-dialog v-model="addVisible" title="添加健康记录" width="500px">
      <el-form :model="formData" label-width="100px">
        <el-form-item label="血压">
          <el-input v-model="formData.bloodPressure" placeholder="如：120/80" />
        </el-form-item>
        <el-form-item label="血糖">
          <el-input v-model="formData.bloodSugar" placeholder="如：5.5" />
        </el-form-item>
        <el-form-item label="心率">
          <el-input v-model="formData.heartRate" placeholder="如：72" />
        </el-form-item>
        <el-form-item label="体重(kg)">
          <el-input-number v-model="formData.weight" :min="0" :precision="1" controls-position="right" />
        </el-form-item>
        <el-form-item label="身高(cm)">
          <el-input-number v-model="formData.height" :min="0" :precision="1" controls-position="right" />
        </el-form-item>
        <el-form-item label="步数">
          <el-input-number v-model="formData.stepCount" :min="0" controls-position="right" />
        </el-form-item>
        <el-form-item label="睡眠(h)">
          <el-input-number v-model="formData.sleepDuration" :min="0" :precision="1" controls-position="right" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="addVisible = false">取消</el-button>
        <el-button type="primary" @click="handleSubmit">保存</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<style lang="scss" scoped>
.health-record-view {
  background: #fff;
  border-radius: 12px;
  padding: 20px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
}
.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
  h3 { margin: 0; font-size: 18px; }
}
</style>
