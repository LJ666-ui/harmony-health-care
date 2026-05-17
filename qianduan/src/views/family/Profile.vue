<script setup>
import { ref, reactive, onMounted } from 'vue'
import { useUserStore } from '@/stores/user'
import request from '@/utils/request'
import { ElMessage } from 'element-plus'

const userStore = useUserStore()
const loading = ref(false)
const saving = ref(false)
const passwordVisible = ref(false)

const formData = reactive({
  id: null,
  name: '',
  phone: '',
  relation: '',
  gender: null,
  age: null,
  idCard: '',
  address: '',
  healthCondition: ''
})

const passwordForm = reactive({
  oldPassword: '',
  newPassword: '',
  confirmPassword: ''
})

const loadProfile = async () => {
  loading.value = true
  try {
    const familyMemberId = userStore.userInfo?.familyMemberId
    if (!familyMemberId) {
      ElMessage.error('无法获取家属信息')
      return
    }
    const res = await request.get(`/family-member/${familyMemberId}`)
    if (res) {
      Object.assign(formData, {
        id: res.id,
        name: res.name || '',
        phone: res.phone || '',
        relation: res.relation || '',
        gender: res.gender,
        age: res.age,
        idCard: res.idCard || '',
        address: res.address || '',
        healthCondition: res.healthCondition || ''
      })
    }
  } catch (e) {
    ElMessage.error('加载个人信息失败')
  } finally {
    loading.value = false
  }
}

const handleSave = async () => {
  if (!formData.name) { ElMessage.warning('请输入姓名'); return }
  if (!formData.phone) { ElMessage.warning('请输入手机号'); return }
  saving.value = true
  try {
    await request.put(`/family-member/${formData.id}`, {
      name: formData.name,
      phone: formData.phone,
      relation: formData.relation,
      gender: formData.gender,
      age: formData.age,
      idCard: formData.idCard,
      address: formData.address,
      healthCondition: formData.healthCondition
    })
    ElMessage.success('保存成功')
    const userInfo = { ...userStore.userInfo, realName: formData.name, username: formData.name }
    userStore.userInfo = userInfo
  } catch (e) {
    ElMessage.error(e.message || '保存失败')
  } finally {
    saving.value = false
  }
}

const handleChangePassword = async () => {
  if (!passwordForm.oldPassword) { ElMessage.warning('请输入原密码'); return }
  if (!passwordForm.newPassword) { ElMessage.warning('请输入新密码'); return }
  if (passwordForm.newPassword.length < 6) { ElMessage.warning('新密码至少6位'); return }
  if (passwordForm.newPassword !== passwordForm.confirmPassword) { ElMessage.warning('两次密码不一致'); return }
  try {
    await request.put(`/family-member/${formData.id}`, { password: passwordForm.newPassword })
    ElMessage.success('密码修改成功')
    passwordVisible.value = false
    passwordForm.oldPassword = ''
    passwordForm.newPassword = ''
    passwordForm.confirmPassword = ''
  } catch (e) {
    ElMessage.error(e.message || '密码修改失败')
  }
}

onMounted(() => { loadProfile() })
</script>

<template>
  <div class="profile-container" v-loading="loading">
    <el-card>
      <template #header>
        <div class="card-header">
          <span>个人设置</span>
          <el-button type="primary" @click="handleSave" :loading="saving">保存修改</el-button>
        </div>
      </template>
      <el-form :model="formData" label-width="100px" style="max-width: 600px;">
        <el-form-item label="姓名">
          <el-input v-model="formData.name" placeholder="请输入姓名" />
        </el-form-item>
        <el-form-item label="手机号">
          <el-input v-model="formData.phone" placeholder="请输入手机号" maxlength="11" />
        </el-form-item>
        <el-form-item label="与患者关系">
          <el-select v-model="formData.relation" placeholder="请选择关系" style="width: 100%;">
            <el-option label="配偶" value="配偶" />
            <el-option label="子女" value="子女" />
            <el-option label="父母" value="父母" />
            <el-option label="兄弟姐妹" value="兄弟姐妹" />
            <el-option label="其他" value="其他" />
          </el-select>
        </el-form-item>
        <el-form-item label="性别">
          <el-radio-group v-model="formData.gender">
            <el-radio :value="1">男</el-radio>
            <el-radio :value="0">女</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item label="年龄">
          <el-input-number v-model="formData.age" :min="0" :max="150" style="width: 100%;" />
        </el-form-item>
        <el-form-item label="身份证号">
          <el-input v-model="formData.idCard" placeholder="请输入身份证号" maxlength="18" />
        </el-form-item>
        <el-form-item label="地址">
          <el-input v-model="formData.address" placeholder="请输入地址" />
        </el-form-item>
        <el-form-item label="健康状况">
          <el-input v-model="formData.healthCondition" type="textarea" :rows="2" placeholder="请描述您的健康状况" />
        </el-form-item>
        <el-form-item>
          <el-button type="warning" @click="passwordVisible = true">修改密码</el-button>
        </el-form-item>
      </el-form>
    </el-card>

    <el-dialog v-model="passwordVisible" title="修改密码" width="400px">
      <el-form :model="passwordForm" label-width="100px">
        <el-form-item label="原密码">
          <el-input v-model="passwordForm.oldPassword" type="password" show-password placeholder="请输入原密码" />
        </el-form-item>
        <el-form-item label="新密码">
          <el-input v-model="passwordForm.newPassword" type="password" show-password placeholder="请输入新密码（至少6位）" />
        </el-form-item>
        <el-form-item label="确认密码">
          <el-input v-model="passwordForm.confirmPassword" type="password" show-password placeholder="请再次输入新密码" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="passwordVisible = false">取消</el-button>
        <el-button type="primary" @click="handleChangePassword">确认修改</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<style scoped>
.profile-container { max-width: 800px; margin: 0 auto; }
.card-header { display: flex; justify-content: space-between; align-items: center; }
</style>
