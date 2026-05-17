<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import hospitalApi from '@/api/hospital'

const router = useRouter()
const hospitalList = ref([])
const searchForm = ref({ name: '', level: '' })
const loading = ref(false)
const pagination = ref({ page: 1, pageSize: 10, total: 0 })

const loadHospitals = async () => {
  loading.value = true
  try {
    const res = await hospitalApi.getPage({
      page: pagination.value.page,
      size: pagination.value.pageSize,
      ...searchForm.value
    })
    hospitalList.value = res.records || res.list || []
    pagination.value.total = res.total || 0
  } catch (error) {
    ElMessage.error('加载医院列表失败')
  } finally {
    loading.value = false
  }
}

const handleEdit = (row) => {
  router.push({ path: '/admin/hospital/form', query: { id: row.id } })
}

const handleDelete = async (row) => {
  try {
    await ElMessageBox.confirm(`确定删除医院 "${row.name}" 吗？`, '提示', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })
    await hospitalApi.delete(row.id)
    ElMessage.success('删除成功')
    loadHospitals()
  } catch (error) {
    if (error !== 'cancel') {
      ElMessage.error(error.message || '删除失败')
    }
  }
}

const handleView = (row) => {
  router.push({ path: '/admin/hospital/form', query: { id: row.id, view: true } })
}

onMounted(() => {
  loadHospitals()
})
</script>

<template>
  <div class="hospital-list">
    <div class="search-bar">
      <el-input v-model="searchForm.name" placeholder="搜索医院名称" class="search-input" @keyup.enter="loadHospitals" />
      <el-select v-model="searchForm.level" placeholder="医院等级" class="search-input" clearable>
        <el-option label="全部" value="" />
        <el-option label="三级甲等" value="三级甲等" />
        <el-option label="综合医院" value="综合医院" />
        <el-option label="专科医院" value="专科医院" />
      </el-select>
      <el-button type="primary" @click="loadHospitals">搜索</el-button>
      <el-button type="success" @click="router.push('/admin/hospital/form')">添加医院</el-button>
    </div>

    <el-table :data="hospitalList" :loading="loading" border>
      <el-table-column prop="id" label="ID" width="80" />
      <el-table-column prop="name" label="医院名称" />
      <el-table-column prop="level" label="等级" width="100" />
      <el-table-column prop="address" label="地址" />
      <el-table-column prop="phone" label="电话" width="130" />
      <el-table-column label="操作" width="200">
        <template #default="scope">
          <el-button size="small" @click="handleView(scope.row)">查看</el-button>
          <el-button size="small" @click="handleEdit(scope.row)">编辑</el-button>
          <el-button size="small" type="danger" @click="handleDelete(scope.row)">删除</el-button>
        </template>
      </el-table-column>
    </el-table>

    <el-pagination
      :current-page="pagination.page"
      :page-size="pagination.pageSize"
      :total="pagination.total"
      class="pagination"
      @current-change="(page) => { pagination.page = page; loadHospitals() }"
    />
  </div>
</template>

<style lang="scss" scoped>
.hospital-list { background: #fff; border-radius: 12px; padding: 20px; box-shadow: 0 2px 8px rgba(0,0,0,0.05); }
.search-bar { display: flex; gap: 12px; margin-bottom: 20px; .search-input { width: 200px; } }
.pagination { margin-top: 20px; text-align: right; }
</style>
