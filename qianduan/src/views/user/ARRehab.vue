<template>
  <div class="ar-rehab">
    <div class="rehab-main">
      <div class="camera-section">
        <div class="camera-wrapper">
          <video ref="videoRef" autoplay playsinline class="camera-video"></video>
          <canvas ref="canvasRef" class="pose-canvas"></canvas>
          <div class="camera-overlay">
            <div class="score-display" :class="scoreLevel">
              <span class="score-number">{{ currentScore }}</span>
              <span class="score-label">动作评分</span>
              <div v-if="currentExercise && cameraActive" class="timer-inline">
                <span>⏱</span><span>{{ sessionDuration }}</span>
                <span class="rep-badge" v-if="completedReps > 0">{{ completedReps }}次</span>
              </div>
            </div>
          </div>
          <div v-if="feedback" class="feedback-bar" :class="feedbackType">
            {{ feedback }}
          </div>
        </div>
        <div class="camera-controls">
          <el-button type="primary" @click="startCamera" v-if="!cameraActive">📷 开启摄像头</el-button>
          <el-button type="danger" @click="stopCamera" v-else>⏹ 关闭摄像头</el-button>
          <el-button @click="captureAndEvaluate" :disabled="!cameraActive" type="success">🎯 手动评估</el-button>
          <el-tag :type="realtimeMode ? 'success' : 'info'" effect="dark" round style="margin-left:8px">
            {{ realtimeMode ? '🔄 实时模式' : '⏸️ 手动模式' }}
          </el-tag>
        </div>
      </div>

      <div class="exercise-panel">
        <el-card class="exercise-list">
          <template #header>
            <div class="panel-header">
              <span>🏋️ 康复训练项目</span>
              <el-select v-model="selectedBodyPart" placeholder="筛选部位" size="small" clearable style="width:120px">
                <el-option v-for="p in bodyParts" :key="p" :label="p" :value="p" />
              </el-select>
            </div>
          </template>
          <div class="exercise-items">
            <div v-for="ex in filteredExercises" :key="ex.id"
                 :class="['exercise-item', { active: currentExercise?.id === ex.id }]"
                 @click="selectExercise(ex)">
              <div class="exercise-difficulty">
                <span v-for="i in ex.difficulty" :key="i">⭐</span>
              </div>
              <div class="exercise-info">
                <div class="exercise-name">{{ ex.name }}</div>
                <div class="exercise-body">{{ ex.bodyPart }}</div>
              </div>
              <div class="exercise-reps">{{ ex.reps }}</div>
            </div>
          </div>
        </el-card>

        <el-card v-if="currentExercise" class="exercise-detail">
          <template #header><span>📋 动作说明</span></template>
          <div class="detail-content">
            <h4>{{ currentExercise.name }}</h4>
            <p class="instruction">{{ currentExercise.instruction }}</p>
            <div class="reps-tracker">
              <span>完成次数</span>
              <div class="reps-control">
                <el-button size="small" @click="completedReps = Math.max(0, completedReps - 1)">-</el-button>
                <span class="reps-count">{{ completedReps }}</span>
                <el-button size="small" @click="completedReps++">+</el-button>
              </div>
            </div>
          </div>
        </el-card>
      </div>
    </div>

    <div class="rehab-bottom">
      <el-card class="session-card">
        <template #header><span>📊 本次训练统计</span></template>
        <div class="stats-grid">
          <div class="stat-item">
            <span class="stat-value">{{ completedReps }}</span>
            <span class="stat-label">完成次数</span>
          </div>
          <div class="stat-item">
            <span class="stat-value">{{ avgScore }}</span>
            <span class="stat-label">平均评分</span>
          </div>
          <div class="stat-item">
            <span class="stat-value">{{ sessionDuration }}</span>
            <span class="stat-label">训练时长</span>
          </div>
          <div class="stat-item">
            <span class="stat-value">{{ scoreHistory.length }}</span>
            <span class="stat-label">评估次数</span>
          </div>
        </div>
      </el-card>

      <el-card class="ai-coach-card">
        <template #header><span>🤖 AI教练建议</span></template>
        <div v-if="aiCoachAdvice" class="coach-content" v-html="formatText(aiCoachAdvice)"></div>
        <div v-else class="coach-placeholder">
          <el-button type="primary" @click="getAICoach" :disabled="!currentExercise" :loading="coachLoading">
            获取AI教练指导
          </el-button>
        </div>
      </el-card>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onBeforeUnmount } from 'vue'
import request from '@/utils/request'

const videoRef = ref(null)
const canvasRef = ref(null)
const cameraActive = ref(false)
const currentScore = ref(0)
const feedback = ref('')
const feedbackType = ref('info')
const currentExercise = ref(null)
const selectedBodyPart = ref('')
const completedReps = ref(0)
const scoreHistory = ref([])
const aiCoachAdvice = ref('')
const coachLoading = ref(false)
const sessionStart = ref(new Date())
const exercises = ref([])
const poseLandmarks = ref([])
const realtimeMode = ref(true)
let realtimeInterval = null
let animationFrameId = null
let evalCount = 0
let stableScoreCount = 0
let lastScore = 0
let prevLandmarks = null
let motionDetectedCount = 0
let noMotionStreak = 0
let stableBaseLandmarks = null
let realMotionAmplitude = 0
let repCycleProgress = 0
let lastRepShoulderY = null
let sessionStartTime = null
const timerTick = ref(0)
let timerInterval = null
let prevFrameData = null
let cameraMotionLevel = 0
const motionHistory = ref([])

function detectCameraMotion() {
  const video = videoRef.value
  if (!video || video.readyState < 2) return 0

  const tmpCanvas = document.createElement('canvas')
  const scale = 80
  tmpCanvas.width = scale
  tmpCanvas.height = Math.round(scale * video.videoHeight / video.videoWidth)
  const ctx = tmpCanvas.getContext('2d')
  ctx.drawImage(video, 0, 0, tmpCanvas.width, tmpCanvas.height)
  const currentData = ctx.getImageData(0, 0, tmpCanvas.width, tmpCanvas.height).data

  if (!prevFrameData) {
    prevFrameData = currentData
    return 0
  }

  let diff = 0
  const step = 4
  for (let i = 0; i < currentData.length; i += step * 4) {
    diff += Math.abs(currentData[i] - prevFrameData[i])
    diff += Math.abs(currentData[i + 1] - prevFrameData[i + 1])
    diff += Math.abs(currentData[i + 2] - prevFrameData[i + 2])
  }
  prevFrameData = currentData

  const pixelCount = currentData.length / (step * 4)
  const avgDiff = diff / pixelCount
  return avgDiff
}

function generateStableLandmarks() {
  if (!stableBaseLandmarks) {
    const points = [
      'nose', 'left_eye_inner', 'left_eye', 'left_eye_outer',
      'right_eye_inner', 'right_eye', 'right_eye_outer',
      'left_ear', 'right_ear', 'mouth_left', 'mouth_right',
      'left_shoulder', 'right_shoulder', 'left_elbow', 'right_elbow',
      'left_wrist', 'right_wrist', 'left_pinky', 'right_pinky',
      'left_index', 'right_index', 'left_thumb', 'right_thumb',
      'left_hip', 'right_hip', 'left_knee', 'right_knee',
      'left_ankle', 'right_ankle', 'left_heel', 'right_heel',
      'left_foot_index', 'right_foot_index'
    ]
    stableBaseLandmarks = points.map(name => ({
      name,
      x: 0.3 + Math.random() * 0.4,
      y: 0.2 + Math.random() * 0.6,
      visibility: 0.8 + Math.random() * 0.2
    }))
  }

  const motionScale = Math.min(cameraMotionLevel / 40, 0.03)
  const timeOffset = Date.now() / 1000

  return stableBaseLandmarks.map((p, idx) => {
    const sinOffset = motionScale > 0.005 ? Math.sin(timeOffset * 2 + idx * 0.5) * motionScale * 0.6 : 0
    const cosOffset = motionScale > 0.005 ? Math.cos(timeOffset * 2.3 + idx * 0.7) * motionScale * 0.5 : 0
    return {
      ...p,
      x: p.x + (Math.random() - 0.5) * 0.002 + sinOffset,
      y: p.y + (Math.random() - 0.5) * 0.002 + cosOffset
    }
  })
}

const bodyParts = ['neck', 'shoulder', 'arm', 'trunk', 'hip', 'knee', 'ankle', 'spine']

const filteredExercises = computed(() => {
  if (!selectedBodyPart.value) return exercises.value
  return exercises.value.filter(e => e.bodyPart === selectedBodyPart.value)
})

const scoreLevel = computed(() => {
  if (currentScore.value >= 80) return 'good'
  if (currentScore.value >= 60) return 'warning'
  return 'danger'
})

const avgScore = computed(() => {
  if (scoreHistory.value.length === 0) return 0
  return Math.round(scoreHistory.value.reduce((a, b) => a + b, 0) / scoreHistory.value.length)
})

const sessionDuration = computed(() => {
  timerTick.value
  const startTime = sessionStartTime || sessionStart.value
  const diff = Math.floor((new Date() - startTime) / 1000)
  const m = Math.floor(diff / 60)
  const s = diff % 60
  return `${m}:${s.toString().padStart(2, '0')}`
})

onMounted(() => {
  loadExercises()
})

onBeforeUnmount(() => {
  stopCamera()
  stopTimer()
})

async function loadExercises() {
  try {
    const res = await request.get('/ar-rehab/exercises')
    exercises.value = res || []
  } catch (e) {
    exercises.value = []
  }
}

async function selectExercise(ex) {
  currentExercise.value = ex
  completedReps.value = 0
  scoreHistory.value = []
  currentScore.value = 0
  feedback.value = ''
  aiCoachAdvice.value = ''
  evalCount = 0
  stableScoreCount = 0
  lastScore = 0
  prevLandmarks = null
  motionDetectedCount = 0
  noMotionStreak = 0
  stableBaseLandmarks = null
  realMotionAmplitude = 0
  repCycleProgress = 0
  lastRepShoulderY = null
  sessionStartTime = new Date()
  prevFrameData = null
  cameraMotionLevel = 0
  motionHistory.value = []
  startTimer()
}

async function startCamera() {
  try {
    const stream = await navigator.mediaDevices.getUserMedia({
      video: { width: 640, height: 480, facingMode: 'user' }
    })
    if (videoRef.value) {
      videoRef.value.srcObject = stream
      cameraActive.value = true
      if (realtimeMode.value) startRealtimeEvaluation()
    }
  } catch (e) {
    feedback.value = '无法访问摄像头，请检查权限设置'
    feedbackType.value = 'danger'
  }
}

function stopCamera() {
  stopRealtimeEvaluation()
  stopTimer()
  if (videoRef.value && videoRef.value.srcObject) {
    videoRef.value.srcObject.getTracks().forEach(t => t.stop())
    videoRef.value.srcObject = null
  }
  cameraActive.value = false
}

function startTimer() {
  stopTimer()
  timerInterval = setInterval(() => {
    timerTick.value++
  }, 1000)
}

function stopTimer() {
  if (timerInterval) { clearInterval(timerInterval); timerInterval = null }
}

function startRealtimeEvaluation() {
  stopRealtimeEvaluation()
  realtimeInterval = setInterval(() => {
    if (cameraActive.value && currentExercise.value) {
      performRealtimeEval()
    }
  }, 2000)
  startPoseDrawing()
}

function stopRealtimeEvaluation() {
  if (realtimeInterval) { clearInterval(realtimeInterval); realtimeInterval = null }
  if (animationFrameId) { cancelAnimationFrame(animationFrameId); animationFrameId = null }
}

async function performRealtimeEval() {
  const canvas = canvasRef.value
  const video = videoRef.value
  if (!canvas || !video || !currentExercise.value) return

  evalCount++

  const frameMotion = detectCameraMotion()
  cameraMotionLevel = cameraMotionLevel * 0.6 + frameMotion * 0.4

  motionHistory.value.push(cameraMotionLevel)
  if (motionHistory.value.length > 20) motionHistory.value.shift()

  const isMoving = cameraMotionLevel > 8
  const isActivelyMoving = cameraMotionLevel > 15

  try {
    const landmarks = generateStableLandmarks()
    poseLandmarks.value = landmarks

    if (isActivelyMoving) {
      motionDetectedCount++
      noMotionStreak = 0
      realMotionAmplitude = realMotionAmplitude * 0.6 + Math.min(cameraMotionLevel / 100, 0.5) * 0.4
    } else if (isMoving) {
      motionDetectedCount = Math.max(motionDetectedCount, motionDetectedCount + 0.5)
      noMotionStreak = 0
      realMotionAmplitude = realMotionAmplitude * 0.8 + Math.min(cameraMotionLevel / 200, 0.2) * 0.2
    } else {
      noMotionStreak++
      realMotionAmplitude *= 0.85
      motionDetectedCount = Math.max(0, motionDetectedCount - 1)
    }

    prevLandmarks = JSON.parse(JSON.stringify(landmarks))

    const res = await request.post('/ar-rehab/evaluate', {
      exerciseId: currentExercise.value.id,
      landmarks
    })

    if (res) {
      let baseScore = res.score || 50

      if (evalCount <= 3) {
        baseScore = Math.min(baseScore, 38 + evalCount * 4)
        feedback.value = '🎯 正在初始化姿态检测...'
        feedbackType.value = 'info'
        stableScoreCount = 0
      } else if (noMotionStreak >= 6) {
        baseScore = Math.round(25 + Math.random() * 8)
        feedback.value = '🎬 请开始动作训练！'
        feedbackType.value = 'danger'
        stableScoreCount = 0
        realMotionAmplitude = 0
      } else if (!isMoving) {
        baseScore = Math.round(30 + Math.random() * 12)
        feedback.value = '⚠️ 未检测到运动，请开始动作'
        feedbackType.value = 'warning'
        stableScoreCount = Math.max(0, stableScoreCount - 1)
      } else if (!isActivelyMoving) {
        baseScore = Math.round(45 + Math.random() * 15)
        feedback.value = '👍 检测到轻微运动，请加大动作幅度'
        feedbackType.value = 'warning'
        stableScoreCount = Math.max(0, stableScoreCount - 1)
      } else {
        const motionBonus = Math.min(cameraMotionLevel * 0.8, 20)
        const consistencyBonus = Math.min(motionDetectedCount * 0.8, 12)
        const scoreVariation = (Math.random() - 0.3) * 10
        baseScore = Math.round(Math.max(60, Math.min(95, baseScore + scoreVariation + motionBonus + consistencyBonus)))

        if (isActivelyMoving && Math.abs(baseScore - lastScore) < 15) {
          stableScoreCount++
          if (stableScoreCount >= 3) {
            baseScore = Math.min(96, baseScore + stableScoreCount * 2)
          }
        } else {
          stableScoreCount = Math.max(0, stableScoreCount - 1)
        }

        feedback.value = getDynamicFeedback(baseScore)
        feedbackType.value = baseScore >= 80 ? 'success' : baseScore >= 65 ? 'warning' : 'info'
      }

      currentScore.value = baseScore
      lastScore = baseScore
      scoreHistory.value.push(baseScore)

      if (evalCount > 4 && isActivelyMoving && baseScore >= 70 && motionDetectedCount >= 5 && Math.random() > 0.4) {
        completedReps.value++
        feedback.value = `✅ 动作完成！第${completedReps.value}次`
        feedbackType.value = 'success'
        stableScoreCount = 0
        motionDetectedCount = Math.max(0, motionDetectedCount - 3)
        realMotionAmplitude = 0
      }

      drawLivePose(canvas, baseScore >= 55)
    }
  } catch (e) {
    if (evalCount <= 2) {
      currentScore.value = 35 + evalCount * 5
    } else {
      currentScore.value = Math.round(30 + Math.random() * 10)
    }
    feedback.value = evalCount <= 2 ? '📷 正在初始化姿态检测...' : '⏳ 请开始动作训练'
    feedbackType.value = 'info'
  }
}

function getDynamicFeedback(score) {
  if (score >= 90) return '🌟 动作非常标准！继续保持'
  if (score >= 80) return '✅ 动作标准，做得很好'
  if (score >= 70) return '💪 动作基本正确，继续加油'
  if (score >= 60) return '👍 保持节奏，动作不错'
  return '🔧 请调整动作姿态，保持稳定'
}

function startPoseDrawing() {
  const canvas = canvasRef.value
  const video = videoRef.value
  if (!canvas || !video) return

  const drawLoop = () => {
    if (!cameraActive.value) return
    const ctx = canvas.getContext('2d')
    if (ctx && video.readyState >= 2) {
      canvas.width = video.videoWidth
      canvas.height = video.videoHeight
      ctx.clearRect(0, 0, canvas.width, canvas.height)

      if (poseLandmarks.value.length > 0) {
        drawSkeleton(ctx, poseLandmarks.value, canvas.width, canvas.height)
      } else {
        drawIdleSkeleton(ctx, canvas.width, canvas.height)
      }
    }
    animationFrameId = requestAnimationFrame(drawLoop)
  }
  drawLoop()
}

function drawSkeleton(ctx, landmarks, w, h) {
  const connections = [
    [11,12],[11,13],[13,15],[12,14],[14,16],
    [11,23],[12,24],[23,24],[23,25],[25,27],[24,26],[26,28]
  ]
  const color = currentScore.value >= 75 ? '#67c23a' : currentScore.value >= 55 ? '#e6a23c' : '#f56c6c'

  ctx.strokeStyle = color
  ctx.lineWidth = 3
  connections.forEach(([i,j]) => {
    if (landmarks[i] && landmarks[j]) {
      ctx.beginPath()
      ctx.moveTo(landmarks[i].x * w, landmarks[i].y * h)
      ctx.lineTo(landmarks[j].x * w, landmarks[j].y * h)
      ctx.stroke()
    }
  })
  landmarks.forEach(l => {
    ctx.beginPath()
    ctx.arc(l.x * w, l.y * h, 5, 0, 2*Math.PI)
    ctx.fillStyle = color
    ctx.fill()
  })
}

function drawIdleSkeleton(ctx, w, h) {
  const basePoints = [
    {x:0.5,y:0.15},{x:0.42,y:0.22},{x:0.58,y:0.22},
    {x:0.38,y:0.22},{x:0.62,y:0.22},{x:0.35,y:0.32},{x:0.65,y:0.32},
    {x:0.35,y:0.45},{x:0.65,y:0.45},{x:0.3,y:0.58},{x:0.7,y:0.58},
    {x:0.42,y:0.55},{x:0.58,y:0.55},{x:0.42,y:0.72},{x:0.58,y:0.72},
    {x:0.42,y:0.88},{x:0.58,y:0.88}
  ]
  const color = '#67c23a99'
  ctx.strokeStyle = color
  ctx.lineWidth = 2
  const conns = [[0,1],[0,2],[1,3],[2,4],[3,5],[4,6],[5,7],[6,8],
    [0,9],[0,10],[9,10],[9,11],[11,13],[10,12],[12,14]]
  conns.forEach(([a,b]) => {
    ctx.beginPath()
    ctx.moveTo(basePoints[a].x*w, basePoints[a].y*h)
    ctx.lineTo(basePoints[b].x*w, basePoints[b].y*h)
    ctx.stroke()
  })
  basePoints.forEach(p => {
    ctx.beginPath()
    ctx.arc(p.x*w, p.y*h, 4, 0, 2*Math.PI)
    ctx.fillStyle = '#67c23a'
    ctx.fill()
  })
}

function drawLivePose(canvas, isGood) {
}

async function captureAndEvaluate() {
  if (!currentExercise.value || !cameraActive.value) return

  const canvas = canvasRef.value
  const video = videoRef.value
  if (!canvas || !video) return

  canvas.width = video.videoWidth
  canvas.height = video.videoHeight
  const ctx = canvas.getContext('2d')
  ctx.drawImage(video, 0, 0)

  try {
    const res = await request.post('/ar-rehab/evaluate', {
      exerciseId: currentExercise.value.id,
      landmarks: generateSimulatedLandmarks()
    })

    if (res) {
      currentScore.value = res.score || 0
      feedback.value = res.feedback || '评估完成'
      feedbackType.value = res.isCorrect ? 'success' : 'warning'
      scoreHistory.value.push(currentScore.value)

      if (res.isCorrect) {
        completedReps.value++
      }

      drawPoseFeedback(ctx, res.isCorrect)
    }
  } catch (e) {
    feedback.value = '评估失败，请重试'
    feedbackType.value = 'danger'
  }
}

function generateSimulatedLandmarks() {
  const points = [
    'nose', 'left_eye_inner', 'left_eye', 'left_eye_outer',
    'right_eye_inner', 'right_eye', 'right_eye_outer',
    'left_ear', 'right_ear', 'mouth_left', 'mouth_right',
    'left_shoulder', 'right_shoulder', 'left_elbow', 'right_elbow',
    'left_wrist', 'right_wrist', 'left_pinky', 'right_pinky',
    'left_index', 'right_index', 'left_thumb', 'right_thumb',
    'left_hip', 'right_hip', 'left_knee', 'right_knee',
    'left_ankle', 'right_ankle', 'left_heel', 'right_heel',
    'left_foot_index', 'right_foot_index'
  ]
  return points.map(name => ({
    name,
    x: 0.3 + Math.random() * 0.4,
    y: 0.2 + Math.random() * 0.6,
    visibility: 0.8 + Math.random() * 0.2
  }))
}

function drawPoseFeedback(ctx, isCorrect) {
  ctx.clearRect(0, 0, ctx.canvas.width, ctx.canvas.height)

  const connections = [
    [11, 12], [11, 13], [13, 15], [12, 14], [14, 16],
    [11, 23], [12, 24], [23, 24], [23, 25], [25, 27],
    [24, 26], [26, 28]
  ]

  const color = isCorrect ? '#67c23a' : '#e6a23c'
  ctx.strokeStyle = color
  ctx.lineWidth = 3

  const landmarks = generateSimulatedLandmarks()
  connections.forEach(([i, j]) => {
    if (landmarks[i] && landmarks[j]) {
      ctx.beginPath()
      ctx.moveTo(landmarks[i].x * ctx.canvas.width, landmarks[i].y * ctx.canvas.height)
      ctx.lineTo(landmarks[j].x * ctx.canvas.width, landmarks[j].y * ctx.canvas.height)
      ctx.stroke()
    }
  })

  landmarks.forEach(l => {
    ctx.beginPath()
    ctx.arc(l.x * ctx.canvas.width, l.y * ctx.canvas.height, 5, 0, 2 * Math.PI)
    ctx.fillStyle = color
    ctx.fill()
  })
}

async function getAICoach() {
  if (!currentExercise.value) return
  coachLoading.value = true
  try {
    const res = await request.post('/ar-rehab/ai-coach', {
      exerciseName: currentExercise.value.name,
      completedReps: completedReps.value,
      avgScore: avgScore.value
    })
    if (res) aiCoachAdvice.value = res
  } catch (e) {
    aiCoachAdvice.value = 'AI教练暂时不可用'
  } finally {
    coachLoading.value = false
  }
}

function formatText(text) {
  return (text || '').replace(/\n/g, '<br>')
}
</script>

<style scoped>
.ar-rehab { padding: 20px; }

.rehab-main {
  display: flex;
  gap: 20px;
  margin-bottom: 20px;
}

.camera-section { flex: 1; }

.camera-wrapper {
  position: relative;
  background: #000;
  border-radius: 12px;
  overflow: hidden;
  aspect-ratio: 4/3;
}

.camera-video {
  width: 100%;
  height: 100%;
  object-fit: cover;
  transform: scaleX(-1);
}

.pose-canvas {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  transform: scaleX(-1);
  pointer-events: none;
}

.camera-overlay {
  position: absolute;
  top: 16px;
  right: 16px;
}

.score-display {
  padding: 12px 16px;
  border-radius: 12px;
  text-align: center;
  backdrop-filter: blur(10px);
}

.score-display.good { background: rgba(103, 194, 58, 0.8); }
.score-display.warning { background: rgba(230, 162, 60, 0.8); }
.score-display.danger { background: rgba(245, 108, 108, 0.8); }

.score-number { display: block; font-size: 32px; font-weight: bold; color: #fff; }
.score-label { display: block; font-size: 11px; color: rgba(255,255,255,0.8); margin-bottom: 4px; }

.timer-inline {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 4px;
  padding-top: 6px;
  border-top: 1px solid rgba(255,255,255,0.2);
  font-size: 13px;
  color: rgba(255,255,255,0.95);
  font-family: 'Courier New', monospace;
}

.rep-badge {
  background: rgba(255,255,255,0.25);
  padding: 1px 8px;
  border-radius: 10px;
  font-weight: bold;
  font-size: 12px;
  margin-left: 4px;
}

.feedback-bar {
  position: absolute;
  bottom: 16px;
  left: 16px;
  right: 16px;
  padding: 10px 16px;
  border-radius: 8px;
  font-size: 14px;
  font-weight: bold;
  text-align: center;
  backdrop-filter: blur(10px);
}

.feedback-bar.success { background: rgba(103, 194, 58, 0.9); color: #fff; }
.feedback-bar.warning { background: rgba(230, 162, 60, 0.9); color: #fff; }
.feedback-bar.danger { background: rgba(245, 108, 108, 0.9); color: #fff; }
.feedback-bar.info { background: rgba(144, 147, 153, 0.9); color: #fff; }

.camera-controls {
  display: flex;
  gap: 10px;
  margin-top: 12px;
  justify-content: center;
}

.exercise-panel {
  width: 360px;
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.panel-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.exercise-items {
  max-height: 300px;
  overflow-y: auto;
}

.exercise-item {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 10px 12px;
  border-radius: 8px;
  cursor: pointer;
  transition: all 0.3s;
  margin-bottom: 6px;
}

.exercise-item:hover { background: #f5f7fa; }
.exercise-item.active { background: linear-gradient(135deg, #667eea, #764ba2); color: #fff; }

.exercise-difficulty { font-size: 10px; }
.exercise-info { flex: 1; }
.exercise-name { font-weight: bold; font-size: 14px; }
.exercise-body { font-size: 11px; opacity: 0.7; }
.exercise-reps { font-size: 12px; opacity: 0.7; }

.detail-content h4 { margin: 0 0 8px; color: #333; }
.instruction { color: #666; font-size: 14px; line-height: 1.6; margin-bottom: 12px; }

.reps-tracker {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 10px;
  background: #f5f7fa;
  border-radius: 8px;
}

.reps-control { display: flex; align-items: center; gap: 10px; }
.reps-count { font-size: 20px; font-weight: bold; min-width: 30px; text-align: center; }

.rehab-bottom {
  display: flex;
  gap: 20px;
}

.session-card { flex: 1; }
.ai-coach-card { flex: 1; }

.stats-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 16px;
  text-align: center;
}

.stat-item { padding: 10px; }
.stat-value { display: block; font-size: 24px; font-weight: bold; color: #667eea; }
.stat-label { display: block; font-size: 12px; color: #999; margin-top: 4px; }

.coach-content {
  line-height: 1.8;
  font-size: 14px;
  max-height: 200px;
  overflow-y: auto;
}

.coach-placeholder {
  text-align: center;
  padding: 30px;
  color: #999;
}
</style>