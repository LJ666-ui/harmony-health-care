<template>
  <div class="knowledge-qa">
    <div class="qa-main">
      <div class="qa-chat">
        <div class="qa-header">
          <h3>🔬 医学知识图谱问答</h3>
          <el-tag type="info" size="small">基于知识图谱推理</el-tag>
        </div>

        <div class="qa-messages" ref="messagesRef">
          <div v-if="qaList.length === 0" class="qa-welcome">
            <div class="welcome-icon">🔬</div>
            <h3>医学知识图谱智能问答</h3>
            <p>基于知识图谱推理，提供可解释的医学问答</p>
            <div class="hot-questions">
              <div class="hot-label">🔥 热门问题</div>
              <el-button v-for="q in hotQuestions" :key="q" size="small" round @click="askQuestion(q)">
                {{ q }}
              </el-button>
            </div>
          </div>

          <div v-for="(qa, index) in qaList" :key="index" class="qa-item">
            <div class="qa-question">
              <span class="qa-icon">🙋</span>
              <span>{{ qa.question }}</span>
            </div>
            <div class="qa-answer">
              <span class="qa-icon">🔬</span>
              <div class="answer-content">
                <div class="answer-text" v-html="formatText(qa.answer)"></div>
                <div v-if="qa.paths && qa.paths.length" class="answer-paths">
                  <div class="paths-label">📋 推理路径：</div>
                  <div v-for="(path, pi) in qa.paths" :key="pi" class="path-item">
                    <span class="path-source">{{ path.source }}</span>
                    <span class="path-arrow" :class="path.risk">—[{{ path.relation }}]→</span>
                    <span class="path-target">{{ path.target }}</span>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <div v-if="loading" class="qa-loading">
            <el-icon class="is-loading"><Loading /></el-icon>
            <span>正在推理中...</span>
          </div>
        </div>

        <div class="qa-input">
          <el-input
            v-model="inputText"
            placeholder="输入医学问题，如：高血压能吃枸杞吗？"
            @keyup.enter="askQuestion(inputText)"
            :disabled="loading"
            size="large"
          >
            <template #append>
              <el-button @click="askQuestion(inputText)" :loading="loading" type="primary">提问</el-button>
            </template>
          </el-input>
        </div>
      </div>

      <div class="graph-panel">
        <el-card>
          <template #header>
            <div class="graph-header">
              <span>🕸️ 知识图谱</span>
              <el-input v-model="graphKeyword" placeholder="搜索节点" size="small" style="width:140px" @keyup.enter="loadGraph" clearable>
                <template #append>
                  <el-button @click="loadGraph">🔍</el-button>
                </template>
              </el-input>
            </div>
          </template>
          <div ref="graphChartRef" style="height: 400px;"></div>
        </el-card>

        <el-card class="legend-card">
          <template #header><span>📌 图例说明</span></template>
          <div class="legend-items">
            <div class="legend-item"><span class="legend-dot disease"></span> 疾病</div>
            <div class="legend-item"><span class="legend-dot medicine"></span> 药物</div>
            <div class="legend-item"><span class="legend-dot herb"></span> 中药材</div>
            <div class="legend-item"><span class="legend-dot other"></span> 其他</div>
            <div class="legend-item"><span class="legend-line safe"></span> 安全/推荐</div>
            <div class="legend-item"><span class="legend-line warning"></span> 注意/关联</div>
            <div class="legend-item"><span class="legend-line danger"></span> 危险/禁忌</div>
          </div>
        </el-card>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, nextTick } from 'vue'
import request from '@/utils/request'
import * as echarts from 'echarts'
import { Loading } from '@element-plus/icons-vue'

const inputText = ref('')
const loading = ref(false)
const qaList = ref([])
const messagesRef = ref(null)
const graphChartRef = ref(null)
const graphKeyword = ref('')

const hotQuestions = [
  '高血压能吃枸杞吗？',
  '糖尿病有哪些并发症？',
  '人参和什么不能一起吃？',
  '头孢类药物禁忌',
  '冠心病怎么预防？'
]

let graphChart = null

onMounted(() => {
  loadGraph()
})

async function askQuestion(question) {
  if (!question || !question.trim() || loading.value) return
  inputText.value = ''
  loading.value = true

  try {
    const res = await request.post('/knowledge-qa/ask', { question })
    if (res) {
      qaList.value.push({
        question,
        answer: res.answer || '暂无答案',
        paths: res.graphPaths || []
      })

      if (res.graphData) {
        renderGraph(res.graphData)
      }
    }
  } catch (e) {
    qaList.value.push({
      question,
      answer: '抱歉，知识问答服务暂时不可用',
      paths: []
    })
  } finally {
    loading.value = false
    await scrollToBottom()
  }
}

async function loadGraph() {
  try {
    const res = await request.get('/knowledge-qa/graph', {
      keyword: graphKeyword.value || undefined
    })
    if (res) renderGraph(res)
  } catch (e) {
    console.error('加载图谱失败:', e)
  }
}

function renderGraph(data) {
  if (!graphChartRef.value) return
  if (!graphChart) graphChart = echarts.init(graphChartRef.value)

  const nodes = (data.nodes || []).map(n => ({
    name: n.name,
    symbolSize: n.name.length > 3 ? 40 : 30,
    category: ['disease', 'medicine', 'herb', 'other'].indexOf(n.category || 'other'),
    itemStyle: {
      color: n.category === 'disease' ? '#f56c6c' :
             n.category === 'medicine' ? '#409eff' :
             n.category === 'herb' ? '#67c23a' : '#909399'
    },
    label: { show: true, fontSize: 11 }
  }))

  const edges = (data.edges || []).map(e => ({
    source: e.source,
    target: e.target,
    lineStyle: {
      color: e.risk === 'danger' ? '#f56c6c' : e.risk === 'warning' ? '#e6a23c' : '#67c23a',
      width: e.risk === 'danger' ? 3 : 2,
      curveness: 0.2
    },
    label: {
      show: true,
      formatter: e.relation,
      fontSize: 9,
      color: '#666'
    }
  }))

  graphChart.setOption({
    tooltip: {},
    legend: {
      data: ['疾病', '药物', '中药材', '其他'],
      bottom: 0
    },
    series: [{
      type: 'graph',
      layout: 'force',
      data: nodes,
      links: edges,
      categories: [
        { name: '疾病' },
        { name: '药物' },
        { name: '中药材' },
        { name: '其他' }
      ],
      roam: true,
      draggable: true,
      force: {
        repulsion: 200,
        edgeLength: [80, 200],
        gravity: 0.1
      },
      emphasis: {
        focus: 'adjacency',
        lineStyle: { width: 4 }
      }
    }]
  })
}

function formatText(text) {
  return (text || '').replace(/\n/g, '<br>')
}

async function scrollToBottom() {
  await nextTick()
  if (messagesRef.value) {
    messagesRef.value.scrollTop = messagesRef.value.scrollHeight
  }
}
</script>

<style scoped>
.knowledge-qa { padding: 20px; }

.qa-main {
  display: flex;
  gap: 20px;
  height: calc(100vh - 140px);
}

.qa-chat {
  flex: 1;
  display: flex;
  flex-direction: column;
  background: #fff;
  border-radius: 12px;
  box-shadow: 0 2px 12px rgba(0,0,0,0.08);
  overflow: hidden;
}

.qa-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 16px 20px;
  border-bottom: 1px solid #f0f0f0;
  background: linear-gradient(135deg, #11998e 0%, #38ef7d 100%);
  color: #fff;
}

.qa-header h3 { margin: 0; font-size: 18px; }

.qa-messages {
  flex: 1;
  overflow-y: auto;
  padding: 20px;
}

.qa-welcome {
  text-align: center;
  padding: 40px 20px;
}

.welcome-icon { font-size: 64px; margin-bottom: 16px; }
.qa-welcome h3 { color: #333; margin-bottom: 8px; }
.qa-welcome p { color: #999; margin-bottom: 24px; }

.hot-questions {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
  justify-content: center;
}

.hot-label {
  width: 100%;
  margin-bottom: 8px;
  font-weight: bold;
  color: #666;
}

.qa-item { margin-bottom: 20px; }

.qa-question {
  display: flex;
  align-items: flex-start;
  gap: 8px;
  padding: 10px 14px;
  background: linear-gradient(135deg, #667eea, #764ba2);
  color: #fff;
  border-radius: 12px;
  margin-bottom: 10px;
  max-width: 80%;
  margin-left: auto;
}

.qa-answer {
  display: flex;
  align-items: flex-start;
  gap: 8px;
}

.qa-icon { font-size: 20px; flex-shrink: 0; }

.answer-content {
  background: #f5f7fa;
  border-radius: 12px;
  padding: 12px 16px;
  max-width: 85%;
}

.answer-text {
  line-height: 1.8;
  font-size: 14px;
  color: #333;
}

.answer-paths {
  margin-top: 10px;
  padding-top: 10px;
  border-top: 1px dashed #ddd;
}

.paths-label { font-weight: bold; font-size: 13px; color: #666; margin-bottom: 6px; }

.path-item {
  padding: 4px 0;
  font-size: 13px;
}

.path-source { font-weight: bold; color: #f56c6c; }
.path-target { font-weight: bold; color: #409eff; }

.path-arrow {
  margin: 0 6px;
  font-size: 12px;
}

.path-arrow.safe { color: #67c23a; }
.path-arrow.warning { color: #e6a23c; }
.path-arrow.danger { color: #f56c6c; }

.qa-loading {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 12px;
  color: #999;
}

.qa-input {
  padding: 16px 20px;
  border-top: 1px solid #f0f0f0;
}

.graph-panel {
  width: 420px;
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.graph-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.legend-items {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 8px;
}

.legend-item {
  display: flex;
  align-items: center;
  gap: 6px;
  font-size: 13px;
}

.legend-dot {
  width: 12px;
  height: 12px;
  border-radius: 50%;
}

.legend-dot.disease { background: #f56c6c; }
.legend-dot.medicine { background: #409eff; }
.legend-dot.herb { background: #67c23a; }
.legend-dot.other { background: #909399; }

.legend-line {
  width: 20px;
  height: 3px;
  border-radius: 2px;
}

.legend-line.safe { background: #67c23a; }
.legend-line.warning { background: #e6a23c; }
.legend-line.danger { background: #f56c6c; }
</style>