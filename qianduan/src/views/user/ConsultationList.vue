<script setup>
import { ref, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { useUserStore } from '@/stores/user'
import { ElMessage, ElMessageBox } from 'element-plus'
import consultationApi from '@/api/consultation'
import doctorApi from '@/api/doctor'

const router = useRouter()
const route = useRoute()
const userStore = useUserStore()

const consultations = ref([])
const loading = ref(false)
const showCreateDialog = ref(false)
const createForm = ref({
  doctorId: null,
  consultationType: 1,
  chiefComplaint: ''
})
const doctorOptions = ref([])
const doctorLoading = ref(false)

onMounted(() => {
  loadConsultations()
  if (route.query.doctorId) {
    createForm.value.doctorId = Number(route.query.doctorId)
    showCreateDialog.value = true
  }
  loadDoctorOptions()
})

async function loadDoctorOptions() {
  doctorLoading.value = true
  try {
    const res = await doctorApi.getList({ page: 1, size: 100, status: 1 })
    let list = res.records || res.list || []
    doctorOptions.value = list.map(d => ({
      value: d.id,
      label: `${d.name} - ${d.departmentName || d.department || '未知科室'} - ${d.title || ''}`,
      name: d.name,
      department: d.departmentName || d.department
    }))
    if (route.query.doctorId) {
      const preselected = doctorOptions.value.find(d => d.value === Number(route.query.doctorId))
      if (!preselected) {
        ElMessage.warning('未找到指定医生，请重新选择')
      }
    }
  } catch (e) {
    console.error('加载医生列表失败:', e)
  } finally {
    doctorLoading.value = false
  }
}

async function loadConsultations() {
  loading.value = true
  try {
    const res = await consultationApi.getPatientConsultations(userStore.userInfo?.userId)
    consultations.value = Array.isArray(res) ? res : []
  } catch (e) {
    console.error('加载问诊列表失败:', e)
    ElMessage.error(e?.message || '加载失败，请检查后端是否启动')
  } finally {
    loading.value = false
  }
}

async function createConsultation() {
  if (!createForm.value.doctorId) {
    ElMessage.warning('请先选择医生')
    return
  }
  if (!createForm.value.chiefComplaint.trim()) {
    ElMessage.warning('请填写主诉描述')
    return
  }

  try {
    const res = await consultationApi.createConsultation({
      patientId: userStore.userInfo?.userId,
      doctorId: createForm.value.doctorId,
      consultationType: createForm.value.consultationType,
      chiefComplaint: createForm.value.chiefComplaint.trim()
    })

    if (res && res.id) {
      ElMessage.success('问诊已创建，等待医生接诊')
      showCreateDialog.value = false
      createForm.value = { doctorId: null, consultationType: 1, chiefComplaint: '' }
      loadConsultations()
    } else {
      ElMessage.error('创建失败，请稍后重试')
    }
  } catch (e) {
    ElMessage.error(e?.message || '创建失败: 网络异常')
  }
}

async function cancelConsultation(id) {
  try {
    await ElMessageBox.confirm('确定要取消该问诊吗？', '提示', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })

    const res = await consultationApi.cancelConsultation(id)
    if (res) {
      ElMessage.success('已取消')
      loadConsultations()
    }
  } catch (e) {}
}

function enterChat(id) {
  router.push(`/user/consultation/${id}`)
}

function getStatusText(status) {
  const map = { 0: '等待接诊', 1: '进行中', 2: '已完成', 3: '已取消', 4: '已超时' }
  return map[status] || '未知'
}

function getStatusType(status) {
  const map = { 0: 'warning', 1: 'success', 2: 'info', 3: 'danger', 4: 'danger' }
  return map[status] || 'info'
}

function getTypeText(type) {
  const map = { 1: '图文', 2: '语音', 3: '视频' }
  return map[type] || '图文'
}

function formatDate(time) {
  if (!time) return '--'
  return new Date(time).toLocaleString('zh-CN')
}
</script>

<template>
  <div class="consultation-list-page">
    <div class="page-header">
      <h2>在线问诊</h2>
      <el-button type="primary" @click="showCreateDialog = true">
        <el-icon><Plus /></el-icon> 发起问诊
      </el-button>
    </div>

    <div class="consultation-cards" v-loading="loading">
      <el-empty v-if="consultations.length === 0 && !loading" description="暂无问诊记录" />

      <div v-for="order in consultations" :key="order.id" class="consultation-card">
        <div class="card-header">
          <div class="doctor-info">
            <el-avatar :size="44" :src="order.doctorAvatar">
              {{ order.doctorName?.charAt(0) }}
            </el-avatar>
            <div class="info">
              <h4>{{ order.doctorName }} <span class="title">{{ order.doctorTitle }}</span></h4>
              <p class="department">{{ order.department }}</p>
            </div>
          </div>
          <div class="status-area">
            <el-tag :type="getStatusType(order.status)" size="small">{{ getStatusText(order.status) }}</el-tag>
            <el-tag size="small" type="info" effect="plain">{{ getTypeText(order.consultationType) }}</el-tag>
          </div>
        </div>

        <div class="card-body">
          <p class="complaint"><strong>主诉：</strong>{{ order.chiefComplaint || '未填写' }}</p>
          <p v-if="order.diagnosisResult" class="diagnosis"><strong>诊断：</strong>{{ order.diagnosisResult }}</p>
          <div class="meta">
            <span>创建时间：{{ formatDate(order.createTime) }}</span>
            <span v-if="order.fee">费用：¥{{ order.fee }}</span>
          </div>
        </div>

        <div class="card-footer">
          <el-button
            v-if="order.status === 0 || order.status === 1"
            type="primary"
            size="small"
            @click="enterChat(order.id)"
          >
            {{ order.status === 0 ? '进入等待' : '进入对话' }}
          </el-button>
          <el-button
            v-if="order.status === 0"
            type="danger"
            size="small"
            plain
            @click="cancelConsultation(order.id)"
          >
            取消问诊
          </el-button>
          <el-button
            v-if="order.status === 2 && !order.rating"
            type="warning"
            size="small"
            plain
          >
            去评价
          </el-button>
        </div>
      </div>
    </div>

    <el-dialog v-model="showCreateDialog" title="发起在线问诊" width="500px">
      <el-form :model="createForm" label-width="90px">
        <el-form-item label="选择医生">
          <el-select
            v-model="createForm.doctorId"
            placeholder="请搜索或选择医生"
            filterable
            clearable
            style="width: 100%"
            :loading="doctorLoading"
          >
            <el-option
              v-for="doc in doctorOptions"
              :key="doc.value"
              :label="doc.label"
              :value="doc.value"
            >
              <div style="display:flex;justify-content:space-between;align-items:center">
                <span>{{ doc.label }}</span>
                <el-tag size="small" type="success" effect="plain">可选</el-tag>
              </div>
            </el-option>
          </el-select>
          <div class="doctor-tip" v-if="createForm.doctorId">
            <el-icon><InfoFilled /></el-icon>
            已选择：{{ doctorOptions.find(d => d.value === createForm.doctorId)?.name }}
            （{{ doctorOptions.find(d => d.value === createForm.doctorId)?.department }}）
          </div>
        </el-form-item>
        <el-form-item label="问诊类型">
          <el-radio-group v-model="createForm.consultationType">
            <el-radio :label="1">图文问诊</el-radio>
            <el-radio :label="2">语音问诊</el-radio>
            <el-radio :label="3">视频问诊</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item label="主诉描述">
          <el-input
            v-model="createForm.chiefComplaint"
            type="textarea"
            :rows="4"
            placeholder="请详细描述您的症状、持续时间、是否就医过等信息..."
          />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="showCreateDialog = false">取消</el-button>
        <el-button type="primary" @click="createConsultation">提交问诊</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<style lang="scss" scoped>
.consultation-list-page { padding: 20px; }
.page-header {
  display: flex; justify-content: space-between; align-items: center; margin-bottom: 24px;
  h2 { font-size: 22px; color: #333; margin: 0; }
}
.consultation-cards { display: flex; flex-direction: column; gap: 16px; }
.consultation-card {
  background: #fff; border-radius: 12px; padding: 20px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.05); transition: all 0.2s;
  &:hover { box-shadow: 0 4px 16px rgba(0,0,0,0.1); }
}
.card-header {
  display: flex; justify-content: space-between; align-items: center; margin-bottom: 14px;
  .doctor-info { display: flex; align-items: center; gap: 12px;
    .info { h4 { font-size: 15px; margin: 0 0 2px; .title { font-size: 12px; color: #999; font-weight: normal; } }
      .department { font-size: 13px; color: #666; margin: 0; } }
  }
  .status-area { display: flex; gap: 8px; }
}
.card-body {
  .complaint, .diagnosis { font-size: 14px; color: #333; margin: 0 0 8px; line-height: 1.6; }
  .meta { font-size: 12px; color: #999; display: flex; gap: 16px; }
}
.card-footer {
  margin-top: 14px; padding-top: 14px; border-top: 1px solid #f0f0f0;
  display: flex; gap: 10px;
}
.doctor-tip {
  font-size: 12px; color: #409eff; display: flex; align-items: center; gap: 4px;
  margin-top: 6px;
}
</style>
