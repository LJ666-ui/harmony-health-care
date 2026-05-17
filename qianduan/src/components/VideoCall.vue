<script setup>
import { ref, onMounted, onUnmounted } from 'vue'
import { ElMessage } from 'element-plus'

const props = defineProps({
  consultationId: {
    type: [String, Number],
    required: true
  },
  isCaller: {
    type: Boolean,
    default: false
  },
  onCallEnd: {
    type: Function,
    default: () => {}
  }
})

const localVideo = ref(null)
const remoteVideo = ref(null)
const isCalling = ref(false)
const isConnected = ref(false)
const callDuration = ref(0)
const isMuted = ref(false)
const isVideoOff = ref(false)
const isScreenSharing = ref(false)

let localStream = null
let peerConnection = null
let stompClient = null
let durationTimer = null

const config = {
  iceServers: [
    { urls: 'stun:stun.l.google.com:19302' },
    { urls: 'stun:stun1.l.google.com:19302' }
  ]
}

onMounted(() => {
  initWebSocket()
})

onUnmounted(() => {
  hangup()
})

async function initWebSocket() {
  const SockJS = (await import('sockjs-client')).default
  const Stomp = (await import('webstomp-client')).default

  const socket = new SockJS(import.meta.env.VITE_APP_API_BASE_URL + '/ws')
  stompClient = Stomp.over(socket)

  stompClient.connect({}, () => {
    stompClient.subscribe(`/topic/consultation/${props.consultationId}/video`, handleSignalMessage)

    if (props.isCaller) {
      startCall()
    }
  })
}

function handleSignalMessage(message) {
  const signal = JSON.parse(message.body)
  switch (signal.type) {
    case 'offer':
      handleOffer(signal)
      break
    case 'answer':
      handleAnswer(signal)
      break
    case 'ice-candidate':
      handleIceCandidate(signal)
      break
    case 'hangup':
      handleRemoteHangup()
      break
  }
}

async function startCall() {
  try {
    localStream = await navigator.mediaDevices.getUserMedia({
      video: { width: 640, height: 480 },
      audio: true
    })

    if (localVideo.value) {
      localVideo.value.srcObject = localStream
    }

    createPeerConnection()
    localStream.getTracks().forEach(track => {
      peerConnection.addTrack(track, localStream)
    })

    const offer = await peerConnection.createOffer()
    await peerConnection.setLocalDescription(offer)

    isCalling.value = true
    sendSignal({ type: 'offer', sdp: offer })

  } catch (error) {
    console.error('无法获取媒体设备:', error)
    ElMessage.error('无法访问摄像头/麦克风，请检查权限设置')
  }
}

function createPeerConnection() {
  peerConnection = new RTCPeerConnection(config)

  peerConnection.onicecandidate = (event) => {
    if (event.candidate) {
      sendSignal({ type: 'ice-candidate', candidate: event.candidate })
    }
  }

  peerConnection.ontrack = (event) => {
    if (remoteVideo.value) {
      remoteVideo.value.srcObject = event.streams[0]
    }
    isConnected.value = true
    startDurationTimer()
  }

  peerConnection.onconnectionstatechange = () => {
    console.log('连接状态:', peerConnection.connectionState)
    if (peerConnection.connectionState === 'disconnected' ||
        peerConnection.connectionState === 'failed') {
      handleRemoteHangup()
    }
  }
}

async function handleOffer(signal) {
  try {
    createPeerConnection()

    localStream = await navigator.mediaDevices.getUserMedia({
      video: true,
      audio: true
    })

    if (localVideo.value) {
      localVideo.value.srcObject = localStream
    }

    localStream.getTracks().forEach(track => {
      peerConnection.addTrack(track, localStream)
    })

    await peerConnection.setRemoteDescription(new RTCSessionDescription(signal.sdp))

    const answer = await peerConnection.createAnswer()
    await peerConnection.setLocalDescription(answer)

    sendSignal({ type: 'answer', sdp: answer })
    isCalling.value = true

  } catch (error) {
    console.error('处理offer失败:', error)
  }
}

async function handleAnswer(signal) {
  try {
    await peerConnection.setRemoteDescription(new RTCSessionDescription(signal.sdp))
  } catch (error) {
    console.error('处理answer失败:', error)
  }
}

async function handleIceCandidate(signal) {
  try {
    if (signal.candidate && peerConnection) {
      await peerConnection.addIceCandidate(new RTCIceCandidate(signal.candidate))
    }
  } catch (error) {
    console.error('添加ICE候选失败:', error)
  }
}

function sendSignal(signal) {
  if (stompClient && stompClient.connected) {
    stompClient.send(`/app/video/${props.consultationId}/signal`, {}, JSON.stringify({
      ...signal,
      senderId: props.isCaller ? 'caller' : 'callee',
      timestamp: Date.now()
    }))
  }
}

function toggleMute() {
  if (localStream) {
    const audioTrack = localStream.getAudioTracks()[0]
    if (audioTrack) {
      audioTrack.enabled = !audioTrack.enabled
      isMuted.value = !audioTrack.enabled
    }
  }
}

function toggleVideo() {
  if (localStream) {
    const videoTrack = localStream.getVideoTracks()[0]
    if (videoTrack) {
      videoTrack.enabled = !videoTrack.enabled
      isVideoOff.value = !videoTrack.enabled
    }
  }
}

async function toggleScreenShare() {
  try {
    if (!isScreenSharing.value) {
      const screenStream = await navigator.mediaDevices.getDisplayMedia({ video: true, audio: false })
      const videoTrack = screenStream.getVideoTracks()[0]

      const sender = peerConnection.getSenders().find(s => s.track.kind === 'video')
      if (sender) {
        sender.replaceTrack(videoTrack)
      }

      if (localVideo.value) {
        localVideo.value.srcObject = screenStream
      }

      isScreenSharing.value = true

      videoTrack.onended = () => {
        stopScreenShare()
      }
    } else {
      stopScreenShare()
    }
  } catch (error) {
    ElMessage.error('无法共享屏幕')
  }
}

function stopScreenShare() {
  if (localStream && peerConnection) {
    const videoTrack = localStream.getVideoTracks()[0]
    const sender = peerConnection.getSenders().find(s => s.track.kind === 'video')
    if (videoTrack && sender) {
      sender.replaceTrack(videoTrack)
    }
    if (localVideo.value) {
      localVideo.value.srcObject = localStream
    }
    isScreenSharing.value = false
  }
}

function startDurationTimer() {
  durationTimer = setInterval(() => {
    callDuration.value++
  }, 1000)
}

function formatDuration(seconds) {
  const h = Math.floor(seconds / 3600)
  const m = Math.floor((seconds % 3600) / 60)
  const s = seconds % 60
  return `${h.toString().padStart(2, '0')}:${m.toString().padStart(2, '0')}:${s.toString().padStart(2, '0')}`
}

function hangup() {
  sendSignal({ type: 'hangup' })

  if (durationTimer) {
    clearInterval(durationTimer)
  }

  if (peerConnection) {
    peerConnection.close()
    peerConnection = null
  }

  if (localStream) {
    localStream.getTracks().forEach(track => track.stop())
    localStream = null
  }

  if (stompClient && stompClient.connected) {
    stompClient.disconnect()
  }

  isConnected.value = false
  isCalling.value = false
  callDuration.value = 0

  props.onCallEnd()
}

function handleRemoteHangup() {
  ElMessage.info('对方已挂断')
  hangup()
}
</script>

<template>
  <div class="video-call-container">
    <div class="video-header">
      <div class="call-info">
        <span v-if="isCalling && !isConnected" class="calling-status">
          <el-icon class="is-loading"><Loading /></el-icon>
          {{ isCaller ? '正在呼叫...' : '正在接听...' }}
        </span>
        <span v-else-if="isConnected" class="connected-status">
          ● 已连接 {{ formatDuration(callDuration) }}
        </span>
      </div>
    </div>

    <div class="video-area">
      <div class="remote-video-wrapper">
        <video ref="remoteVideo" autoplay playsinline class="remote-video"></video>
        <div v-if="!isConnected" class="video-placeholder">
          <el-icon :size="48"><VideoCamera /></el-icon>
          <p>等待对方连接...</p>
        </div>
      </div>

      <div class="local-video-wrapper">
        <video ref="localVideo" autoplay playsinline muted class="local-video"></video>
        <div v-if="isVideoOff" class="video-off-overlay">
          <el-icon :size="32"><VideoCamera /></el-icon>
          <span>摄像头已关闭</span>
        </div>
      </div>
    </div>

    <div class="control-bar">
      <button :class="['ctrl-btn', { active: isMuted }]" @click="toggleMute">
        <el-icon :size="22"><Microphone v-if="!isMuted" /><Mute v-else /></el-icon>
        <span>{{ isMuted ? '取消静音' : '静音' }}</span>
      </button>

      <button :class="['ctrl-btn', { active: isVideoOff }]" @click="toggleVideo">
        <el-icon :size="22"><VideoCamera v-if="!isVideoOff" /><VideoPause v-else /></el-icon>
        <span>{{ isVideoOff ? '开启摄像头' : '关闭摄像头' }}</span>
      </button>

      <button :class="['ctrl-btn', { active: isScreenSharing }]" @click="toggleScreenShare">
        <el-icon :size="22"><Monitor /></el-icon>
        <span>{{ isScreenSharing ? '停止共享' : '屏幕共享' }}</span>
      </button>

      <button class="ctrl-btn hangup" @click="hangup">
        <el-icon :size="22"><Phone /></el-icon>
        <span>挂断</span>
      </button>
    </div>
  </div>
</template>

<style lang="scss" scoped>
.video-call-container {
  background: #1a1a2e; border-radius: 12px; overflow: hidden;
  display: flex; flex-direction: column; height: 500px;
}
.video-header {
  padding: 12px 20px; background: rgba(0,0,0,0.3); text-align: center;
  .call-info {
    color: #fff; font-size: 14px;
    .calling-status { color: #ffd700; display: flex; align-items: center; justify-content: center; gap: 8px; }
    .connected-status { color: #4ade80; }
  }
}
.video-area {
  flex: 1; position: relative; background: #000; display: flex; align-items: center; justify-content: center;
}
.remote-video-wrapper {
  width: 100%; height: 100%; display: flex; align-items: center; justify-content: center;
  .remote-video { width: 100%; height: 100%; object-fit: cover; }
  .video-placeholder {
    color: #666; text-align: center;
    p { margin-top: 12px; font-size: 14px; }
  }
}
.local-video-wrapper {
  position: absolute; bottom: 80px; right: 20px; width: 180px; height: 135px;
  border-radius: 10px; overflow: hidden; border: 2px solid rgba(255,255,255,0.3);
  box-shadow: 0 4px 12px rgba(0,0,0,0.5);
  .local-video { width: 100%; height: 100%; object-fit: cover; transform: scaleX(-1); }
  .video-off-overlay {
    position: absolute; inset: 0; background: #333; color: #999;
    display: flex; flex-direction: column; align-items: center; justify-content: center; gap: 8px; font-size: 12px;
  }
}
.control-bar {
  padding: 16px 20px; background: rgba(0,0,0,0.4);
  display: flex; justify-content: center; gap: 16px;
}
.ctrl-btn {
  display: flex; flex-direction: column; align-items: center; gap: 4px;
  padding: 10px 18px; border: none; border-radius: 50px; cursor: pointer;
  background: rgba(255,255,255,0.15); color: #fff; transition: all 0.2s;
  span { font-size: 11px; }
  &:hover { background: rgba(255,255,255,0.25); transform: translateY(-2px); }
  &.active { background: #ef4444; }
  &.hangup { background: #dc2626;
    &:hover { background: #b91c1c; }
  }
}
</style>
