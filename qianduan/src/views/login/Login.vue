<script setup>
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { useUserStore } from '@/stores/user'
import { ElMessage } from 'element-plus'

const router = useRouter()
const userStore = useUserStore()

const loginType = ref('user')
const form = ref({ phone: '', username: '', password: '' })
const loading = ref(false)

const loginTypes = [
  { key: 'user', label: '用户登录', icon: '👤' },
  { key: 'doctor', label: '医生登录', icon: '🩺' },
  { key: 'nurse', label: '护士登录', icon: '👩‍⚕️' },
  { key: 'family', label: '家属登录', icon: '👨‍👩‍👧' },
  { key: 'admin', label: '管理员登录', icon: '🛡️' }
]

const handleLogin = async () => {
  if (loginType.value === 'admin') {
    if (!form.value.username || !form.value.password) {
      ElMessage.warning('请输入用户名和密码')
      return
    }
  } else {
    if (!form.value.phone || !form.value.password) {
      ElMessage.warning('请输入手机号和密码')
      return
    }
  }
  loading.value = true
  try {
    if (loginType.value === 'admin') {
      await userStore.adminLogin(form.value.username, form.value.password)
      router.push('/admin/home')
    } else if (loginType.value === 'family') {
      await userStore.familyLogin(form.value.phone, form.value.password)
      router.push('/family/home')
    } else {
      await userStore.login(form.value.phone, form.value.password)
      const userType = userStore.userInfo?.userType
      const expectedType = { doctor: 1, nurse: 3, user: 0 }[loginType.value]
      if (expectedType !== undefined && userType !== expectedType && userType !== 2) {
        const typeNames = { 0: '普通用户', 1: '医生', 2: '管理员', 3: '护士', 4: '家属' }
        ElMessage.error(`该账号类型为${typeNames[userType] || '未知'}，无法以${loginTypes.find(t => t.key === loginType.value)?.label.replace('登录', '')}身份登录`)
        userStore.logout()
        return
      }
      if (userType === 2) {
        router.push('/admin/home')
      } else if (userType === 1) {
        router.push('/doctor/home')
      } else if (userType === 3) {
        router.push('/nurse/home')
      } else if (userType === 4) {
        router.push('/family/home')
      } else {
        router.push('/user/home')
      }
    }
  } catch (error) {
    ElMessage.error(error.message || '登录失败')
  } finally {
    loading.value = false
  }
}
</script>

<template>
  <div class="login-container">
    <div class="login-box">
      <div class="login-header">
        <h1>智慧医疗系统</h1>
        <p>Smart Medical System</p>
      </div>

      <div class="login-type-switch">
        <div
          v-for="item in loginTypes"
          :key="item.key"
          :class="['type-btn', { active: loginType === item.key }]"
          @click="loginType = item.key"
        >
          <span class="type-icon">{{ item.icon }}</span>
          <span>{{ item.label }}</span>
        </div>
      </div>

      <el-form :model="form" class="login-form">
        <el-form-item v-if="loginType === 'admin'">
          <el-input v-model="form.username" placeholder="管理员用户名" prefix-icon="User" size="large" />
        </el-form-item>
        <el-form-item v-else>
          <el-input v-model="form.phone" placeholder="手机号" prefix-icon="Phone" size="large" maxlength="11" />
        </el-form-item>
        <el-form-item>
          <el-input v-model="form.password" placeholder="密码" type="password" prefix-icon="Lock" size="large" show-password />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleLogin" :loading="loading" class="login-btn" size="large">
            {{ loginTypes.find(t => t.key === loginType)?.label }}
          </el-button>
        </el-form-item>
      </el-form>

      <div class="register-link" v-if="loginType === 'user' || loginType === 'family'">
        还没有账号？<a @click="router.push('/register')">立即注册</a>
      </div>
    </div>
  </div>
</template>

<style lang="scss" scoped>
.login-container { min-height: 100vh; display: flex; align-items: center; justify-content: center; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); }
.login-box { width: 460px; background: #fff; border-radius: 16px; padding: 40px; box-shadow: 0 20px 60px rgba(0,0,0,0.15); }
.login-header { text-align: center; margin-bottom: 20px; h1 { font-size: 26px; color: #333; margin-bottom: 8px; } p { color: #999; font-size: 14px; } }
.login-type-switch { display: flex; flex-wrap: wrap; gap: 8px; margin-bottom: 24px; justify-content: center;
  .type-btn { flex: 0 0 auto; display: flex; align-items: center; gap: 4px; padding: 8px 14px; border: 2px solid #e2e8f0; border-radius: 8px; cursor: pointer; transition: all 0.3s; font-size: 13px; color: #666;
    &:hover { border-color: #667eea; color: #667eea; }
    &.active { border-color: #667eea; background: #f0f0ff; color: #667eea; font-weight: 600; }
    .type-icon { font-size: 16px; }
  }
}
.login-form { margin-bottom: 16px; }
.login-btn { width: 100%; height: 48px; font-size: 16px; }
.register-link { text-align: center; color: #666; font-size: 14px; a { color: #667eea; margin-left: 5px; text-decoration: none; cursor: pointer; &:hover { text-decoration: underline; } } }
</style>
