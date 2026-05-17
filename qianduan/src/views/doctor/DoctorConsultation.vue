<script setup>
import { ref, onMounted, onUnmounted, nextTick } from 'vue'
import { useRoute } from 'vue-router'
import { useUserStore } from '@/stores/user'
import { ElMessage, ElMessageBox } from 'element-plus'
import consultationApi from '@/api/consultation'
import SockJS from 'sockjs-client'
import Stomp from 'webstomp-client'

const route = useRoute()
const userStore = useUserStore()

const activeTab = ref('queue')
const consultationId = ref(null)
const queueList = ref([])
const currentOrder = ref(null)
const messages = ref([])
const inputMessage = ref('')
const loading = ref(false)
const isConnected = ref(false)
const statistics = ref({})
let stompClient = null
let queueTimer = null

onMounted(() => {
  loadQueue()
  loadStatistics()
  startQueuePolling()
})

onUnmounted(() => {
  disconnectWebSocket()
  stopQueuePolling()
})

function startQueuePolling() {
  queueTimer = setInterval(() => {
    if (activeTab.value === 'queue') {
      loadQueue()
    }
  }, 5000)
}

function stopQueuePolling() {
  if (queueTimer) {
    clearInterval(queueTimer)
  }
}

async function loadQueue() {
  try {
    const res = await consultationApi.getDoctorQueue(userStore.userInfo?.userId)
    queueList.value = res?.orders || []
  } catch (e) {
    console.error('加载候诊队列失败:', e)
  }
}

async function loadStatistics() {
  try {
    const res = await consultationApi.getStatistics(userStore.userInfo?.userId)
    if (res) statistics.value = res
  } catch (e) {}
}

async function acceptOrder(order) {
  try {
    await ElMessageBox.confirm(`确定要接诊患者 ${order.patientName} 吗？`, '确认接诊', {
      confirmButtonText: '立即接诊',
      cancelButtonText: '取消',
      type: 'info'
    })

    const res = await consultationApi.acceptConsultation(order.id)
    if (res) {
      ElMessage.success('已接诊')
      currentOrder.value = order
      consultationId.value = order.id
      activeTab.value = 'chat'
      connectWebSocket()
      loadMessages()
    }
  } catch (e) {}
}

function enterChat(order) {
  currentOrder.value = order
  consultationId.value = order.id
  activeTab.value = 'chat'
  connectWebSocket()
  loadMessages()
}

function backToQueue() {
  activeTab.value = 'queue'
  disconnectWebSocket()
  consultationId.value = null
  currentOrder.value = null
  messages.value = []
  loadQueue()
}

async function loadMessages() {
  try {
    const res = await consultationApi.getMessages(consultationId.value)
    const list = Array.isArray(res) ? res : (res?.records || [])
    messages.value = list
    await nextTick()
    scrollToBottom()
  } catch (e) {
    console.error('加载消息失败:', e)
  }
}

function connectWebSocket() {
  try {
    const socket = new SockJS(import.meta.env.VITE_APP_API_BASE_URL + '/ws')
    stompClient = Stomp.over(socket)

    stompClient.connect({}, () => {
      isConnected.value = true

      stompClient.subscribe(`/topic/consultation/${consultationId.value}`, (message) => {
        const msg = JSON.parse(message.body)
        messages.value.push(msg)
        scrollToBottom()
      })

      stompClient.subscribe(`/topic/consultation/${consultationId.value}/typing`, (message) => {
        const data = JSON.parse(message.body)
        if (data.isTyping) {
          ElMessage.info(`${currentOrder.value?.patientName} 正在输入...`)
        }
      })
    }, (error) => {
      isConnected.value = false
      setTimeout(connectWebSocket, 3000)
    })
  } catch (e) {
    console.error('WebSocket初始化失败:', e)
    isConnected.value = false
  }
}

function disconnectWebSocket() {
  if (stompClient && stompClient.connected) {
    stompClient.disconnect()
  }
  isConnected.value = false
}

function sendMessage() {
  if (!inputMessage.value.trim()) return

  const messageData = {
    senderId: userStore.userInfo?.userId,
    senderType: 2,
    content: inputMessage.value.trim(),
    messageType: 1,
    mediaUrl: null
  }

  if (stompClient && stompClient.connected) {
    stompClient.send(`/app/chat/${consultationId.value}`, {}, JSON.stringify(messageData))
  }

  messages.value.push({
    id: Date.now(),
    senderId: userStore.userInfo?.userId,
    senderType: 2,
    message_type: 1,
    content: inputMessage.value.trim(),
    create_time: new Date().toLocaleString(),
    sender_name: userStore.userInfo?.username,
    is_temp: true
  })

  inputMessage.value = ''
  scrollToBottom()
}

async function completeConsultation() {
  try {
    const { value } = await ElMessageBox.prompt('请输入诊断结果（可选）', '结束问诊', {
      confirmButtonText: '确定结束',
      cancelButtonText: '取消',
      inputPlaceholder: '输入诊断结果或建议...'
    })

    const res = await consultationApi.completeConsultation(consultationId.value, {
      diagnosisResult: value || ''
    })

    if (res) {
      ElMessage.success('问诊已结束')
      backToQueue()
      loadStatistics()
    }
  } catch (e) {}
}

function scrollToBottom() {
  nextTick(() => {
    const container = document.querySelector('.doctor-message-list')
    if (container) {
      container.scrollTop = container.scrollHeight
    }
  })
}

function formatTime(time) {
  if (!time) return ''
  const date = new Date(time)
  return date.toLocaleTimeString('zh-CN', { hour: '2-digit', minute: '2-digit' })
}

function getWaitTime(createTime) {
  if (!createTime) return '--'
  const diff = Math.floor((Date.now() - new Date(createTime).getTime()) / 1000)
  if (diff < 60) return `${diff}秒`
  if (diff < 3600) return `${Math.floor(diff / 60)}分钟`
  return `${Math.floor(diff / 3600)}小时`
}

function getStatusTag(status) {
  const map = { 0: { text: '等待中', type: 'warning' }, 1: { text: '进行中', type: 'success' } }
  return map[status] || { text: '未知', type: 'info' }
}
</script>

<template>
  <div class="doctor-consultation">
    <div class="page-header">
      <h2>在线问诊工作台</h2>
      <div class="stats-cards">
        <el-statistic title="今日总问诊" :value="statistics.total || 0" />
        <el-statistic title="已完成" :value="statistics.completed || 0" class="success-stat" />
        <el-statistic title="待处理" :value="statistics.pending || 0" class="warning-stat" />
        <el-statistic title="平均评分" :value="statistics.avgRating || '-'" :precision="1">
          <template #suffix><span v-if="statistics.avgRating">分</span></template>
        </el-statistic>
      </div>
    </div>

    <el-tabs v-model="activeTab" @tab-change="(tab) => tab === 'queue' ? backToQueue() : ''">
      <el-tab-pane label="候诊队列" name="queue">
        <div class="queue-container">
          <div v-if="queueList.length === 0" class="empty-queue">
            <el-empty description="暂无待接诊的患者" :image-size="120" />
          </div>

          <transition-group name="list-fade" tag="div" class="queue-list">
            <div
              v-for="order in queueList"
              :key="order.id"
              :class="['queue-item', { pending: order.status === 0, inProgress: order.status === 1 }]"
            >
              <div class="patient-info">
                <el-avatar :size="48" :src="order.patientAvatar">
                  {{ order.patientName?.charAt(0) }}
                </el-avatar>
                <div class="info-detail">
                  <h4>{{ order.patientName }}</h4>
                  <p class="complaint">{{ order.chiefComplaint || '未填写主诉' }}</p>
                </div>
              </div>

              <div class="order-meta">
                <el-tag :type="getStatusTag(order.status).type" size="small">
                  {{ getStatusTag(order.status).text }}
                </el-tag>
                <span class="wait-time">等待: {{ getWaitTime(order.createTime) }}</span>
                <span class="order-type">{{ order.consultationType === 3 ? '视频' : order.consultationType === 2 ? '语音' : '图文' }}</span>
              </div>

              <div class="order-actions">
                <el-button
                  v-if="order.status === 0"
                  type="primary"
                  size="small"
                  @click="acceptOrder(order)"
                >
                  接诊
                </el-button>
                <el-button
                  v-if="order.status === 1"
                  type="primary"
                  size="small"
                  plain
                  @click="enterChat(order)"
                >
                  进入对话
                </el-button>
              </div>
            </div>
          </transition-group>
        </div>
      </el-tab-pane>

      <el-tab-pane label="当前对话" name="chat" :disabled="!consultationId">
        <div v-if="currentOrder" class="chat-workspace">
          <div class="chat-info-bar">
            <div class="patient-brief">
              <el-avatar :size="36" :src="currentOrder.patientAvatar">
                {{ currentOrder.patientName?.charAt(0) }}
              </el-avatar>
              <span class="name">{{ currentOrder.patientName }}</span>
              <el-tag size="small" type="info">{{ currentOrder.consultationType === 3 ? '视频问诊' : '图文问诊' }}</el-tag>
            </div>
            <div class="chat-actions">
              <span v-if="isConnected" class="status-dot online">● 已连接</span>
              <span v-else class="status-dot offline">● 未连接</span>
              <el-button size="small" @click="backToQueue">返回队列</el-button>
              <el-button type="danger" size="small" @click="completeConsultation">结束问诊</el-button>
            </div>
          </div>

          <div class="chat-body">
            <div class="doctor-message-list">
              <div v-for="(msg, index) in messages" :key="msg.id || index"
                   :class="['message-row', { self: msg.sender_id === userStore.userInfo?.userId, system: msg.message_type === 5 }]">
                <div v-if="msg.message_type !== 5" class="avatar-wrap">
                  <el-avatar :size="32" :src="msg.sender_avatar">{{ msg.sender_name?.charAt(0) }}</el-avatar>
                </div>
                <div class="bubble-wrap">
                  <div v-if="msg.message_type !== 5" class="sender-label">{{ msg.sender_name }}</div>
                  <div :class="['bubble', { self: msg.sender_id === userStore.userInfo?.userId, system: msg.message_type === 5 }]">
                    <img v-if="msg.media_url && msg.media_type === 'image'" :src="msg.media_url" class="msg-image" />
                    <p v-else>{{ msg.content }}</p>
                  </div>
                  <span class="msg-time">{{ formatTime(msg.create_time) }}</span>
                </div>
              </div>
            </div>

            <div class="input-area">
              <el-input
                v-model="inputMessage"
                type="textarea"
                :rows="2"
                placeholder="回复患者..."
                @keyup.enter.exact="sendMessage"
                :disabled="!isConnected"
              />
              <el-button type="primary" @click="sendMessage" :disabled="!isConnected || !inputMessage.trim()">
                发送
              </el-button>
            </div>
          </div>
        </div>
      </el-tab-pane>
    </el-tabs>
  </div>
</template>

<style lang="scss" scoped>
.doctor-consultation { padding: 20px; background: #f5f7fa; min-height: calc(100vh - 100px); }
.page-header {
  margin-bottom: 24px;
  h2 { font-size: 22px; color: #333; margin-bottom: 16px; }
  .stats-cards {
    display: flex; gap: 16px;
    .el-statistic { background: #fff; padding: 16px 24px; border-radius: 8px; box-shadow: 0 2px 8px rgba(0,0,0,0.04); }
    .success-stat { border-left: 4px solid #67c23a; }
    .warning-stat { border-left: 4px solid #e6a23c; }
  }
}
.queue-container { min-height: 400px; }
.empty-queue { padding: 60px 0; }
.queue-list { display: flex; flex-direction: column; gap: 12px; }

.queue-item {
  background: #fff; padding: 16px 20px; border-radius: 10px;
  display: flex; align-items: center; gap: 20px;
  box-shadow: 0 2px 6px rgba(0,0,0,0.04); transition: all 0.2s;
  &:hover { transform: translateY(-2px); box-shadow: 0 4px 12px rgba(0,0,0,0.08); }
  &.pending { border-left: 4px solid #e6a23c; }
  &.inProgress { border-left: 4px solid #409eff; }
}
.patient-info {
  display: flex; align-items: center; gap: 12px; flex: 1; min-width: 0;
  .info-detail { flex: 1;
    h4 { font-size: 15px; color: #333; margin: 0 0 4px; }
    .complaint { font-size: 13px; color: #666; margin: 0; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; max-width: 250px; }
  }
}
.order-meta {
  display: flex; align-items: center; gap: 10px;
  .wait-time { font-size: 13px; color: #999; }
  .order-type { font-size: 12px; color: #409eff; background: #ecf5ff; padding: 2px 8px; border-radius: 4px; }
}
.order-actions { flex-shrink: 0; }

.chat-workspace { height: calc(100vh - 280px); display: flex; flex-direction: column; }
.chat-info-bar {
  background: #fff; padding: 12px 20px; border-radius: 8px;
  display: flex; justify-content: space-between; align-items: center; margin-bottom: 12px;
  box-shadow: 0 2px 4px rgba(0,0,0,0.04);
  .patient-brief { display: flex; align-items: center; gap: 10px;
    .name { font-weight: 600; font-size: 15px; }
  }
  .chat-actions { display: flex; align-items: center; gap: 10px;
    .status-dot { font-size: 12px;
      &.online { color: #67c23a; }
      &.offline { color: #f56c6c; }
    }
  }
}
.chat-body { flex: 1; display: flex; flex-direction: column; background: #fff; border-radius: 8px; overflow: hidden; }
.doctor-message-list {
  flex: 1; overflow-y: auto; padding: 20px;
  scroll-behavior: smooth;
}
.message-row {
  display: flex; margin-bottom: 16px; max-width: 80%;
  &.self { align-self: flex-end; flex-direction: row-reverse;
    .bubble { background: #409eff; color: #fff; }
    .sender-label { display: none; }
  }
  &.system { justify-content: center; max-width: 90%;
    .bubble { background: #f0f2f5; color: #666; font-size: 13px; }
  }
}
.bubble-wrap { display: flex; flex-direction: column; margin: 0 12px; max-width: 70%;
  .sender-label { font-size: 12px; color: #888; margin-bottom: 4px; }
}
.bubble {
  padding: 10px 14px; border-radius: 14px; word-break: break-word; line-height: 1.5;
  p { margin: 0; white-space: pre-wrap; }
}
.msg-image { max-width: 240px; max-height: 200px; border-radius: 8px; cursor: pointer; }
.msg-time { font-size: 11px; color: #aaa; margin-top: 4px; padding: 0 4px; }
.input-area {
  border-top: 1px solid #eee; padding: 12px 20px;
  display: flex; gap: 10px; align-items: flex-end;
  .el-textarea { flex: 1; }
}

.list-fade-enter-active, .list-fade-leave-active { transition: all 0.3s ease; }
.list-fade-enter-from, .list-fade-leave-to { opacity: 0; transform: translateX(-20px); }
</style>
