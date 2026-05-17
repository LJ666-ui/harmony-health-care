<script setup>
import { ref, onMounted } from 'vue'
import consultationApi from '@/api/consultation'

const consultations = ref([])
const loading = ref(false)
const page = ref(1)
const pageSize = ref(10)
const total = ref(0)
const statusFilter = ref(null)

onMounted(() => {
  loadConsultations()
})

async function loadConsultations() {
  loading.value = true
  try {
    const res = await consultationApi.getConsultationList({
      page: page.value,
      pageSize: pageSize.value,
      status: statusFilter.value
    })
    if (res.code === 200) {
      consultations.value = res.data.records || []
      total.value = res.data.total || 0
    }
  } catch (e) {
    console.error('加载问诊列表失败:', e)
  } finally {
    loading.value = false
  }
}

function handlePageChange(val) {
  page.value = val
  loadConsultations()
}

function handleFilterChange() {
  page.value = 1
  loadConsultations()
}

function getStatusText(status) {
  const map = { 0: '等待接诊', 1: '进行中', 2: '已完成', 3: '已取消', 4: '已超时' }
  return map[status] || '未知'
}

function getStatusType(status) {
  const map = { 0: 'warning', 1: 'success', 2: 'info', 3: 'danger', 4: 'danger' }
  return map[status] || 'info'
}

function getTypeText(type) {
  const map = { 1: '图文', 2: '语音', 3: '视频' }
  return map[type] || '图文'
}

function formatDate(time) {
  if (!time) return '--'
  return new Date(time).toLocaleString('zh-CN')
}
</script>

<template>
  <div class="admin-consultation">
    <div class="page-header">
      <h2>问诊管理</h2>
      <el-select v-model="statusFilter" placeholder="状态筛选" clearable @change="handleFilterChange" style="width: 140px">
        <el-option label="等待接诊" :value="0" />
        <el-option label="进行中" :value="1" />
        <el-option label="已完成" :value="2" />
        <el-option label="已取消" :value="3" />
      </el-select>
    </div>

    <el-table :data="consultations" v-loading="loading" stripe style="width: 100%">
      <el-table-column prop="orderNo" label="问诊单号" width="180" />
      <el-table-column prop="patientName" label="患者" width="100" />
      <el-table-column prop="doctorName" label="医生" width="100" />
      <el-table-column prop="department" label="科室" width="100" />
      <el-table-column label="类型" width="80">
        <template #default="{ row }">{{ getTypeText(row.consultationType) }}</template>
      </el-table-column>
      <el-table-column label="状态" width="100">
        <template #default="{ row }">
          <el-tag :type="getStatusType(row.status)" size="small">{{ getStatusText(row.status) }}</el-tag>
        </template>
      </el-table-column>
      <el-table-column prop="chiefComplaint" label="主诉" show-overflow-tooltip />
      <el-table-column label="费用" width="80">
        <template #default="{ row }">¥{{ row.fee || 0 }}</template>
      </el-table-column>
      <el-table-column label="创建时间" width="170">
        <template #default="{ row }">{{ formatDate(row.createTime) }}</template>
      </el-table-column>
    </el-table>

    <div class="pagination-wrap">
      <el-pagination
        v-model:current-page="page"
        :page-size="pageSize"
        :total="total"
        layout="total, prev, pager, next"
        @current-change="handlePageChange"
      />
    </div>
  </div>
</template>

<style lang="scss" scoped>
.admin-consultation { padding: 20px; }
.page-header {
  display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px;
  h2 { font-size: 20px; color: #333; margin: 0; }
}
.pagination-wrap { margin-top: 20px; display: flex; justify-content: flex-end; }
</style>
