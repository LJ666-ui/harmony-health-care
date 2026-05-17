<script setup>
import { ref, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import categoryApi from '@/api/category'

const categoryList = ref([])
const loading = ref(false)
const addVisible = ref(false)
const editVisible = ref(false)
const formData = ref({ name: '', description: '' })
const editingId = ref(null)

const loadCategories = async () => {
  loading.value = true
  try {
    const res = await categoryApi.getList()
    categoryList.value = res.records || res || []
  } catch (error) {
    ElMessage.error('加载分类列表失败')
  } finally {
    loading.value = false
  }
}

const handleAdd = () => {
  formData.value = { name: '', description: '' }
  addVisible.value = true
}

const handleEdit = (row) => {
  formData.value = { name: row.name, description: row.description || '' }
  editingId.value = row.id
  editVisible.value = true
}

const handleDelete = async (row) => {
  try {
    await ElMessageBox.confirm(`确定删除分类 "${row.name}" 吗？`, '提示', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })
    await categoryApi.delete(row.id)
    ElMessage.success('删除成功')
    loadCategories()
  } catch (error) {
    if (error !== 'cancel') {
      ElMessage.error(error.message || '删除失败')
    }
  }
}

const submitAdd = async () => {
  if (!formData.value.name) {
    ElMessage.warning('请输入分类名称')
    return
  }
  try {
    await categoryApi.add(formData.value)
    ElMessage.success('添加成功')
    addVisible.value = false
    loadCategories()
  } catch (error) {
    ElMessage.error(error.message || '添加失败')
  }
}

const submitEdit = async () => {
  if (!formData.value.name) {
    ElMessage.warning('请输入分类名称')
    return
  }
  try {
    await categoryApi.update(editingId.value, formData.value)
    ElMessage.success('更新成功')
    editVisible.value = false
    loadCategories()
  } catch (error) {
    ElMessage.error(error.message || '更新失败')
  }
}

onMounted(() => {
  loadCategories()
})
</script>

<template>
  <div class="category-list">
    <div class="page-header">
      <h3>文章分类管理</h3>
      <el-button type="success" @click="handleAdd">添加分类</el-button>
    </div>

    <el-table :data="categoryList" :loading="loading" border>
      <el-table-column prop="id" label="ID" width="80" />
      <el-table-column prop="name" label="分类名称" />
      <el-table-column prop="description" label="描述" />
      <el-table-column label="操作" width="200">
        <template #default="scope">
          <el-button size="small" @click="handleEdit(scope.row)">编辑</el-button>
          <el-button size="small" type="danger" @click="handleDelete(scope.row)">删除</el-button>
        </template>
      </el-table-column>
    </el-table>

    <el-dialog v-model="addVisible" title="添加分类" width="400px">
      <el-form :model="formData" label-width="80px">
        <el-form-item label="名称"><el-input v-model="formData.name" /></el-form-item>
        <el-form-item label="描述"><el-input v-model="formData.description" type="textarea" :rows="3" /></el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="addVisible = false">取消</el-button>
        <el-button type="primary" @click="submitAdd">保存</el-button>
      </template>
    </el-dialog>

    <el-dialog v-model="editVisible" title="编辑分类" width="400px">
      <el-form :model="formData" label-width="80px">
        <el-form-item label="名称"><el-input v-model="formData.name" /></el-form-item>
        <el-form-item label="描述"><el-input v-model="formData.description" type="textarea" :rows="3" /></el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="editVisible = false">取消</el-button>
        <el-button type="primary" @click="submitEdit">保存</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<style lang="scss" scoped>
.category-list { background: #fff; border-radius: 12px; padding: 20px; box-shadow: 0 2px 8px rgba(0,0,0,0.05); }
.page-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; h3 { margin: 0; font-size: 18px; } }
</style>
