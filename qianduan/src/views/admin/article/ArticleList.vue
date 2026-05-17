<script setup>
import { ref, onMounted } from 'vue'
import { useI18n } from 'vue-i18n'
import { useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import articleApi from '@/api/article'

const { t } = useI18n()
const router = useRouter()

const articleList = ref([])
const searchForm = ref({ title: '' })
const loading = ref(false)
const pagination = ref({ page: 1, pageSize: 10, total: 0 })

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

const handleEdit = (row) => {
  router.push({ path: '/admin/article/form', query: { id: row.id } })
}

const handleDelete = async (row) => {
  try {
    await ElMessageBox.confirm(`确定删除文章 "${row.title}" 吗？`, '提示', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })
    await articleApi.delete(row.id)
    ElMessage.success('删除成功')
    loadArticles()
  } catch (error) {
    if (error !== 'cancel') {
      ElMessage.error(error.message || '删除失败')
    }
  }
}

const handleView = (row) => {
  router.push({ path: '/admin/article/form', query: { id: row.id, view: true } })
}

onMounted(() => {
  loadArticles()
})
</script>

<template>
  <div class="article-list">
    <div class="search-bar">
      <el-input v-model="searchForm.title" placeholder="搜索文章标题" class="search-input" @keyup.enter="loadArticles" />
      <el-button type="primary" @click="loadArticles">搜索</el-button>
      <el-button type="success" @click="router.push('/admin/article/form')">添加文章</el-button>
    </div>

    <el-table :data="articleList" :loading="loading" border class="article-table">
      <el-table-column prop="id" label="ID" width="80" />
      <el-table-column prop="title" label="标题" />
      <el-table-column prop="author" label="作者" width="100" />
      <el-table-column prop="viewCount" label="浏览量" width="100" />
      <el-table-column prop="collectCount" label="收藏量" width="100" />
      <el-table-column prop="publishTime" label="发布时间" width="180" />
      <el-table-column label="操作" width="200">
        <template #default="scope">
          <el-button size="small" @click="handleView(scope.row)">查看</el-button>
          <el-button size="small" @click="handleEdit(scope.row)">编辑</el-button>
          <el-button size="small" type="danger" @click="handleDelete(scope.row)">删除</el-button>
        </template>
      </el-table-column>
    </el-table>

    <el-pagination
      :current-page="pagination.page"
      :page-size="pagination.pageSize"
      :total="pagination.total"
      class="pagination"
      @current-change="(page) => { pagination.page = page; loadArticles() }"
    />
  </div>
</template>

<style lang="scss" scoped>
.article-list { background: #fff; border-radius: 12px; padding: 20px; box-shadow: 0 2px 8px rgba(0,0,0,0.05); }
.search-bar { display: flex; gap: 12px; margin-bottom: 20px; .search-input { width: 300px; } }
.pagination { margin-top: 20px; text-align: right; }
</style>
