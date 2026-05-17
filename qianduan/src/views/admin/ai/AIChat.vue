<script setup>
import { ref, onMounted } from 'vue'
import aiService from '@/services/ai'

const messages = ref([
  { id: 1, type: 'system', content: '您好！我是您的智能医疗助手，请问有什么可以帮助您的？', time: '刚刚' }
])
const inputMessage = ref('')
const loading = ref(false)
const currentAgent = ref(null)
const agentList = ref([])
const showAgentPanel = ref(false)

onMounted(() => {
  agentList.value = aiService.getAllAgentsStatus()
  currentAgent.value = aiService.getCurrentAgent()
})

const sendMessage = async () => {
  if (!inputMessage.value.trim() || loading.value) return

  messages.value.push({ id: Date.now(), type: 'user', content: inputMessage.value.trim(), time: '刚刚' })
  const tempId = Date.now() + 1
  messages.value.push({ id: tempId, type: 'ai', content: '', time: '刚刚', loading: true })

  const userMsg = inputMessage.value.trim()
  inputMessage.value = ''
  loading.value = true

  try {
    const result = await aiService.chat(userMsg, {
      stream: false,
      onChunk: (chunk, full) => {
        const idx = messages.value.findIndex(m => m.id === tempId)
        if (idx !== -1) messages.value[idx].content = full
      }
    })

    const idx = messages.value.findIndex(m => m.id === tempId)
    if (idx !== -1) {
      if (result.success) {
        messages.value[idx] = { ...messages.value[idx], content: result.data || '抱歉，我暂时无法回答这个问题。', loading: false }
      } else {
        messages.value[idx] = { ...messages.value[idx], content: `服务异常: ${result.error}`, loading: false, isError: true }
      }
    }

    currentAgent.value = aiService.getCurrentAgent()
    agentList.value = aiService.getAllAgentsStatus()
  } catch (error) {
    const idx = messages.value.findIndex(m => m.id === tempId)
    if (idx !== -1) {
      messages.value[idx] = { ...messages.value[idx], content: '网络连接失败，请检查后重试。', loading: false, isError: true }
    }
  } finally {
    loading.value = false
  }
}

const switchAgent = (agentId) => {
  if (aiService.setPrimaryAgent(agentId)) {
    currentAgent.value = aiService.getCurrentAgent()
    aiService.clearAllHistory()
    messages.value = [{ id: Date.now(), type: 'system', content: `已切换到${currentAgent.value.config.name}，请问有什么可以帮助您的？`, time: '刚刚' }]
  }
}
</script>

<template>
  <div class="ai-chat">
    <div class="chat-header">
      <div class="header-left">
        <h3>AI 智能助手</h3>
        <span v-if="currentAgent" class="agent-badge" @click="showAgentPanel = !showAgentPanel">
          {{ currentAgent.config.name }}
          <span class="status-dot" :class="{ online: currentAgent.status.available }"></span>
        </span>
      </div>
      <div class="header-right">
        <span class="online-status"><span class="dot"></span>在线</span>
        <el-button size="small" text @click="showAgentPanel = !showAgentPanel">切换智能体</el-button>
      </div>
    </div>

    <transition name="slide">
      <div v-if="showAgentPanel" class="agent-panel">
        <h4>选择AI智能体</h4>
        <div class="agent-list">
          <div
            v-for="agent in agentList"
            :key="agent.id"
            :class="['agent-item', { active: agent.isCurrent, disabled: !agent.available }]"
            @click="agent.available && switchAgent(agent.id)"
          >
            <div class="agent-info">
              <span class="agent-name">{{ agent.name }}</span>
              <span class="agent-type" :class="agent.type">{{ agent.type === 'cloud' ? '云端' : '本地' }}</span>
            </div>
            <span v-if="!agent.available" class="offline-tag">离线</span>
            <span v-else class="online-tag">{{ agent.isCurrent ? '使用中' : '可用' }}</span>
          </div>
        </div>
      </div>
    </transition>

    <div class="chat-messages">
      <div v-for="msg in messages" :key="msg.id" :class="['message', msg.type, { error: msg.isError }]">
        <div class="avatar">
          <span v-if="msg.type === 'user'">U</span>
          <span v-else-if="msg.type === 'ai'">AI</span>
          <span v-else>SYS</span>
        </div>
        <div class="message-content">
          <p style="white-space: pre-wrap; word-break: break-word;">{{ msg.content }}</p>
          <span class="time">{{ msg.time }}</span>
        </div>
        <div v-if="msg.loading" class="loading">
          <span class="loading-dot"></span>
          <span class="loading-dot"></span>
          <span class="loading-dot"></span>
        </div>
      </div>
    </div>

    <div class="chat-input">
      <el-input v-model="inputMessage" placeholder="输入您的问题..." @keyup.enter="sendMessage" :disabled="loading" />
      <el-button type="primary" @click="sendMessage" :loading="loading">发送</el-button>
    </div>
  </div>
</template>

<style lang="scss" scoped>
.ai-chat {
  background: #fff;
  border-radius: 12px;
  padding: 20px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
  display: flex;
  flex-direction: column;
  height: 650px;
}
.chat-header {
  display: flex; justify-content: space-between; align-items: center;
  padding-bottom: 15px; border-bottom: 1px solid #e2e8f0; margin-bottom: 15px;
  .header-left {
    display: flex; align-items: center; gap: 10px;
    h3 { font-size: 16px; color: #333; margin: 0; }
    .agent-badge {
      font-size: 12px; padding: 4px 10px; background: #f0f5ff; color: #667eea;
      border-radius: 12px; cursor: pointer; transition: all 0.3s;
      &:hover { background: #e8edff; }
      .status-dot {
        width: 6px; height: 6px; border-radius: 50%; background: #ff4d4f; display: inline-block; margin-left: 6px;
        &.online { background: #52c41a; }
      }
    }
  }
  .header-right {
    display: flex; align-items: center; gap: 10px;
    .online-status { display: flex; align-items: center; gap: 6px; font-size: 12px; color: #48bb78;
      .dot { width: 8px; height: 8px; background: #48bb78; border-radius: 50%; animation: pulse 2s infinite; }
    }
  }
}
@keyframes pulse { 0%, 100% { opacity: 1; } 50% { opacity: 0.5; } }

.agent-panel {
  background: #fafbfc; border-radius: 8px; padding: 15px; margin-bottom: 15px;
  h4 { font-size: 14px; color: #333; margin: 0 0 12px; }
}
.agent-list { display: flex; flex-direction: column; gap: 8px; }
.agent-item {
  display: flex; justify-content: space-between; align-items: center;
  padding: 10px 12px; background: #fff; border-radius: 8px; cursor: pointer;
  transition: all 0.2s; border: 2px solid transparent;
  &:hover { border-color: #d6e4ff; }
  &.active { border-color: #667eea; background: #f0f5ff; }
  &.disabled { opacity: 0.6; cursor: not-allowed; }
  .agent-info {
    display: flex; align-items: center; gap: 8px;
    .agent-name { font-size: 13px; color: #333; font-weight: 500; }
    .agent-type {
      font-size: 11px; padding: 2px 6px; border-radius: 4px;
      &.cloud { background: #e6f7ff; color: #1890ff; }
      &.local { background: #f6ffed; color: #52c41a; }
    }
  }
  .online-tag { font-size: 11px; color: #52c41a; }
  .offline-tag { font-size: 11px; color: #ff4d4f; }
}

.slide-enter-active, .slide-leave-active { transition: all 0.3s ease; }
.slide-enter-from, .slide-leave-to { opacity: 0; transform: translateY(-10px); max-height: 0; overflow: hidden; }

.chat-messages { flex: 1; overflow-y: auto; display: flex; flex-direction: column; gap: 15px; }
.message {
  display: flex; gap: 12px;
  &.user { flex-direction: row-reverse; .avatar { background: #667eea; } .message-content { background: #667eea; color: #fff; .time { color: rgba(255,255,255,0.7); } } }
  &.ai, &.system { .avatar { background: #48bb78; } .message-content { background: #f5f7fa; color: #333; } }
  &.error .message-content { background: #fff2f0; color: #cf1322; border: 1px solid #ffa39e; }
  .avatar { width: 36px; height: 36px; border-radius: 50%; display: flex; align-items: center; justify-content: center; color: #fff; font-size: 12px; flex-shrink: 0; }
  .message-content { max-width: 70%; padding: 12px 16px; border-radius: 18px; p { margin: 0 0 6px; white-space: pre-wrap; } .time { font-size: 11px; color: #999; } }
  .loading { display: flex; gap: 4px; padding: 8px 12px; .loading-dot { width: 8px; height: 8px; background: #667eea; border-radius: 50%; animation: bounce 1.4s infinite ease-in-out both; &:nth-child(1) { animation-delay: -0.32s; } &:nth-child(2) { animation-delay: -0.16s; } } }
}
@keyframes bounce { 0%, 80%, 100% { transform: scale(0); } 40% { transform: scale(1); } }
.chat-input { display: flex; gap: 12px; padding-top: 15px; border-top: 1px solid #e2e8f0; .el-input { flex: 1; } }
</style>
