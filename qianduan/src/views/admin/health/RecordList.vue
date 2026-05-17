<template>
  <div class="health-record-container">
    <div class="page-header">
      <h1>健康档案</h1>
      <p>管理用户健康记录</p>
    </div>

    <div class="stats-cards">
      <div class="stat-card">
        <div class="stat-icon">
          <el-icon><Heart /></el-icon>
        </div>
        <div class="stat-info">
          <div class="stat-value">72</div>
          <div class="stat-label">心率</div>
        </div>
      </div>
      <div class="stat-card">
        <div class="stat-icon bp-icon">
          <el-icon><Activity /></el-icon>
        </div>
        <div class="stat-info">
          <div class="stat-value">120/80</div>
          <div class="stat-label">血压</div>
        </div>
      </div>
      <div class="stat-card">
        <div class="stat-icon sugar-icon">
          <el-icon><Droplets /></el-icon>
        </div>
        <div class="stat-info">
          <div class="stat-value">5.2</div>
          <div class="stat-label">血糖 mmol/L</div>
        </div>
      </div>
      <div class="stat-card">
        <div class="stat-icon weight-icon">
          <el-icon><Scale /></el-icon>
        </div>
        <div class="stat-info">
          <div class="stat-value">68.5</div>
          <div class="stat-label">体重 kg</div>
        </div>
      </div>
    </div>

    <div class="chart-section">
      <h3>健康数据趋势（近7天）</h3>
      <div ref="healthChart" class="chart-container"></div>
    </div>

    <div class="records-section">
      <h3>最近记录</h3>
      <el-table :data="recordList" border>
        <el-table-column prop="recordTime" label="记录时间" width="180" />
        <el-table-column prop="recordType" label="记录类型" width="120">
          <template #default="scope">
            {{ getTypeName(scope.row.recordType) }}
          </template>
        </el-table-column>
        <el-table-column prop="value" label="数值" width="120" />
        <el-table-column prop="unit" label="单位" width="80" />
        <el-table-column prop="status" label="状态" width="100">
          <template #default="scope">
            <el-tag :type="scope.row.status === 'NORMAL' ? 'success' : 'warning'">
              {{ scope.row.status === 'NORMAL' ? '正常' : '异常' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="remark" label="备注" />
      </el-table>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { Heart, Activity, Droplets, Scale } from '@element-plus/icons-vue'
import * as echarts from 'echarts'
import { healthApi } from '../../../../api/health'

const healthChart = ref(null)
const recordList = ref([
  { id: 1, recordTime: '2024-01-15 08:00', recordType: 'HEART_RATE', value: '72', unit: 'bpm', status: 'NORMAL', remark: '' },
  { id: 2, recordTime: '2024-01-15 08:00', recordType: 'BLOOD_PRESSURE', value: '120/80', unit: 'mmHg', status: 'NORMAL', remark: '' },
  { id: 3, recordTime: '2024-01-15 08:05', recordType: 'BLOOD_SUGAR', value: '5.2', unit: 'mmol/L', status: 'NORMAL', remark: '' },
  { id: 4, recordTime: '2024-01-15 08:10', recordType: 'WEIGHT', value: '68.5', unit: 'kg', status: 'NORMAL', remark: '' },
  { id: 5, recordTime: '2024-01-14 22:00', recordType: 'SLEEP', value: '7.5', unit: '小时', status: 'NORMAL', remark: '睡眠质量良好' },
  { id: 6, recordTime: '2024-01-14 20:30', recordType: 'STEPS', value: '8560', unit: '步', status: 'NORMAL', remark: '' }
])

const typeNames = {
  HEART_RATE: '心率',
  BLOOD_PRESSURE: '血压',
  BLOOD_SUGAR: '血糖',
  WEIGHT: '体重',
  SLEEP: '睡眠',
  STEPS: '步数',
  HEIGHT: '身高'
}

const getTypeName = (type) => typeNames[type] || type

onMounted(() => {
  initChart()
})

const initChart = () => {
  if (!healthChart.value) return
  
  const chart = echarts.init(healthChart.value)
  const option = {
    tooltip: { trigger: 'axis' },
    legend: { data: ['心率', '收缩压', '舒张压'] },
    grid: { left: '3%', right: '4%', bottom: '3%', containLabel: true },
    xAxis: { type: 'category', data: ['1月9日', '1月10日', '1月11日', '1月12日', '1月13日', '1月14日', '1月15日'] },
    yAxis: [
      { type: 'value', name: '心率', position: 'left' },
      { type: 'value', name: '血压', position: 'right' }
    ],
    series: [
      { name: '心率', type: 'line', data: [70, 72, 68, 75, 71, 69, 72] },
      { name: '收缩压', type: 'line', yAxisIndex: 1, data: [118, 120, 115, 122, 119, 121, 120] },
      { name: '舒张压', type: 'line', yAxisIndex: 1, data: [78, 80, 76, 82, 79, 81, 80] }
    ]
  }
  
  chart.setOption(option)
}
</script>

<style lang="scss">
.health-record-container {
  padding: 20px;
}

.page-header {
  margin-bottom: 24px;

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

.stats-cards {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 20px;
  margin-bottom: 24px;
}

.stat-card {
  background: #fff;
  border-radius: 12px;
  padding: 20px;
  display: flex;
  align-items: center;
  gap: 16px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.06);
}

.stat-icon {
  width: 48px;
  height: 48px;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 24px;
  color: #fff;
  background: linear-gradient(135deg, #e74c3c 0%, #c0392b 100%);
}

.bp-icon {
  background: linear-gradient(135deg, #3498db 0%, #2980b9 100%);
}

.sugar-icon {
  background: linear-gradient(135deg, #f39c12 0%, #e67e22 100%);
}

.weight-icon {
  background: linear-gradient(135deg, #9b59b6 0%, #8e44ad 100%);
}

.stat-info {
  .stat-value {
    font-size: 28px;
    font-weight: bold;
    color: #1a1a2e;
  }
  .stat-label {
    font-size: 14px;
    color: #666;
    margin-top: 4px;
  }
}

.chart-section,
.records-section {
  background: #fff;
  border-radius: 12px;
  padding: 20px;
  margin-bottom: 20px;

  h3 {
    font-size: 16px;
    font-weight: 600;
    margin-bottom: 16px;
    color: #1a1a2e;
  }
}

.chart-container {
  height: 300px;
}
</style>
