<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import userApi from '@/api/user'

const router = useRouter()

const userList = ref([])
const searchForm = ref({ username: '', phone: '' })
const loading = ref(false)
const pagination = ref({ page: 1, pageSize: 10, total: 0 })

const loadUsers = async () => {
  loading.value = true
  try {
    const res = await userApi.getUserList({
      page: pagination.value.page,
      pageSize: pagination.value.pageSize,
      keyword: searchForm.value.username || searchForm.value.phone || '',
      userType: 0
    })
    userList.value = res.list || res.records || []
    pagination.value.total = res.total || 0
  } catch (error) {
    ElMessage.error('加载用户列表失败')
  } finally {
    loading.value = false
  }
}

const handleEdit = (row) => {
  router.push({ path: '/admin/user/form', query: { id: row.id } })
}

const handleDelete = async (row) => {
  try {
    await ElMessageBox.confirm(`确定删除用户 "${row.username}" 吗？`, '提示', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })
    await userApi.delete(row.id)
    ElMessage.success('删除成功')
    loadUsers()
  } catch (error) {
    if (error !== 'cancel') {
      ElMessage.error(error.message || '删除失败')
    }
  }
}

const handleView = (row) => {
  router.push({ path: '/admin/user/form', query: { id: row.id, view: true } })
}

const userTypeLabel = (val) => ['普通用户', '医生', '管理员', '护士'][val] || '未知'

onMounted(() => {
  loadUsers()
})
</script>

<template>
  <div class="user-list">
    <div class="search-bar">
      <el-input v-model="searchForm.username" placeholder="搜索用户名" class="search-input" @keyup.enter="loadUsers" />
      <el-input v-model="searchForm.phone" placeholder="搜索手机号" class="search-input" @keyup.enter="loadUsers" />
      <el-button type="primary" @click="loadUsers">搜索</el-button>
      <el-button type="success" @click="router.push('/admin/user/form')">添加用户</el-button>
    </div>

    <el-table :data="userList" :loading="loading" border>
      <el-table-column prop="id" label="ID" width="80" />
      <el-table-column prop="username" label="用户名" />
      <el-table-column prop="phone" label="手机号" />
      <el-table-column prop="userType" label="角色" width="120">
        <template #default="scope">{{ userTypeLabel(scope.row.userType) }}</template>
      </el-table-column>
      <el-table-column prop="status" label="状态" width="100">
        <template #default="scope">
          <el-tag :type="scope.row.status === 1 ? 'success' : 'danger'">{{ scope.row.status === 1 ? '正常' : '禁用' }}</el-tag>
        </template>
      </el-table-column>
      <el-table-column prop="createTime" label="创建时间" width="180" />
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
      @current-change="(page) => { pagination.page = page; loadUsers() }"
    />
  </div>
</template>

<style lang="scss" scoped>
.user-list { background: #fff; border-radius: 12px; padding: 20px; box-shadow: 0 2px 8px rgba(0,0,0,0.05); }
.search-bar { display: flex; gap: 12px; margin-bottom: 20px; flex-wrap: wrap; .search-input { width: 200px; } }
.pagination { margin-top: 20px; text-align: right; }
</style>
