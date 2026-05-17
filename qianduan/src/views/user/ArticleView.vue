<script setup>
import { ref, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import articleApi from '@/api/article'

const articleList = ref([])
const searchForm = ref({ title: '' })
const loading = ref(false)
const pagination = ref({ page: 1, pageSize: 10, total: 0 })
const detailVisible = ref(false)
const detailData = ref(null)

const loadArticles = async () => {
  loading.value = true
  try {
    const res = await articleApi.getPage({
      page: pagination.value.page,
      pageSize: pagination.value.pageSize,
      title: searchForm.value.title
    })
    articleList.value = res.list || res.records || []
    pagination.value.total = res.total || 0
  } catch (error) {
    ElMessage.error('加载文章列表失败')
  } finally {
    loading.value = false
  }
}

const handleView = async (row) => {
  try {
    const res = await articleApi.getDetail(row.id)
    detailData.value = res
    detailVisible.value = true
  } catch (error) {
    detailData.value = row
    detailVisible.value = true
  }
}

onMounted(() => {
  loadArticles()
})
</script>

<template>
  <div class="article-view">
    <div class="search-bar">
      <el-input v-model="searchForm.title" placeholder="搜索文章标题" class="search-input" @keyup.enter="loadArticles" />
      <el-button type="primary" @click="loadArticles">搜索</el-button>
    </div>

    <el-table :data="articleList" :loading="loading" border>
      <el-table-column prop="id" label="ID" width="80" />
      <el-table-column prop="title" label="标题" />
      <el-table-column prop="author" label="作者" width="100" />
      <el-table-column prop="viewCount" label="浏览量" width="100" />
      <el-table-column prop="publishTime" label="发布时间" width="180" />
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
      @current-change="(page) => { pagination.page = page; loadArticles() }"
      style="margin-top: 20px; text-align: right"
    />

    <el-dialog v-model="detailVisible" title="文章详情" width="700px">
      <div v-if="detailData" class="article-detail">
        <h2>{{ detailData.title }}</h2>
        <div class="meta">
          <span>作者：{{ detailData.author }}</span>
          <span>发布时间：{{ detailData.publishTime }}</span>
          <span>浏览量：{{ detailData.viewCount }}</span>
        </div>
        <el-divider />
        <div class="content" v-html="detailData.content"></div>
      </div>
      <template #footer>
        <el-button @click="detailVisible = false">关闭</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<style lang="scss" scoped>
.article-view {
  background: #fff;
  border-radius: 12px;
  padding: 20px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
}

.search-bar {
  display: flex;
  gap: 12px;
  margin-bottom: 20px;
  .search-input { width: 300px; }
}

.article-detail {
  h2 { font-size: 20px; margin: 0 0 12px; }
  .meta {
    display: flex;
    gap: 20px;
    font-size: 13px;
    color: #999;
  }
  .content {
    line-height: 1.8;
    color: #333;
  }
}
</style>
