<script setup>
import { ref, reactive, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import doctorApi from '@/api/doctor'
import { ElMessage } from 'element-plus'

const router = useRouter()

const loading = ref(false)
const doctorList = ref([])
const total = ref(0)
const currentPage = ref(1)
const pageSize = ref(12)
const detailVisible = ref(false)
const detailData = ref(null)

const searchForm = reactive({
  keyword: '',
  department: ''
})

const departments = ref([
  { label: '心内科', value: '心内科' },
  { label: '神经内科', value: '神经内科' },
  { label: '消化内科', value: '消化内科' },
  { label: '呼吸内科', value: '呼吸内科' },
  { label: '内分泌科', value: '内分泌科' },
  { label: '骨科', value: '骨科' },
  { label: '普外科', value: '普外科' },
  { label: '神经外科', value: '神经外科' },
  { label: '中医内科', value: '中医内科' },
  { label: '康复医学科', value: '康复医学科' },
  { label: '老年病科', value: '老年病科' },
  { label: '皮肤科', value: '皮肤科' },
  { label: '眼科', value: '眼科' },
  { label: '口腔科', value: '口腔科' }
])

const diseaseMap = {
  '高血压': ['心内科', '老年病科', '中医内科'],
  '糖尿病': ['内分泌科', '老年病科', '中医内科'],
  '冠心病': ['心内科', '老年病科'],
  '脑卒中': ['神经内科', '康复医学科'],
  '骨质疏松': ['骨科', '老年病科', '康复医学科'],
  '关节炎': ['骨科', '康复医学科', '中医内科'],
  '胃炎': ['消化内科', '中医内科'],
  '肺炎': ['呼吸内科', '老年病科'],
  '失眠': ['神经内科', '中医内科'],
  '颈椎病': ['骨科', '康复医学科', '中医内科'],
  '腰椎间盘突出': ['骨科', '康复医学科'],
  '皮肤病': ['皮肤科', '中医内科'],
  '白内障': ['眼科'],
  '牙周炎': ['口腔科']
}

const commonDiseases = ref(Object.keys(diseaseMap))
const selectedDisease = ref('')

const loadDoctors = async () => {
  loading.value = true
  try {
    const params = {
      page: currentPage.value,
      size: pageSize.value,
      keyword: searchForm.keyword,
      status: 1
    }
    if (searchForm.department) {
      params.departmentId = searchForm.department
    }
    const res = await doctorApi.getList(params)
    let list = res.records || res.list || []
    doctorList.value = list
    total.value = res.total || list.length
  } catch (e) {
    console.error('加载医生列表失败:', e)
    ElMessage.error('加载医生列表失败')
  } finally {
    loading.value = false
  }
}

const handleSearch = () => {
  currentPage.value = 1
  selectedDisease.value = ''
  loadDoctors()
}

const handleReset = () => {
  searchForm.keyword = ''
  searchForm.department = ''
  selectedDisease.value = ''
  currentPage.value = 1
  loadDoctors()
}

const handleDiseaseClick = (disease) => {
  selectedDisease.value = disease
  const depts = diseaseMap[disease]
  if (depts && depts.length > 0) {
    searchForm.department = depts[0]
  }
  searchForm.keyword = ''
  currentPage.value = 1
  loadDoctors()
}

const showDetail = (doctor) => {
  detailData.value = doctor
  detailVisible.value = true
}

const handlePageChange = (page) => {
  currentPage.value = page
  loadDoctors()
}

onMounted(() => { loadDoctors() })

function goToConsultation() {
  if (detailData.value) {
    router.push({
      path: '/user/consultation',
      query: { doctorId: detailData.value.id }
    })
  }
}

function quickConsultation(doctor) {
  router.push({
    path: '/user/consultation',
    query: { doctorId: doctor.id }
  })
}
</script>

<template>
  <div class="doctor-search-container">
    <el-card class="search-card">
      <h3 style="margin: 0 0 16px;">🔍 医生查询</h3>
      <div class="search-bar">
        <el-input v-model="searchForm.keyword" placeholder="搜索医生姓名/专长" class="search-input" @keyup.enter="handleSearch" clearable />
        <el-select v-model="searchForm.department" placeholder="选择科室" clearable style="width: 160px;">
          <el-option v-for="d in departments" :key="d.value" :label="d.label" :value="d.value" />
        </el-select>
        <el-button type="primary" @click="handleSearch">搜索</el-button>
        <el-button @click="handleReset">重置</el-button>
      </div>
      <div class="disease-tags">
        <span class="disease-label">常见疾病：</span>
        <el-tag v-for="d in commonDiseases" :key="d" :type="selectedDisease === d ? '' : 'info'" :effect="selectedDisease === d ? 'dark' : 'plain'" class="disease-tag" @click="handleDiseaseClick(d)" style="cursor: pointer;">{{ d }}</el-tag>
      </div>
    </el-card>

    <div class="doctor-grid" v-loading="loading">
      <el-empty v-if="doctorList.length === 0 && !loading" description="暂无医生信息" />
      <el-card v-for="doc in doctorList" :key="doc.id" class="doctor-card" shadow="hover">
        <div class="card-body-row" @click="showDetail(doc)">
          <div class="doctor-avatar">{{ (doc.name || '医').charAt(0) }}</div>
          <div class="doctor-info">
            <div class="doctor-name">{{ doc.name || '未知' }}</div>
            <div class="doctor-dept">{{ doc.departmentName || doc.department || '-' }}</div>
            <div class="doctor-title">{{ doc.title || '-' }}</div>
            <div class="doctor-specialty" v-if="doc.specialty">专长：{{ doc.specialty }}</div>
            <div class="doctor-hospital">{{ doc.hospitalName || doc.hospital || '-' }}</div>
          </div>
          <div class="doctor-score" v-if="doc.score">
            <span class="score-num">{{ doc.score }}</span>
            <span class="score-label">评分</span>
          </div>
        </div>
        <div class="card-actions">
          <el-button type="primary" size="small" @click.stop="$router.push('/user/appointment')">预约挂号</el-button>
          <el-button type="success" size="small" @click.stop="quickConsultation(doc)">💬 在线问诊</el-button>
        </div>
      </el-card>
    </div>

    <el-pagination v-model:current-page="currentPage" v-model:page-size="pageSize" :total="total" @current-change="handlePageChange" layout="total, prev, pager, next" style="margin-top: 20px; text-align: center;" />

    <el-dialog v-model="detailVisible" title="医生详情" width="550px">
      <div v-if="detailData" class="doctor-detail">
        <div class="detail-header">
          <div class="detail-avatar">{{ (detailData.name || '医').charAt(0) }}</div>
          <div>
            <h3 style="margin: 0;">{{ detailData.name || '未知' }}</h3>
            <p style="color: #666; margin: 4px 0 0;">{{ detailData.title || '-' }} · {{ detailData.departmentName || detailData.department || '-' }}</p>
          </div>
        </div>
        <el-descriptions :column="1" border style="margin-top: 16px;">
          <el-descriptions-item label="所属医院">{{ detailData.hospitalName || detailData.hospital || '-' }}</el-descriptions-item>
          <el-descriptions-item label="专长">{{ detailData.specialty || '-' }}</el-descriptions-item>
          <el-descriptions-item label="评分">{{ detailData.score || '-' }}</el-descriptions-item>
          <el-descriptions-item label="简介">{{ detailData.introduction || detailData.description || '-' }}</el-descriptions-item>
        </el-descriptions>
      </div>
      <template #footer>
        <el-button @click="detailVisible = false">关闭</el-button>
        <el-button type="primary" @click="detailVisible = false; $router.push('/user/appointment')">去预约</el-button>
        <el-button type="success" @click="goToConsultation">
          💬 立即问诊
        </el-button>
      </template>
    </el-dialog>
  </div>
</template>

<style scoped>
.doctor-search-container { max-width: 1200px; margin: 0 auto; }
.search-card { margin-bottom: 20px; }
.search-bar { display: flex; gap: 12px; margin-bottom: 12px; }
.search-input { flex: 1; }
.disease-tags { display: flex; flex-wrap: wrap; gap: 8px; align-items: center; }
.disease-label { color: #666; font-size: 14px; white-space: nowrap; }
.disease-tag { cursor: pointer; }
.doctor-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(340px, 1fr)); gap: 16px; }
.doctor-card { cursor: pointer; transition: transform 0.2s; }
.doctor-card:hover { transform: translateY(-2px); }
.doctor-card :deep(.el-card__body) { padding: 16px; display: flex; flex-direction: column; gap: 12px; }
.card-body-row { display: flex; gap: 16px; align-items: center; }
.doctor-avatar { width: 56px; height: 56px; border-radius: 50%; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: #fff; display: flex; align-items: center; justify-content: center; font-size: 22px; font-weight: bold; flex-shrink: 0; }
.doctor-info { flex: 1; min-width: 0; }
.doctor-name { font-size: 16px; font-weight: bold; color: #333; }
.doctor-dept { font-size: 13px; color: #409eff; margin-top: 2px; }
.doctor-title { font-size: 13px; color: #666; margin-top: 2px; }
.doctor-specialty { font-size: 12px; color: #999; margin-top: 4px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
.doctor-hospital { font-size: 12px; color: #999; margin-top: 2px; }
.doctor-score { text-align: center; flex-shrink: 0; }
.score-num { font-size: 24px; font-weight: bold; color: #f39c12; display: block; }
.score-label { font-size: 12px; color: #999; }
.detail-header { display: flex; gap: 16px; align-items: center; }
.detail-avatar { width: 64px; height: 64px; border-radius: 50%; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: #fff; display: flex; align-items: center; justify-content: center; font-size: 28px; font-weight: bold; }
.card-actions { display: flex; gap: 10px; justify-content: flex-end; border-top: 1px solid #f0f0f0; padding-top: 12px; }
</style>
