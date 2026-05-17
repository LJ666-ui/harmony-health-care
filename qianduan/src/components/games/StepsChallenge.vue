<template>
  <div class="steps-challenge">
    <div class="steps-header">
      <span>步数挑战</span>
      <span>目标: {{ goal }} 步</span>
    </div>

    <div class="steps-display">
      <div class="steps-ring">
        <el-progress type="dashboard" :percentage="stepsPercent" :width="180" :color="stepsColor">
          <template #default="{ percentage }">
            <div class="steps-inner">
              <div class="steps-count">{{ currentSteps }}</div>
              <div class="steps-label">步</div>
            </div>
          </template>
        </el-progress>
      </div>
    </div>

    <div class="steps-simulator">
      <p>📱 模拟计步（点击或摇晃手机）</p>
      <el-button type="primary" size="large" @click="addSteps" round :disabled="completed">
        🏃 +{{ stepIncrement }}步
      </el-button>
    </div>

    <div class="steps-stats">
      <div class="stat-item">
        <span class="stat-value">{{ calories }}</span>
        <span class="stat-label">千卡</span>
      </div>
      <div class="stat-item">
        <span class="stat-value">{{ distance }}</span>
        <span class="stat-label">公里</span>
      </div>
      <div class="stat-item">
        <span class="stat-value">{{ duration }}</span>
        <span class="stat-label">分钟</span>
      </div>
    </div>

    <div v-if="completed" class="complete-banner">
      🎉 目标达成！
      <el-button type="success" @click="submitResult">领取奖励</el-button>
    </div>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'

const emit = defineEmits(['game-over'])

const goal = ref(1000)
const currentSteps = ref(0)
const stepIncrement = ref(50)
const completed = ref(false)

const stepsPercent = computed(() => Math.min(100, Math.round((currentSteps.value / goal.value) * 100)))
const stepsColor = computed(() => {
  if (stepsPercent.value >= 100) return '#67c23a'
  if (stepsPercent.value >= 60) return '#409eff'
  return '#e6a23c'
})
const calories = computed(() => (currentSteps.value * 0.04).toFixed(1))
const distance = computed(() => (currentSteps.value * 0.0007).toFixed(2))
const duration = computed(() => Math.round(currentSteps.value / 100))

function addSteps() {
  if (completed.value) return
  currentSteps.value += stepIncrement.value
  if (currentSteps.value >= goal.value) {
    currentSteps.value = goal.value
    completed.value = true
  }
}

function submitResult() {
  const score = Math.round((currentSteps.value / goal.value) * 100)
  emit('game-over', { score, reward: 20 })
}
</script>

<style scoped>
.steps-challenge { padding: 10px; text-align: center; }

.steps-header {
  display: flex;
  justify-content: space-between;
  margin-bottom: 16px;
  font-weight: bold;
  color: #666;
}

.steps-display {
  display: flex;
  justify-content: center;
  margin-bottom: 20px;
}

.steps-inner { text-align: center; }
.steps-count { font-size: 42px; font-weight: bold; color: #333; }
.steps-label { font-size: 14px; color: #999; }

.steps-simulator { margin-bottom: 20px; }
.steps-simulator p { color: #999; font-size: 13px; margin-bottom: 10px; }

.steps-stats {
  display: flex;
  justify-content: center;
  gap: 40px;
  margin-bottom: 20px;
}

.stat-item { text-align: center; }
.stat-value { display: block; font-size: 24px; font-weight: bold; color: #667eea; }
.stat-label { display: block; font-size: 12px; color: #999; }

.complete-banner {
  padding: 16px;
  background: linear-gradient(135deg, #67c23a, #38ef7d);
  color: #fff;
  border-radius: 12px;
  font-size: 18px;
  font-weight: bold;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 16px;
}
</style>