<script setup>
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { useUserStore } from '@/stores/user'
import userApi from '@/api/user'

const userStore = useUserStore()

const tableData = ref([])
const searchForm = reactive({ keyword: '' })
const loading = ref(false)
const detailVisible = ref(false)
const detailData = ref(null)
const formVisible = ref(false)
const isEdit = ref(false)

const formData = reactive({
  id: null,
  username: '',
  password: '',
  realName: '',
  phone: '',
  email: '',
  userType: 2
})

const pagination = reactive({ currentPage: 1, pageSize: 10, total: 0 })

const loadData = async () => {
  loading.value = true
  try {
    const data = await userApi.getUserList({
      page: pagination.currentPage,
      pageSize: pagination.pageSize,
      keyword: searchForm.keyword,
      userType: 2
    })
    tableData.value = data.list || data.records || []
    pagination.total = data.total || 0
  } catch (error) {
    ElMessage.error('加载管理员列表失败')
  } finally {
    loading.value = false
  }
}

const handleSearch = () => {
  pagination.currentPage = 1
  loadData()
}

const handleReset = () => {
  searchForm.keyword = ''
  handleSearch()
}

const handlePageChange = (page) => {
  pagination.currentPage = page
  loadData()
}

const handleView = (row) => {
  detailData.value = row
  detailVisible.value = true
}

const handleAdd = () => {
  isEdit.value = false
  Object.assign(formData, { id: null, username: '', password: '', realName: '', phone: '', email: '', userType: 2 })
  formVisible.value = true
}

const handleEdit = (row) => {
  isEdit.value = true
  Object.assign(formData, { ...row, password: '' })
  formVisible.value = true
}

const handleDelete = async (row) => {
  try {
    await ElMessageBox.confirm(`确定删除管理员 "${row.username}" 吗？`, '提示', {
      confirmButtonText: '确定', cancelButtonText: '取消', type: 'warning'
    })
    await userApi.deleteUser(row.id)
    ElMessage.success('删除成功')
    loadData()
  } catch (error) {
    if (error !== 'cancel') {
      ElMessage.error(error.message || '删除失败')
    }
  }
}

const handleSubmit = async () => {
  if (!formData.username) {
    ElMessage.warning('请输入用户名')
    return
  }
  if (!isEdit.value && !formData.password) {
    ElMessage.warning('请输入密码')
    return
  }
  try {
    if (isEdit.value) {
      await userApi.updateUser(formData)
      ElMessage.success('修改成功')
    } else {
      await userApi.register({ ...formData, userType: 2 })
      ElMessage.success('添加成功')
    }
    formVisible.value = false
    loadData()
  } catch (error) {
    ElMessage.error(error.message || '操作失败')
  }
}

onMounted(() => {
  loadData()
})
</script>

<template>
  <div class="admin-list-container">
    <div class="page-header">
      <h1>管理员管理</h1>
      <p>管理系统管理员账号</p>
    </div>

    <div class="search-bar">
      <el-input v-model="searchForm.keyword" placeholder="搜索用户名" class="search-input" @keyup.enter="handleSearch" />
      <el-button type="primary" @click="handleSearch">搜索</el-button>
      <el-button @click="handleReset">重置</el-button>
    </div>

    <div class="table-toolbar">
      <el-button type="primary" @click="handleAdd">新增管理员</el-button>
    </div>

    <el-table :data="tableData" :loading="loading" border>
      <el-table-column prop="id" label="ID" width="80" />
      <el-table-column prop="username" label="用户名" width="120" />
      <el-table-column prop="realName" label="真实姓名" width="120" />
      <el-table-column prop="phone" label="联系电话" width="130" />
      <el-table-column prop="email" label="邮箱" width="180" />
      <el-table-column prop="status" label="状态" width="100">
        <template #default="scope">
          <el-tag type="success">启用</el-tag>
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
      :current-page="pagination.currentPage"
      :page-size="pagination.pageSize"
      :total="pagination.total"
      @current-change="handlePageChange"
      layout="total, prev, pager, next, jumper"
      style="margin-top: 20px; text-align: right"
    />

    <el-dialog v-model="detailVisible" title="管理员详情" width="500px">
      <div v-if="detailData">
        <el-descriptions :column="1" border>
          <el-descriptions-item label="ID">{{ detailData.id }}</el-descriptions-item>
          <el-descriptions-item label="用户名">{{ detailData.username }}</el-descriptions-item>
          <el-descriptions-item label="真实姓名">{{ detailData.realName }}</el-descriptions-item>
          <el-descriptions-item label="联系电话">{{ detailData.phone }}</el-descriptions-item>
          <el-descriptions-item label="邮箱">{{ detailData.email }}</el-descriptions-item>
          <el-descriptions-item label="状态">{{ detailData.status === 1 ? '启用' : '禁用' }}</el-descriptions-item>
          <el-descriptions-item label="创建时间">{{ detailData.createTime }}</el-descriptions-item>
        </el-descriptions>
      </div>
      <template #footer><el-button @click="detailVisible = false">关闭</el-button></template>
    </el-dialog>

    <el-dialog v-model="formVisible" :title="isEdit ? '编辑管理员' : '新增管理员'" width="500px">
      <el-form :model="formData" label-width="100px">
        <el-form-item label="用户名"><el-input v-model="formData.username" /></el-form-item>
        <el-form-item label="密码" v-if="!isEdit"><el-input v-model="formData.password" type="password" show-password /></el-form-item>
        <el-form-item label="真实姓名"><el-input v-model="formData.realName" /></el-form-item>
        <el-form-item label="联系电话"><el-input v-model="formData.phone" /></el-form-item>
        <el-form-item label="邮箱"><el-input v-model="formData.email" /></el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="formVisible = false">取消</el-button>
        <el-button type="primary" @click="handleSubmit">保存</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<style lang="scss" scoped>
.admin-list-container { background: #fff; border-radius: 12px; padding: 20px; box-shadow: 0 2px 8px rgba(0,0,0,0.05); }
.page-header { margin-bottom: 20px; h1 { font-size: 20px; font-weight: bold; margin: 0 0 4px; } p { color: #666; font-size: 14px; margin: 0; } }
.search-bar { display: flex; gap: 12px; margin-bottom: 20px; .search-input { width: 300px; } }
.table-toolbar { display: flex; gap: 12px; margin-bottom: 16px; }
</style>
