<script setup>
import { ref, onMounted } from 'vue'
import { useUserStore } from '@/stores/user'
import { ElMessage } from 'element-plus'
import medicalRecordApi from '@/api/medicalRecord'

const userStore = useUserStore()
const recordList = ref([])
const loading = ref(false)
const detailVisible = ref(false)
const detailData = ref(null)

const loadRecords = async () => {
  loading.value = true
  try {
    const res = await medicalRecordApi.getList({
      pageNum: 1,
      pageSize: 50,
      userId: userStore.userInfo?.userId
    })
    recordList.value = res.records || res.data?.records || res || []
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

onMounted(() => {
  loadRecords()
})
</script>

<template>
  <div class="medical-record-view">
    <el-table :data="recordList" :loading="loading" border>
      <el-table-column prop="id" label="ID" width="80" />
      <el-table-column prop="diagnosis" label="诊断" />
      <el-table-column prop="treatment" label="治疗方案" />
      <el-table-column prop="recordTime" label="记录时间" width="180" />
      <el-table-column prop="isDesensitized" label="脱敏状态" width="100">
        <template #default="scope">
          <el-tag :type="scope.row.isDesensitized === 1 ? 'success' : 'warning'">
            {{ scope.row.isDesensitized === 1 ? '已脱敏' : '未脱敏' }}
          </el-tag>
        </template>
      </el-table-column>
      <el-table-column label="操作" width="100">
        <template #default="scope">
          <el-button size="small" @click="handleView(scope.row)">查看</el-button>
        </template>
      </el-table-column>
    </el-table>

    <el-dialog v-model="detailVisible" title="病历详情（脱敏）" width="600px">
      <div v-if="detailData" class="record-detail">
        <el-descriptions :column="1" border>
          <el-descriptions-item label="诊断">{{ detailData.diagnosis }}</el-descriptions-item>
          <el-descriptions-item label="治疗方案">{{ detailData.treatment }}</el-descriptions-item>
          <el-descriptions-item label="记录时间">{{ detailData.recordTime }}</el-descriptions-item>
        </el-descriptions>
      </div>
      <template #footer>
        <el-button @click="detailVisible = false">关闭</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<style lang="scss" scoped>
.medical-record-view {
  background: #fff;
  border-radius: 12px;
  padding: 20px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
}
</style>
