<script setup>
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import rehabApi from '@/api/rehab'

const planList = ref([])
const searchForm = ref({ disease: '' })
const loading = ref(false)
const detailVisible = ref(false)
const detailData = ref(null)
const formVisible = ref(false)
const isEdit = ref(false)

const formData = reactive({
  id: null,
  disease: '',
  title: '',
  content: '',
  source: '',
  startDate: '',
  endDate: '',
  planStatus: 0
})

const statusLabel = (val) => ['进行中', '已完成', '已取消'][val] || '未知'
const statusTagType = (val) => ['primary', 'success', 'info'][val] || 'info'

const loadPlans = async () => {
  loading.value = true
  try {
    const res = await rehabApi.getList({ userId: 1, disease: searchForm.value.disease })
    planList.value = res.records || res || []
  } catch (error) {
    ElMessage.error('加载康复计划失败')
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
  Object.assign(formData, { id: null, disease: '', title: '', content: '', source: '', startDate: '', endDate: '', planStatus: 0 })
  formVisible.value = true
}

const handleEdit = (row) => {
  isEdit.value = true
  Object.assign(formData, row)
  formVisible.value = true
}

const handleDelete = async (row) => {
  try {
    await ElMessageBox.confirm('确定删除该康复计划吗？', '提示', {
      confirmButtonText: '确定', cancelButtonText: '取消', type: 'warning'
    })
    await rehabApi.delete(row.id)
    ElMessage.success('删除成功')
    loadPlans()
  } catch (error) {
    if (error !== 'cancel') {
      ElMessage.error(error.message || '删除失败')
    }
  }
}

const handleSubmit = async () => {
  if (!formData.title) {
    ElMessage.warning('请输入计划标题')
    return
  }
  try {
    if (isEdit.value) {
      await rehabApi.update(formData.id, formData)
      ElMessage.success('修改成功')
    } else {
      await rehabApi.add(formData)
      ElMessage.success('添加成功')
    }
    formVisible.value = false
    loadPlans()
  } catch (error) {
    ElMessage.error(error.message || '操作失败')
  }
}

onMounted(() => {
  loadPlans()
})
</script>

<template>
  <div class="rehab-plan">
    <div class="search-bar">
      <el-input v-model="searchForm.disease" placeholder="疾病名称" class="search-input" @keyup.enter="loadPlans" />
      <el-button type="primary" @click="loadPlans">搜索</el-button>
      <el-button type="success" @click="handleAdd">添加计划</el-button>
    </div>

    <el-table :data="planList" :loading="loading" border>
      <el-table-column prop="id" label="ID" width="80" />
      <el-table-column prop="disease" label="疾病" width="120" />
      <el-table-column prop="title" label="标题" width="150" />
      <el-table-column prop="content" label="内容" />
      <el-table-column prop="source" label="来源" width="120" />
      <el-table-column prop="startDate" label="开始日期" width="120" />
      <el-table-column prop="endDate" label="结束日期" width="120" />
      <el-table-column prop="planStatus" label="状态" width="100">
        <template #default="scope"><el-tag :type="statusTagType(scope.row.planStatus)">{{ statusLabel(scope.row.planStatus) }}</el-tag></template>
      </el-table-column>
      <el-table-column label="操作" width="200">
        <template #default="scope">
          <el-button size="small" @click="handleView(scope.row)">查看</el-button>
          <el-button size="small" @click="handleEdit(scope.row)">编辑</el-button>
          <el-button size="small" type="danger" @click="handleDelete(scope.row)">删除</el-button>
        </template>
      </el-table-column>
    </el-table>

    <el-dialog v-model="detailVisible" title="康复计划详情" width="600px">
      <div v-if="detailData">
        <el-descriptions :column="1" border>
          <el-descriptions-item label="疾病">{{ detailData.disease }}</el-descriptions-item>
          <el-descriptions-item label="标题">{{ detailData.title }}</el-descriptions-item>
          <el-descriptions-item label="内容">{{ detailData.content }}</el-descriptions-item>
          <el-descriptions-item label="来源">{{ detailData.source }}</el-descriptions-item>
          <el-descriptions-item label="开始日期">{{ detailData.startDate }}</el-descriptions-item>
          <el-descriptions-item label="结束日期">{{ detailData.endDate }}</el-descriptions-item>
          <el-descriptions-item label="状态"><el-tag :type="statusTagType(detailData.planStatus)">{{ statusLabel(detailData.planStatus) }}</el-tag></el-descriptions-item>
        </el-descriptions>
      </div>
      <template #footer><el-button @click="detailVisible = false">关闭</el-button></template>
    </el-dialog>

    <el-dialog v-model="formVisible" :title="isEdit ? '编辑康复计划' : '添加康复计划'" width="600px">
      <el-form :model="formData" label-width="80px">
        <el-form-item label="疾病"><el-input v-model="formData.disease" /></el-form-item>
        <el-form-item label="标题"><el-input v-model="formData.title" /></el-form-item>
        <el-form-item label="内容"><el-input v-model="formData.content" type="textarea" :rows="4" /></el-form-item>
        <el-form-item label="来源"><el-input v-model="formData.source" /></el-form-item>
        <el-form-item label="开始日期"><el-input v-model="formData.startDate" placeholder="如：2024-01-01" /></el-form-item>
        <el-form-item label="结束日期"><el-input v-model="formData.endDate" placeholder="如：2024-06-01" /></el-form-item>
        <el-form-item label="状态">
          <el-select v-model="formData.planStatus">
            <el-option :value="0" label="进行中" />
            <el-option :value="1" label="已完成" />
            <el-option :value="2" label="已取消" />
          </el-select>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="formVisible = false">取消</el-button>
        <el-button type="primary" @click="handleSubmit">保存</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<style lang="scss" scoped>
.rehab-plan { background: #fff; border-radius: 12px; padding: 20px; box-shadow: 0 2px 8px rgba(0,0,0,0.05); }
.search-bar { display: flex; gap: 12px; margin-bottom: 20px; flex-wrap: wrap; .search-input { width: 200px; } }
</style>
