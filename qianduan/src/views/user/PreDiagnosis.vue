<template>
  <div class="pre-diagnosis">
    <div class="chat-container">
      <div class="chat-header">
        <h3>🧠 AI智能预问诊</h3>
        <el-tag :type="isTriageComplete ? 'success' : 'info'" size="small">
          {{ isTriageComplete ? '分诊完成' : '问诊中' }}
        </el-tag>
      </div>

      <div class="chat-messages" ref="messagesRef">
        <div v-if="messages.length === 0" class="welcome-section">
          <div class="welcome-icon">🏥</div>
          <h3>欢迎使用AI智能预问诊</h3>
          <p>请描述您的症状，AI将为您推荐合适的科室和医生</p>
          <div class="quick-symptoms">
            <el-button v-for="s in quickSymptoms" :key="s" size="small" round @click="sendQuickSymptom(s)">
              {{ s }}
            </el-button>
          </div>
        </div>

        <div v-for="(msg, index) in messages" :key="index" :class="['message', msg.role]">
          <div class="message-avatar">
            {{ msg.role === 'user' ? '👤' : '🤖' }}
          </div>
          <div class="message-content">
            <div class="message-bubble" v-html="formatMessage(msg.content)"></div>
            <div class="message-time">{{ msg.time }}</div>
          </div>
        </div>

        <div v-if="loading" class="message assistant">
          <div class="message-avatar">🤖</div>
          <div class="message-content">
            <div class="typing-indicator">
              <span></span><span></span><span></span>
            </div>
          </div>
        </div>
      </div>

      <div v-if="triageResult" class="triage-result">
        <div class="triage-header">
          <span>📋 分诊结果</span>
          <el-button type="primary" size="small" @click="goToConsultation">立即问诊</el-button>
        </div>
        <div class="triage-body">
          <div class="triage-item">
            <label>推荐科室</label>
            <el-tag type="warning">{{ triageResult.department }}</el-tag>
          </div>
          <div class="triage-item">
            <label>紧急程度</label>
            <el-tag :type="urgencyType(triageResult.urgency)">{{ triageResult.urgency }}</el-tag>
          </div>
          <div class="triage-item">
            <label>症状摘要</label>
            <span>{{ triageResult.summary }}</span>
          </div>
        </div>
      </div>

      <div class="chat-input">
        <el-input
          v-model="inputText"
          placeholder="请描述您的症状..."
          @keyup.enter="sendMessage"
          :disabled="loading"
          size="large"
        >
          <template #append>
            <el-button @click="sendMessage" :loading="loading" type="primary">发送</el-button>
          </template>
        </el-input>
      </div>
    </div>

    <div class="side-panel">
      <el-card class="dept-card">
        <template #header><span>🏥 科室导航</span></template>
        <div class="dept-grid">
          <div v-for="dept in departments" :key="dept.name" class="dept-item" @click="selectDept(dept)">
            <span class="dept-name">{{ dept.name }}</span>
          </div>
        </div>
      </el-card>

      <el-card class="tips-card">
        <template #header><span>💡 问诊技巧</span></template>
        <ul class="tips-list">
          <li>描述症状的具体部位</li>
          <li>说明症状持续时间</li>
          <li>提及伴随的其他症状</li>
          <li>告知既往病史和过敏史</li>
          <li>说明目前服用的药物</li>
        </ul>
      </el-card>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, nextTick } from 'vue'
import { useRouter } from 'vue-router'
import request from '@/utils/request'
import { ElMessage } from 'element-plus'

const router = useRouter()
const messages = ref([])
const inputText = ref('')
const loading = ref(false)
const isTriageComplete = ref(false)
const triageResult = ref(null)
const departments = ref([])
const messagesRef = ref(null)

const quickSymptoms = ['头痛头晕', '胸闷心悸', '腹痛腹泻', '关节疼痛', '咳嗽发热', '失眠焦虑']

onMounted(() => {
  loadDepartments()
  messages.value.push({
    role: 'assistant',
    content: '您好！我是AI预问诊助手。请告诉我您哪里不舒服，我会帮您分析症状并推荐合适的科室和医生。',
    time: new Date().toLocaleTimeString()
  })
})

async function loadDepartments() {
  try {
    const res = await request.get('/ai/pre-diagnosis/departments')
    departments.value = res || []
  } catch (e) {
    departments.value = []
  }
}

async function sendMessage() {
  const text = inputText.value.trim()
  if (!text || loading.value) return

  messages.value.push({ role: 'user', content: text, time: new Date().toLocaleTimeString() })
  inputText.value = ''
  loading.value = true
  await scrollToBottom()

  try {
    const history = messages.value.slice(-10).map(m => ({
      role: m.role === 'user' ? '患者' : '助手',
      content: m.content
    }))

    const res = await request.post('/ai/pre-diagnosis/chat', {
      userId: JSON.parse(localStorage.getItem('medical_user_info') || '{}').userId || JSON.parse(localStorage.getItem('medical_user_info') || '{}').id || 1,
      message: text,
      history
    })

    if (res) {
      messages.value.push({
        role: 'assistant',
        content: res.reply || '抱歉，我暂时无法回答',
        time: new Date().toLocaleTimeString()
      })

      if (res.isTriageComplete) {
        try {
          const jsonMatch = (res.reply || '').match(/\{[\s\S]*"triage"[\s\S]*\}/)
          if (jsonMatch) {
            const parsed = JSON.parse(jsonMatch[0])
            triageResult.value = parsed.triage
            isTriageComplete.value = true
          }
        } catch (e) { /* ignore parse error */ }
      }
    }
  } catch (e) {
    messages.value.push({
      role: 'assistant',
      content: '抱歉，服务暂时不可用，请稍后再试。',
      time: new Date().toLocaleTimeString()
    })
  } finally {
    loading.value = false
    await scrollToBottom()
  }
}

function sendQuickSymptom(symptom) {
  inputText.value = symptom
  sendMessage()
}

function selectDept(dept) {
  inputText.value = `我想看${dept.name}，${dept.description}`
  sendMessage()
}

function goToConsultation() {
  router.push('/user/doctor-search')
}

function urgencyType(urgency) {
  if (urgency === '紧急') return 'danger'
  if (urgency === '较急') return 'warning'
  return 'success'
}

function formatMessage(content) {
  return content.replace(/\n/g, '<br>')
}

async function scrollToBottom() {
  await nextTick()
  if (messagesRef.value) {
    messagesRef.value.scrollTop = messagesRef.value.scrollHeight
  }
}
</script>

<style scoped>
.pre-diagnosis {
  display: flex;
  gap: 20px;
  height: calc(100vh - 140px);
  padding: 20px;
}

.chat-container {
  flex: 1;
  display: flex;
  flex-direction: column;
  background: #fff;
  border-radius: 12px;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.08);
  overflow: hidden;
}

.chat-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 16px 20px;
  border-bottom: 1px solid #f0f0f0;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: #fff;
}

.chat-header h3 { margin: 0; font-size: 18px; }

.chat-messages {
  flex: 1;
  overflow-y: auto;
  padding: 20px;
}

.welcome-section {
  text-align: center;
  padding: 40px 20px;
}

.welcome-icon { font-size: 64px; margin-bottom: 16px; }

.welcome-section h3 { color: #333; margin-bottom: 8px; }

.welcome-section p { color: #999; margin-bottom: 24px; }

.quick-symptoms {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
  justify-content: center;
}

.message {
  display: flex;
  margin-bottom: 16px;
  gap: 10px;
}

.message.user { flex-direction: row-reverse; }

.message-avatar {
  width: 36px;
  height: 36px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 18px;
  flex-shrink: 0;
}

.message.user .message-avatar { background: #e8f5e9; }
.message.assistant .message-avatar { background: #e3f2fd; }

.message-bubble {
  max-width: 70%;
  padding: 10px 14px;
  border-radius: 12px;
  line-height: 1.6;
  font-size: 14px;
}

.message.user .message-bubble {
  background: linear-gradient(135deg, #667eea, #764ba2);
  color: #fff;
  border-bottom-right-radius: 4px;
}

.message.assistant .message-bubble {
  background: #f5f7fa;
  color: #333;
  border-bottom-left-radius: 4px;
}

.message-time {
  font-size: 11px;
  color: #bbb;
  margin-top: 4px;
}

.typing-indicator {
  display: flex;
  gap: 4px;
  padding: 10px 14px;
  background: #f5f7fa;
  border-radius: 12px;
  width: fit-content;
}

.typing-indicator span {
  width: 8px;
  height: 8px;
  border-radius: 50%;
  background: #999;
  animation: typing 1.4s infinite;
}

.typing-indicator span:nth-child(2) { animation-delay: 0.2s; }
.typing-indicator span:nth-child(3) { animation-delay: 0.4s; }

@keyframes typing {
  0%, 60%, 100% { transform: translateY(0); opacity: 0.4; }
  30% { transform: translateY(-6px); opacity: 1; }
}

.triage-result {
  margin: 0 20px 10px;
  border: 2px solid #67c23a;
  border-radius: 12px;
  overflow: hidden;
}

.triage-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 10px 16px;
  background: #f0f9eb;
  font-weight: bold;
}

.triage-body { padding: 12px 16px; }

.triage-item {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-bottom: 8px;
}

.triage-item label {
  font-weight: bold;
  color: #666;
  min-width: 80px;
}

.chat-input {
  padding: 16px 20px;
  border-top: 1px solid #f0f0f0;
}

.side-panel {
  width: 300px;
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.dept-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 8px;
}

.dept-item {
  padding: 8px 12px;
  background: #f5f7fa;
  border-radius: 8px;
  cursor: pointer;
  text-align: center;
  transition: all 0.3s;
  font-size: 13px;
}

.dept-item:hover {
  background: linear-gradient(135deg, #667eea, #764ba2);
  color: #fff;
  transform: translateY(-2px);
}

.tips-list {
  padding-left: 16px;
  margin: 0;
  color: #666;
  font-size: 13px;
  line-height: 2;
}
</style>