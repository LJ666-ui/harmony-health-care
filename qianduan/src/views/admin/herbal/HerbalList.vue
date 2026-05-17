<script setup>
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import herbalApi from '@/api/herbal'

const herbalList = ref([])
const total = ref(0)
const currentPage = ref(1)
const pageSize = ref(10)
const searchForm = reactive({ name: '', category: '' })
const loading = ref(false)
const detailVisible = ref(false)
const detailData = ref(null)
const formVisible = ref(false)
const isEdit = ref(false)
const categories = ref([])

const formData = reactive({
  id: null,
  name: '',
  pinyin: '',
  alias: '',
  category: '',
  nature: '',
  taste: '',
  meridian: '',
  efficacySummary: '',
  efficacyDetail: '',
  indication: '',
  usageDosage: '',
  contraindication: '',
  toxicity: '',
  processingMethod: '',
  sourceOrigin: '',
  appearance: '',
  imageUrl: '',
  model3dUrl: '',
  classicPrescription: '',
  modernResearch: '',
  referenceSource: ''
})

const loadHerbals = async () => {
  loading.value = true
  try {
    const res = await herbalApi.getList({
      page: currentPage.value,
      size: pageSize.value,
      name: searchForm.name,
      keyword: searchForm.name
    })
    herbalList.value = res.records || res.list || res || []
    total.value = res.total || 0
  } catch (error) {
    ElMessage.error('加载药材列表失败')
  } finally {
    loading.value = false
  }
}

const loadCategories = async () => {
  try {
    categories.value = await herbalApi.getCategories()
  } catch (e) {}
}

const handleSearch = () => { currentPage.value = 1; loadHerbals() }
const handleReset = () => { searchForm.name = ''; searchForm.category = ''; handleSearch() }
const handlePageChange = (page) => { currentPage.value = page; loadHerbals() }

const handleView = (row) => {
  detailData.value = row
  detailVisible.value = true
}

const handleAdd = () => {
  isEdit.value = false
  Object.assign(formData, {
    id: null, name: '', pinyin: '', alias: '', category: '', nature: '', taste: '', meridian: '',
    efficacySummary: '', efficacyDetail: '', indication: '', usageDosage: '', contraindication: '',
    toxicity: '', processingMethod: '', sourceOrigin: '', appearance: '', imageUrl: '', model3dUrl: '',
    classicPrescription: '', modernResearch: '', referenceSource: ''
  })
  formVisible.value = true
}

const handleEdit = (row) => {
  isEdit.value = true
  Object.assign(formData, row)
  formVisible.value = true
}

const handleDelete = async (row) => {
  try {
    await ElMessageBox.confirm(`确定删除药材 "${row.name}" 吗？`, '提示', {
      confirmButtonText: '确定', cancelButtonText: '取消', type: 'warning'
    })
    await herbalApi.delete(row.id)
    ElMessage.success('删除成功')
    loadHerbals()
  } catch (error) {
    if (error !== 'cancel') ElMessage.error(error.message || '删除失败')
  }
}

const handleSubmit = async () => {
  if (!formData.name) { ElMessage.warning('请输入药材名称'); return }
  try {
    if (isEdit.value) {
      await herbalApi.update(formData.id, formData)
      ElMessage.success('修改成功')
    } else {
      await herbalApi.add(formData)
      ElMessage.success('添加成功')
    }
    formVisible.value = false
    loadHerbals()
  } catch (error) {
    ElMessage.error(error.message || '操作失败')
  }
}

onMounted(() => {
  loadHerbals()
  loadCategories()
})
</script>

<template>
  <div class="herbal-list">
    <div class="search-bar">
      <el-input v-model="searchForm.name" placeholder="药材名称/拼音" class="search-input" @keyup.enter="handleSearch" />
      <el-select v-model="searchForm.category" placeholder="分类" class="search-input" @change="handleSearch">
        <el-option label="全部" :value="''" />
        <el-option v-for="cat in categories" :key="cat" :label="cat" :value="cat" />
      </el-select>
      <el-button type="primary" @click="handleSearch">搜索</el-button>
      <el-button @click="handleReset">重置</el-button>
      <el-button type="success" @click="handleAdd">添加药材</el-button>
    </div>

    <el-table :data="herbalList" v-loading="loading" border stripe>
      <el-table-column prop="id" label="ID" width="70" />
      <el-table-column prop="name" label="药材名称" width="120" />
      <el-table-column prop="pinyin" label="拼音" width="130" />
      <el-table-column prop="category" label="分类" width="100" />
      <el-table-column prop="nature" label="药性" width="80" />
      <el-table-column prop="taste" label="味" width="80" />
      <el-table-column prop="meridian" label="归经" width="100" />
      <el-table-column prop="efficacySummary" label="功效概述" min-width="150" show-overflow-tooltip />
      <el-table-column prop="viewCount" label="浏览量" width="80" />
      <el-table-column prop="collectCount" label="收藏量" width="80" />
      <el-table-column label="操作" width="180" fixed="right">
        <template #default="scope">
          <el-button size="small" @click="handleView(scope.row)">查看</el-button>
          <el-button size="small" type="primary" @click="handleEdit(scope.row)">编辑</el-button>
          <el-button size="small" type="danger" @click="handleDelete(scope.row)">删除</el-button>
        </template>
      </el-table-column>
    </el-table>

    <el-pagination v-model:current-page="currentPage" v-model:page-size="pageSize" :total="total" @current-change="handlePageChange" layout="total, prev, pager, next, jumper" style="margin-top: 20px; text-align: right" />

    <el-dialog v-model="detailVisible" title="药材详情" width="700px">
      <div v-if="detailData">
        <el-descriptions :column="2" border>
          <el-descriptions-item label="名称">{{ detailData.name }}</el-descriptions-item>
          <el-descriptions-item label="拼音">{{ detailData.pinyin }}</el-descriptions-item>
          <el-descriptions-item label="别名">{{ detailData.alias }}</el-descriptions-item>
          <el-descriptions-item label="分类">{{ detailData.category }}</el-descriptions-item>
          <el-descriptions-item label="药性">{{ detailData.nature }}</el-descriptions-item>
          <el-descriptions-item label="味">{{ detailData.taste }}</el-descriptions-item>
          <el-descriptions-item label="归经" :span="2">{{ detailData.meridian }}</el-descriptions-item>
          <el-descriptions-item label="功效概述" :span="2">{{ detailData.efficacySummary }}</el-descriptions-item>
          <el-descriptions-item label="详细功效" :span="2">{{ detailData.efficacyDetail }}</el-descriptions-item>
          <el-descriptions-item label="主治" :span="2">{{ detailData.indication }}</el-descriptions-item>
          <el-descriptions-item label="用法用量" :span="2">{{ detailData.usageDosage }}</el-descriptions-item>
          <el-descriptions-item label="禁忌" :span="2">{{ detailData.contraindication }}</el-descriptions-item>
          <el-descriptions-item label="毒性">{{ detailData.toxicity }}</el-descriptions-item>
          <el-descriptions-item label="炮制方法" :span="2">{{ detailData.processingMethod }}</el-descriptions-item>
          <el-descriptions-item label="来源" :span="2">{{ detailData.sourceOrigin }}</el-descriptions-item>
          <el-descriptions-item label="外观" :span="2">{{ detailData.appearance }}</el-descriptions-item>
          <el-descriptions-item label="经典方剂" :span="2">{{ detailData.classicPrescription }}</el-descriptions-item>
          <el-descriptions-item label="现代研究" :span="2">{{ detailData.modernResearch }}</el-descriptions-item>
          <el-descriptions-item label="参考文献" :span="2">{{ detailData.referenceSource }}</el-descriptions-item>
          <el-descriptions-item label="浏览量">{{ detailData.viewCount }}</el-descriptions-item>
          <el-descriptions-item label="收藏量">{{ detailData.collectCount }}</el-descriptions-item>
        </el-descriptions>
      </div>
      <template #footer><el-button @click="detailVisible = false">关闭</el-button></template>
    </el-dialog>

    <el-dialog v-model="formVisible" :title="isEdit ? '编辑药材' : '添加药材'" width="700px">
      <el-form :model="formData" label-width="90px">
        <el-row :gutter="16">
          <el-col :span="12">
            <el-form-item label="名称"><el-input v-model="formData.name" /></el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="拼音"><el-input v-model="formData.pinyin" /></el-form-item>
          </el-col>
        </el-row>
        <el-row :gutter="16">
          <el-col :span="12">
            <el-form-item label="别名"><el-input v-model="formData.alias" /></el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="分类"><el-input v-model="formData.category" /></el-form-item>
          </el-col>
        </el-row>
        <el-row :gutter="16">
          <el-col :span="8">
            <el-form-item label="药性"><el-input v-model="formData.nature" placeholder="寒/热/温/凉/平" /></el-form-item>
          </el-col>
          <el-col :span="8">
            <el-form-item label="味"><el-input v-model="formData.taste" placeholder="甘苦辛酸咸涩" /></el-form-item>
          </el-col>
          <el-col :span="8">
            <el-form-item label="毒性"><el-input v-model="formData.toxicity" placeholder="无毒/小毒/有毒/大毒" /></el-form-item>
          </el-col>
        </el-row>
        <el-form-item label="归经"><el-input v-model="formData.meridian" /></el-form-item>
        <el-form-item label="功效概述"><el-input v-model="formData.efficacySummary" /></el-form-item>
        <el-form-item label="详细功效"><el-input v-model="formData.efficacyDetail" type="textarea" :rows="3" /></el-form-item>
        <el-form-item label="主治"><el-input v-model="formData.indication" type="textarea" :rows="2" /></el-form-item>
        <el-form-item label="用法用量"><el-input v-model="formData.usageDosage" type="textarea" :rows="2" /></el-form-item>
        <el-form-item label="禁忌"><el-input v-model="formData.contraindication" type="textarea" :rows="2" /></el-form-item>
        <el-form-item label="炮制方法"><el-input v-model="formData.processingMethod" type="textarea" :rows="2" /></el-form-item>
        <el-form-item label="来源"><el-input v-model="formData.sourceOrigin" /></el-form-item>
        <el-form-item label="外观"><el-input v-model="formData.appearance" type="textarea" :rows="2" /></el-form-item>
        <el-form-item label="图片URL"><el-input v-model="formData.imageUrl" /></el-form-item>
        <el-form-item label="经典方剂"><el-input v-model="formData.classicPrescription" type="textarea" :rows="2" /></el-form-item>
        <el-form-item label="现代研究"><el-input v-model="formData.modernResearch" type="textarea" :rows="2" /></el-form-item>
        <el-form-item label="参考文献"><el-input v-model="formData.referenceSource" /></el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="formVisible = false">取消</el-button>
        <el-button type="primary" @click="handleSubmit">保存</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<style lang="scss" scoped>
.herbal-list { background: #fff; border-radius: 12px; padding: 20px; box-shadow: 0 2px 8px rgba(0,0,0,0.05); }
.search-bar { display: flex; gap: 12px; margin-bottom: 20px; flex-wrap: wrap; .search-input { width: 200px; } }
</style>
