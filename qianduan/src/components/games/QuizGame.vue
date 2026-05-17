<template>
  <div class="quiz-game">
    <div class="quiz-header">
      <span>题目 {{ currentIndex + 1 }}/{{ questions.length }}</span>
      <span>得分: {{ score }}</span>
      <span class="timer" :class="{ warning: timeLeft <= 5 }">⏱️ {{ timeLeft }}s</span>
    </div>

    <div v-if="currentIndex < questions.length" class="quiz-body">
      <div class="question-text">{{ currentQuestion.question }}</div>
      <div class="options">
        <div v-for="(opt, i) in currentQuestion.options" :key="i"
             :class="['option-btn', optionClass(i)]"
             @click="selectAnswer(i)">
          <span class="option-letter">{{ ['A','B','C','D'][i] }}</span>
          <span class="option-text">{{ opt }}</span>
        </div>
      </div>
    </div>

    <div v-else class="quiz-result">
      <div class="result-icon">{{ score >= 80 ? '🎉' : score >= 60 ? '👍' : '💪' }}</div>
      <div class="result-score">{{ score }} 分</div>
      <div class="result-text">
        答对 {{ correctCount }}/{{ questions.length }} 题
      </div>
      <el-button type="primary" @click="initGame">再来一局</el-button>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onBeforeUnmount } from 'vue'
import request from '@/utils/request'

const emit = defineEmits(['game-over'])

const questions = ref([])
const currentIndex = ref(0)
const score = ref(0)
const correctCount = ref(0)
const timeLeft = ref(15)
const selectedAnswer = ref(-1)
const answered = ref(false)
let timer = null

const currentQuestion = computed(() => questions.value[currentIndex.value] || {})

onMounted(() => initGame())
onBeforeUnmount(() => clearInterval(timer))

async function initGame() {
  try {
    const res = await request.get('/game/quiz/questions?count=5')
    questions.value = res || []
  } catch (e) {
    questions.value = [
      { question: '正常心率范围？', options: ['60-100次/分', '40-60次/分', '100-140次/分'], correctIndex: 0 },
      { question: '人体最大器官？', options: ['肝脏', '皮肤', '心脏'], correctIndex: 1 },
      { question: '正常体温？', options: ['35-36℃', '36.1-37.2℃', '37-38℃'], correctIndex: 1 },
      { question: '每日建议饮水量？', options: ['500ml', '1500-2000ml', '3000ml'], correctIndex: 1 },
      { question: '哪种维生素促进钙吸收？', options: ['维生素A', '维生素C', '维生素D'], correctIndex: 2 }
    ]
  }
  currentIndex.value = 0
  score.value = 0
  correctCount.value = 0
  selectedAnswer.value = -1
  answered.value = false
  startTimer()
}

function startTimer() {
  clearInterval(timer)
  timeLeft.value = 15
  timer = setInterval(() => {
    timeLeft.value--
    if (timeLeft.value <= 0) {
      clearInterval(timer)
      if (!answered.value) selectAnswer(-1)
    }
  }, 1000)
}

function selectAnswer(index) {
  if (answered.value) return
  answered.value = true
  selectedAnswer.value = index
  clearInterval(timer)

  if (index === currentQuestion.value.correctIndex) {
    score.value += 20
    correctCount.value++
  }

  setTimeout(() => {
    currentIndex.value++
    selectedAnswer.value = -1
    answered.value = false
    if (currentIndex.value < questions.value.length) {
      startTimer()
    } else {
      emit('game-over', { score: score.value, reward: score.value > 60 ? 15 : 8 })
    }
  }, 1200)
}

function optionClass(index) {
  if (!answered.value) return ''
  if (index === currentQuestion.value.correctIndex) return 'correct'
  if (index === selectedAnswer.value && index !== currentQuestion.value.correctIndex) return 'wrong'
  return 'dim'
}
</script>

<style scoped>
.quiz-game { padding: 10px; }

.quiz-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
  font-weight: bold;
  color: #666;
}

.timer { color: #67c23a; font-size: 18px; }
.timer.warning { color: #f56c6c; animation: blink 0.5s infinite; }

@keyframes blink { 50% { opacity: 0.5; } }

.question-text {
  font-size: 18px;
  font-weight: bold;
  color: #333;
  margin-bottom: 20px;
  line-height: 1.6;
}

.options { display: flex; flex-direction: column; gap: 10px; }

.option-btn {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 14px 18px;
  border: 2px solid #e2e8f0;
  border-radius: 10px;
  cursor: pointer;
  transition: all 0.3s;
  font-size: 15px;
}

.option-btn:hover { border-color: #667eea; background: #f0f0ff; }

.option-btn.correct {
  border-color: #67c23a;
  background: #f0f9eb;
  color: #67c23a;
}

.option-btn.wrong {
  border-color: #f56c6c;
  background: #fef0f0;
  color: #f56c6c;
}

.option-btn.dim { opacity: 0.4; }

.option-letter {
  width: 28px;
  height: 28px;
  border-radius: 50%;
  background: #f5f7fa;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: bold;
  font-size: 13px;
  flex-shrink: 0;
}

.quiz-result {
  text-align: center;
  padding: 40px;
}

.result-icon { font-size: 64px; margin-bottom: 16px; }
.result-score { font-size: 48px; font-weight: bold; color: #667eea; margin-bottom: 8px; }
.result-text { color: #666; margin-bottom: 20px; }
</style>