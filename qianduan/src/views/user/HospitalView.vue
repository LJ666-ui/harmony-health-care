<script setup>
import { ref, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import hospitalApi from '@/api/hospital'

const hospitalList = ref([])
const searchForm = ref({ name: '', level: '' })
const loading = ref(false)
const pagination = ref({ page: 1, pageSize: 10, total: 0 })
const detailVisible = ref(false)
const detailData = ref(null)

const loadHospitals = async () => {
  loading.value = true
  try {
    const res = await hospitalApi.getPage({
      page: pagination.value.page,
      size: pagination.value.pageSize,
      ...searchForm.value
    })
    hospitalList.value = res.records || res.list || []
    pagination.value.total = res.total || 0
  } catch (error) {
    ElMessage.error('加载医院列表失败')
  } finally {
    loading.value = false
  }
}

const handleView = async (row) => {
  try {
    const res = await hospitalApi.getDetail(row.id)
    detailData.value = res
    detailVisible.value = true
  } catch (error) {
    detailData.value = row
    detailVisible.value = true
  }
}

onMounted(() => {
  loadHospitals()
})
</script>

<template>
  <div class="hospital-view">
    <div class="search-bar">
      <el-input v-model="searchForm.name" placeholder="搜索医院名称" class="search-input" @keyup.enter="loadHospitals" />
      <el-select v-model="searchForm.level" placeholder="医院等级" class="search-input" clearable>
        <el-option label="全部" value="" />
        <el-option label="三级甲等" value="三级甲等" />
        <el-option label="综合医院" value="综合医院" />
        <el-option label="专科医院" value="专科医院" />
      </el-select>
      <el-button type="primary" @click="loadHospitals">搜索</el-button>
    </div>

    <el-table :data="hospitalList" :loading="loading" border>
      <el-table-column prop="id" label="ID" width="80" />
      <el-table-column prop="name" label="医院名称" />
      <el-table-column prop="level" label="等级" width="100" />
      <el-table-column prop="address" label="地址" />
      <el-table-column prop="phone" label="电话" width="130" />
      <el-table-column label="操作" width="100">
        <template #default="scope">
          <el-button size="small" @click="handleView(scope.row)">查看</el-button>
        </template>
      </el-table-column>
    </el-table>

    <el-pagination
      :current-page="pagination.page"
      :page-size="pagination.pageSize"
      :total="pagination.total"
      @current-change="(page) => { pagination.page = page; loadHospitals() }"
      style="margin-top: 20px; text-align: right"
    />

    <el-dialog v-model="detailVisible" title="医院详情" width="600px">
      <div v-if="detailData" class="hospital-detail">
        <h2>{{ detailData.name }}</h2>
        <el-descriptions :column="1" border>
          <el-descriptions-item label="等级">{{ detailData.level }}</el-descriptions-item>
          <el-descriptions-item label="地址">{{ detailData.address }}</el-descriptions-item>
          <el-descriptions-item label="电话">{{ detailData.phone }}</el-descriptions-item>
          <el-descriptions-item label="简介">{{ detailData.description }}</el-descriptions-item>
        </el-descriptions>
      </div>
      <template #footer>
        <el-button @click="detailVisible = false">关闭</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<style lang="scss" scoped>
.hospital-view {
  background: #fff;
  border-radius: 12px;
  padding: 20px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
}
.search-bar {
  display: flex;
  gap: 12px;
  margin-bottom: 20px;
  .search-input { width: 200px; }
}
.hospital-detail {
  h2 { font-size: 20px; margin: 0 0 16px; }
}
</style>
