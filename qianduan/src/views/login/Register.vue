<script setup>
import { ref, computed } from 'vue'
import { useRouter } from 'vue-router'
import { useUserStore } from '@/stores/user'
import userApi from '@/api/user'
import { ElMessage } from 'element-plus'

const router = useRouter()
const userStore = useUserStore()

const registerType = ref('user')
const form = ref({
  username: '',
  password: '',
  confirmPassword: '',
  phone: '',
  realName: '',
  userType: 0,
  department: '',
  licenseNumber: '',
  title: '',
  specialty: '',
  nurseNo: '',
  relation: '',
  patientPhone: '',
  gender: null,
  age: null,
  idCard: '',
  address: ''
})

const loading = ref(false)
const searchingPatient = ref(false)
const foundPatient = ref(null)

const registerTypes = [
  { key: 'user', label: '普通用户', icon: '👤', userType: 0 },
  { key: 'family', label: '家属', icon: '👨‍👩‍👧', userType: 4 }
]

const relationOptions = [
  { label: '配偶', value: '配偶' },
  { label: '子女', value: '子女' },
  { label: '父母', value: '父母' },
  { label: '兄弟姐妹', value: '兄弟姐妹' },
  { label: '其他', value: '其他' }
]

const titleOptions = [
  { label: '住院医师', value: '住院医师' },
  { label: '主治医师', value: '主治医师' },
  { label: '副主任医师', value: '副主任医师' },
  { label: '主任医师', value: '主任医师' }
]

const isFamily = computed(() => registerType.value === 'family')

const handleTypeChange = (type) => {
  registerType.value = type
  const found = registerTypes.find(t => t.key === type)
  if (found) form.value.userType = found.userType
  foundPatient.value = null
}

const searchPatient = async () => {
  if (!form.value.patientPhone || form.value.patientPhone.length !== 11) {
    ElMessage.warning('请输入正确的11位手机号')
    return
  }
  searchingPatient.value = true
  foundPatient.value = null
  try {
    const res = await userApi.searchPatient(form.value.patientPhone)
    foundPatient.value = res
    ElMessage.success('已找到患者，请确认绑定')
  } catch (e) {
    foundPatient.value = null
    ElMessage.error(e.message || '未找到该手机号对应的患者')
  } finally {
    searchingPatient.value = false
  }
}

const handleRegister = async () => {
  if (!form.value.phone) { ElMessage.warning('请输入手机号'); return }
  if (!form.value.password) { ElMessage.warning('请输入密码'); return }
  if (form.value.password !== form.value.confirmPassword) { ElMessage.warning('两次密码输入不一致'); return }
  if (isFamily.value && !form.value.relation) { ElMessage.warning('请选择与患者关系'); return }
  if (isFamily.value && !foundPatient.value) { ElMessage.warning('请先搜索并确认绑定患者'); return }

  loading.value = true
  try {
    const registerData = {
      username: form.value.phone,
      password: form.value.password,
      phone: form.value.phone,
      realName: form.value.realName,
      userType: form.value.userType
    }
    if (isFamily.value) {
      registerData.relation = form.value.relation
      registerData.patientPhone = form.value.patientPhone
      registerData.gender = form.value.gender
      registerData.age = form.value.age
      registerData.idCard = form.value.idCard
      registerData.address = form.value.address
    }
    await userStore.register(registerData)
    ElMessage.success('注册成功，请登录')
    router.push('/login')
  } catch (error) {
    ElMessage.error(error.message || '注册失败')
  } finally {
    loading.value = false
  }
}
</script>

<template>
  <div class="register-container">
    <div class="register-box">
      <div class="register-header">
        <h1>用户注册</h1>
        <p>Smart Medical System</p>
      </div>

      <div class="type-switch">
        <div
          v-for="item in registerTypes"
          :key="item.key"
          :class="['type-btn', { active: registerType === item.key }]"
          @click="handleTypeChange(item.key)"
        >
          <span class="type-icon">{{ item.icon }}</span>
          <span>{{ item.label }}</span>
        </div>
      </div>

      <el-form :model="form" class="register-form">
        <el-form-item>
          <el-input v-model="form.phone" placeholder="手机号（作为登录账号）" prefix-icon="Phone" size="large" maxlength="11" />
        </el-form-item>

        <el-form-item>
          <el-input v-model="form.password" placeholder="密码" type="password" prefix-icon="Lock" size="large" show-password />
        </el-form-item>

        <el-form-item>
          <el-input v-model="form.confirmPassword" placeholder="确认密码" type="password" prefix-icon="Lock" size="large" show-password />
        </el-form-item>

        <el-form-item>
          <el-input v-model="form.realName" placeholder="真实姓名" prefix-icon="UserFilled" size="large" />
        </el-form-item>

        <template v-if="isFamily">
          <el-form-item>
            <el-select v-model="form.gender" placeholder="性别" size="large" style="width: 100%;">
              <el-option label="男" :value="1" />
              <el-option label="女" :value="0" />
            </el-select>
          </el-form-item>
          <el-form-item>
            <el-input v-model="form.age" placeholder="年龄" type="number" size="large" />
          </el-form-item>
          <el-form-item>
            <el-input v-model="form.idCard" placeholder="身份证号" size="large" maxlength="18" />
          </el-form-item>
          <el-form-item>
            <el-input v-model="form.address" placeholder="地址" size="large" />
          </el-form-item>
          <el-form-item>
            <el-select v-model="form.relation" placeholder="与患者关系" size="large" style="width: 100%;">
              <el-option v-for="opt in relationOptions" :key="opt.value" :label="opt.label" :value="opt.value" />
            </el-select>
          </el-form-item>
          <el-form-item>
            <div style="display: flex; gap: 8px; width: 100%;">
              <el-input v-model="form.patientPhone" placeholder="患者手机号" prefix-icon="Phone" size="large" maxlength="11" style="flex: 1;" />
              <el-button type="primary" size="large" :loading="searchingPatient" @click="searchPatient" style="flex-shrink: 0;">搜索</el-button>
            </div>
          </el-form-item>

          <div v-if="foundPatient" class="patient-bind-card">
            <div class="bind-title">✅ 已找到患者，确认绑定</div>
            <div class="bind-info">
              <div class="bind-row">
                <span class="bind-label">患者姓名：</span>
                <span class="bind-value">{{ foundPatient.username }}</span>
              </div>
              <div class="bind-row">
                <span class="bind-label">手机号：</span>
                <span class="bind-value">{{ foundPatient.phone }}</span>
              </div>
              <div class="bind-row" v-if="foundPatient.age">
                <span class="bind-label">年龄：</span>
                <span class="bind-value">{{ foundPatient.age }}岁</span>
              </div>
            </div>
          </div>

          <div v-if="!foundPatient && form.patientPhone && form.patientPhone.length === 11 && !searchingPatient" class="patient-bind-card bind-fail">
            <div class="bind-title">❌ 未找到该手机号对应的患者</div>
            <div class="bind-hint">请确认患者手机号是否正确，或提示患者先注册普通用户账号</div>
          </div>

          <div v-if="!foundPatient && (!form.patientPhone || form.patientPhone.length < 11)" class="patient-bind-card bind-hint-card">
            <div class="bind-title">ℹ️ 绑定患者说明</div>
            <div class="bind-hint">请输入患者的手机号并点击搜索，找到患者后确认绑定。绑定后您将能够查看该患者的健康信息。</div>
          </div>
        </template>

        <el-form-item>
          <el-button type="primary" @click="handleRegister" :loading="loading" class="register-btn" size="large">
            注册{{ registerTypes.find(t => t.key === registerType)?.label }}账号
          </el-button>
        </el-form-item>
      </el-form>

      <div class="login-link">
        已有账号？<a @click="router.push('/login')">立即登录</a>
      </div>
    </div>
  </div>
</template>

<style lang="scss" scoped>
.register-container { min-height: 100vh; display: flex; align-items: center; justify-content: center; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); }
.register-box { width: 460px; background: #fff; border-radius: 16px; padding: 40px; box-shadow: 0 20px 60px rgba(0, 0, 0, 0.15); max-height: 90vh; overflow-y: auto; }
.register-header { text-align: center; margin-bottom: 20px; h1 { font-size: 26px; color: #333; margin-bottom: 8px; } p { color: #999; font-size: 14px; } }
.type-switch { display: flex; flex-wrap: wrap; gap: 8px; margin-bottom: 20px; justify-content: center;
  .type-btn { flex: 0 0 auto; display: flex; align-items: center; gap: 4px; padding: 8px 14px; border: 2px solid #e2e8f0; border-radius: 8px; cursor: pointer; transition: all 0.3s; font-size: 13px; color: #666;
    &:hover { border-color: #667eea; color: #667eea; }
    &.active { border-color: #667eea; background: #f0f0ff; color: #667eea; font-weight: 600; }
    .type-icon { font-size: 16px; }
  }
}
.register-form { margin-bottom: 16px; }
.register-btn { width: 100%; height: 48px; font-size: 16px; }
.login-link { text-align: center; color: #666; font-size: 14px; a { color: #667eea; margin-left: 5px; text-decoration: none; cursor: pointer; &:hover { text-decoration: underline; } } }

.patient-bind-card { margin-bottom: 16px; padding: 16px; border-radius: 10px; background: #f0fff4; border: 1px solid #b7eb8f; }
.patient-bind-card.bind-fail { background: #fff2f0; border-color: #ffccc7; }
.patient-bind-card.bind-hint-card { background: #f0f5ff; border-color: #adc6ff; }
.bind-title { font-size: 14px; font-weight: 600; margin-bottom: 10px; color: #333; }
.bind-info { display: flex; flex-direction: column; gap: 6px; }
.bind-row { display: flex; align-items: center; font-size: 13px; }
.bind-label { color: #999; width: 80px; flex-shrink: 0; }
.bind-value { color: #333; font-weight: 500; }
.bind-hint { font-size: 12px; color: #666; line-height: 1.6; margin-top: 4px; }
</style>
