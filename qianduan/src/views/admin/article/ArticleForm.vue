<script setup>
import { ref, reactive, onMounted, computed } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import articleApi from '@/api/article'
import categoryApi from '@/api/category'

const route = useRoute()
const router = useRouter()

const isEdit = computed(() => !!route.query.id)
const isView = computed(() => route.query.view === 'true')
const loading = ref(false)
const categoryList = ref([])

const formData = reactive({
  title: '',
  content: '',
  author: '',
  categoryId: '',
  summary: '',
  coverImage: '',
  status: 0
})

const loadCategories = async () => {
  try {
    const res = await categoryApi.getList()
    categoryList.value = res.records || res || []
  } catch (error) {
    console.error(error)
  }
}

const loadArticle = async (id) => {
  loading.value = true
  try {
    const res = await articleApi.getDetail(id)
    Object.assign(formData, res)
  } catch (error) {
    ElMessage.error('加载文章失败')
  } finally {
    loading.value = false
  }
}

const handleSubmit = async () => {
  if (!formData.title) {
    ElMessage.warning('请输入标题')
    return
  }
  loading.value = true
  try {
    if (isEdit.value) {
      await articleApi.update({ id: route.query.id, ...formData })
      ElMessage.success('更新成功')
    } else {
      await articleApi.add(formData)
      ElMessage.success('添加成功')
    }
    router.push('/admin/article')
  } catch (error) {
    ElMessage.error(error.message || '操作失败')
  } finally {
    loading.value = false
  }
}

onMounted(() => {
  loadCategories()
  if (route.query.id) {
    loadArticle(route.query.id)
  }
})
</script>

<template>
  <div class="article-form">
    <div class="page-header">
      <h3>{{ isView ? '查看文章' : (isEdit ? '编辑文章' : '添加文章') }}</h3>
      <el-button @click="router.push('/admin/article')">返回</el-button>
    </div>

    <el-form :model="formData" label-width="100px" :disabled="isView">
      <el-form-item label="标题" required>
        <el-input v-model="formData.title" placeholder="请输入文章标题" />
      </el-form-item>
      <el-form-item label="作者">
        <el-input v-model="formData.author" placeholder="请输入作者" />
      </el-form-item>
      <el-form-item label="分类">
        <el-select v-model="formData.categoryId" placeholder="请选择分类">
          <el-option v-for="cat in categoryList" :key="cat.id" :label="cat.name" :value="cat.id" />
        </el-select>
      </el-form-item>
      <el-form-item label="摘要">
        <el-input v-model="formData.summary" type="textarea" :rows="3" placeholder="请输入摘要" />
      </el-form-item>
      <el-form-item label="内容" required>
        <el-input v-model="formData.content" type="textarea" :rows="12" placeholder="请输入文章内容" />
      </el-form-item>
      <el-form-item label="状态">
        <el-radio-group v-model="formData.status">
          <el-radio :value="0">草稿</el-radio>
          <el-radio :value="1">发布</el-radio>
        </el-radio-group>
      </el-form-item>
      <el-form-item v-if="!isView">
        <el-button type="primary" @click="handleSubmit" :loading="loading">保存</el-button>
        <el-button @click="router.push('/admin/article')">取消</el-button>
      </el-form-item>
    </el-form>
  </div>
</template>

<style lang="scss" scoped>
.article-form { background: #fff; border-radius: 12px; padding: 24px; box-shadow: 0 2px 8px rgba(0,0,0,0.05); }
.page-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; h3 { margin: 0; font-size: 18px; } }
</style>
