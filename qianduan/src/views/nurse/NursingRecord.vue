<script setup>
import { ref, onMounted } from 'vue'
import { useUserStore } from '@/stores/user'
import nursePortalApi from '@/api/nursePortal'
import { ElMessage } from 'element-plus'

const userStore = useUserStore()
const nurseId = ref(null)
const patientList = ref([])
const selectedPatientId = ref(null)
const tableData = ref([])
const total = ref(0)
const page = ref(1)
const pageSize = ref(10)
const loading = ref(false)
const dialogVisible = ref(false)
const form = ref({ patientId: null, nurseId: null, recordType: 2, recordContent: '', remark: '', vitalSigns: '', careTime: '' })

const detailVisible = ref(false)
const detailData = ref(null)

const recordTypeMap = { 2: '用药护理', 3: '伤口护理', 4: '日常护理' }

const formatVitalSigns = (vs) => {
  if (!vs) return '无'
  try {
    const obj = typeof vs === 'string' ? JSON.parse(vs) : vs
    const labels = {
      heartRate: '心率',
      bloodPressure: '血压',
      temperature: '体温',
      respiratoryRate: '呼吸频率',
      oxygenSaturation: '血氧饱和度',
      weight: '体重',
      height: '身高',
      bloodSugar: '血糖',
      painLevel: '疼痛等级'
    }
    return Object.entries(obj).map(([k, v]) => `${labels[k] || k}: ${v}`).join('，')
  } catch {
    return String(vs)
  }
}

const showDetail = (row) => {
  detailData.value = row
  detailVisible.value = true
}

const loadPatients = async () => {
  try {
    const res = await nursePortalApi.getPatients(nurseId.value, { page: 1, pageSize: 100 })
    patientList.value = (res.records || []).map(p => ({ id: p.id, name: p.username || `患者${p.id}` }))
  } catch (e) { console.error(e) }
}

const loadData = async () => {
  if (!selectedPatientId.value) { ElMessage.warning('请选择患者'); return }
  loading.value = true
  try {
    const res = await nursePortalApi.getNursingRecords(selectedPatientId.value, { page: page.value, pageSize: pageSize.value })
    tableData.value = res.records || []
    total.value = res.total || 0
  } catch (e) { ElMessage.error('加载护理记录失败') }
  finally { loading.value = false }
}

const openCreate = () => {
  const now = new Date()
  const pad = n => String(n).padStart(2, '0')
  const careTimeStr = `${now.getFullYear()}-${pad(now.getMonth() + 1)}-${pad(now.getDate())} ${pad(now.getHours())}:${pad(now.getMinutes())}:${pad(now.getSeconds())}`
  form.value = { patientId: selectedPatientId.value, nurseId: nurseId.value, recordType: 2, recordContent: '', remark: '', vitalSigns: '', careTime: careTimeStr }
  dialogVisible.value = true
}

const handleCreate = async () => {
  if (!form.value.recordContent) { ElMessage.warning('请填写记录内容'); return }
  try {
    const submitData = { ...form.value }
    if (!submitData.vitalSigns || submitData.vitalSigns.trim() === '') {
      delete submitData.vitalSigns
    } else {
      try {
        submitData.vitalSigns = JSON.parse(submitData.vitalSigns)
      } catch {
        delete submitData.vitalSigns
      }
    }
    if (!submitData.remark || submitData.remark.trim() === '') {
      delete submitData.remark
    }
    if (!submitData.careTime) {
      delete submitData.careTime
    }
    await nursePortalApi.createNursingRecord(submitData)
    ElMessage.success('护理记录创建成功')
    dialogVisible.value = false
    loadData()
  } catch (e) { ElMessage.error(e.message || '创建失败') }
}

onMounted(async () => {
  try {
    const res = await nursePortalApi.getNurseInfo(userStore.userInfo?.userId)
    if (res && res.id) {
      if (res.nurseNo !== undefined) {
        nurseId.value = res.id
      } else {
        nurseId.value = null
        ElMessage.warning('请先完善护士信息')
        return
      }
      loadPatients()
    }
  } catch (e) { ElMessage.warning('请先完善护士信息') }
})
</script>

<template>
  <div class="page-container">
    <el-card>
      <template #header>
        <div class="card-header">
          <span>护理记录</span>
          <div class="filter-row">
            <el-select v-model="selectedPatientId" placeholder="选择患者" style="width: 200px; margin-right: 10px;" @change="loadData">
              <el-option v-for="p in patientList" :key="p.id" :label="p.name" :value="p.id" />
            </el-select>
            <el-button type="success" @click="openCreate" :disabled="!selectedPatientId">新增记录</el-button>
          </div>
        </div>
      </template>
      <el-table :data="tableData" v-loading="loading" stripe>
        <el-table-column prop="patientName" label="患者" width="100" />
        <el-table-column prop="nurseName" label="护士" width="100" />
        <el-table-column label="类型" width="120">
          <template #default="{ row }">{{ recordTypeMap[row.recordType] || '未知' }}</template>
        </el-table-column>
        <el-table-column prop="recordContent" label="记录内容" min-width="200" show-overflow-tooltip />
        <el-table-column prop="remark" label="备注" width="150" show-overflow-tooltip />
        <el-table-column prop="careTime" label="护理时间" width="170" />
        <el-table-column label="操作" width="80" fixed="right">
          <template #default="{ row }">
            <el-button type="primary" size="small" @click="showDetail(row)">查看</el-button>
          </template>
        </el-table-column>
      </el-table>
      <el-pagination v-model:current-page="page" v-model:page-size="pageSize" :total="total" @current-change="loadData" layout="total, prev, pager, next" style="margin-top: 16px;" />
    </el-card>

    <el-dialog v-model="dialogVisible" title="新增护理记录" width="600px">
      <el-form :model="form" label-width="80px">
        <el-form-item label="患者">
          <el-select v-model="form.patientId" style="width: 100%;">
            <el-option v-for="p in patientList" :key="p.id" :label="p.name" :value="p.id" />
          </el-select>
        </el-form-item>
        <el-form-item label="记录类型">
          <el-select v-model="form.recordType">
            <el-option label="用药护理" :value="2" /><el-option label="伤口护理" :value="3" /><el-option label="日常护理" :value="4" />
          </el-select>
        </el-form-item>
        <el-form-item label="记录内容" required><el-input v-model="form.recordContent" type="textarea" :rows="3" /></el-form-item>
        <el-form-item label="备注"><el-input v-model="form.remark" /></el-form-item>
        <el-form-item label="护理时间"><el-date-picker v-model="form.careTime" type="datetime" placeholder="选择护理时间" value-format="YYYY-MM-DD HH:mm:ss" style="width: 100%;" /></el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleCreate">确定</el-button>
      </template>
    </el-dialog>

    <el-dialog v-model="detailVisible" title="护理记录详情" width="650px">
      <el-descriptions v-if="detailData" :column="2" border>
        <el-descriptions-item label="记录ID">{{ detailData.id }}</el-descriptions-item>
        <el-descriptions-item label="记录类型">{{ recordTypeMap[detailData.recordType] || '未知' }}</el-descriptions-item>
        <el-descriptions-item label="患者">{{ detailData.patientName || '-' }}</el-descriptions-item>
        <el-descriptions-item label="护士">{{ detailData.nurseName || '-' }}</el-descriptions-item>
        <el-descriptions-item label="护理时间" :span="2">{{ detailData.careTime || '-' }}</el-descriptions-item>
        <el-descriptions-item label="记录内容" :span="2">{{ detailData.recordContent || '-' }}</el-descriptions-item>
        <el-descriptions-item label="生命体征" :span="2">{{ formatVitalSigns(detailData.vitalSigns) }}</el-descriptions-item>
        <el-descriptions-item label="备注" :span="2">{{ detailData.remark || '无' }}</el-descriptions-item>
        <el-descriptions-item label="创建时间">{{ detailData.createTime || '-' }}</el-descriptions-item>
        <el-descriptions-item label="更新时间">{{ detailData.updateTime || '-' }}</el-descriptions-item>
      </el-descriptions>
      <template #footer>
        <el-button @click="detailVisible = false">关闭</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<style scoped>
.card-header { display: flex; justify-content: space-between; align-items: center; }
.filter-row { display: flex; align-items: center; }
</style>
