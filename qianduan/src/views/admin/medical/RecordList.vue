<template>
  <div class="record-list-container">
    <div class="page-header">
      <h1>病历管理</h1>
      <p>管理患者病历信息</p>
    </div>

    <div class="search-bar">
      <el-input v-model="searchForm.keyword" placeholder="搜索患者姓名或病历号" class="search-input">
        <template #suffix><el-icon><Search /></el-icon></template>
      </el-input>
      <el-button type="primary" @click="handleSearch">搜索</el-button>
      <el-button @click="handleReset">重置</el-button>
    </div>

    <div class="table-toolbar">
      <el-button type="primary" @click="handleAdd">新建病历</el-button>
    </div>

    <el-table :data="tableData" border>
      <el-table-column prop="id" label="病历ID" width="100" />
      <el-table-column prop="patientName" label="患者姓名" width="120" />
      <el-table-column prop="patientIdCard" label="身份证号" width="180" />
      <el-table-column prop="hospitalName" label="就诊医院" width="150" />
      <el-table-column prop="departmentName" label="就诊科室" width="120" />
      <el-table-column prop="doctorName" label="主治医生" width="120" />
      <el-table-column prop="diagnosis" label="诊断结果" min-width="200" />
      <el-table-column prop="recordTime" label="记录时间" width="180" />
      <el-table-column label="操作" width="180">
        <template #default="scope">
          <el-button size="small" @click="handleView(scope.row)">查看</el-button>
          <el-button size="small" @click="handleEdit(scope.row)">编辑</el-button>
          <el-button size="small" type="danger" @click="handleDelete(scope.row)">删除</el-button>
        </template>
      </el-table-column>
    </el-table>

    <el-pagination
      :current-page="pagination.currentPage"
      :page-size="pagination.pageSize"
      :total="pagination.total"
      @current-change="handlePageChange"
      layout="total, prev, pager, next, jumper"
    />

    <el-dialog title="病历详情" :visible.sync="detailVisible" width="700px">
      <div v-if="detailData" class="record-detail">
        <div class="detail-section">
          <h4>基本信息</h4>
          <div class="detail-grid">
            <div>
              <span class="label">患者姓名：</span>
              <span>{{ detailData.patientName }}</span>
            </div>
            <div>
              <span class="label">身份证号：</span>
              <span>{{ detailData.patientIdCard }}</span>
            </div>
            <div>
              <span class="label">性别：</span>
              <span>{{ detailData.gender === 0 ? '男' : '女' }}</span>
            </div>
            <div>
              <span class="label">年龄：</span>
              <span>{{ detailData.age }}</span>
            </div>
            <div>
              <span class="label">联系电话：</span>
              <span>{{ detailData.phone }}</span>
            </div>
          </div>
        </div>
        <div class="detail-section">
          <h4>就诊信息</h4>
          <div class="detail-grid">
            <div>
              <span class="label">就诊医院：</span>
              <span>{{ detailData.hospitalName }}</span>
            </div>
            <div>
              <span class="label">就诊科室：</span>
              <span>{{ detailData.departmentName }}</span>
            </div>
            <div>
              <span class="label">主治医生：</span>
              <span>{{ detailData.doctorName }}</span>
            </div>
            <div>
              <span class="label">就诊时间：</span>
              <span>{{ detailData.recordTime }}</span>
            </div>
          </div>
        </div>
        <div class="detail-section">
          <h4>诊断结果</h4>
          <p>{{ detailData.diagnosis }}</p>
        </div>
        <div class="detail-section">
          <h4>治疗方案</h4>
          <p>{{ detailData.treatmentPlan }}</p>
        </div>
        <div class="detail-section">
          <h4>医嘱</h4>
          <p>{{ detailData.doctorAdvice }}</p>
        </div>
      </div>
      <template #footer>
        <el-button @click="detailVisible = false">关闭</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { Search } from '@element-plus/icons-vue'
import { medicalApi } from '../../../../api/medical'

const tableData = ref([])
const detailVisible = ref(false)
const detailData = ref(null)

const searchForm = reactive({
  keyword: ''
})

const pagination = reactive({
  currentPage: 1,
  pageSize: 10,
  total: 0
})

onMounted(() => {
  loadData()
})

const loadData = async () => {
  try {
    const data = await medicalApi.recordList({
      page: pagination.currentPage,
      size: pagination.pageSize,
      keyword: searchForm.keyword
    })
    tableData.value = data.list || data.records || []
    pagination.total = data.total || 0
  } catch (error) {
    console.error('加载病历列表失败:', error)
  }
}

const handleSearch = () => {
  pagination.currentPage = 1
  loadData()
}

const handleReset = () => {
  searchForm.keyword = ''
  handleSearch()
}

const handlePageChange = (page) => {
  pagination.currentPage = page
  loadData()
}

const handleAdd = () => {
  alert('新建病历功能开发中')
}

const handleEdit = (row) => {
  alert('编辑病历功能开发中')
}

const handleView = (row) => {
  detailData.value = row
  detailVisible.value = true
}

const handleDelete = async (row) => {
  if (confirm(`确定删除病历 ID:${row.id} 吗？`)) {
    try {
      await medicalApi.recordDelete(row.id)
      loadData()
    } catch (error) {
      alert(error.message || '删除失败')
    }
  }
}
</script>

<style lang="scss">
.record-list-container {
  padding: 20px;
}

.page-header {
  margin-bottom: 20px;

  h1 {
    font-size: 20px;
    font-weight: bold;
    margin-bottom: 4px;
  }

  p {
    color: #666;
    font-size: 14px;
  }
}

.search-bar {
  display: flex;
  gap: 12px;
  margin-bottom: 20px;

  .search-input {
    width: 300px;
  }
}

.table-toolbar {
  display: flex;
  gap: 12px;
  margin-bottom: 16px;
}

.record-detail {
  .detail-section {
    margin-bottom: 20px;
    padding-bottom: 20px;
    border-bottom: 1px solid #eee;

    &:last-child {
      border-bottom: none;
    }

    h4 {
      font-size: 14px;
      font-weight: 600;
      margin-bottom: 12px;
      color: #333;
    }
  }

  .detail-grid {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 12px;
  }

  .label {
    color: #666;
    font-weight: 500;
  }
}
</style>
