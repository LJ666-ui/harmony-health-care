<script setup>
import { ref, onMounted, onBeforeUnmount, nextTick, computed } from 'vue'
import { ElMessage } from 'element-plus'
import knowledgeApi from '@/api/knowledge'
import * as echarts from 'echarts'

const searchKeyword = ref('')
const loading = ref(false)
const chartRef = ref(null)
let chartInstance = null

const stats = ref({ nodeCount: 0, edgeCount: 0, coreNodeCount: 0, nodeTypes: [], edgeTypes: [] })
const currentCenterId = ref(null)
const currentCenterName = ref('')
const searchResults = ref([])
const showSearchResults = ref(false)
const selectedNodeType = ref('')
const nodeDetailVisible = ref(false)
const nodeDetail = ref(null)
const pathDialogVisible = ref(false)
const pathFrom = ref('')
const pathTo = ref('')
const pathFromId = ref(null)
const pathToId = ref(null)
const pathResult = ref(null)
const pathLoading = ref(false)
const searchSuggestions = ref([])
const showSuggestions = ref(false)
const exploreQuery = ref('')
const exploreLoading = ref(false)
const exploreResult = ref('')
const activeTab = ref('graph')

const nodeTypeConfig = {
  DISEASE: { label: '疾病', color: '#ef4444', icon: '🦠' },
  SYMPTOM: { label: '症状', color: '#f97316', icon: '🤒' },
  HERBAL: { label: '中药', color: '#22c55e', icon: '🌿' },
  PRESCRIPTION: { label: '方剂', color: '#3b82f6', icon: '💊' },
  FOOD_THERAPY: { label: '食疗', color: '#a855f7', icon: '🍲' },
  THERAPY: { label: '疗法', color: '#06b6d4', icon: '💆' },
  BODY_PART: { label: '部位', color: '#ec4899', icon: '🫀' },
  CONCEPT: { label: '概念', color: '#6366f1', icon: '📖' }
}

const nodeTypeList = computed(() => {
  return Object.entries(nodeTypeConfig).map(([value, config]) => ({
    value,
    ...config
  }))
})

const typeStatsMap = computed(() => {
  const map = {}
  if (stats.value.nodeTypes) {
    stats.value.nodeTypes.forEach(item => {
      map[item.itemType] = item.itemCount
    })
  }
  return map
})

const loadStats = async () => {
  try {
    const res = await knowledgeApi.getStats()
    stats.value = res || {}
  } catch (error) {
    console.error('加载统计失败', error)
  }
}

const renderGraph = (graphData) => {
  if (!chartRef.value) return
  if (!chartInstance) {
    chartInstance = echarts.init(chartRef.value)
    chartInstance.on('click', (params) => {
      if (params.dataType === 'node') {
        handleNodeClick(params.data)
      }
    })
  }

  const nodes = (graphData.nodes || []).map(node => ({
    id: String(node.id),
    name: node.label || node.name,
    symbolSize: node.radius || 30,
    nodeType: node.type,
    itemStyle: { color: node.color || getColorByType(node.type) },
    label: { show: true, fontSize: node.depthLevel === 0 ? 14 : 11, fontWeight: node.depthLevel === 0 ? 'bold' : 'normal' },
    rawData: node
  }))

  const edges = (graphData.edges || []).map(edge => ({
    source: String(edge.source),
    target: String(edge.target),
    label: { show: true, formatter: edge.label || edge.relationName || '', fontSize: 9, color: '#888' },
    lineStyle: { width: Math.max(1, (edge.weight || 1) * 3), curveness: 0.2, color: '#aaa' }
  }))

  const option = {
    title: {
      text: currentCenterName.value ? `知识图谱 - ${currentCenterName.value}` : '知识图谱',
      left: 'center',
      textStyle: { fontSize: 16, color: '#333' }
    },
    tooltip: {
      trigger: 'item',
      formatter: (params) => {
        if (params.dataType === 'node') {
          const type = params.data.nodeType
          const typeLabel = nodeTypeConfig[type]?.label || type
          const desc = params.data.rawData?.description || ''
          return `<div style="padding:8px;max-width:300px">
            <div style="font-weight:bold;font-size:14px">${params.name}</div>
            <div style="color:#666;font-size:12px;margin-top:4px">类型: ${typeLabel}</div>
            ${desc ? `<div style="color:#999;font-size:11px;margin-top:4px">${desc}</div>` : ''}
          </div>`
        }
        return `<div style="padding:4px">${params.data.label?.formatter || '关联'}</div>`
      }
    },
    legend: {
      data: nodeTypeList.value.map(t => t.label),
      bottom: 10,
      textStyle: { fontSize: 11 },
      itemWidth: 12,
      itemHeight: 12
    },
    series: [{
      type: 'graph',
      layout: 'force',
      animation: true,
      draggable: true,
      roam: true,
      label: { show: true, position: 'bottom' },
      edgeSymbol: ['circle', 'arrow'],
      edgeSymbolSize: [4, 10],
      categories: nodeTypeList.value.map(t => ({ name: t.label })),
      data: nodes,
      links: edges,
      lineStyle: { color: '#aaa', width: 2, curveness: 0.2 },
      emphasis: {
        focus: 'adjacency',
        lineStyle: { width: 4 }
      },
      force: {
        repulsion: 300,
        gravity: 0.08,
        edgeLength: [80, 200],
        layoutAnimation: true
      }
    }]
  }
  chartInstance.setOption(option, true)
}

const getColorByType = (type) => {
  return nodeTypeConfig[type]?.color || '#999'
}

const loadGraphByCenterId = async (centerId, depth = 2) => {
  loading.value = true
  try {
    const res = await knowledgeApi.getGraph(centerId, depth)
    currentCenterId.value = res.centerId
    const centerNode = (res.nodes || []).find(n => n.id === centerId || n.depthLevel === 0)
    currentCenterName.value = centerNode?.label || centerNode?.name || ''
    renderGraph(res)
  } catch (error) {
    ElMessage.error('加载知识图谱失败')
    console.error(error)
  } finally {
    loading.value = false
  }
}

const handleSearch = async () => {
  const keyword = searchKeyword.value.trim()
  if (!keyword) {
    showSearchResults.value = false
    return
  }
  loading.value = true
  try {
    const res = await knowledgeApi.searchNodes(keyword)
    searchResults.value = res || []
    showSearchResults.value = true
    if (searchResults.value.length === 0) {
      ElMessage.info('未找到相关节点')
    }
  } catch (error) {
    ElMessage.error('搜索失败')
  } finally {
    loading.value = false
  }
}

const handleSearchInput = async () => {
  const keyword = searchKeyword.value.trim()
  if (keyword.length < 1) {
    showSuggestions.value = false
    return
  }
  try {
    const res = await knowledgeApi.searchNodes(keyword)
    searchSuggestions.value = (res || []).slice(0, 8)
    showSuggestions.value = searchSuggestions.value.length > 0
  } catch (error) {
    showSuggestions.value = false
  }
}

const selectSuggestion = (node) => {
  searchKeyword.value = node.name
  showSuggestions.value = false
  showSearchResults.value = false
  loadGraphByCenterId(node.id)
}

const handleSearchResultClick = (node) => {
  showSearchResults.value = false
  loadGraphByCenterId(node.id)
}

const handleNodeClick = async (nodeData) => {
  const nodeId = nodeData.rawData?.id || nodeData.id
  try {
    const res = await knowledgeApi.getNodeDetail(Number(nodeId))
    nodeDetail.value = res
    nodeDetailVisible.value = true
  } catch (error) {
    nodeDetail.value = { name: nodeData.name, nodeType: nodeData.nodeType }
    nodeDetailVisible.value = true
  }
}

const handleTypeFilter = async (type) => {
  selectedNodeType.value = type
  if (!type) {
    if (currentCenterId.value) {
      loadGraphByCenterId(currentCenterId.value)
    }
    return
  }
  loading.value = true
  try {
    const res = await knowledgeApi.getNodesByType(type)
    const nodes = (res || []).slice(0, 30)
    if (nodes.length > 0) {
      loadGraphByCenterId(nodes[0].id, 2)
    } else {
      ElMessage.info('该类型暂无节点数据')
    }
  } catch (error) {
    ElMessage.error('加载失败')
  } finally {
    loading.value = false
  }
}

const handleExplore = async () => {
  const query = exploreQuery.value.trim()
  if (!query) return
  exploreLoading.value = true
  try {
    const res = await knowledgeApi.explore({ query, depth: 2 })
    if (res) {
      currentCenterId.value = res.centerId
      currentCenterName.value = res.centerNode?.name || query
      renderGraph(res)
      exploreResult.value = res.interpretation || ''
      if (exploreResult.value) {
        ElMessage.success({ message: exploreResult.value, duration: 5000, showClose: true })
      }
    }
  } catch (error) {
    ElMessage.error('AI探索失败')
  } finally {
    exploreLoading.value = false
  }
}

const handleFindPath = async () => {
  if (!pathFromId.value || !pathToId.value) {
    ElMessage.warning('请先搜索并选择起点和终点节点')
    return
  }
  if (pathFromId.value === pathToId.value) {
    ElMessage.warning('起点和终点不能相同')
    return
  }
  pathLoading.value = true
  try {
    const res = await knowledgeApi.findPath(pathFromId.value, pathToId.value)
    pathResult.value = res
    if (res && res.nodes && res.nodes.length > 0) {
      renderGraph(res)
      ElMessage.success(`找到路径，长度为 ${res.pathLength || res.nodes.length - 1}`)
    } else {
      ElMessage.info('未找到可达路径')
    }
  } catch (error) {
    ElMessage.error('路径查询失败')
  } finally {
    pathLoading.value = false
  }
}

const selectPathFrom = (node) => {
  pathFrom.value = node.name
  pathFromId.value = node.id
  showSearchResults.value = false
}

const selectPathTo = (node) => {
  pathTo.value = node.name
  pathToId.value = node.id
  showSearchResults.value = false
}

const searchForPath = async (target) => {
  const keyword = target === 'from' ? pathFrom.value : pathTo.value
  if (!keyword.trim()) return
  try {
    const res = await knowledgeApi.searchNodes(keyword)
    searchResults.value = res || []
    showSearchResults.value = true
  } catch (error) {
    ElMessage.error('搜索失败')
  }
}

const loadCoreNodeGraph = async () => {
  loading.value = true
  try {
    const res = await knowledgeApi.getNodesByType('DISEASE')
    const coreNodes = (res || []).filter(n => n.isCoreNode === 1)
    if (coreNodes.length > 0) {
      loadGraphByCenterId(coreNodes[0].id, 2)
    } else if (res && res.length > 0) {
      loadGraphByCenterId(res[0].id, 2)
    }
  } catch (error) {
    ElMessage.error('加载失败')
  } finally {
    loading.value = false
  }
}

const loadTypeGraph = async (type) => {
  loading.value = true
  try {
    const res = await knowledgeApi.getNodesByType(type)
    const nodes = (res || []).slice(0, 5)
    if (nodes.length > 0) {
      loadGraphByCenterId(nodes[0].id, 2)
    } else {
      ElMessage.info('该类型暂无数据')
    }
  } catch (error) {
    ElMessage.error('加载失败')
  } finally {
    loading.value = false
  }
}

const handleResize = () => chartInstance?.resize()

onMounted(async () => {
  await loadStats()
  await loadCoreNodeGraph()
  window.addEventListener('resize', handleResize)
})

onBeforeUnmount(() => {
  window.removeEventListener('resize', handleResize)
  chartInstance?.dispose()
  chartInstance = null
})
</script>

<template>
  <div class="knowledge-view">
    <div class="top-section">
      <div class="search-bar">
        <div class="search-input-wrapper">
          <el-input
            v-model="searchKeyword"
            placeholder="搜索疾病、症状、中药、方剂..."
            class="search-input"
            @keyup.enter="handleSearch"
            @input="handleSearchInput"
            clearable
          />
          <div v-if="showSuggestions" class="suggestions-dropdown">
            <div
              v-for="node in searchSuggestions"
              :key="node.id"
              class="suggestion-item"
              @click="selectSuggestion(node)"
            >
              <span class="suggestion-type" :style="{ color: nodeTypeConfig[node.nodeType]?.color }">
                {{ nodeTypeConfig[node.nodeType]?.icon }} {{ nodeTypeConfig[node.nodeType]?.label }}
              </span>
              <span class="suggestion-name">{{ node.name }}</span>
            </div>
          </div>
        </div>
        <el-button type="primary" @click="handleSearch" :loading="loading">搜索</el-button>
      </div>

      <div class="type-filter">
        <el-tag
          v-for="typeItem in nodeTypeList"
          :key="typeItem.value"
          :class="['type-tag', { active: selectedNodeType === typeItem.value }]"
          :color="selectedNodeType === typeItem.value ? typeItem.color : ''"
          :style="selectedNodeType === typeItem.value ? { color: '#fff', borderColor: typeItem.color } : { color: typeItem.color, borderColor: typeItem.color + '66' }"
          effect="plain"
          @click="handleTypeFilter(selectedNodeType === typeItem.value ? '' : typeItem.value)"
        >
          {{ typeItem.icon }} {{ typeItem.label }}
          <span v-if="typeStatsMap[typeItem.value]" class="type-count">({{ typeStatsMap[typeItem.value] }})</span>
        </el-tag>
      </div>
    </div>

    <div class="main-content">
      <div class="sidebar">
        <el-card class="sidebar-card">
          <template #header>
            <span class="card-title">图谱导航</span>
          </template>
          <div class="nav-list">
            <div class="nav-item" @click="loadCoreNodeGraph">
              <span class="nav-icon">🏠</span> 核心疾病图谱
            </div>
            <div class="nav-item" @click="loadTypeGraph('DISEASE')">
              <span class="nav-icon">🦠</span> 疾病关系图谱
            </div>
            <div class="nav-item" @click="loadTypeGraph('SYMPTOM')">
              <span class="nav-icon">🤒</span> 症状关联图谱
            </div>
            <div class="nav-item" @click="loadTypeGraph('HERBAL')">
              <span class="nav-icon">🌿</span> 中药方剂图谱
            </div>
            <div class="nav-item" @click="loadTypeGraph('PRESCRIPTION')">
              <span class="nav-icon">💊</span> 方剂组成图谱
            </div>
            <div class="nav-item" @click="loadTypeGraph('FOOD_THERAPY')">
              <span class="nav-icon">🍲</span> 食疗养生图谱
            </div>
            <div class="nav-item" @click="loadTypeGraph('THERAPY')">
              <span class="nav-icon">💆</span> 疗法调理图谱
            </div>
          </div>
        </el-card>

        <el-card class="sidebar-card">
          <template #header>
            <span class="card-title">AI 智能探索</span>
          </template>
          <el-input
            v-model="exploreQuery"
            placeholder="输入问题探索知识..."
            :rows="2"
            type="textarea"
          />
          <el-button
            type="success"
            @click="handleExplore"
            :loading="exploreLoading"
            style="width: 100%; margin-top: 8px"
          >
            AI 探索
          </el-button>
        </el-card>

        <el-card class="sidebar-card">
          <template #header>
            <span class="card-title">路径查询</span>
          </template>
          <div class="path-form">
            <el-input v-model="pathFrom" placeholder="起点节点" size="small" @keyup.enter="searchForPath('from')">
              <template #append>
                <el-button @click="searchForPath('from')" size="small">搜</el-button>
              </template>
            </el-input>
            <div class="path-arrow">→</div>
            <el-input v-model="pathTo" placeholder="终点节点" size="small" @keyup.enter="searchForPath('to')">
              <template #append>
                <el-button @click="searchForPath('to')" size="small">搜</el-button>
              </template>
            </el-input>
            <el-button type="primary" @click="handleFindPath" :loading="pathLoading" size="small" style="width: 100%; margin-top: 8px">
              查询路径
            </el-button>
          </div>
        </el-card>

        <el-card class="sidebar-card stats-card">
          <template #header>
            <span class="card-title">图谱统计</span>
          </template>
          <div class="stat-item">
            <span class="stat-label">节点总数</span>
            <span class="stat-value">{{ stats.nodeCount || 0 }}</span>
          </div>
          <div class="stat-item">
            <span class="stat-label">关系总数</span>
            <span class="stat-value">{{ stats.edgeCount || 0 }}</span>
          </div>
          <div class="stat-item">
            <span class="stat-label">核心节点</span>
            <span class="stat-value">{{ stats.coreNodeCount || 0 }}</span>
          </div>
        </el-card>
      </div>

      <div class="chart-area">
        <div v-if="showSearchResults && searchResults.length > 0" class="search-results-overlay">
          <div class="search-results-header">
            <span>搜索结果 ({{ searchResults.length }})</span>
            <el-button size="small" text @click="showSearchResults = false">关闭</el-button>
          </div>
          <div class="search-results-list">
            <div
              v-for="node in searchResults"
              :key="node.id"
              class="search-result-item"
              @click="handleSearchResultClick(node)"
            >
              <span class="result-type" :style="{ color: nodeTypeConfig[node.nodeType]?.color }">
                {{ nodeTypeConfig[node.nodeType]?.icon }} {{ nodeTypeConfig[node.nodeType]?.label }}
              </span>
              <span class="result-name">{{ node.name }}</span>
              <span v-if="node.alias" class="result-alias">{{ node.alias }}</span>
            </div>
          </div>
        </div>
        <div ref="chartRef" class="chart" v-loading="loading"></div>
      </div>
    </div>

    <el-dialog v-model="nodeDetailVisible" title="节点详情" width="500px">
      <div v-if="nodeDetail" class="node-detail">
        <div class="detail-header">
          <span class="detail-type-tag" :style="{ backgroundColor: nodeTypeConfig[nodeDetail.nodeType]?.color }">
            {{ nodeTypeConfig[nodeDetail.nodeType]?.icon }} {{ nodeTypeConfig[nodeDetail.nodeType]?.label }}
          </span>
          <h3>{{ nodeDetail.name }}</h3>
        </div>
        <el-descriptions :column="1" border>
          <el-descriptions-item v-if="nodeDetail.alias" label="别名">{{ nodeDetail.alias }}</el-descriptions-item>
          <el-descriptions-item v-if="nodeDetail.description" label="描述">{{ nodeDetail.description }}</el-descriptions-item>
          <el-descriptions-item v-if="nodeDetail.sourceReference" label="来源">{{ nodeDetail.sourceReference }}</el-descriptions-item>
          <el-descriptions-item v-if="nodeDetail.confidenceScore" label="可信度">{{ nodeDetail.confidenceScore }}</el-descriptions-item>
        </el-descriptions>
      </div>
      <template #footer>
        <el-button @click="nodeDetailVisible = false">关闭</el-button>
        <el-button type="primary" @click="nodeDetailVisible = false; loadGraphByCenterId(nodeDetail.id)">查看图谱</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<style lang="scss" scoped>
.knowledge-view {
  background: #fff;
  border-radius: 12px;
  padding: 20px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
  min-height: calc(100vh - 140px);
}

.top-section {
  margin-bottom: 16px;
}

.search-bar {
  display: flex;
  gap: 12px;
  margin-bottom: 12px;
  position: relative;

  .search-input-wrapper {
    position: relative;
    flex: 0 0 400px;
  }

  .search-input {
    width: 100%;
  }

  .suggestions-dropdown {
    position: absolute;
    top: 100%;
    left: 0;
    right: 0;
    background: #fff;
    border: 1px solid #e4e7ed;
    border-radius: 4px;
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
    z-index: 100;
    max-height: 300px;
    overflow-y: auto;

    .suggestion-item {
      padding: 8px 12px;
      cursor: pointer;
      display: flex;
      align-items: center;
      gap: 8px;

      &:hover {
        background: #f5f7fa;
      }

      .suggestion-type {
        font-size: 12px;
        flex-shrink: 0;
      }

      .suggestion-name {
        font-size: 13px;
      }
    }
  }
}

.type-filter {
  display: flex;
  gap: 8px;
  flex-wrap: wrap;

  .type-tag {
    cursor: pointer;
    transition: all 0.2s;

    &:hover {
      transform: scale(1.05);
    }

    &.active {
      color: #fff !important;
    }

    .type-count {
      font-size: 11px;
      opacity: 0.8;
    }
  }
}

.main-content {
  display: flex;
  gap: 16px;
}

.sidebar {
  width: 260px;
  flex-shrink: 0;
  display: flex;
  flex-direction: column;
  gap: 12px;

  .sidebar-card {
    :deep(.el-card__header) {
      padding: 10px 14px;
    }

    :deep(.el-card__body) {
      padding: 12px 14px;
    }
  }

  .card-title {
    font-weight: 600;
    font-size: 14px;
  }

  .nav-list {
    .nav-item {
      padding: 8px 10px;
      cursor: pointer;
      border-radius: 6px;
      font-size: 13px;
      transition: all 0.2s;
      display: flex;
      align-items: center;
      gap: 6px;

      &:hover {
        background: #f0f9ff;
        color: #3b82f6;
      }

      .nav-icon {
        font-size: 16px;
      }
    }
  }

  .path-form {
    display: flex;
    flex-direction: column;
    gap: 6px;

    .path-arrow {
      text-align: center;
      font-size: 18px;
      color: #999;
    }
  }

  .stat-item {
    display: flex;
    justify-content: space-between;
    padding: 4px 0;
    font-size: 13px;

    .stat-label {
      color: #666;
    }

    .stat-value {
      font-weight: 600;
      color: #333;
    }
  }
}

.chart-area {
  flex: 1;
  position: relative;
  min-height: 550px;

  .chart {
    height: 550px;
    width: 100%;
  }

  .search-results-overlay {
    position: absolute;
    top: 0;
    right: 0;
    width: 280px;
    max-height: 400px;
    background: #fff;
    border: 1px solid #e4e7ed;
    border-radius: 8px;
    box-shadow: 0 4px 16px rgba(0, 0, 0, 0.1);
    z-index: 50;
    overflow: hidden;
    display: flex;
    flex-direction: column;

    .search-results-header {
      display: flex;
      justify-content: space-between;
      align-items: center;
      padding: 8px 12px;
      background: #f5f7fa;
      font-size: 13px;
      font-weight: 600;
      border-bottom: 1px solid #e4e7ed;
    }

    .search-results-list {
      overflow-y: auto;
      max-height: 350px;

      .search-result-item {
        padding: 8px 12px;
        cursor: pointer;
        border-bottom: 1px solid #f0f0f0;
        transition: background 0.2s;

        &:hover {
          background: #f0f9ff;
        }

        .result-type {
          font-size: 11px;
          margin-right: 6px;
        }

        .result-name {
          font-size: 13px;
          font-weight: 500;
        }

        .result-alias {
          font-size: 11px;
          color: #999;
          margin-left: 6px;
        }
      }
    }
  }
}

.node-detail {
  .detail-header {
    display: flex;
    align-items: center;
    gap: 10px;
    margin-bottom: 16px;

    .detail-type-tag {
      color: #fff;
      padding: 2px 10px;
      border-radius: 12px;
      font-size: 12px;
    }

    h3 {
      margin: 0;
      font-size: 18px;
    }
  }
}
</style>
