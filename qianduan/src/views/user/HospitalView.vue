<script setup>
import { ref, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { useRouter } from 'vue-router'
import hospitalApi from '@/api/hospital'
import request from '@/utils/request'

const router = useRouter()
const hospitalList = ref([])
const searchForm = ref({ name: '', level: '' })
const loading = ref(false)
const pagination = ref({ page: 1, pageSize: 10, total: 0 })
const detailVisible = ref(false)
const detailData = ref(null)

const departments = ref([])
const doctors = ref([])
const deptLoading = ref(false)
const doctorLoading = ref(false)
const selectedDeptId = ref(null)

const appointmentForm = ref({
  scheduleDate: '',
  schedulePeriod: 1,
  reason: ''
})
const showAppointmentDialog = ref(false)
const selectedDoctor = ref(null)
const submitting = ref(false)

const periodMap = { 1: '上午', 2: '下午', 3: '晚上' }

const loadHospitals = async () => {
  loading.value = true
  try {
    const res = await hospitalApi.getPage({
      page: pagination.value.page,
      size: pagination.value.pageSize,
      ...searchForm.value
    })
    hospitalList.value = res.records || res.list || []
    pagination.value.total = res.total || 0
  } catch (error) {
    ElMessage.error('加载医院列表失败')
  } finally {
    loading.value = false
  }
}

const handleView = async (row) => {
  try {
    const res = await hospitalApi.getDetail(row.id)
    detailData.value = res
  } catch (error) {
    detailData.value = row
  }
  detailVisible.value = true
  selectedDeptId.value = null
  doctors.value = []
  loadDepartments(row.id)
}

async function loadDepartments(hospitalId) {
  deptLoading.value = true
  try {
    const res = await request.get(`/hospital/department/list?hospitalId=${hospitalId}`)
    departments.value = res || []
  } catch (e) {
    departments.value = []
  } finally {
    deptLoading.value = false
  }
}

async function handleSelectDept(deptId) {
  if (!deptId) {
    doctors.value = []
    return
  }
  selectedDeptId.value = deptId
  doctorLoading.value = true
  try {
    const res = await request.get(`/doctor/list?page=1&size=50&departmentId=${deptId}`)
    doctors.value = res.records || res.list || []
  } catch (e) {
    doctors.value = []
  } finally {
    doctorLoading.value = false
  }
}

function openAppointment(doctor) {
  selectedDoctor.value = doctor
  appointmentForm.value = { scheduleDate: '', schedulePeriod: 1, reason: '' }
  showAppointmentDialog.value = true
}

async function submitAppointment() {
  if (!appointmentForm.value.scheduleDate) {
    ElMessage.warning('请选择预约日期')
    return
  }
  submitting.value = true
  try {
    const user = JSON.parse(localStorage.getItem('medical_user_info') || '{}')
    const userId = user.userId || user.id || 1

    await request.post('/appointment', {
      userId,
      doctorId: selectedDoctor.value.id,
      scheduleDate: appointmentForm.value.scheduleDate,
      schedulePeriod: appointmentForm.value.schedulePeriod,
      reason: appointmentForm.value.reason,
      status: 0
    })

    ElMessage.success(`预约成功！已预约 ${selectedDoctor.value.name} ${periodMap[appointmentForm.value.schedulePeriod]}`)
    showAppointmentDialog.value = false
    detailVisible.value = false
  } catch (e) {
    ElMessage.error(e.message || '预约失败')
  } finally {
    submitting.value = false
  }
}

function goAppointmentPage() {
  detailVisible.value = false
  router.push('/user/appointment')
}

onMounted(() => {
  loadHospitals()
})
</script>

<template>
  <div class="hospital-view">
    <div class="search-bar">
      <el-input v-model="searchForm.name" placeholder="搜索医院名称" class="search-input" @keyup.enter="loadHospitals" />
      <el-select v-model="searchForm.level" placeholder="医院等级" class="search-input" clearable>
        <el-option label="全部" value="" />
        <el-option label="三级甲等" value="三级甲等" />
        <el-option label="综合医院" value="综合医院" />
        <el-option label="专科医院" value="专科医院" />
      </el-select>
      <el-button type="primary" @click="loadHospitals">搜索</el-button>
    </div>

    <el-table :data="hospitalList" :loading="loading" border>
      <el-table-column prop="id" label="ID" width="80" />
      <el-table-column prop="name" label="医院名称" />
      <el-table-column prop="level" label="等级" width="100" />
      <el-table-column prop="address" label="地址" />
      <el-table-column prop="phone" label="电话" width="130" />
      <el-table-column label="操作" width="160">
        <template #default="scope">
          <el-button size="small" type="primary" @click="handleView(scope.row)">查看/挂号</el-button>
        </template>
      </el-table-column>
    </el-table>

    <el-pagination
      :current-page="pagination.page"
      :page-size="pagination.pageSize"
      :total="pagination.total"
      @current-change="(page) => { pagination.page = page; loadHospitals() }"
      style="margin-top: 20px; text-align: right"
    />

    <el-dialog v-model="detailVisible" title="医院详情与挂号" width="800px" top="5vh">
      <div v-if="detailData" class="hospital-detail">
        <h2>{{ detailData.name }}</h2>
        <el-descriptions :column="2" border size="small">
          <el-descriptions-item label="等级">{{ detailData.level }}</el-descriptions-item>
          <el-descriptions-item label="电话">{{ detailData.phone }}</el-descriptions-item>
          <el-descriptions-item label="地址" :span="2">{{ detailData.address }}</el-descriptions-item>
          <el-descriptions-item label="简介" :span="2">{{ detailData.description }}</el-descriptions-item>
        </el-descriptions>
      </div>

      <el-divider content-position="left">🏥 选择科室</el-divider>
      <el-select v-model="selectedDeptId" placeholder="请先选择科室" style="width: 100%" :loading="deptLoading" @change="handleSelectDept" clearable>
        <el-option v-for="d in departments" :key="d.id" :label="d.name" :value="d.id">
          <span>{{ d.name }}</span>
          <span v-if="d.location" style="color:#999;font-size:12px;margin-left:8px;">({{ d.location }})</span>
        </el-option>
      </el-select>

      <el-divider v-if="selectedDeptId && doctors.length > 0" content-position="left">👨‍⚕️ 选择医生</el-divider>
      <div v-if="doctorLoading" style="text-align:center;padding:20px;">
        <el-icon class="is-loading"><loading /></el-icon> 加载医生列表...
      </div>
      <div v-else-if="selectedDeptId && doctors.length === 0" class="empty-doctors">
        <el-empty description="该科室暂无可用医生，请选择其他科室" :image-size="80" />
      </div>
      <div v-else-if="doctors.length > 0" class="doctor-grid">
        <div v-for="doc in doctors" :key="doc.id" class="doctor-card" :class="{ disabled: doc.status === 0 }">
          <div class="doc-header">
            <el-avatar :size="48" :style="{ background: (doc.name && doc.name.includes('李') || doc.name && doc.name.includes('陈')) ? '#f56c6c' : '#409eff' }">
              {{ (doc.name || '?')[0] }}
            </el-avatar>
            <div class="doc-info">
              <div class="doc-name">{{ doc.name }}<el-tag v-if="doc.title" size="small" type="info" style="margin-left:6px;">{{ doc.title }}</el-tag></div>
              <div class="doc-dept">{{ doc.departmentName || detailData?.name }}</div>
            </div>
          </div>
          <div class="doc-specialty" v-if="doc.specialty">📋 {{ doc.specialty }}</div>
          <div class="doc-meta">
            <span v-if="doc.score">⭐ {{ doc.score.toFixed(1) }}</span>
            <span v-else>⭐ 暂无评分</span>
            <el-tag :type="doc.status === 1 ? 'success' : 'danger'" size="small">{{ doc.status === 1 ? '可预约' : '停诊' }}</el-tag>
          </div>
          <el-button type="primary" size="small" style="width:100%;margin-top:10px;" :disabled="doc.status !== 1" @click="openAppointment(doc)">
            立即挂号
          </el-button>
        </div>
      </div>

      <template #footer>
        <el-button @click="goAppointmentPage">查看我的预约</el-button>
        <el-button @click="detailVisible = false">关闭</el-button>
      </template>
    </el-dialog>

    <el-dialog v-model="showAppointmentDialog" title="确认挂号信息" width="480px">
      <div v-if="selectedDoctor" class="appointment-confirm">
        <el-descriptions :column="1" border size="small">
          <el-descriptions-item label="医生">{{ selectedDoctor.name }}（{{ selectedDoctor.title }}）</el-descriptions-item>
          <el-descriptions-item label="科室">{{ selectedDoctor.departmentName || detailData?.name }}</el-descriptions-item>
          <el-descriptions-item label="医院">{{ detailData?.name }}</el-descriptions-item>
        </el-descriptions>

        <el-form label-width="80px" style="margin-top:16px;" size="large">
          <el-form-item label="日期">
            <el-date-picker v-model="appointmentForm.scheduleDate" type="date" placeholder="选择日期" value-format="YYYY-MM-DD" :disabled-date="(d) => d.getTime() < Date.now() - 86400000" style="width:100%;" />
          </el-form-item>
          <el-form-item label="时段">
            <el-radio-group v-model="appointmentForm.schedulePeriod">
              <el-radio-button :value="1">上午</el-radio-button>
              <el-radio-button :value="2">下午</el-radio-button>
              <el-radio-button :value="3">晚上</el-radio-button>
            </el-radio-group>
          </el-form-item>
          <el-form-item label="病情描述">
            <el-input v-model="appointmentForm.reason" type="textarea" :rows="3" placeholder="简要描述您的症状或就诊原因（选填）" />
          </el-form-item>
        </el-form>
      </div>
      <template #footer>
        <el-button @click="showAppointmentDialog = false">取消</el-button>
        <el-button type="primary" :loading="submitting" @click="submitAppointment">确认提交</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<style lang="scss" scoped>
.hospital-view {
  background: #fff;
  border-radius: 12px;
  padding: 20px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
}
.search-bar {
  display: flex;
  gap: 12px;
  margin-bottom: 20px;
  .search-input { width: 200px; }
}
.hospital-detail {
  h2 { font-size: 20px; margin: 0 0 16px; color: #303133; }
}
.doctor-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(220px, 1fr));
  gap: 14px;
  max-height: 360px;
  overflow-y: auto;
  padding-right: 4px;
}
.doctor-card {
  border: 1px solid #ebeef5;
  border-radius: 10px;
  padding: 14px;
  transition: all 0.25s;
  &:hover { box-shadow: 0 4px 16px rgba(64,158,255,0.15); transform: translateY(-2px); }
  &.disabled { opacity: 0.55; pointer-events: none; }
}
.doc-header {
  display: flex; gap: 10px; align-items: center;
  .doc-info {
    flex: 1; min-width: 0;
    .doc-name { font-size: 15px; font-weight: 600; color: #303133; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
    .doc-dept { font-size: 12px; color: #909399; margin-top: 2px; }
  }
}
.doc-specialty { font-size: 12px; color: #606266; margin: 8px 0; line-height: 1.4; }
.doc-meta { display: flex; justify-content: space-between; align-items: center; font-size: 13px; color: #909399; }
.empty-doctors { padding: 10px 0; }
.appointment-confirm { max-height: 400px; overflow-y: auto; }
</style>
