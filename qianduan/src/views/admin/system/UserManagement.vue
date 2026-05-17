<script setup>
import { ref, reactive, onMounted } from 'vue'
import userApi from '@/api/user'
import { ElMessage, ElMessageBox } from 'element-plus'

const tableData = ref([])
const total = ref(0)
const currentPage = ref(1)
const pageSize = ref(10)
const loading = ref(false)
const modalVisible = ref(false)
const isEdit = ref(false)

const searchForm = reactive({
  keyword: ''
})

const formData = reactive({
  id: '',
  username: '',
  password: '',
  phone: '',
  realName: '',
  userType: 0,
  status: 1
})

const loadData = async () => {
  loading.value = true
  try {
    const data = await userApi.getUserList({
      page: currentPage.value,
      pageSize: pageSize.value,
      keyword: searchForm.keyword,
      userType: 0
    })
    tableData.value = data.records || data.list || []
    total.value = data.total || 0
  } catch (e) {
    ElMessage.error('加载用户列表失败')
  } finally {
    loading.value = false
  }
}

const handleSearch = () => {
  currentPage.value = 1
  loadData()
}

const handleReset = () => {
  searchForm.keyword = ''
  handleSearch()
}

const handlePageChange = (page) => {
  currentPage.value = page
  loadData()
}

const openAddModal = () => {
  isEdit.value = false
  formData.id = ''
  formData.username = ''
  formData.password = ''
  formData.phone = ''
  formData.realName = ''
  formData.userType = 0
  formData.status = 1
  modalVisible.value = true
}

const openEditModal = (row) => {
  isEdit.value = true
  formData.id = row.id
  formData.username = row.username
  formData.password = ''
  formData.phone = row.phone
  formData.realName = row.realName
  formData.userType = row.userType
  formData.status = row.status
  modalVisible.value = true
}

const handleSubmit = async () => {
  try {
    if (isEdit.value) {
      await userApi.updateUser(formData)
      ElMessage.success('更新成功')
    } else {
      await userApi.register(formData)
      ElMessage.success('添加成功')
    }
    modalVisible.value = false
    loadData()
  } catch (e) {
    ElMessage.error(e.message || '操作失败')
  }
}

const handleStatusChange = async (row) => {
  const newStatus = row.status === 1 ? 0 : 1
  const statusText = newStatus === 1 ? '启用' : '禁用'
  try {
    await ElMessageBox.confirm(`确认${statusText}用户 ${row.realName || row.username}？`, '状态变更', { type: 'warning' })
    await userApi.updateUser({ id: row.id, status: newStatus })
    ElMessage.success(`已${statusText}`)
    loadData()
  } catch (e) { if (e !== 'cancel') ElMessage.error(e.message || '操作失败') }
}

const handleDelete = async (row) => {
  try {
    await ElMessageBox.confirm(`确认删除用户 ${row.realName || row.username}？`, '删除确认', { type: 'warning' })
    await userApi.deleteUser(row.id)
    ElMessage.success('删除成功')
    loadData()
  } catch (e) { if (e !== 'cancel') ElMessage.error(e.message || '删除失败') }
}

onMounted(() => {
  loadData()
})
</script>

<template>
  <div class="user-management-container">
    <div class="page-header">
      <h1>用户管理</h1>
      <p>管理普通用户账号（仅显示普通用户）</p>
    </div>

    <div class="search-bar">
      <el-input v-model="searchForm.keyword" placeholder="搜索用户名/手机号" class="search-input" @keyup.enter="handleSearch" />
      <el-button type="primary" @click="handleSearch">搜索</el-button>
      <el-button @click="handleReset">重置</el-button>
      <el-button type="primary" @click="openAddModal">新增用户</el-button>
    </div>

    <el-table :data="tableData" v-loading="loading" border stripe>
      <el-table-column prop="id" label="ID" width="80" />
      <el-table-column prop="username" label="用户名" width="120" />
      <el-table-column prop="realName" label="真实姓名" width="120" />
      <el-table-column prop="phone" label="手机号" width="130" />
      <el-table-column prop="status" label="状态" width="100">
        <template #default="{ row }">
          <el-switch :model-value="row.status === 1" @change="handleStatusChange(row)" active-text="启用" inactive-text="禁用" />
        </template>
      </el-table-column>
      <el-table-column prop="createTime" label="创建时间" min-width="170" />
      <el-table-column label="操作" width="180" fixed="right">
        <template #default="{ row }">
          <el-button size="small" type="primary" @click="openEditModal(row)">编辑</el-button>
          <el-button size="small" type="danger" @click="handleDelete(row)">删除</el-button>
        </template>
      </el-table-column>
    </el-table>

    <el-pagination
      v-model:current-page="currentPage"
      v-model:page-size="pageSize"
      :total="total"
      @current-change="handlePageChange"
      layout="total, prev, pager, next, jumper"
      style="margin-top: 20px; text-align: right"
    />

    <el-dialog v-model="modalVisible" :title="isEdit ? '编辑用户' : '新增用户'" width="500px">
      <el-form :model="formData" label-width="100px">
        <el-form-item label="用户名"><el-input v-model="formData.username" /></el-form-item>
        <el-form-item v-if="!isEdit" label="密码"><el-input v-model="formData.password" type="password" show-password /></el-form-item>
        <el-form-item label="手机号"><el-input v-model="formData.phone" /></el-form-item>
        <el-form-item label="真实姓名"><el-input v-model="formData.realName" /></el-form-item>
        <el-form-item label="状态">
          <el-radio-group v-model="formData.status">
            <el-radio :label="1">启用</el-radio>
            <el-radio :label="0">禁用</el-radio>
          </el-radio-group>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="modalVisible = false">取消</el-button>
        <el-button type="primary" @click="handleSubmit">保存</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<style lang="scss" scoped>
.user-management-container { background: #fff; border-radius: 12px; padding: 20px; box-shadow: 0 2px 8px rgba(0,0,0,0.05); }
.page-header { margin-bottom: 20px; h1 { font-size: 20px; font-weight: bold; margin: 0 0 4px; } p { color: #666; font-size: 14px; margin: 0; } }
.search-bar { display: flex; gap: 12px; margin-bottom: 20px; .search-input { width: 300px; } }
</style>
