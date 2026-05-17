<template>
  <div class="drug-interaction">
    <el-card class="header-card">
      <div class="page-header">
        <div class="header-icon">💊</div>
        <div class="header-text">
          <h2>AI药物相互作用检测</h2>
          <p>覆盖中西药联合用药安全，智能配伍禁忌检查</p>
        </div>
      </div>
    </el-card>

    <div class="main-content">
      <el-card class="input-card">
        <template #header><span>🔍 输入药品</span></template>

        <div class="drug-input-area">
          <el-select v-model="selectedDrugs" multiple filterable remote reserve-keyword
                     :remote-method="searchDrugs" :loading="searching" placeholder="搜索药品名称..."
                     style="width: 100%" size="large" value-key="id">
            <el-option v-for="drug in drugOptions" :key="drug.id" :label="drug.name + ' (' + drug.category + ')'" :value="drug.id">
              <div class="drug-option">
                <span :class="['drug-category-tag', drug.category]">{{ drug.category }}</span>
                <span class="drug-option-name">{{ drug.name }}</span>
                <span class="drug-option-type">{{ drug.type }}</span>
              </div>
            </el-option>
          </el-select>

          <div class="selected-drugs" v-if="selectedDrugs.length">
            <div class="selected-label">已选药品：</div>
            <div class="selected-list">
              <el-tag v-for="drugId in selectedDrugs" :key="drugId" closable
                      @close="removeDrug(drugId)" :type="getDrugCategory(drugId) === '中药' ? 'success' : ''"
                      effect="dark" size="large" class="drug-tag">
                {{ getDrugName(drugId) }}
              </el-tag>
            </div>
          </div>

          <el-button type="primary" @click="checkInteractions" :loading="checking"
                     :disabled="selectedDrugs.length < 2" size="large" round style="margin-top: 16px; width: 100%">
            🔬 开始检测 ({{ selectedDrugs.length }}种药品)
          </el-button>
        </div>
      </el-card>

      <el-card v-if="result" class="result-card">
        <template #header>
          <div class="result-header">
            <span>📋 检测结果</span>
            <el-tag :type="riskTagType" size="large" effect="dark">{{ result.summary.overallRisk }}</el-tag>
          </div>
        </template>

        <div class="risk-summary">
          <div class="risk-stat">
            <span class="risk-num danger">{{ result.summary.highRisk }}</span>
            <span class="risk-label">高风险</span>
          </div>
          <div class="risk-stat">
            <span class="risk-num warning">{{ result.summary.mediumRisk }}</span>
            <span class="risk-label">中风险</span>
          </div>
          <div class="risk-stat">
            <span class="risk-num info">{{ result.summary.lowRisk }}</span>
            <span class="risk-label">低风险</span>
          </div>
          <div class="risk-stat">
            <span class="risk-num total">{{ result.summary.totalInteractions }}</span>
            <span class="risk-label">总相互作用</span>
          </div>
        </div>

        <div class="warnings" v-if="result.warnings?.length">
          <el-alert v-for="(w, i) in result.warnings" :key="i"
                    :title="w.message" :type="w.level" show-icon :closable="false" style="margin-bottom: 8px" />
        </div>

        <div class="interactions-list">
          <div v-for="(interaction, index) in result.interactions" :key="index"
               :class="['interaction-item', interaction.riskLevel]">
            <div class="interaction-header">
              <div class="drug-pair">
                <span class="drug-name">{{ interaction.drugAName }}</span>
                <span class="interaction-symbol">⚡</span>
                <span class="drug-name">{{ interaction.drugBName }}</span>
              </div>
              <div class="interaction-badges">
                <el-tag :type="riskLevelTag(interaction.riskLevel)" effect="dark" size="small">
                  {{ riskLevelText(interaction.riskLevel) }}
                </el-tag>
                <el-tag v-if="interaction.interactionType" type="warning" size="small">
                  {{ interaction.interactionType }}
                </el-tag>
              </div>
            </div>
            <div class="interaction-title">{{ interaction.riskTitle }}</div>
            <div class="interaction-desc">{{ interaction.description }}</div>
            <div class="interaction-recommendation">
              <span class="rec-icon">💡</span>
              <span>{{ interaction.recommendation }}</span>
            </div>
          </div>
        </div>
      </el-card>

      <el-card v-if="!result && selectedDrugs.length >= 2" class="tip-card">
        <div class="tip-content">
          <span class="tip-icon">💡</span>
          <span>已选择 {{ selectedDrugs.length }} 种药品，点击"开始检测"查看相互作用</span>
        </div>
      </el-card>
    </div>

    <el-card class="database-card">
      <template #header><span>📚 药品数据库</span></template>
      <div class="db-filter">
        <el-radio-group v-model="dbCategory" @change="loadDrugDB">
          <el-radio-button value="">全部</el-radio-button>
          <el-radio-button value="西药">西药</el-radio-button>
          <el-radio-button value="中药">中药</el-radio-button>
        </el-radio-group>
      </div>
      <div class="drug-db-grid">
        <div v-for="drug in drugDatabase" :key="drug.id"
             :class="['db-drug-item', { selected: selectedDrugs.includes(drug.id) }]"
             @click="toggleDrug(drug.id)">
          <span :class="['db-category', drug.category]">{{ drug.category }}</span>
          <span class="db-name">{{ drug.name }}</span>
          <span class="db-type">{{ drug.type }}</span>
          <span class="db-desc">{{ drug.description }}</span>
        </div>
      </div>
    </el-card>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import request from '@/utils/request'
import { ElMessage } from 'element-plus'

const selectedDrugs = ref([])
const drugOptions = ref([])
const drugDatabase = ref([])
const searching = ref(false)
const checking = ref(false)
const result = ref(null)
const dbCategory = ref('')

const riskTagType = computed(() => {
  if (!result.value) return 'info'
  const risk = result.value.summary.overallRisk
  if (risk === '高风险') return 'danger'
  if (risk === '中等风险') return 'warning'
  return 'success'
})

onMounted(() => {
  loadDrugDB()
  searchDrugs('')
})

async function searchDrugs(query) {
  searching.value = true
  try {
    const res = await request.get('/drug-interaction/drugs', { params: { keyword: query } })
    drugOptions.value = res || []
  } catch (e) { drugOptions.value = [] }
  finally { searching.value = false }
}

async function loadDrugDB() {
  try {
    const res = await request.get('/drug-interaction/drugs', { params: { category: dbCategory.value } })
    drugDatabase.value = res || []
  } catch (e) { drugDatabase.value = [] }
}

async function checkInteractions() {
  if (selectedDrugs.value.length < 2) {
    ElMessage.warning('请至少选择两种药品')
    return
  }
  checking.value = true
  try {
    const res = await request.post('/drug-interaction/check', { drugs: selectedDrugs.value })
    result.value = res
    if (res?.summary?.highRisk > 0) {
      ElMessage.error(`发现${res.summary.highRisk}项高风险相互作用！`)
    } else if (res?.summary?.totalInteractions > 0) {
      ElMessage.warning(`发现${res.summary.totalInteractions}项相互作用`)
    } else {
      ElMessage.success('未发现已知相互作用，用药相对安全')
    }
  } catch (e) {
    ElMessage.error('检测失败')
  } finally {
    checking.value = false
  }
}

function toggleDrug(drugId) {
  const idx = selectedDrugs.value.indexOf(drugId)
  if (idx >= 0) selectedDrugs.value.splice(idx, 1)
  else selectedDrugs.value.push(drugId)
  result.value = null
}

function removeDrug(drugId) {
  const idx = selectedDrugs.value.indexOf(drugId)
  if (idx >= 0) selectedDrugs.value.splice(idx, 1)
  result.value = null
}

function getDrugName(drugId) {
  const drug = drugOptions.value.find(d => d.id === drugId) || drugDatabase.value.find(d => d.id === drugId)
  return drug ? drug.name : drugId
}

function getDrugCategory(drugId) {
  const drug = drugOptions.value.find(d => d.id === drugId) || drugDatabase.value.find(d => d.id === drugId)
  return drug ? drug.category : ''
}

function riskLevelTag(level) {
  return { high: 'danger', medium: 'warning', low: 'info' }[level] || 'info'
}

function riskLevelText(level) {
  return { high: '高风险', medium: '中风险', low: '低风险' }[level] || '未知'
}
</script>

<style scoped>
.drug-interaction { padding: 20px; }

.page-header { display: flex; align-items: center; gap: 16px; }
.header-icon { font-size: 48px; }
.header-text h2 { margin: 0; font-size: 22px; color: #333; }
.header-text p { margin: 4px 0 0; color: #999; font-size: 14px; }

.main-content { display: flex; flex-direction: column; gap: 20px; margin-top: 20px; }

.drug-option { display: flex; align-items: center; gap: 8px; }
.drug-category-tag {
  padding: 1px 6px;
  border-radius: 4px;
  font-size: 11px;
  font-weight: bold;
}
.drug-category-tag.西药 { background: #ecf5ff; color: #409eff; }
.drug-category-tag.中药 { background: #f0f9eb; color: #67c23a; }
.drug-option-name { font-weight: bold; }
.drug-option-type { color: #999; font-size: 12px; }

.selected-drugs { margin-top: 12px; }
.selected-label { font-size: 13px; color: #999; margin-bottom: 8px; }
.selected-list { display: flex; flex-wrap: wrap; gap: 8px; }
.drug-tag { font-size: 14px; }

.result-header { display: flex; justify-content: space-between; align-items: center; }

.risk-summary {
  display: flex;
  justify-content: space-around;
  padding: 20px;
  background: #f5f7fa;
  border-radius: 12px;
  margin-bottom: 16px;
}

.risk-stat { text-align: center; }
.risk-num { display: block; font-size: 32px; font-weight: bold; }
.risk-num.danger { color: #f56c6c; }
.risk-num.warning { color: #e6a23c; }
.risk-num.info { color: #409eff; }
.risk-num.total { color: #667eea; }
.risk-label { display: block; font-size: 13px; color: #999; margin-top: 4px; }

.interactions-list { display: flex; flex-direction: column; gap: 14px; }

.interaction-item {
  padding: 16px;
  border-radius: 12px;
  border-left: 4px solid #e2e8f0;
}
.interaction-item.high { border-left-color: #f56c6c; background: #fff5f5; }
.interaction-item.medium { border-left-color: #e6a23c; background: #fffbf0; }
.interaction-item.low { border-left-color: #409eff; background: #f0f7ff; }

.interaction-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 8px;
}

.drug-pair { display: flex; align-items: center; gap: 8px; }
.drug-name { font-weight: bold; font-size: 16px; color: #333; }
.interaction-symbol { font-size: 20px; }

.interaction-badges { display: flex; gap: 6px; }

.interaction-title { font-weight: bold; font-size: 15px; color: #333; margin-bottom: 6px; }
.interaction-desc { font-size: 13px; color: #666; line-height: 1.6; margin-bottom: 10px; }

.interaction-recommendation {
  display: flex;
  align-items: flex-start;
  gap: 6px;
  padding: 10px;
  background: rgba(255,255,255,0.8);
  border-radius: 8px;
  font-size: 13px;
  color: #333;
}
.rec-icon { flex-shrink: 0; }

.tip-card { margin-top: 20px; }
.tip-content { display: flex; align-items: center; gap: 10px; color: #667eea; font-size: 14px; }
.tip-icon { font-size: 24px; }

.database-card { margin-top: 20px; }
.db-filter { margin-bottom: 16px; }

.drug-db-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
  gap: 10px;
}

.db-drug-item {
  padding: 10px;
  border: 2px solid #e2e8f0;
  border-radius: 8px;
  cursor: pointer;
  transition: all 0.3s;
}
.db-drug-item:hover { border-color: #667eea; }
.db-drug-item.selected { border-color: #667eea; background: #f0f0ff; }

.db-category {
  display: inline-block;
  padding: 1px 6px;
  border-radius: 4px;
  font-size: 10px;
  font-weight: bold;
  margin-right: 4px;
}
.db-category.西药 { background: #ecf5ff; color: #409eff; }
.db-category.中药 { background: #f0f9eb; color: #67c23a; }

.db-name { font-weight: bold; font-size: 14px; }
.db-type { display: block; font-size: 12px; color: #999; margin-top: 2px; }
.db-desc { display: block; font-size: 11px; color: #bbb; margin-top: 2px; }
</style>