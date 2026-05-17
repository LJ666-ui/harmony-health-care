<script setup>
import { ref, onMounted } from 'vue'
import { useUserStore } from '@/stores/user'
import nursePortalApi from '@/api/nursePortal'
import request from '@/utils/request'
import { ElMessage, ElMessageBox } from 'element-plus'

const userStore = useUserStore()
const patients = ref([])
const total = ref(0)
const page = ref(1)
const pageSize = ref(10)
const loading = ref(false)
const nurseId = ref(null)
const detailVisible = ref(false)
const patientDetail = ref(null)
const recoveryReason = ref('')
const familyDialogVisible = ref(false)
const familyList = ref([])
const familyPatientName = ref('')

const loadPatients = async () => {
  loading.value = true
  try {
    const res = await nursePortalApi.getPatients(nurseId.value, { page: page.value, pageSize: pageSize.value })
    patients.value = res.records || []
    total.value = res.total || 0
  } catch (e) { ElMessage.error('加载患者列表失败') }
  finally { loading.value = false }
}

const viewDetail = async (patientId) => {
  try {
    const res = await nursePortalApi.getPatientDetail(patientId)
    patientDetail.value = res
    detailVisible.value = true
  } catch (e) { ElMessage.error('加载患者详情失败') }
}

const handleRecoveryRequest = async (row) => {
}

const viewFamily = async (row) => {
  try {
    const res = await request.get(`/family-member/by-patient/${row.id}`)
    familyList.value = res || []
    familyPatientName.value = row.realName || row.username
    familyDialogVisible.value = true
  } catch (e) { ElMessage.error('加载家属信息失败') }
}

onMounted(async () => {
  try {
    const res = await nursePortalApi.getNurseInfo(userStore.userInfo?.userId)
    if (res && res.id) { nurseId.value = res.id; loadPatients() }
  } catch (e) { ElMessage.warning('请先完善护士信息') }
})
</script>

<template>
  <div class="page-container">
    <el-card>
      <template #header><span>患者监护</span></template>
      <el-table :data="patients" v-loading="loading" stripe>
        <el-table-column prop="id" label="ID" width="80" />
        <el-table-column prop="username" label="姓名" width="120" />
        <el-table-column prop="phone" label="手机号" width="130" />
        <el-table-column prop="age" label="年龄" width="80" />
        <el-table-column prop="createTime" label="注册时间" min-width="170" />
        <el-table-column label="操作" width="250" fixed="right">
          <template #default="{ row }">
            <el-button type="primary" size="small" @click="viewDetail(row.id)">查看详情</el-button>
            <el-button type="warning" size="small" @click="viewFamily(row)">家属信息</el-button>
          </template>
        </el-table-column>
      </el-table>
      <el-pagination v-model:current-page="page" v-model:page-size="pageSize" :total="total" @current-change="loadPatients" layout="total, prev, pager, next" style="margin-top: 16px;" />
    </el-card>

    <el-dialog v-model="detailVisible" title="患者详情" width="700px">
      <div v-if="patientDetail">
        <h4>基本信息</h4>
        <p v-if="patientDetail.patient">姓名：{{ patientDetail.patient.username }} | 手机：{{ patientDetail.patient.phone }} | 年龄：{{ patientDetail.patient.age }}</p>
        <h4 style="margin-top: 16px;">主治医生</h4>
        <el-table :data="patientDetail.doctors || []" size="small" stripe>
          <el-table-column prop="name" label="医生姓名" width="120" />
          <el-table-column prop="department" label="科室" width="120" />
          <el-table-column prop="title" label="职称" width="100" />
          <el-table-column prop="hospital" label="所属医院" width="150" />
          <el-table-column prop="specialty" label="专长" min-width="150" />
          <el-table-column prop="phone" label="联系电话" width="130" />
        </el-table>
        <el-empty v-if="!patientDetail.doctors || patientDetail.doctors.length === 0" description="暂无主治医生信息" :image-size="40" />
        <h4 style="margin-top: 16px;">最近健康记录</h4>
        <el-table :data="patientDetail.recentHealthRecords || []" size="small" stripe>
          <el-table-column prop="bloodPressure" label="血压" width="100" />
          <el-table-column prop="bloodSugar" label="血糖" width="80" />
          <el-table-column prop="heartRate" label="心率" width="80" />
          <el-table-column prop="recordTime" label="记录时间" min-width="150" />
        </el-table>
        <h4 style="margin-top: 16px;">最近护理记录</h4>
        <el-table :data="patientDetail.recentNursingRecords || []" size="small" stripe>
          <el-table-column prop="recordContent" label="内容" min-width="200" />
          <el-table-column prop="careTime" label="护理时间" width="170" />
        </el-table>
      </div>
    </el-dialog>

    <el-dialog v-model="familyDialogVisible" :title="`${familyPatientName} 的家属信息`" width="700px">
      <el-table :data="familyList" stripe>
        <el-table-column prop="name" label="姓名" width="120" />
        <el-table-column prop="relation" label="与患者关系" width="120" />
        <el-table-column prop="phone" label="手机号" width="130" />
        <el-table-column prop="gender" label="性别" width="80">
          <template #default="{ row }">{{ row.gender === 1 ? '男' : row.gender === 0 ? '女' : '-' }}</template>
        </el-table-column>
        <el-table-column prop="age" label="年龄" width="80" />
        <el-table-column prop="address" label="地址" min-width="150" />
      </el-table>
      <el-empty v-if="familyList.length === 0" description="暂无家属信息" />
    </el-dialog>
  </div>
</template>
