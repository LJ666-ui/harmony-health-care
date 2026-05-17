<script setup>
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import doctorApi from '@/api/doctor'
import hospitalApi from '@/api/hospital'

const tableData = ref([])
const departments = ref([])
const hospitals = ref([])
const detailVisible = ref(false)
const detailData = ref(null)
const formVisible = ref(false)
const isEdit = ref(false)
const loading = ref(false)

const searchForm = reactive({ keyword: '', departmentId: null })
const pagination = reactive({ currentPage: 1, pageSize: 10, total: 0 })

const formData = reactive({
  id: null,
  name: '',
  hospital: '',
  department: '',
  title: '',
  specialty: '',
  phone: '',
  rating: 0,
  description: '',
  status: 1
})

const loadData = async () => {
  loading.value = true
  try {
    const data = await doctorApi.getList({
      page: pagination.currentPage,
      size: pagination.pageSize,
      keyword: searchForm.keyword,
      departmentId: searchForm.departmentId
    })
    tableData.value = data.list || data.records || []
    pagination.total = data.total || 0
  } catch (error) {
    ElMessage.error('加载医生列表失败')
  } finally {
    loading.value = false
  }
}

const loadDepartments = async () => {
  departments.value = [
    { id: 1, deptName: '心内科' },
    { id: 2, deptName: '神经内科' },
    { id: 3, deptName: '消化内科' },
    { id: 4, deptName: '中医内科' },
    { id: 5, deptName: '康复医学科' }
  ]
}

const loadHospitals = async () => {
  try {
    const res = await hospitalApi.getPage({ page: 1, size: 200 })
    hospitals.value = res.records || res.list || res || []
  } catch (e) { console.error(e) }
}

const handleSearch = () => { pagination.currentPage = 1; loadData() }
const handleReset = () => { searchForm.keyword = ''; searchForm.departmentId = null; handleSearch() }
const handlePageChange = (page) => { pagination.currentPage = page; loadData() }

const handleAdd = () => {
  isEdit.value = false
  loadHospitals()
  Object.assign(formData, { id: null, name: '', hospital: '', department: '', title: '', specialty: '', phone: '', rating: 0, description: '', status: 1 })
  formVisible.value = true
}

const handleEdit = (row) => {
  isEdit.value = true
  loadHospitals()
  Object.assign(formData, {
    id: row.id,
    name: row.name || '',
    hospital: row.hospital || '',
    department: row.departmentName || '',
    title: row.title || '',
    specialty: row.specialty || '',
    phone: row.phone || '',
    rating: row.score || 0,
    description: row.introduction || '',
    status: row.status ?? 1
  })
  formVisible.value = true
}

const handleView = (row) => {
  detailData.value = row
  detailVisible.value = true
}

const handleDelete = async (row) => {
  try {
    await ElMessageBox.confirm(`确定删除医生 "${row.name}" 吗？`, '提示', {
      confirmButtonText: '确定', cancelButtonText: '取消', type: 'warning'
    })
    await doctorApi.delete(row.id)
    ElMessage.success('删除成功')
    loadData()
  } catch (error) {
    if (error !== 'cancel') {
      ElMessage.error(error.message || '删除失败')
    }
  }
}

const handleSubmit = async () => {
  if (!formData.name || !formData.hospital || !formData.department) {
    ElMessage.warning('请填写必填项（姓名、医院、科室）')
    return
  }
  try {
    if (isEdit.value) {
      await doctorApi.update(formData.id, formData)
      ElMessage.success('修改成功')
    } else {
      await doctorApi.create(formData)
      ElMessage.success('新增成功')
    }
    formVisible.value = false
    loadData()
  } catch (error) {
    ElMessage.error(error.message || '操作失败')
  }
}

onMounted(() => {
  loadData()
  loadDepartments()
  loadHospitals()
})
</script>

<template>
  <div class="doctor-list-container">
    <div class="page-header">
      <h1>医生管理</h1>
      <p>管理医生信息</p>
    </div>

    <div class="search-bar">
      <el-input v-model="searchForm.keyword" placeholder="搜索医生姓名" class="search-input" />
      <el-select v-model="searchForm.departmentId" placeholder="科室">
        <el-option :value="null" label="全部" />
        <el-option v-for="dept in departments" :key="dept.id" :value="dept.deptName" :label="dept.deptName" />
      </el-select>
      <el-button type="primary" @click="handleSearch">搜索</el-button>
      <el-button @click="handleReset">重置</el-button>
    </div>

    <div class="table-toolbar">
      <el-button type="primary" @click="handleAdd">新增医生</el-button>
    </div>

    <el-table :data="tableData" border>
      <el-table-column prop="id" label="ID" width="80" />
      <el-table-column prop="name" label="医生姓名" width="120" />
      <el-table-column prop="hospitalName" label="所属医院" width="150" />
      <el-table-column prop="departmentName" label="科室" width="120" />
      <el-table-column prop="title" label="职称" width="100" />
      <el-table-column prop="specialty" label="专长" width="150" />
      <el-table-column prop="phone" label="联系电话" width="130" />
      <el-table-column prop="score" label="评分" width="100">
        <template #default="scope"><span class="score">{{ scope.row.score }}</span></template>
      </el-table-column>
      <el-table-column label="操作" width="180">
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
    />

    <el-dialog v-model="detailVisible" title="医生详情" width="600px">
      <div v-if="detailData" class="doctor-detail">
        <el-descriptions :column="1" border>
          <el-descriptions-item label="姓名">{{ detailData.name }}</el-descriptions-item>
          <el-descriptions-item label="医院">{{ detailData.hospitalName }}</el-descriptions-item>
          <el-descriptions-item label="科室">{{ detailData.departmentName }}</el-descriptions-item>
          <el-descriptions-item label="职称">{{ detailData.title }}</el-descriptions-item>
          <el-descriptions-item label="专长">{{ detailData.specialty }}</el-descriptions-item>
          <el-descriptions-item label="联系电话">{{ detailData.phone }}</el-descriptions-item>
          <el-descriptions-item label="评分">{{ detailData.score }}</el-descriptions-item>
          <el-descriptions-item label="简介">{{ detailData.introduction }}</el-descriptions-item>
        </el-descriptions>
      </div>
      <template #footer><el-button @click="detailVisible = false">关闭</el-button></template>
    </el-dialog>

    <el-dialog v-model="formVisible" :title="isEdit ? '编辑医生' : '新增医生'" width="600px">
      <el-form :model="formData" label-width="100px">
        <el-form-item label="姓名"><el-input v-model="formData.name" placeholder="请输入医生姓名" /></el-form-item>
        <el-form-item label="医院"><el-select v-model="formData.hospital" placeholder="请选择医院" filterable style="width: 100%;"><el-option v-for="h in hospitals" :key="h.id" :label="h.name" :value="h.id" /></el-select></el-form-item>
        <el-form-item label="科室"><el-input v-model="formData.department" placeholder="请输入科室名称" /></el-form-item>
        <el-form-item label="职称"><el-input v-model="formData.title" placeholder="请输入职称" /></el-form-item>
        <el-form-item label="专长"><el-input v-model="formData.specialty" placeholder="请输入专长" /></el-form-item>
        <el-form-item label="联系电话"><el-input v-model="formData.phone" placeholder="请输入联系电话" /></el-form-item>
        <el-form-item label="评分"><el-input-number v-model="formData.rating" :min="0" :max="5" :step="0.1" /></el-form-item>
        <el-form-item label="简介"><el-input v-model="formData.description" type="textarea" placeholder="请输入医生简介" :rows="3" /></el-form-item>
        <el-form-item label="状态"><el-switch v-model="formData.status" :active-value="1" :inactive-value="0" /></el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="formVisible = false">取消</el-button>
        <el-button type="primary" @click="handleSubmit">{{ isEdit ? '保存修改' : '确认新增' }}</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<style lang="scss" scoped>
.doctor-list-container { padding: 20px; background: #fff; border-radius: 12px; box-shadow: 0 2px 8px rgba(0,0,0,0.05); }
.page-header { margin-bottom: 20px; h1 { font-size: 20px; font-weight: bold; margin: 0 0 4px; } p { color: #666; font-size: 14px; margin: 0; } }
.search-bar { display: flex; gap: 12px; margin-bottom: 20px; .search-input { width: 300px; } }
.table-toolbar { display: flex; gap: 12px; margin-bottom: 16px; }
.score { color: #f39c12; font-weight: bold; font-size: 16px; }
</style>
