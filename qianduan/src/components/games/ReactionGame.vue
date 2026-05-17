<template>
  <div class="reaction-game">
    <div class="reaction-header">
      <span>反应力测试</span>
      <span>轮次: {{ currentRound }}/{{ totalRounds }}</span>
    </div>

    <div class="reaction-area" @click="handleClick">
      <div v-if="state === 'waiting'" class="state-waiting">
        <p>点击下方按钮开始</p>
        <el-button type="primary" @click.stop="startRound" size="large" round>开始</el-button>
      </div>
      <div v-else-if="state === 'ready'" class="state-ready">
        <p>等待绿色信号...</p>
        <p class="hint">看到绿色立即点击！</p>
      </div>
      <div v-else-if="state === 'go'" class="state-go">
        <p class="go-text">🎯 点击！</p>
      </div>
      <div v-else-if="state === 'tooEarly'" class="state-early">
        <p>❌ 太早了！</p>
        <p>请等到绿色信号再点击</p>
        <el-button @click.stop="startRound" size="large">重试</el-button>
      </div>
      <div v-else-if="state === 'result'" class="state-result">
        <p class="reaction-time">{{ lastTime }} ms</p>
        <p class="reaction-rating">{{ rating }}</p>
        <el-button v-if="currentRound < totalRounds" @click.stop="startRound" type="primary" size="large">
          下一轮
        </el-button>
      </div>
    </div>

    <div v-if="results.length" class="results-bar">
      <span v-for="(r, i) in results" :key="i" class="result-dot" :style="{ background: r < 300 ? '#67c23a' : r < 500 ? '#e6a23c' : '#f56c6c' }">
        {{ r }}ms
      </span>
      <span class="avg-time">平均: {{ avgTime }}ms</span>
    </div>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'

const emit = defineEmits(['game-over'])

const state = ref('waiting')
const currentRound = ref(0)
const totalRounds = ref(5)
const lastTime = ref(0)
const results = ref([])
let startTime = 0
let goTimer = null

const avgTime = computed(() => {
  if (!results.value.length) return 0
  return Math.round(results.value.reduce((a, b) => a + b, 0) / results.value.length)
})

const rating = computed(() => {
  if (lastTime.value < 200) return '⚡ 超人反应！'
  if (lastTime.value < 300) return '🔥 非常快！'
  if (lastTime.value < 400) return '👍 不错！'
  if (lastTime.value < 500) return '😊 还行'
  return '🐢 需要锻炼'
})

function startRound() {
  state.value = 'ready'
  const delay = 1500 + Math.random() * 3000
  goTimer = setTimeout(() => {
    state.value = 'go'
    startTime = Date.now()
  }, delay)
}

function handleClick() {
  if (state.value === 'ready') {
    clearTimeout(goTimer)
    state.value = 'tooEarly'
  } else if (state.value === 'go') {
    lastTime.value = Date.now() - startTime
    results.value.push(lastTime.value)
    currentRound.value++
    state.value = 'result'

    if (currentRound.value >= totalRounds.value) {
      const score = Math.max(10, Math.min(100, 200 - (avgTime.value - 200) / 5))
      setTimeout(() => emit('game-over', { score: Math.round(score), reward: score > 70 ? 12 : 8 }), 1500)
    }
  }
}
</script>

<style scoped>
.reaction-game { padding: 10px; }

.reaction-header {
  display: flex;
  justify-content: space-between;
  margin-bottom: 16px;
  font-weight: bold;
  color: #666;
}

.reaction-area {
  height: 280px;
  border-radius: 16px;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  user-select: none;
  transition: background 0.3s;
}

.state-waiting { background: #f5f7fa; }
.state-ready { background: #f56c6c; color: #fff; }
.state-go { background: #67c23a; color: #fff; }
.state-early { background: #e6a23c; color: #fff; }
.state-result { background: #f0f0ff; }

.state-ready, .state-go, .state-early, .state-result {
  border-radius: 16px;
  width: 100%;
  height: 100%;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 10px;
}

.state-ready p, .state-go p, .state-early p { font-size: 20px; font-weight: bold; margin: 0; }
.hint { font-size: 14px !important; opacity: 0.8; }

.go-text { font-size: 48px !important; }

.reaction-time {
  font-size: 64px;
  font-weight: bold;
  color: #667eea;
  margin: 0;
}

.reaction-rating {
  font-size: 20px;
  margin: 0 0 10px;
}

.results-bar {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-top: 16px;
  flex-wrap: wrap;
}

.result-dot {
  padding: 4px 10px;
  border-radius: 12px;
  color: #fff;
  font-size: 12px;
  font-weight: bold;
}

.avg-time {
  margin-left: auto;
  font-weight: bold;
  color: #667eea;
}
</style>