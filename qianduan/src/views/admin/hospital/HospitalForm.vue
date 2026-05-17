<script setup>
import { ref, reactive, onMounted, computed } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import hospitalApi from '@/api/hospital'

const route = useRoute()
const router = useRouter()

const isEdit = computed(() => !!route.query.id)
const isView = computed(() => route.query.view === 'true')
const loading = ref(false)

const formData = reactive({
  name: '',
  level: '',
  address: '',
  phone: '',
  description: '',
  longitude: '',
  latitude: ''
})

const loadHospital = async (id) => {
  loading.value = true
  try {
    const res = await hospitalApi.getDetail(id)
    Object.assign(formData, res)
  } catch (error) {
    ElMessage.error('加载医院信息失败')
  } finally {
    loading.value = false
  }
}

const handleSubmit = async () => {
  if (!formData.name) {
    ElMessage.warning('请输入医院名称')
    return
  }
  loading.value = true
  try {
    if (isEdit.value) {
      await hospitalApi.update(route.query.id, formData)
      ElMessage.success('更新成功')
    } else {
      await hospitalApi.add(formData)
      ElMessage.success('添加成功')
    }
    router.push('/admin/hospital')
  } catch (error) {
    ElMessage.error(error.message || '操作失败')
  } finally {
    loading.value = false
  }
}

onMounted(() => {
  if (route.query.id) {
    loadHospital(route.query.id)
  }
})
</script>

<template>
  <div class="hospital-form">
    <div class="page-header">
      <h3>{{ isView ? '查看医院' : (isEdit ? '编辑医院' : '添加医院') }}</h3>
      <el-button @click="router.push('/admin/hospital')">返回</el-button>
    </div>

    <el-form :model="formData" label-width="100px" :disabled="isView">
      <el-form-item label="医院名称" required>
        <el-input v-model="formData.name" placeholder="请输入医院名称" />
      </el-form-item>
      <el-form-item label="等级">
        <el-select v-model="formData.level" placeholder="请选择等级">
          <el-option label="三级甲等" value="三级甲等" />
          <el-option label="三级" value="三级" />
          <el-option label="二级" value="二级" />
          <el-option label="一级" value="一级" />
        </el-select>
      </el-form-item>
      <el-form-item label="地址">
        <el-input v-model="formData.address" placeholder="请输入地址" />
      </el-form-item>
      <el-form-item label="电话">
        <el-input v-model="formData.phone" placeholder="请输入电话" />
      </el-form-item>
      <el-form-item label="经度">
        <el-input-number v-model="formData.longitude" :precision="6" controls-position="right" />
      </el-form-item>
      <el-form-item label="纬度">
        <el-input-number v-model="formData.latitude" :precision="6" controls-position="right" />
      </el-form-item>
      <el-form-item label="简介">
        <el-input v-model="formData.description" type="textarea" :rows="4" placeholder="请输入简介" />
      </el-form-item>
      <el-form-item v-if="!isView">
        <el-button type="primary" @click="handleSubmit" :loading="loading">保存</el-button>
        <el-button @click="router.push('/admin/hospital')">取消</el-button>
      </el-form-item>
    </el-form>
  </div>
</template>

<style lang="scss" scoped>
.hospital-form { background: #fff; border-radius: 12px; padding: 24px; box-shadow: 0 2px 8px rgba(0,0,0,0.05); }
.page-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; h3 { margin: 0; font-size: 18px; } }
</style>
