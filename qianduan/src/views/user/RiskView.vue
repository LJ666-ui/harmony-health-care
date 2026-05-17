<script setup>
import { ref, onMounted } from 'vue'
import { useUserStore } from '@/stores/user'
import { ElMessage } from 'element-plus'
import riskApi from '@/api/risk'

const userStore = useUserStore()
const assessList = ref([])
const loading = ref(false)

const loadAssessments = async () => {
  loading.value = true
  try {
    const userId = userStore.userInfo?.userId || 1
    const res = await riskApi.getList(userId)
    assessList.value = res.records || res || []
  } catch (error) {
    ElMessage.error('加载风险评估失败')
  } finally {
    loading.value = false
  }
}

const handleAssess = async () => {
  try {
    const userId = userStore.userInfo?.userId || 1
    await riskApi.assess(userId)
    ElMessage.success('风险评估完成')
    loadAssessments()
  } catch (error) {
    ElMessage.error(error.message || '评估失败')
  }
}

const riskLabel = (val) => ['低', '中', '高'][val] || '-'
const riskTagType = (val) => ['success', 'warning', 'danger'][val] || 'info'

onMounted(() => {
  loadAssessments()
})
</script>

<template>
  <div class="risk-view">
    <div class="page-header">
      <h3>我的风险评估</h3>
      <el-button type="primary" @click="handleAssess">开始评估</el-button>
    </div>

    <el-table :data="assessList" :loading="loading" border>
      <el-table-column prop="hypertensionRisk" label="高血压风险" width="120">
        <template #default="scope">
          <el-tag :type="riskTagType(scope.row.hypertensionRisk)">{{ riskLabel(scope.row.hypertensionRisk) }}</el-tag>
        </template>
      </el-table-column>
      <el-table-column prop="diabetesRisk" label="糖尿病风险" width="120">
        <template #default="scope">
          <el-tag :type="riskTagType(scope.row.diabetesRisk)">{{ riskLabel(scope.row.diabetesRisk) }}</el-tag>
        </template>
      </el-table-column>
      <el-table-column prop="fallRisk" label="跌倒风险" width="100">
        <template #default="scope">
          <el-tag :type="riskTagType(scope.row.fallRisk)">{{ riskLabel(scope.row.fallRisk) }}</el-tag>
        </template>
      </el-table-column>
      <el-table-column prop="frailtyRisk" label="衰弱风险" width="100">
        <template #default="scope">
          <el-tag :type="riskTagType(scope.row.frailtyRisk)">{{ riskLabel(scope.row.frailtyRisk) }}</el-tag>
        </template>
      </el-table-column>
      <el-table-column prop="totalRisk" label="综合风险" width="100">
        <template #default="scope">
          <el-tag :type="riskTagType(scope.row.totalRisk)" size="large">{{ riskLabel(scope.row.totalRisk) }}</el-tag>
        </template>
      </el-table-column>
      <el-table-column prop="assessTime" label="评估时间" width="180" />
    </el-table>
  </div>
</template>

<style lang="scss" scoped>
.risk-view {
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
