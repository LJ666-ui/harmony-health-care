<template>
  <div class="face-login">
    <div class="camera-area">
      <div class="camera-wrapper">
        <video ref="videoRef" autoplay playsinline class="camera-video" v-show="cameraActive"></video>
        <canvas ref="canvasRef" class="face-canvas" v-show="cameraActive"></canvas>
        <div v-if="!cameraActive" class="camera-placeholder">
          <span class="placeholder-icon">📷</span>
          <p>点击下方按钮开启摄像头</p>
        </div>
        <div v-if="cameraActive && !faceDetected" class="scan-overlay">
          <div class="scan-line"></div>
          <div class="scan-frame"></div>
          <p class="scan-text">正在检测人脸...</p>
        </div>
        <div v-if="faceDetected" class="face-detected-overlay">
          <div class="face-frame detected"></div>
          <p class="detected-text">✅ 人脸已检测到</p>
        </div>
      </div>
    </div>

    <div class="face-controls">
      <el-button v-if="!cameraActive" type="primary" @click="startCamera" size="large" round>
        📷 开启摄像头
      </el-button>
      <template v-else>
        <el-button type="primary" @click="captureAndLogin" :loading="recognizing" size="large" round>
          {{ recognizing ? '识别中...' : '🎯 人脸识别登录' }}
        </el-button>
        <el-button @click="stopCamera" size="large" round>
          关闭
        </el-button>
      </template>
    </div>

    <div v-if="recognizedUser" class="recognized-info">
      <div class="user-avatar-lg">{{ (recognizedUser.realName || recognizedUser.username || 'U').charAt(0) }}</div>
      <div class="user-detail">
        <div class="user-name">{{ recognizedUser.realName || recognizedUser.username }}</div>
        <div class="user-confidence">置信度: {{ recognizedUser.confidence }}%</div>
      </div>
      <el-button type="success" @click="confirmLogin" size="large">确认登录</el-button>
    </div>

    <div class="face-tips">
      <p>💡 请确保光线充足，正对摄像头，保持面部完整可见</p>
    </div>
  </div>
</template>

<script setup>
import { ref, onBeforeUnmount } from 'vue'
import request from '@/utils/request'
import { storage } from '@/utils/storage'
import { ElMessage } from 'element-plus'

const emit = defineEmits(['login-success'])

const videoRef = ref(null)
const canvasRef = ref(null)
const cameraActive = ref(false)
const faceDetected = ref(false)
const recognizing = ref(false)
const recognizedUser = ref(null)
let detectInterval = null

async function startCamera() {
  try {
    const stream = await navigator.mediaDevices.getUserMedia({
      video: { width: 640, height: 480, facingMode: 'user' }
    })
    if (videoRef.value) {
      videoRef.value.srcObject = stream
      cameraActive.value = true
      startFaceDetection()
    }
  } catch (e) {
    ElMessage.error('无法访问摄像头，请检查权限设置')
  }
}

function stopCamera() {
  if (videoRef.value && videoRef.value.srcObject) {
    videoRef.value.srcObject.getTracks().forEach(t => t.stop())
    videoRef.value.srcObject = null
  }
  cameraActive.value = false
  faceDetected.value = false
  recognizedUser.value = null
  if (detectInterval) clearInterval(detectInterval)
}

function startFaceDetection() {
  detectInterval = setInterval(() => {
    if (!videoRef.value || !canvasRef.value) return
    const video = videoRef.value
    const canvas = canvasRef.value
    if (video.readyState < 2) return

    canvas.width = video.videoWidth
    canvas.height = video.videoHeight
    const ctx = canvas.getContext('2d')
    ctx.drawImage(video, 0, 0)

    const imageData = ctx.getImageData(
      video.videoWidth * 0.2, video.videoHeight * 0.1,
      video.videoWidth * 0.6, video.videoHeight * 0.8
    )

    let brightness = 0
    const data = imageData.data
    for (let i = 0; i < data.length; i += 40) {
      brightness += (data[i] + data[i + 1] + data[i + 2]) / 3
    }
    brightness = brightness / (data.length / 40)

    faceDetected.value = brightness > 30 && brightness < 240

    if (faceDetected.value) {
      drawFaceFrame(ctx, video.videoWidth, video.videoHeight)
    }
  }, 300)
}

function drawFaceFrame(ctx, w, h) {
  ctx.strokeStyle = '#67c23a'
  ctx.lineWidth = 3
  ctx.setLineDash([8, 4])

  const cx = w / 2
  const cy = h / 2
  const rx = w * 0.18
  const ry = h * 0.25

  ctx.beginPath()
  ctx.ellipse(cx, cy, rx, ry, 0, 0, Math.PI * 2)
  ctx.stroke()
  ctx.setLineDash([])
}

async function captureAndLogin() {
  if (!cameraActive.value || recognizing.value) return
  recognizing.value = true

  try {
    const canvas = canvasRef.value
    const video = videoRef.value
    canvas.width = video.videoWidth
    canvas.height = video.videoHeight
    const ctx = canvas.getContext('2d')
    ctx.drawImage(video, 0, 0)
    const faceData = canvas.toDataURL('image/jpeg', 0.8)

    const loginTypeMap = {
      user: 'user', doctor: 'doctor', nurse: 'nurse',
      family: 'family', admin: 'admin'
    }

    const res = await request.post('/face/login', {
      faceData,
      loginType: loginTypeMap['user'] || 'user'
    })

    if (res) {
      recognizedUser.value = res
      ElMessage.success(`识别成功！欢迎 ${res.realName || res.username}`)
    }
  } catch (e) {
    ElMessage.error('人脸识别失败，请重试或使用密码登录')
  } finally {
    recognizing.value = false
  }
}

function confirmLogin() {
  if (!recognizedUser.value) return
  const user = recognizedUser.value
  storage.setToken(user.token)
  storage.setUserInfo({
    userId: user.userId,
    username: user.username,
    realName: user.realName,
    userType: user.userType
  })
  stopCamera()
  emit('login-success', user)
}

onBeforeUnmount(() => {
  stopCamera()
})
</script>

<style scoped>
.face-login {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 16px;
}

.camera-area {
  width: 100%;
  max-width: 400px;
}

.camera-wrapper {
  position: relative;
  width: 100%;
  aspect-ratio: 4/3;
  background: #1a1a2e;
  border-radius: 16px;
  overflow: hidden;
}

.camera-video {
  width: 100%;
  height: 100%;
  object-fit: cover;
  transform: scaleX(-1);
}

.face-canvas {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  transform: scaleX(-1);
  pointer-events: none;
}

.camera-placeholder {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  height: 100%;
  color: #666;
}

.placeholder-icon { font-size: 64px; margin-bottom: 12px; }

.scan-overlay {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
}

.scan-frame {
  width: 55%;
  height: 70%;
  border: 2px dashed rgba(102, 126, 234, 0.6);
  border-radius: 50%;
  position: absolute;
}

.scan-line {
  position: absolute;
  width: 55%;
  height: 2px;
  background: linear-gradient(90deg, transparent, #667eea, transparent);
  animation: scanMove 2s linear infinite;
}

@keyframes scanMove {
  0% { top: 15%; }
  100% { top: 85%; }
}

.scan-text {
  position: absolute;
  bottom: 20px;
  color: #667eea;
  font-size: 14px;
  font-weight: bold;
  background: rgba(0,0,0,0.5);
  padding: 6px 16px;
  border-radius: 20px;
}

.face-detected-overlay {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
}

.face-frame.detected {
  width: 55%;
  height: 70%;
  border: 3px solid #67c23a;
  border-radius: 50%;
  position: absolute;
  animation: pulseFrame 1.5s infinite;
}

@keyframes pulseFrame {
  0%, 100% { box-shadow: 0 0 0 0 rgba(103, 194, 58, 0.4); }
  50% { box-shadow: 0 0 0 15px rgba(103, 194, 58, 0); }
}

.detected-text {
  position: absolute;
  bottom: 20px;
  color: #67c23a;
  font-size: 14px;
  font-weight: bold;
  background: rgba(0,0,0,0.5);
  padding: 6px 16px;
  border-radius: 20px;
}

.face-controls {
  display: flex;
  gap: 10px;
}

.recognized-info {
  display: flex;
  align-items: center;
  gap: 16px;
  padding: 16px 24px;
  background: #f0f9eb;
  border-radius: 12px;
  border: 2px solid #67c23a;
  width: 100%;
  max-width: 400px;
}

.user-avatar-lg {
  width: 48px;
  height: 48px;
  border-radius: 50%;
  background: #667eea;
  color: #fff;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 20px;
  font-weight: bold;
}

.user-detail { flex: 1; }
.user-name { font-weight: bold; font-size: 16px; color: #333; }
.user-confidence { font-size: 12px; color: #67c23a; }

.face-tips {
  text-align: center;
  color: #999;
  font-size: 12px;
}
</style>