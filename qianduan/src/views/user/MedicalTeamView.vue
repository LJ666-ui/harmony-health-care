<script setup>
import { ref, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { useUserStore } from '@/stores/user'
import userApi from '@/api/user'

const userStore = useUserStore()
const doctors = ref([])
const nurses = ref([])
const loading = ref(false)

const loadData = async () => {
  loading.value = true
  try {
    const userId = userStore.userInfo?.userId
    const [docRes, nurseRes] = await Promise.all([
      userApi.getMyDoctors(userId),
      userApi.getMyNurses(userId)
    ])
    doctors.value = docRes || []
    nurses.value = nurseRes || []
  } catch (error) {
    ElMessage.error('加载医护信息失败')
  } finally {
    loading.value = false
  }
}

onMounted(() => {
  loadData()
})
</script>

<template>
  <div class="medical-team-view" v-loading="loading">
    <el-row :gutter="20">
      <el-col :span="12">
        <el-card>
          <template #header>
            <div class="card-header">
              <span>🩺 我的治疗医生</span>
              <el-tag type="primary" size="small">共 {{ doctors.length }} 位</el-tag>
            </div>
          </template>
          <div v-if="doctors.length === 0" class="empty-state">
            <el-empty description="暂无关联医生" />
          </div>
          <div v-else class="team-list">
            <div v-for="doc in doctors" :key="doc.id" class="team-card">
              <div class="team-avatar doctor-avatar">医</div>
              <div class="team-info">
                <div class="team-name">{{ doc.userName || '未知' }}</div>
                <div class="team-detail">
                  <span v-if="doc.department">科室：{{ doc.department }}</span>
                  <span v-if="doc.title">职称：{{ doc.title }}</span>
                </div>
                <div class="team-detail">
                  <span v-if="doc.specialty">专长：{{ doc.specialty }}</span>
                </div>
                <div class="team-detail" v-if="doc.hospitalName || doc.hospital">
                  <span>医院：{{ doc.hospitalName || doc.hospital }}</span>
                </div>
                <div class="team-detail" v-if="doc.description">
                  <span>简介：{{ doc.description }}</span>
                </div>
              </div>
            </div>
          </div>
        </el-card>
      </el-col>
      <el-col :span="12">
        <el-card>
          <template #header>
            <div class="card-header">
              <span>👩‍⚕️ 我的护理护士</span>
              <el-tag type="success" size="small">共 {{ nurses.length }} 位</el-tag>
            </div>
          </template>
          <div v-if="nurses.length === 0" class="empty-state">
            <el-empty description="暂无关联护士" />
          </div>
          <div v-else class="team-list">
            <div v-for="nur in nurses" :key="nur.id" class="team-card">
              <div class="team-avatar nurse-avatar">护</div>
              <div class="team-info">
                <div class="team-name">{{ nur.userName || '未知' }}</div>
                <div class="team-detail">
                  <span v-if="nur.department">科室：{{ nur.department }}</span>
                  <span v-if="nur.title">职称：{{ nur.title }}</span>
                </div>
                <div class="team-detail" v-if="nur.nurseNo">
                  <span>工号：{{ nur.nurseNo }}</span>
                </div>
              </div>
            </div>
          </div>
        </el-card>
      </el-col>
    </el-row>
  </div>
</template>

<style lang="scss" scoped>
.medical-team-view { min-height: 400px; }
.card-header { display: flex; justify-content: space-between; align-items: center; font-size: 16px; font-weight: 500; }
.team-list { display: flex; flex-direction: column; gap: 12px; }
.team-card { display: flex; gap: 14px; padding: 14px; background: #f8f9fa; border-radius: 10px; transition: box-shadow 0.2s;
  &:hover { box-shadow: 0 2px 8px rgba(0,0,0,0.08); }
}
.team-avatar { width: 48px; height: 48px; border-radius: 50%; display: flex; align-items: center; justify-content: center; color: #fff; font-size: 16px; font-weight: bold; flex-shrink: 0; }
.doctor-avatar { background: #409eff; }
.nurse-avatar { background: #67c23a; }
.team-info { flex: 1; }
.team-name { font-size: 16px; font-weight: 600; color: #333; margin-bottom: 6px; }
.team-detail { font-size: 13px; color: #666; margin-bottom: 3px; display: flex; gap: 16px; }
.empty-state { padding: 20px 0; }
</style>
