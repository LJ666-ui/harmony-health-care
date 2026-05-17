<script setup>
import { ref, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import riskApi from '@/api/risk'

const assessList = ref([])
const searchForm = ref({ userId: '' })
const loading = ref(false)
const detailVisible = ref(false)
const detailData = ref(null)
const pagination = ref({ page: 1, pageSize: 10, total: 0 })

const riskLabel = (val) => {
  if (val === 0) return '低'
  if (val === 1) return '中'
  if (val === 2) return '高'
  return '-'
}
const riskTagType = (val) => {
  if (val === 0) return 'success'
  if (val === 1) return 'warning'
  if (val === 2) return 'danger'
  return 'info'
}

const loadAssessments = async () => {
  loading.value = true
  try {
    const userId = searchForm.value.userId || 1
    const res = await riskApi.getList(userId, pagination.value.page, pagination.value.pageSize)
    assessList.value = res.records || res.list || res || []
    pagination.value.total = res.total || 0
  } catch (error) {
    ElMessage.error('加载风险评估失败')
  } finally {
    loading.value = false
  }
}

const handleView = (row) => {
  detailData.value = row
  detailVisible.value = true
}

const handleDelete = async (row) => {
  try {
    await ElMessageBox.confirm('确定删除该评估记录吗？', '提示', {
      confirmButtonText: '确定', cancelButtonText: '取消', type: 'warning'
    })
    await riskApi.delete(row.id)
    ElMessage.success('删除成功')
    loadAssessments()
  } catch (error) {
    if (error !== 'cancel') {
      ElMessage.error(error.message || '删除失败')
    }
  }
}

const handleAssess = async () => {
  const userId = searchForm.value.userId
  if (!userId) {
    ElMessage.warning('请输入用户ID后再进行评估')
    return
  }
  try {
    await riskApi.assess(userId)
    ElMessage.success('风险评估完成')
    loadAssessments()
  } catch (error) {
    ElMessage.error(error.message || '评估失败')
  }
}

const handlePageChange = (page) => {
  pagination.value.page = page
  loadAssessments()
}

const parseAssessResult = (result) => {
  if (!result) return null
  try {
    return typeof result === 'string' ? JSON.parse(result) : result
  } catch {
    return null
  }
}

onMounted(() => {
  loadAssessments()
})
</script>

<template>
  <div class="risk-assess">
    <div class="search-bar">
      <el-input v-model="searchForm.userId" placeholder="用户ID" class="search-input" @keyup.enter="loadAssessments" />
      <el-button type="primary" @click="loadAssessments">搜索</el-button>
      <el-button type="success" @click="handleAssess">开始评估</el-button>
    </div>

    <el-table :data="assessList" :loading="loading" border>
      <el-table-column prop="id" label="ID" width="80" />
      <el-table-column prop="userId" label="用户ID" width="100" />
      <el-table-column prop="hypertensionRisk" label="高血压风险" width="120">
        <template #default="scope"><el-tag :type="riskTagType(scope.row.hypertensionRisk)">{{ riskLabel(scope.row.hypertensionRisk) }}</el-tag></template>
      </el-table-column>
      <el-table-column prop="diabetesRisk" label="糖尿病风险" width="120">
        <template #default="scope"><el-tag :type="riskTagType(scope.row.diabetesRisk)">{{ riskLabel(scope.row.diabetesRisk) }}</el-tag></template>
      </el-table-column>
      <el-table-column prop="fallRisk" label="跌倒风险" width="100">
        <template #default="scope"><el-tag :type="riskTagType(scope.row.fallRisk)">{{ riskLabel(scope.row.fallRisk) }}</el-tag></template>
      </el-table-column>
      <el-table-column prop="frailtyRisk" label="衰弱风险" width="100">
        <template #default="scope"><el-tag :type="riskTagType(scope.row.frailtyRisk)">{{ riskLabel(scope.row.frailtyRisk) }}</el-tag></template>
      </el-table-column>
      <el-table-column prop="sarcopeniaRisk" label="肌少症风险" width="120">
        <template #default="scope"><el-tag :type="riskTagType(scope.row.sarcopeniaRisk)">{{ riskLabel(scope.row.sarcopeniaRisk) }}</el-tag></template>
      </el-table-column>
      <el-table-column prop="totalRisk" label="综合风险" width="100">
        <template #default="scope"><el-tag :type="riskTagType(scope.row.totalRisk)" size="large">{{ riskLabel(scope.row.totalRisk) }}</el-tag></template>
      </el-table-column>
      <el-table-column prop="assessTime" label="评估时间" width="180" />
      <el-table-column label="操作" width="150">
        <template #default="scope">
          <el-button size="small" @click="handleView(scope.row)">查看</el-button>
          <el-button size="small" type="danger" @click="handleDelete(scope.row)">删除</el-button>
        </template>
      </el-table-column>
    </el-table>

    <el-pagination
      :current-page="pagination.page"
      :page-size="pagination.pageSize"
      :total="pagination.total"
      @current-change="handlePageChange"
      layout="total, prev, pager, next, jumper"
      style="margin-top: 20px; text-align: right"
    />

    <el-dialog v-model="detailVisible" title="风险评估详情" width="700px">
      <div v-if="detailData">
        <el-descriptions :column="2" border>
          <el-descriptions-item label="用户ID">{{ detailData.userId }}</el-descriptions-item>
          <el-descriptions-item label="评估时间">{{ detailData.assessTime }}</el-descriptions-item>
          <el-descriptions-item label="高血压风险"><el-tag :type="riskTagType(detailData.hypertensionRisk)">{{ riskLabel(detailData.hypertensionRisk) }}</el-tag></el-descriptions-item>
          <el-descriptions-item label="糖尿病风险"><el-tag :type="riskTagType(detailData.diabetesRisk)">{{ riskLabel(detailData.diabetesRisk) }}</el-tag></el-descriptions-item>
          <el-descriptions-item label="跌倒风险"><el-tag :type="riskTagType(detailData.fallRisk)">{{ riskLabel(detailData.fallRisk) }}</el-tag></el-descriptions-item>
          <el-descriptions-item label="衰弱风险"><el-tag :type="riskTagType(detailData.frailtyRisk)">{{ riskLabel(detailData.frailtyRisk) }}</el-tag></el-descriptions-item>
          <el-descriptions-item label="肌少症风险"><el-tag :type="riskTagType(detailData.sarcopeniaRisk)">{{ riskLabel(detailData.sarcopeniaRisk) }}</el-tag></el-descriptions-item>
          <el-descriptions-item label="综合风险"><el-tag :type="riskTagType(detailData.totalRisk)" size="large">{{ riskLabel(detailData.totalRisk) }}</el-tag></el-descriptions-item>
        </el-descriptions>

        <div v-if="parseAssessResult(detailData.assessResult)" style="margin-top: 16px;">
          <h4 style="margin-bottom: 8px;">评估建议</h4>
          <el-alert
            :title="parseAssessResult(detailData.assessResult).suggestion || '暂无建议'"
            :type="detailData.totalRisk === 2 ? 'error' : detailData.totalRisk === 1 ? 'warning' : 'success'"
            show-icon
            :closable="false"
          />
        </div>
      </div>
      <template #footer><el-button @click="detailVisible = false">关闭</el-button></template>
    </el-dialog>
  </div>
</template>

<style lang="scss" scoped>
.risk-assess { background: #fff; border-radius: 12px; padding: 20px; box-shadow: 0 2px 8px rgba(0,0,0,0.05); }
.search-bar { display: flex; gap: 12px; margin-bottom: 20px; flex-wrap: wrap; .search-input { width: 150px; } }
</style>
