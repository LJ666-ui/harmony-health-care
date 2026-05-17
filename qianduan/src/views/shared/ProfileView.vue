<script setup>
import { ref, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { useUserStore } from '@/stores/user'
import userApi from '@/api/user'

const userStore = useUserStore()
const loading = ref(false)
const saving = ref(false)
const form = ref({
  id: null,
  username: '',
  phone: '',
  age: null,
  idCard: ''
})

const loadUserInfo = async () => {
  loading.value = true
  try {
    const res = await userApi.getUserInfo(userStore.userInfo?.userId)
    form.value = {
      id: res.id,
      username: res.username || '',
      phone: res.phone || '',
      age: res.age || null,
      idCard: res.idCard || ''
    }
  } catch (error) {
    ElMessage.error('加载用户信息失败')
  } finally {
    loading.value = false
  }
}

const handleSave = async () => {
  if (!form.value.username) { ElMessage.warning('用户名不能为空'); return }
  if (!form.value.phone) { ElMessage.warning('手机号不能为空'); return }
  saving.value = true
  try {
    await userApi.updateUser({
      id: form.value.id,
      username: form.value.username,
      phone: form.value.phone,
      age: form.value.age,
      idCard: form.value.idCard
    })
    ElMessage.success('保存成功')
    userStore.userInfo.username = form.value.username
  } catch (error) {
    ElMessage.error('保存失败')
  } finally {
    saving.value = false
  }
}

onMounted(() => {
  loadUserInfo()
})
</script>

<template>
  <div class="profile-view" v-loading="loading">
    <h3>个人设置</h3>
    <el-form :model="form" label-width="100px" class="profile-form">
      <el-form-item label="用户名">
        <el-input v-model="form.username" placeholder="请输入用户名" />
      </el-form-item>
      <el-form-item label="手机号">
        <el-input v-model="form.phone" placeholder="请输入手机号" maxlength="11" />
      </el-form-item>
      <el-form-item label="年龄">
        <el-input-number v-model="form.age" :min="0" :max="150" />
      </el-form-item>
      <el-form-item label="身份证号">
        <el-input v-model="form.idCard" placeholder="请输入身份证号" maxlength="18" />
      </el-form-item>
      <el-form-item>
        <el-button type="primary" @click="handleSave" :loading="saving">保存修改</el-button>
      </el-form-item>
    </el-form>
  </div>
</template>

<style lang="scss" scoped>
.profile-view {
  background: #fff;
  border-radius: 12px;
  padding: 24px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
  h3 { font-size: 18px; margin: 0 0 20px; }
}
.profile-form { max-width: 500px; }
</style>
