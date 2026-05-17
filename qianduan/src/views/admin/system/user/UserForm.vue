<script setup>
import { ref, reactive, onMounted, computed } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import userApi from '@/api/user'

const route = useRoute()
const router = useRouter()

const isEdit = computed(() => !!route.query.id)
const isView = computed(() => route.query.view === 'true')
const loading = ref(false)

const form = reactive({
  username: '',
  phone: '',
  password: '',
  userType: 0,
  status: 1
})

const userTypeOptions = [
  { value: 0, label: '普通用户' },
  { value: 1, label: '医生' },
  { value: 2, label: '管理员' },
  { value: 3, label: '护士' }
]

const loadUser = async () => {
  if (isEdit.value && route.query.id) {
    loading.value = true
    try {
      const res = await userApi.getDetail(route.query.id)
      Object.assign(form, res)
    } catch (error) {
      ElMessage.error('加载用户信息失败')
    } finally {
      loading.value = false
    }
  }
}

const handleSubmit = async () => {
  if (!form.username) {
    ElMessage.warning('请输入用户名')
    return
  }
  if (!form.phone) {
    ElMessage.warning('请输入手机号')
    return
  }
  if (!isEdit.value && !form.password) {
    ElMessage.warning('请输入密码')
    return
  }
  loading.value = true
  try {
    if (isEdit.value) {
      await userApi.update(route.query.id, form)
      ElMessage.success('修改成功')
    } else {
      await userApi.add(form)
      ElMessage.success('新增成功')
    }
    router.push('/admin/user')
  } catch (error) {
    ElMessage.error(error.message || '操作失败')
  } finally {
    loading.value = false
  }
}

onMounted(() => {
  loadUser()
})
</script>

<template>
  <div class="user-form">
    <div class="page-header">
      <h3>{{ isView ? '查看用户' : (isEdit ? '编辑用户' : '添加用户') }}</h3>
      <el-button @click="router.push('/admin/user')">返回</el-button>
    </div>

    <el-form :model="form" label-width="120px" :disabled="isView" class="form-body">
      <el-form-item label="用户名">
        <el-input v-model="form.username" placeholder="请输入用户名" />
      </el-form-item>
      <el-form-item label="手机号">
        <el-input v-model="form.phone" placeholder="请输入手机号" />
      </el-form-item>
      <el-form-item label="密码">
        <el-input v-model="form.password" type="password" placeholder="请输入密码" :disabled="isEdit" />
        <span v-if="isEdit" class="password-hint">编辑时密码保持不变</span>
      </el-form-item>
      <el-form-item label="角色">
        <el-select v-model="form.userType" placeholder="请选择角色">
          <el-option v-for="opt in userTypeOptions" :key="opt.value" :value="opt.value" :label="opt.label" />
        </el-select>
      </el-form-item>
      <el-form-item label="状态">
        <el-switch v-model="form.status" :active-value="1" :inactive-value="0" />
      </el-form-item>
      <el-form-item v-if="!isView">
        <el-button type="primary" @click="handleSubmit" :loading="loading">保存</el-button>
        <el-button @click="router.push('/admin/user')">取消</el-button>
      </el-form-item>
    </el-form>
  </div>
</template>

<style lang="scss" scoped>
.user-form { background: #fff; border-radius: 12px; padding: 24px; box-shadow: 0 2px 8px rgba(0,0,0,0.05); max-width: 600px; }
.page-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; h3 { margin: 0; font-size: 18px; } }
.password-hint { font-size: 12px; color: #999; margin-left: 10px; }
</style>
