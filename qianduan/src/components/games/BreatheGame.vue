<template>
  <div class="breathe-game">
    <div class="breathe-header">
      <span>呼吸训练</span>
      <span>轮次: {{ round }}/{{ totalRounds }}</span>
    </div>

    <div class="breathe-area">
      <div :class="['breathe-circle', phase]" :style="circleStyle">
        <div class="breathe-text">{{ phaseText }}</div>
        <div class="breathe-countdown">{{ countdown }}</div>
      </div>
    </div>

    <div class="breathe-controls">
      <el-button v-if="!started" type="primary" @click="startBreathing" size="large" round>
        开始训练
      </el-button>
      <el-button v-else type="warning" @click="stopBreathing" size="large" round>
        结束训练
      </el-button>
    </div>

    <div class="breathe-tips">
      <p>💡 跟随圆圈的节奏进行深呼吸</p>
      <p>吸气4秒 → 屏息4秒 → 呼气6秒 → 休息2秒</p>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onBeforeUnmount } from 'vue'
import { ElMessage } from 'element-plus'

const emit = defineEmits(['game-over'])

const started = ref(false)
const phase = ref('idle')
const countdown = ref(0)
const round = ref(0)
const totalRounds = ref(3)
let timer = null

const phaseText = computed(() => {
  const map = { idle: '准备开始', inhale: '缓缓吸气', hold: '屏住呼吸', exhale: '慢慢呼气', rest: '放松' }
  return map[phase.value] || ''
})

const circleStyle = computed(() => {
  const scaleMap = { idle: 0.6, inhale: 1.2, hold: 1.2, exhale: 0.6, rest: 0.6 }
  const colorMap = {
    idle: 'rgba(102, 126, 234, 0.3)',
    inhale: 'rgba(103, 194, 58, 0.5)',
    hold: 'rgba(230, 162, 60, 0.5)',
    exhale: 'rgba(64, 158, 255, 0.5)',
    rest: 'rgba(102, 126, 234, 0.3)'
  }
  return {
    transform: `scale(${scaleMap[phase.value] || 0.6})`,
    background: colorMap[phase.value] || colorMap.idle,
    transition: phase.value === 'inhale' ? 'transform 4s ease-in-out, background 1s' :
                phase.value === 'exhale' ? 'transform 6s ease-in-out, background 1s' :
                'transform 0.5s ease, background 1s'
  }
})

function startBreathing() {
  started.value = true
  round.value = 0
  runCycle()
}

function runCycle() {
  if (round.value >= totalRounds.value) {
    finishBreathing()
    return
  }

  round.value++
  runPhase('inhale', 4, () => {
    runPhase('hold', 4, () => {
      runPhase('exhale', 6, () => {
        runPhase('rest', 2, () => {
          runCycle()
        })
      })
    })
  })
}

function runPhase(phaseName, duration, callback) {
  phase.value = phaseName
  countdown.value = duration

  timer = setInterval(() => {
    countdown.value--
    if (countdown.value <= 0) {
      clearInterval(timer)
      if (callback) callback()
    }
  }, 1000)
}

function stopBreathing() {
  clearInterval(timer)
  started.value = false
  phase.value = 'idle'
  countdown.value = 0
  finishBreathing()
}

function finishBreathing() {
  const completedRounds = round.value
  const score = Math.min(100, completedRounds * 35)
  ElMessage.success('呼吸训练完成！身心放松了~')
  emit('game-over', { score, reward: 8 })
}

onBeforeUnmount(() => {
  clearInterval(timer)
})
</script>

<style scoped>
.breathe-game { padding: 10px; text-align: center; }

.breathe-header {
  display: flex;
  justify-content: space-between;
  margin-bottom: 20px;
  font-weight: bold;
  color: #666;
}

.breathe-area {
  display: flex;
  justify-content: center;
  align-items: center;
  height: 280px;
}

.breathe-circle {
  width: 200px;
  height: 200px;
  border-radius: 50%;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  border: 3px solid rgba(102, 126, 234, 0.4);
}

.breathe-text {
  font-size: 18px;
  font-weight: bold;
  color: #333;
  margin-bottom: 8px;
}

.breathe-countdown {
  font-size: 36px;
  font-weight: bold;
  color: #667eea;
}

.breathe-controls { margin: 20px 0; }

.breathe-tips {
  color: #999;
  font-size: 13px;
  line-height: 2;
}
</style>