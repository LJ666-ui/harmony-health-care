<script setup>
import { ref, onMounted, onUnmounted, nextTick } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useUserStore } from '@/stores/user'
import { ElMessage, ElMessageBox } from 'element-plus'
import consultationApi from '@/api/consultation'
import SockJS from 'sockjs-client'
import Stomp from 'webstomp-client'

const route = useRoute()
const router = useRouter()
const userStore = useUserStore()

const consultationId = ref(route.params.id || null)
const orderInfo = ref(null)
const messages = ref([])
const inputMessage = ref('')
const loading = ref(false)
const isConnected = ref(false)
const isTyping = ref(false)
const otherTyping = ref(false)
let stompClient = null
let typingTimer = null

onMounted(() => {
  if (consultationId.value) {
    loadConsultationDetail()
    loadMessages()
    connectWebSocket()
  }
})

onUnmounted(() => {
  disconnectWebSocket()
})

async function loadConsultationDetail() {
  try {
    const res = await consultationApi.getConsultationDetail(consultationId.value)
    if (res && res.id) {
      orderInfo.value = res
    }
  } catch (e) {
    console.error('加载问诊详情失败:', e)
  }
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
      ElMessage.success('已连接到聊天服务')

      stompClient.subscribe(`/topic/consultation/${consultationId.value}`, (message) => {
        const msg = JSON.parse(message.body)
        messages.value.push(msg)
        scrollToBottom()
      })

      stompClient.subscribe(`/topic/consultation/${consultationId.value}/typing`, (message) => {
        const data = JSON.parse(message.body)
        otherTyping.value = data.isTyping
        if (data.isTyping) {
          setTimeout(() => { otherTyping.value = false }, 3000)
        }
      })
    }, (error) => {
      console.error('WebSocket连接失败:', error)
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
    senderType: 1,
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
    senderType: 1,
    message_type: 1,
    content: inputMessage.value.trim(),
    create_time: new Date().toLocaleString(),
    sender_name: userStore.userInfo?.username,
    is_temp: true
  })

  inputMessage.value = ''
  scrollToBottom()
}

function handleInput() {
  if (!isTyping.value && isConnected.value && stompClient && stompClient.connected) {
    isTyping.value = true
    stompClient.send(`/app/chat/${consultationId.value}/typing`, {}, JSON.stringify({
      userId: userStore.userInfo?.userId,
      isTyping: true
    }))
  }

  clearTimeout(typingTimer)
  typingTimer = setTimeout(() => {
    isTyping.value = false
    if (isConnected.value && stompClient && stompClient.connected) {
      stompClient.send(`/app/chat/${consultationId.value}/typing`, {}, JSON.stringify({
        userId: userStore.userInfo?.userId,
        isTyping: false
      }))
    }
  }, 1000)
}

function scrollToBottom() {
  nextTick(() => {
    const container = document.querySelector('.message-list')
    if (container) {
      container.scrollTop = container.scrollHeight
    }
  })
}

async function handleImageUpload(event) {
  const file = event.target.files[0]
  if (!file) return

  if (!file.type.startsWith('image/')) {
    ElMessage.error('请选择图片文件')
    return
  }

  const formData = new FormData()
  formData.append('file', file)

  try {
    loading.value = true
    const uploadRes = await fetch(import.meta.env.VITE_APP_API_BASE_URL + '/file/upload', {
      method: 'POST',
      body: formData
    }).then(r => r.json())

    if (uploadRes.code === 200 && stompClient && stompClient.connected) {
      stompClient.send(`/app/chat/${consultationId.value}`, {}, JSON.stringify({
        senderId: userStore.userInfo?.userId,
        senderType: 1,
        content: '[图片]',
        messageType: 2,
        mediaUrl: uploadRes.data
      }))
    }
  } catch (e) {
    ElMessage.error('上传失败')
  } finally {
    loading.value = false
    event.target.value = ''
  }
}

async function endConsultation() {
  try {
    await ElMessageBox.confirm('确定要结束本次问诊吗？', '提示', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })

    const res = await consultationApi.completeConsultation(consultationId.value, {})
    if (res) {
      ElMessage.success('问诊已结束')
      router.push('/user/consultation')
    }
  } catch (e) {}
}

function formatTime(time) {
  if (!time) return ''
  const date = new Date(time)
  return date.toLocaleTimeString('zh-CN', { hour: '2-digit', minute: '2-digit' })
}

function getStatusText(status) {
  const statusMap = {
    0: '等待接诊',
    1: '进行中',
    2: '已完成',
    3: '已取消',
    4: '已超时'
  }
  return statusMap[status] || '未知'
}

function getStatusType(status) {
  const typeMap = {
    0: 'warning',
    1: 'success',
    2: 'info',
    3: 'danger',
    4: 'danger'
  }
  return typeMap[status] || 'info'
}
</script>

<template>
  <div class="consultation-chat">
    <div class="chat-header">
      <div class="header-left">
        <el-button text @click="router.back()">
          <el-icon><ArrowLeft /></el-icon> 返回
        </el-button>
        <div class="doctor-info" v-if="orderInfo">
          <span class="doctor-name">{{ orderInfo.doctorName }}</span>
          <el-tag :type="getStatusType(orderInfo.status)" size="small">
            {{ getStatusText(orderInfo.status) }}
          </el-tag>
          <span v-if="isConnected" class="connection-status online">● 已连接</span>
          <span v-else class="connection-status offline">● 未连接</span>
        </div>
      </div>
      <div class="header-right">
        <el-button type="danger" size="small" @click="endConsultation"
                   v-if="orderInfo && orderInfo.status === 1"
                   :disabled="!isConnected">
          结束问诊
        </el-button>
      </div>
    </div>

    <div class="chat-body">
      <div class="message-list" ref="messageListRef">
        <div v-if="messages.length === 0" class="empty-message">
          暂无消息，开始对话吧~
        </div>

        <transition-group name="message-fade">
          <div
            v-for="(msg, index) in messages"
            :key="msg.id || index"
            :class="['message-item', { self: msg.sender_id === userStore.userInfo?.userId, system: msg.message_type === 5 }]"
          >
            <div v-if="msg.message_type !== 5" class="message-avatar">
              <el-avatar :size="36" :src="msg.sender_avatar">
                {{ msg.sender_name?.charAt(0) }}
              </el-avatar>
            </div>
            <div class="message-content-wrapper">
              <div class="sender-name" v-if="msg.message_type !== 5">{{ msg.sender_name }}</div>
              <div :class="['message-bubble', { image: msg.media_url }]">
                <img v-if="msg.media_url && msg.media_type === 'image'" :src="msg.media_url" alt="图片" class="message-image" />
                <p v-else>{{ msg.content }}</p>
              </div>
              <div class="message-time">{{ formatTime(msg.create_time) }}</div>
            </div>
          </div>
        </transition-group>

        <div v-if="otherTyping" class="typing-indicator">
          <span class="typing-text">对方正在输入...</span>
        </div>
      </div>

      <div class="chat-input-area">
        <div class="input-tools">
          <label class="upload-btn">
            <input type="file" accept="image/*" @change="handleImageUpload" hidden />
            <el-icon><Picture /></el-icon>
          </label>
        </div>
        <el-input
          v-model="inputMessage"
          type="textarea"
          :rows="2"
          placeholder="输入消息..."
          @input="handleInput"
          @keyup.enter.exact="sendMessage"
          :disabled="!isConnected || (orderInfo && orderInfo.status !== 1)"
        />
        <el-button type="primary" @click="sendMessage" :loading="loading"
                   :disabled="!isConnected || !inputMessage.trim() || (orderInfo && orderInfo.status !== 1)">
          发送
        </el-button>
      </div>
    </div>
  </div>
</template>

<style lang="scss" scoped>
.consultation-chat {
  height: calc(100vh - 120px);
  display: flex;
  flex-direction: column;
  background: #f5f7fa;
  border-radius: 12px;
  overflow: hidden;
}
.chat-header {
  background: #fff;
  padding: 16px 20px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  border-bottom: 1px solid #e8ecf0;
  .header-left {
    display: flex; align-items: center; gap: 12px;
    .doctor-info {
      display: flex; align-items: center; gap: 10px;
      .doctor-name { font-size: 15px; font-weight: 600; color: #333; }
      .connection-status { font-size: 12px;
        &.online { color: #67c23a; }
        &.offline { color: #f56c6c; }
      }
    }
  }
}
.chat-body {
  flex: 1; display: flex; flex-direction: column; overflow: hidden;
}
.message-list {
  flex: 1; overflow-y: auto; padding: 20px;
  scroll-behavior: smooth;
  .empty-message {
    text-align: center; color: #999; padding: 60px 0; font-size: 14px;
  }
}
.message-item {
  display: flex; margin-bottom: 20px; max-width: 80%;
  &.self { align-self: flex-end; flex-direction: row-reverse;
    .message-content-wrapper { align-items: flex-end; }
    .message-bubble { background: #409eff; color: #fff; }
    .sender-name { display: none; }
  }
  &.system {
    justify-content: center; max-width: 90%;
    .message-bubble { background: #f0f2f5; color: #666; font-size: 13px; padding: 8px 16px; }
  }
  &:not(.system):not(.self) { align-self: flex-start;
    .message-bubble { background: #fff; }
  }
}
.message-avatar { flex-shrink: 0; }
.message-content-wrapper { display: flex; flex-direction: column; margin: 0 12px; max-width: 70%;
  .sender-name { font-size: 12px; color: #666; margin-bottom: 4px; }
}
.message-bubble {
  padding: 12px 16px; border-radius: 18px; word-break: break-word; line-height: 1.5;
  box-shadow: 0 1px 3px rgba(0,0,0,0.08); position: relative;
  p { margin: 0; white-space: pre-wrap; }
  &.image { padding: 4px; background: transparent; box-shadow: none; }
}
.message-image { max-width: 280px; max-height: 240px; border-radius: 12px; cursor: pointer; }
.message-time { font-size: 11px; color: #999; margin-top: 4px; padding: 0 4px; }
.typing-indicator { padding: 10px 20px;
  .typing-text { color: #999; font-size: 13px; animation: pulse 1.5s infinite; }
}
@keyframes pulse { 0%, 100% { opacity: 0.6; } 50% { opacity: 1; } }
.chat-input-area {
  background: #fff; padding: 16px 20px; border-top: 1px solid #e8ecf0;
  display: flex; gap: 12px; align-items: flex-end;
  .input-tools { display: flex; gap: 8px;
    .upload-btn { cursor: pointer; color: #666; font-size: 20px;
      &:hover { color: #409eff; }
    }
  }
  .el-textarea { flex: 1; }
}
.message-fade-enter-active, .message-fade-leave-active { transition: all 0.3s ease; }
.message-fade-enter-from { opacity: 0; transform: translateY(10px); }
</style>