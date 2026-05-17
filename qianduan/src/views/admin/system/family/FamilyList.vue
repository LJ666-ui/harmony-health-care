<script setup>
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import request from '@/utils/request'

const tableData = ref([])
const total = ref(0)
const loading = ref(false)
const currentPage = ref(1)
const pageSize = ref(10)
const modalVisible = ref(false)
const isEdit = ref(false)
const searchForm = reactive({ keyword: '' })

const formData = reactive({
  id: null,
  name: '',
  phone: '',
  password: '',
  relation: '',
  userId: null,
  gender: null,
  age: null,
  idCard: '',
  address: '',
  loginEnabled: 1
})

const loadData = async () => {
  loading.value = true
  try {
    const data = await request.get('/family-member/list', {
      params: { page: currentPage.value, pageSize: pageSize.value, keyword: searchForm.keyword }
    })
    tableData.value = data.records || data.list || []
    total.value = data.total || 0
  } catch (e) {
    ElMessage.error('加载家属列表失败')
  } finally {
    loading.value = false
  }
}

const handleSearch = () => { currentPage.value = 1; loadData() }
const handleReset = () => { searchForm.keyword = ''; handleSearch() }
const handlePageChange = (page) => { currentPage.value = page; loadData() }

const openAddModal = () => {
  isEdit.value = false
  Object.assign(formData, { id: null, name: '', phone: '', password: '', relation: '', userId: null, gender: null, age: null, idCard: '', address: '', loginEnabled: 1 })
  modalVisible.value = true
}

const openEditModal = (row) => {
  isEdit.value = true
  Object.assign(formData, { ...row, password: '' })
  modalVisible.value = true
}

const handleSubmit = async () => {
  if (!formData.name) { ElMessage.warning('请输入姓名'); return }
  if (!formData.phone) { ElMessage.warning('请输入手机号'); return }
  try {
    if (isEdit.value) {
      await request.put(`/family-member/${formData.id}`, formData)
      ElMessage.success('更新成功')
    } else {
      await request.post('/family-member', formData)
      ElMessage.success('添加成功')
    }
    modalVisible.value = false
    loadData()
  } catch (e) {
    ElMessage.error(e.message || '操作失败')
  }
}

const handleStatusChange = async (row) => {
  const newStatus = row.loginEnabled === 1 ? 0 : 1
  const statusText = newStatus === 1 ? '启用' : '禁用'
  try {
    await ElMessageBox.confirm(`确认${statusText}家属 ${row.name}？`, '状态变更', { type: 'warning' })
    await request.put(`/family-member/${row.id}`, { loginEnabled: newStatus })
    ElMessage.success(`已${statusText}`)
    loadData()
  } catch (e) { if (e !== 'cancel') ElMessage.error(e.message || '操作失败') }
}

const handleDelete = async (row) => {
  try {
    await ElMessageBox.confirm(`确认删除家属 ${row.name}？`, '删除确认', { type: 'warning' })
    await request.delete(`/family-member/${row.id}`)
    ElMessage.success('删除成功')
    loadData()
  } catch (e) { if (e !== 'cancel') ElMessage.error(e.message || '删除失败') }
}

onMounted(() => { loadData() })
</script>

<template>
  <div class="family-list-container">
    <div class="page-header">
      <h1>家属管理</h1>
      <p>管理患者家属信息</p>
    </div>
    <div class="search-bar">
      <el-input v-model="searchForm.keyword" placeholder="搜索姓名/手机号" class="search-input" @keyup.enter="handleSearch" />
      <el-button type="primary" @click="handleSearch">搜索</el-button>
      <el-button @click="handleReset">重置</el-button>
      <el-button type="primary" @click="openAddModal">新增家属</el-button>
    </div>
    <el-table :data="tableData" v-loading="loading" border stripe>
      <el-table-column prop="id" label="ID" width="80" />
      <el-table-column prop="name" label="姓名" width="120" />
      <el-table-column prop="phone" label="手机号" width="130" />
      <el-table-column prop="relation" label="与患者关系" width="120" />
      <el-table-column prop="gender" label="性别" width="80">
        <template #default="{ row }">{{ row.gender === 1 ? '男' : row.gender === 0 ? '女' : '-' }}</template>
      </el-table-column>
      <el-table-column prop="age" label="年龄" width="80" />
      <el-table-column prop="loginEnabled" label="状态" width="100">
        <template #default="{ row }">
          <el-switch :model-value="row.loginEnabled === 1" @change="handleStatusChange(row)" />
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
    <el-pagination v-model:current-page="currentPage" v-model:page-size="pageSize" :total="total" @current-change="handlePageChange" layout="total, prev, pager, next, jumper" style="margin-top: 20px; text-align: right" />

    <el-dialog v-model="modalVisible" :title="isEdit ? '编辑家属' : '新增家属'" width="500px">
      <el-form :model="formData" label-width="100px">
        <el-form-item label="姓名"><el-input v-model="formData.name" /></el-form-item>
        <el-form-item label="手机号"><el-input v-model="formData.phone" /></el-form-item>
        <el-form-item v-if="!isEdit" label="密码"><el-input v-model="formData.password" type="password" show-password /></el-form-item>
        <el-form-item label="与患者关系"><el-input v-model="formData.relation" /></el-form-item>
        <el-form-item label="性别">
          <el-select v-model="formData.gender" style="width: 100%;">
            <el-option label="男" :value="1" /><el-option label="女" :value="0" />
          </el-select>
        </el-form-item>
        <el-form-item label="年龄"><el-input v-model="formData.age" type="number" /></el-form-item>
        <el-form-item label="身份证号"><el-input v-model="formData.idCard" maxlength="18" /></el-form-item>
        <el-form-item label="地址"><el-input v-model="formData.address" /></el-form-item>
        <el-form-item label="状态">
          <el-switch v-model="formData.loginEnabled" :active-value="1" :inactive-value="0" />
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
.family-list-container { background: #fff; border-radius: 12px; padding: 20px; box-shadow: 0 2px 8px rgba(0,0,0,0.05); }
.page-header { margin-bottom: 20px; h1 { font-size: 20px; font-weight: bold; margin: 0 0 4px; } p { color: #666; font-size: 14px; margin: 0; } }
.search-bar { display: flex; gap: 12px; margin-bottom: 20px; .search-input { width: 300px; } }
</style>
