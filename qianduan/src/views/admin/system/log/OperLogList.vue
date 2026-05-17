<script setup>
import { ref, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import systemApi from '@/api/system'

const logList = ref([])
const searchForm = ref({ operationType: '', startTime: '', endTime: '' })
const loading = ref(false)
const detailVisible = ref(false)
const detailData = ref(null)
const pagination = ref({ page: 1, pageSize: 20, total: 0 })

const loadLogs = async () => {
  loading.value = true
  try {
    const res = await systemApi.getOperLogList({
      page: pagination.value.page,
      pageSize: pagination.value.pageSize,
      operationType: searchForm.value.operationType,
      startTime: searchForm.value.startTime,
      endTime: searchForm.value.endTime
    })
    logList.value = res.records || res.list || res || []
    pagination.value.total = res.total || 0
  } catch (error) {
    ElMessage.error('加载操作日志失败')
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
    await ElMessageBox.confirm('确定删除该日志记录吗？', '提示', {
      confirmButtonText: '确定', cancelButtonText: '取消', type: 'warning'
    })
    ElMessage.success('删除成功')
    loadLogs()
  } catch (error) {
    if (error !== 'cancel') {
      ElMessage.error(error.message || '删除失败')
    }
  }
}

const handlePageChange = (page) => {
  pagination.value.page = page
  loadLogs()
}

onMounted(() => {
  loadLogs()
})
</script>

<template>
  <div class="oper-log-list">
    <div class="search-bar">
      <el-select v-model="searchForm.operationType" placeholder="操作类型" class="search-input">
        <el-option label="全部" :value="null" />
        <el-option label="登录" value="login" />
        <el-option label="新增" value="add" />
        <el-option label="修改" value="update" />
        <el-option label="删除" value="delete" />
        <el-option label="查询" value="query" />
      </el-select>
      <el-date-picker v-model="searchForm.startTime" type="date" placeholder="开始时间" class="search-input" value-format="YYYY-MM-DD" />
      <el-date-picker v-model="searchForm.endTime" type="date" placeholder="结束时间" class="search-input" value-format="YYYY-MM-DD" />
      <el-button type="primary" @click="loadLogs">搜索</el-button>
    </div>

    <el-table :data="logList" :loading="loading" border>
      <el-table-column prop="id" label="ID" width="80" />
      <el-table-column prop="userName" label="操作用户" width="120" />
      <el-table-column prop="operationType" label="操作类型" width="120">
        <template #default="scope">
          <el-tag :type="{ login: 'info', add: 'success', update: 'warning', delete: 'danger', query: '' }[scope.row.operationType] || ''">
            {{ { login: '登录', add: '新增', update: '修改', delete: '删除', query: '查询' }[scope.row.operationType] || scope.row.operationType }}
          </el-tag>
        </template>
      </el-table-column>
      <el-table-column prop="operationDesc" label="操作描述" />
      <el-table-column prop="ipAddress" label="IP地址" width="130" />
      <el-table-column prop="operationTime" label="操作时间" width="180" />
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

    <el-dialog v-model="detailVisible" title="日志详情" width="600px">
      <div v-if="detailData">
        <el-descriptions :column="1" border>
          <el-descriptions-item label="操作用户">{{ detailData.userName }}</el-descriptions-item>
          <el-descriptions-item label="操作类型">{{ detailData.operationType }}</el-descriptions-item>
          <el-descriptions-item label="操作描述">{{ detailData.operationDesc }}</el-descriptions-item>
          <el-descriptions-item label="IP地址">{{ detailData.ipAddress }}</el-descriptions-item>
          <el-descriptions-item label="设备信息">{{ detailData.deviceInfo }}</el-descriptions-item>
          <el-descriptions-item label="操作时间">{{ detailData.operationTime }}</el-descriptions-item>
        </el-descriptions>
      </div>
      <template #footer><el-button @click="detailVisible = false">关闭</el-button></template>
    </el-dialog>
  </div>
</template>

<style lang="scss" scoped>
.oper-log-list { background: #fff; border-radius: 12px; padding: 20px; box-shadow: 0 2px 8px rgba(0,0,0,0.05); }
.search-bar { display: flex; gap: 12px; margin-bottom: 20px; flex-wrap: wrap; .search-input { width: 180px; } }
</style>
