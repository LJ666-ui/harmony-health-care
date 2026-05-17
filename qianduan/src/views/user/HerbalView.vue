<script setup>
import { ref, reactive, onMounted } from 'vue'
import { useUserStore } from '@/stores/user'
import herbalApi from '@/api/herbal'
import { ElMessage } from 'element-plus'

const userStore = useUserStore()
const herbalList = ref([])
const total = ref(0)
const currentPage = ref(1)
const pageSize = ref(12)
const loading = ref(false)
const searchForm = reactive({ keyword: '', category: '' })
const categories = ref([])
const detailVisible = ref(false)
const detailData = ref(null)
const collectedIds = ref(new Set())

const loadHerbals = async () => {
  loading.value = true
  try {
    const res = await herbalApi.getList({
      page: currentPage.value,
      size: pageSize.value,
      name: searchForm.keyword,
      keyword: searchForm.keyword
    })
    herbalList.value = res.records || res.list || res || []
    total.value = res.total || 0
  } catch (e) {
    ElMessage.error('加载药材列表失败')
  } finally {
    loading.value = false
  }
}

const loadCategories = async () => {
  try {
    categories.value = await herbalApi.getCategories()
  } catch (e) {}
}

const loadCollected = () => {
  try {
    const stored = localStorage.getItem(`herbal_collected_${userStore.userInfo?.userId || 'guest'}`)
    if (stored) {
      collectedIds.value = new Set(JSON.parse(stored))
    }
  } catch (e) {}
}

const saveCollected = () => {
  localStorage.setItem(`herbal_collected_${userStore.userInfo?.userId || 'guest'}`, JSON.stringify([...collectedIds.value]))
}

const handleSearch = () => { currentPage.value = 1; loadHerbals() }
const handleReset = () => { searchForm.keyword = ''; searchForm.category = ''; handleSearch() }
const handlePageChange = (page) => { currentPage.value = page; loadHerbals() }

const viewDetail = async (row) => {
  detailData.value = row
  detailVisible.value = true
  try {
    await herbalApi.incrementView(row.id)
  } catch (e) {}
}

const toggleCollect = async (row) => {
  const isCollected = collectedIds.value.has(row.id)
  try {
    if (isCollected) {
      await herbalApi.uncollect(row.id)
      collectedIds.value.delete(row.id)
      ElMessage.success('已取消收藏')
    } else {
      await herbalApi.collect(row.id)
      collectedIds.value.add(row.id)
      ElMessage.success('已收藏')
    }
    saveCollected()
  } catch (e) {
    ElMessage.error(e.message || '操作失败')
  }
}

onMounted(() => {
  loadHerbals()
  loadCategories()
  loadCollected()
})
</script>

<template>
  <div class="herbal-view-container">
    <div class="page-header">
      <h1>中药材百科</h1>
      <p>了解中药材的药性、功效与用法</p>
    </div>

    <div class="search-bar">
      <el-input v-model="searchForm.keyword" placeholder="搜索药材名称/拼音" class="search-input" @keyup.enter="handleSearch" />
      <el-select v-model="searchForm.category" placeholder="分类" class="search-input" @change="handleSearch">
        <el-option label="全部" :value="''" />
        <el-option v-for="cat in categories" :key="cat" :label="cat" :value="cat" />
      </el-select>
      <el-button type="primary" @click="handleSearch">搜索</el-button>
      <el-button @click="handleReset">重置</el-button>
    </div>

    <el-row :gutter="16">
      <el-col :xs="12" :sm="8" :md="6" v-for="item in herbalList" :key="item.id">
        <el-card class="herbal-card" shadow="hover" @click="viewDetail(item)">
          <div class="herbal-name">{{ item.name }}</div>
          <div class="herbal-pinyin" v-if="item.pinyin">{{ item.pinyin }}</div>
          <div class="herbal-info">
            <el-tag size="small" v-if="item.category">{{ item.category }}</el-tag>
            <el-tag size="small" type="warning" v-if="item.nature">{{ item.nature }}</el-tag>
          </div>
          <div class="herbal-efficacy" v-if="item.efficacySummary">{{ item.efficacySummary }}</div>
          <div class="herbal-stats">
            <span>👁 {{ item.viewCount || 0 }}</span>
            <span>⭐ {{ item.collectCount || 0 }}</span>
          </div>
          <div class="herbal-actions" @click.stop>
            <el-button :type="collectedIds.has(item.id) ? 'warning' : 'default'" size="small" @click="toggleCollect(item)">
              {{ collectedIds.has(item.id) ? '已收藏' : '收藏' }}
            </el-button>
          </div>
        </el-card>
      </el-col>
    </el-row>

    <el-empty v-if="!loading && herbalList.length === 0" description="暂无药材数据" />

    <el-pagination v-model:current-page="currentPage" v-model:page-size="pageSize" :total="total" @current-change="handlePageChange" layout="total, prev, pager, next" style="margin-top: 20px; text-align: center" />

    <el-dialog v-model="detailVisible" :title="detailData?.name" width="700px">
      <div v-if="detailData">
        <el-descriptions :column="2" border>
          <el-descriptions-item label="名称">{{ detailData.name }}</el-descriptions-item>
          <el-descriptions-item label="拼音">{{ detailData.pinyin }}</el-descriptions-item>
          <el-descriptions-item label="别名">{{ detailData.alias }}</el-descriptions-item>
          <el-descriptions-item label="分类">{{ detailData.category }}</el-descriptions-item>
          <el-descriptions-item label="药性">{{ detailData.nature }}</el-descriptions-item>
          <el-descriptions-item label="味">{{ detailData.taste }}</el-descriptions-item>
          <el-descriptions-item label="归经" :span="2">{{ detailData.meridian }}</el-descriptions-item>
          <el-descriptions-item label="功效概述" :span="2">{{ detailData.efficacySummary }}</el-descriptions-item>
          <el-descriptions-item label="详细功效" :span="2">{{ detailData.efficacyDetail }}</el-descriptions-item>
          <el-descriptions-item label="主治" :span="2">{{ detailData.indication }}</el-descriptions-item>
          <el-descriptions-item label="用法用量" :span="2">{{ detailData.usageDosage }}</el-descriptions-item>
          <el-descriptions-item label="禁忌" :span="2">{{ detailData.contraindication }}</el-descriptions-item>
          <el-descriptions-item label="毒性">{{ detailData.toxicity }}</el-descriptions-item>
          <el-descriptions-item label="炮制方法" :span="2">{{ detailData.processingMethod }}</el-descriptions-item>
          <el-descriptions-item label="来源" :span="2">{{ detailData.sourceOrigin }}</el-descriptions-item>
          <el-descriptions-item label="外观" :span="2">{{ detailData.appearance }}</el-descriptions-item>
          <el-descriptions-item label="经典方剂" :span="2">{{ detailData.classicPrescription }}</el-descriptions-item>
          <el-descriptions-item label="现代研究" :span="2">{{ detailData.modernResearch }}</el-descriptions-item>
          <el-descriptions-item label="浏览量">{{ detailData.viewCount }}</el-descriptions-item>
          <el-descriptions-item label="收藏量">{{ detailData.collectCount }}</el-descriptions-item>
        </el-descriptions>
      </div>
      <template #footer>
        <el-button :type="collectedIds.has(detailData?.id) ? 'warning' : 'primary'" @click="toggleCollect(detailData)">
          {{ collectedIds.has(detailData?.id) ? '取消收藏' : '收藏' }}
        </el-button>
        <el-button @click="detailVisible = false">关闭</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<style lang="scss" scoped>
.herbal-view-container { padding: 20px; }
.page-header { margin-bottom: 20px; h1 { font-size: 22px; font-weight: bold; margin: 0 0 4px; } p { color: #666; font-size: 14px; margin: 0; } }
.search-bar { display: flex; gap: 12px; margin-bottom: 20px; .search-input { width: 200px; } }
.herbal-card { margin-bottom: 16px; cursor: pointer; transition: transform 0.2s; &:hover { transform: translateY(-4px); } }
.herbal-name { font-size: 18px; font-weight: bold; color: #333; }
.herbal-pinyin { font-size: 12px; color: #999; margin-top: 4px; }
.herbal-info { margin-top: 8px; display: flex; gap: 6px; }
.herbal-efficacy { margin-top: 8px; font-size: 13px; color: #666; line-height: 1.5; display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; overflow: hidden; }
.herbal-stats { margin-top: 8px; font-size: 12px; color: #999; display: flex; gap: 12px; }
.herbal-actions { margin-top: 8px; text-align: right; }
</style>
