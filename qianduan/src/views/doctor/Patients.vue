<script setup>
import { ref, onMounted } from 'vue'
import { useUserStore } from '@/stores/user'
import doctorPortalApi from '@/api/doctorPortal'
import nursePortalApi from '@/api/nursePortal'
import request from '@/utils/request'
import { ElMessage, ElMessageBox } from 'element-plus'

const userStore = useUserStore()
const patients = ref([])
const total = ref(0)
const page = ref(1)
const pageSize = ref(10)
const loading = ref(false)
const doctorId = ref(null)
const groups = ref([])
const groupDialogVisible = ref(false)
const groupForm = ref({ doctorId: null, groupName: '', description: '', color: '#4caf50' })
const familyDialogVisible = ref(false)
const familyList = ref([])
const familyPatientName = ref('')
const nurseDialogVisible = ref(false)
const nurseList = ref([])
const nurseAssignPatientId = ref(null)
const nurseAssignPatientName = ref('')
const assignedNurses = ref([])

const loadPatients = async () => {
  loading.value = true
  try {
    const res = await doctorPortalApi.getPatients(doctorId.value, { page: page.value, pageSize: pageSize.value })
    patients.value = res.records || []
    total.value = res.total || 0
  } catch (e) { ElMessage.error('加载患者列表失败') }
  finally { loading.value = false }
}

const loadGroups = async () => {
  try {
    groups.value = await doctorPortalApi.getPatientGroups(doctorId.value)
  } catch (e) {}
}

const openCreateGroup = () => {
  groupForm.value = { doctorId: doctorId.value, groupName: '', description: '', color: '#4caf50' }
  groupDialogVisible.value = true
}

const handleCreateGroup = async () => {
  if (!groupForm.value.groupName) { ElMessage.warning('请输入分组名称'); return }
  try {
    await doctorPortalApi.createPatientGroup(groupForm.value)
    ElMessage.success('分组创建成功')
    groupDialogVisible.value = false
    loadGroups()
  } catch (e) { ElMessage.error('创建失败') }
}

const handleDeleteGroup = async (id) => {
  try {
    await doctorPortalApi.deletePatientGroup(id)
    ElMessage.success('删除成功')
    loadGroups()
  } catch (e) { ElMessage.error('删除失败') }
}

const handleRecover = async (row) => {
  try {
    await ElMessageBox.confirm(`确认患者 ${row.realName || row.username} 已痊愈出院？此操作将从医生和护士名下移除该患者。`, '痊愈确认', { type: 'warning' })
    await doctorPortalApi.recoverPatient(row.id, doctorId.value)
    ElMessage.success('患者已痊愈出院')
    loadPatients()
  } catch (e) { if (e !== 'cancel') ElMessage.error(e.message || '操作失败') }
}

const viewFamily = async (row) => {
  try {
    const res = await request.get(`/family-member/by-patient/${row.id}`)
    familyList.value = res || []
    familyPatientName.value = row.realName || row.username
    familyDialogVisible.value = true
  } catch (e) { ElMessage.error('加载家属信息失败') }
}

const openNurseAssign = async (row) => {
  nurseAssignPatientId.value = row.id
  nurseAssignPatientName.value = row.realName || row.username
  nurseDialogVisible.value = true
  await loadNurseList()
  await loadAssignedNurses(row.id)
}

const loadNurseList = async () => {
  try {
    const res = await request.get('/nurse/list', { params: { page: 1, pageSize: 100 } })
    nurseList.value = res.records || res.list || []
  } catch (e) { console.error(e) }
}

const loadAssignedNurses = async (patientId) => {
  try {
    const res = await request.get('/doctor-portal/patient-nurses', { params: { patientId } })
    assignedNurses.value = res || []
  } catch (e) { assignedNurses.value = [] }
}

const handleAssignNurse = async (nurseId) => {
  try {
    await request.post('/doctor-portal/assign-nurse', { patientId: nurseAssignPatientId.value, nurseId })
    ElMessage.success('护士安排成功')
    await loadAssignedNurses(nurseAssignPatientId.value)
  } catch (e) { ElMessage.error(e.message || '安排失败') }
}

const handleRemoveNurse = async (relationId) => {
  try {
    await request.delete(`/doctor-portal/remove-nurse/${relationId}`)
    ElMessage.success('已移除护士')
    await loadAssignedNurses(nurseAssignPatientId.value)
  } catch (e) { ElMessage.error(e.message || '移除失败') }
}

const isNurseAssigned = (nurseId) => {
  return assignedNurses.value.some(n => n.nurseId === nurseId)
}

const userTypeMap = { 0: '普通用户', 1: '医生', 2: '管理员', 3: '护士', 4: '家属' }

onMounted(async () => {
  try {
    const res = await doctorPortalApi.getDoctorInfo(userStore.userInfo?.userId)
    if (res && res.id) { doctorId.value = res.id; loadPatients(); loadGroups() }
  } catch (e) { ElMessage.warning('请先完善医生信息') }
})
</script>

<template>
  <div class="page-container">
    <el-row :gutter="20">
      <el-col :span="8">
        <el-card>
          <template #header>
            <div class="card-header">
              <span>患者分组</span>
              <el-button type="primary" size="small" @click="openCreateGroup">新建分组</el-button>
            </div>
          </template>
          <div v-for="g in groups" :key="g.id" class="group-item">
            <div class="group-info">
              <span class="group-color" :style="{ background: g.color || '#4caf50' }"></span>
              <span>{{ g.groupName }}</span>
            </div>
            <el-button type="danger" size="small" text @click="handleDeleteGroup(g.id)">删除</el-button>
          </div>
          <el-empty v-if="groups.length === 0" description="暂无分组" />
        </el-card>
      </el-col>
      <el-col :span="16">
        <el-card>
          <template #header>
            <div class="card-header">
              <span>我的患者（共{{ total }}人）</span>
            </div>
          </template>
          <el-table :data="patients" v-loading="loading" stripe>
            <el-table-column prop="id" label="ID" width="80" />
            <el-table-column prop="username" label="姓名" width="120" />
            <el-table-column prop="phone" label="手机号" width="130" />
            <el-table-column prop="age" label="年龄" width="80" />
            <el-table-column label="角色" width="100">
              <template #default="{ row }">{{ userTypeMap[row.userType] || '未知' }}</template>
            </el-table-column>
            <el-table-column prop="createTime" label="注册时间" min-width="170" />
            <el-table-column label="操作" width="250" fixed="right">
              <template #default="{ row }">
                <el-button type="primary" size="small" @click="viewFamily(row)">家属</el-button>
                <el-button type="warning" size="small" @click="openNurseAssign(row)">护士安排</el-button>
                <el-button type="success" size="small" @click="handleRecover(row)">痊愈出院</el-button>
              </template>
            </el-table-column>
          </el-table>
          <el-pagination v-model:current-page="page" v-model:page-size="pageSize" :total="total" @current-change="loadPatients" layout="total, prev, pager, next" style="margin-top: 16px;" />
        </el-card>
      </el-col>
    </el-row>

    <el-dialog v-model="groupDialogVisible" title="新建分组" width="400px">
      <el-form :model="groupForm" label-width="80px">
        <el-form-item label="分组名称" required><el-input v-model="groupForm.groupName" /></el-form-item>
        <el-form-item label="描述"><el-input v-model="groupForm.description" type="textarea" :rows="2" /></el-form-item>
        <el-form-item label="颜色"><el-color-picker v-model="groupForm.color" /></el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="groupDialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleCreateGroup">确定</el-button>
      </template>
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

    <el-dialog v-model="nurseDialogVisible" :title="`${nurseAssignPatientName} - 护士安排`" width="700px">
      <h4>已安排护士</h4>
      <el-table :data="assignedNurses" size="small" stripe style="margin-bottom: 16px;">
        <el-table-column prop="nurseName" label="护士姓名" width="120" />
        <el-table-column prop="nurseDepartment" label="科室" width="120" />
        <el-table-column prop="nurseTitle" label="职称" width="100" />
        <el-table-column label="操作" width="100">
          <template #default="{ row }">
            <el-button type="danger" size="small" @click="handleRemoveNurse(row.id)">移除</el-button>
          </template>
        </el-table-column>
      </el-table>
      <el-empty v-if="assignedNurses.length === 0" description="暂未安排护士" :image-size="40" />
      <h4 style="margin-top: 16px;">添加护士</h4>
      <el-table :data="nurseList" size="small" stripe max-height="300">
        <el-table-column prop="userName" label="护士姓名" width="120" />
        <el-table-column prop="department" label="科室" width="120" />
        <el-table-column prop="title" label="职称" width="100" />
        <el-table-column label="操作" width="100">
          <template #default="{ row }">
            <el-button type="primary" size="small" :disabled="isNurseAssigned(row.id)" @click="handleAssignNurse(row.id)">
              {{ isNurseAssigned(row.id) ? '已安排' : '安排' }}
            </el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-dialog>
  </div>
</template>

<style scoped>
.card-header { display: flex; justify-content: space-between; align-items: center; }
.group-item { display: flex; justify-content: space-between; align-items: center; padding: 10px 0; border-bottom: 1px solid #f0f0f0; }
.group-info { display: flex; align-items: center; gap: 8px; }
.group-color { width: 12px; height: 12px; border-radius: 50%; display: inline-block; }
</style>
