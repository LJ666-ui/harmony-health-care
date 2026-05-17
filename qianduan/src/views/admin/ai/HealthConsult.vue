<template>
  <div class="health-consult-container">
    <div class="consult-header">
      <h2>{{ $t('ai.healthConsult') }}</h2>
    </div>
    <div class="consult-form">
      <el-form ref="formRef" :model="formData" :rules="rules" label-width="120px">
        <el-form-item :label="$t('ai.question')" prop="question">
          <el-input v-model="formData.question" type="textarea" :rows="4"></el-input>
        </el-form-item>
        <el-form-item :label="t('healthRecord.bloodPressure')">
          <el-input v-model="formData.healthProfile.bloodPressure" placeholder="例如: 120/80"></el-input>
        </el-form-item>
        <el-form-item :label="t('healthRecord.bloodSugar')">
          <el-input v-model="formData.healthProfile.bloodSugar" placeholder="例如: 5.2"></el-input>
        </el-form-item>
        <el-form-item :label="t('healthRecord.heartRate')">
          <el-input v-model="formData.healthProfile.heartRate" placeholder="例如: 72"></el-input>
        </el-form-item>
        <el-form-item :label="t('user.age')">
          <el-input v-model="formData.healthProfile.age" placeholder="例如: 35"></el-input>
        </el-form-item>
        <el-form-item :label="t('user.userType')">
          <el-select v-model="formData.healthProfile.gender">
            <el-option label="男" value="male"></el-option>
            <el-option label="女" value="female"></el-option>
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleConsult" :loading="loading">
            {{ $t('ai.send') }}
          </el-button>
        </el-form-item>
      </el-form>
    </div>
    <div v-if="result" class="consult-result">
      <h3>{{ $t('common.detail') }}</h3>
      <div class="result-content">{{ result }}</div>
    </div>
  </div>
</template>

<script setup>
import { reactive, ref } from 'vue'
import { useI18n } from 'vue-i18n'
import { aiApi } from '@/api/ai'
import { ElMessage } from 'element-plus'

const { t } = useI18n()

const formData = reactive({
  question: '',
  healthProfile: {
    bloodPressure: '',
    bloodSugar: '',
    heartRate: '',
    age: '',
    gender: ''
  }
})

const rules = {
  question: [{ required: true, message: '请输入健康问题', trigger: 'blur' }]
}

const loading = ref(false)
const result = ref('')

const handleConsult = async () => {
  if (!formData.question.trim()) {
    ElMessage.error('请输入健康问题')
    return
  }
  
  loading.value = true
  
  try {
    const res = await aiApi.healthConsult(formData)
    loading.value = false
    if (res.code === 200) {
      result.value = res.data
    } else {
      ElMessage.error(res.message || '咨询失败')
    }
  } catch (error) {
    loading.value = false
    ElMessage.error('网络错误，请稍后重试')
  }
}
</script>

<style lang="scss" scoped>
.health-consult-container {
  background: #fff;
  border-radius: 12px;
  padding: 20px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
}

.consult-header {
  margin-bottom: 20px;

  h2 {
    font-size: 18px;
    margin: 0;
    color: #333;
  }
}

.consult-form {
  max-width: 600px;
  margin-bottom: 30px;
}

.consult-result {
  background: #f0f9ff;
  border-radius: 8px;
  padding: 20px;

  h3 {
    font-size: 16px;
    margin: 0 0 15px 0;
    color: #333;
  }

  .result-content {
    font-size: 14px;
    line-height: 1.8;
    color: #666;
    white-space: pre-wrap;
  }
}

@media (max-width: 768px) {
  .consult-form {
    max-width: 100%;
  }
}
</style>
