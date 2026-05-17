<script setup>
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import medicineApi from '@/api/medicine'

const medicineList = ref([])
const searchForm = ref({ name: '', category: '' })
const loading = ref(false)
const detailVisible = ref(false)
const detailData = ref(null)
const formVisible = ref(false)
const isEdit = ref(false)

const formData = reactive({
  id: null,
  name: '',
  category: '',
  categoryCode: '',
  indication: '',
  usageDesc: '',
  taboo: '',
  source: '',
  description: ''
})

const loadMedicines = async () => {
  loading.value = true
  try {
    const res = await medicineApi.getList(searchForm.value)
    medicineList.value = res.records || res || []
  } catch (error) {
    ElMessage.error('加载药品列表失败')
  } finally {
    loading.value = false
  }
}

const handleView = (row) => {
  detailData.value = row
  detailVisible.value = true
}

const handleAdd = () => {
  isEdit.value = false
  Object.assign(formData, { id: null, name: '', category: '', categoryCode: '', indication: '', usageDesc: '', taboo: '', source: '', description: '' })
  formVisible.value = true
}

const handleEdit = (row) => {
  isEdit.value = true
  Object.assign(formData, row)
  formVisible.value = true
}

const handleDelete = async (row) => {
  try {
    await ElMessageBox.confirm(`确定删除药品 "${row.name}" 吗？`, '提示', {
      confirmButtonText: '确定', cancelButtonText: '取消', type: 'warning'
    })
    await medicineApi.delete(row.id)
    ElMessage.success('删除成功')
    loadMedicines()
  } catch (error) {
    if (error !== 'cancel') {
      ElMessage.error(error.message || '删除失败')
    }
  }
}

const handleSubmit = async () => {
  if (!formData.name) {
    ElMessage.warning('请输入药品名称')
    return
  }
  try {
    if (isEdit.value) {
      await medicineApi.update(formData.id, formData)
      ElMessage.success('修改成功')
    } else {
      await medicineApi.add(formData)
      ElMessage.success('添加成功')
    }
    formVisible.value = false
    loadMedicines()
  } catch (error) {
    ElMessage.error(error.message || '操作失败')
  }
}

onMounted(() => {
  loadMedicines()
})
</script>

<template>
  <div class="medicine-list">
    <div class="search-bar">
      <el-input v-model="searchForm.name" placeholder="药品名称" class="search-input" @keyup.enter="loadMedicines" />
      <el-input v-model="searchForm.category" placeholder="分类" class="search-input" @keyup.enter="loadMedicines" />
      <el-button type="primary" @click="loadMedicines">搜索</el-button>
      <el-button type="success" @click="handleAdd">添加药品</el-button>
    </div>

    <el-table :data="medicineList" :loading="loading" border>
      <el-table-column prop="id" label="ID" width="80" />
      <el-table-column prop="name" label="药品名称" width="150" />
      <el-table-column prop="category" label="分类" width="100" />
      <el-table-column prop="indication" label="适应症" width="200" />
      <el-table-column prop="usageDesc" label="用法用量" width="150" />
      <el-table-column prop="taboo" label="禁忌" width="150" />
      <el-table-column label="操作" width="200">
        <template #default="scope">
          <el-button size="small" @click="handleView(scope.row)">查看</el-button>
          <el-button size="small" @click="handleEdit(scope.row)">编辑</el-button>
          <el-button size="small" type="danger" @click="handleDelete(scope.row)">删除</el-button>
        </template>
      </el-table-column>
    </el-table>

    <el-dialog v-model="detailVisible" title="药品详情" width="600px">
      <div v-if="detailData">
        <el-descriptions :column="1" border>
          <el-descriptions-item label="名称">{{ detailData.name }}</el-descriptions-item>
          <el-descriptions-item label="分类">{{ detailData.category }}</el-descriptions-item>
          <el-descriptions-item label="适应症">{{ detailData.indication }}</el-descriptions-item>
          <el-descriptions-item label="用法用量">{{ detailData.usageDesc }}</el-descriptions-item>
          <el-descriptions-item label="禁忌">{{ detailData.taboo }}</el-descriptions-item>
          <el-descriptions-item label="来源">{{ detailData.source }}</el-descriptions-item>
        </el-descriptions>
      </div>
      <template #footer><el-button @click="detailVisible = false">关闭</el-button></template>
    </el-dialog>

    <el-dialog v-model="formVisible" :title="isEdit ? '编辑药品' : '添加药品'" width="600px">
      <el-form :model="formData" label-width="80px">
        <el-form-item label="名称"><el-input v-model="formData.name" /></el-form-item>
        <el-form-item label="分类"><el-input v-model="formData.category" /></el-form-item>
        <el-form-item label="分类编码"><el-input v-model="formData.categoryCode" /></el-form-item>
        <el-form-item label="适应症"><el-input v-model="formData.indication" type="textarea" :rows="3" /></el-form-item>
        <el-form-item label="用法用量"><el-input v-model="formData.usageDesc" /></el-form-item>
        <el-form-item label="禁忌"><el-input v-model="formData.taboo" type="textarea" :rows="3" /></el-form-item>
        <el-form-item label="来源"><el-input v-model="formData.source" /></el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="formVisible = false">取消</el-button>
        <el-button type="primary" @click="handleSubmit">保存</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<style lang="scss" scoped>
.medicine-list { background: #fff; border-radius: 12px; padding: 20px; box-shadow: 0 2px 8px rgba(0,0,0,0.05); }
.search-bar { display: flex; gap: 12px; margin-bottom: 20px; flex-wrap: wrap; .search-input { width: 200px; } }
</style>
