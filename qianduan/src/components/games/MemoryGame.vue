<template>
  <div class="memory-game">
    <div class="game-header">
      <span>步数: {{ moves }}</span>
      <span>配对: {{ matched }}/{{ totalPairs }}</span>
      <el-button size="small" @click="initGame">重新开始</el-button>
    </div>
    <div class="card-grid">
      <div v-for="card in cards" :key="card.id"
           :class="['memory-card', { flipped: card.flipped, matched: card.matched }]"
           @click="flipCard(card)">
        <div class="card-front">{{ card.emoji }}</div>
        <div class="card-back">❓</div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'

const emit = defineEmits(['game-over'])

const emojis = ['🫀', '🧠', '🫁', '💊', '🩺', '🏥', '🌿', '💉', '🦷', '👁️', '🩸', '🧬']
const cards = ref([])
const flippedCards = ref([])
const moves = ref(0)
const matched = ref(0)
const totalPairs = ref(8)
const locked = ref(false)

onMounted(() => initGame())

function initGame() {
  const selected = emojis.slice(0, totalPairs.value)
  const deck = [...selected, ...selected]
    .sort(() => Math.random() - 0.5)
    .map((emoji, i) => ({ id: i, emoji, flipped: false, matched: false }))

  cards.value = deck
  flippedCards.value = []
  moves.value = 0
  matched.value = 0
  locked.value = false
}

function flipCard(card) {
  if (locked.value || card.flipped || card.matched) return

  card.flipped = true
  flippedCards.value.push(card)

  if (flippedCards.value.length === 2) {
    moves.value++
    locked.value = true

    if (flippedCards.value[0].emoji === flippedCards.value[1].emoji) {
      flippedCards.value.forEach(c => c.matched = true)
      matched.value++
      flippedCards.value = []
      locked.value = false

      if (matched.value === totalPairs.value) {
        const score = Math.max(10, 100 - (moves.value - totalPairs.value) * 5)
        setTimeout(() => emit('game-over', { score, reward: score > 80 ? 15 : 10 }), 500)
      }
    } else {
      setTimeout(() => {
        flippedCards.value.forEach(c => c.flipped = false)
        flippedCards.value = []
        locked.value = false
      }, 800)
    }
  }
}
</script>

<style scoped>
.memory-game { padding: 10px; }

.game-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;
  font-weight: bold;
  color: #666;
}

.card-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 10px;
  max-width: 400px;
  margin: 0 auto;
}

.memory-card {
  aspect-ratio: 1;
  border-radius: 10px;
  cursor: pointer;
  position: relative;
  transform-style: preserve-3d;
  transition: transform 0.4s;
  font-size: 32px;
}

.memory-card.flipped, .memory-card.matched {
  transform: rotateY(180deg);
}

.memory-card.matched {
  opacity: 0.6;
  pointer-events: none;
}

.card-front, .card-back {
  position: absolute;
  width: 100%;
  height: 100%;
  backface-visibility: hidden;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 10px;
}

.card-back {
  background: linear-gradient(135deg, #667eea, #764ba2);
  color: #fff;
  font-size: 28px;
}

.card-front {
  background: #f0f9eb;
  border: 2px solid #67c23a;
  transform: rotateY(180deg);
}
</style>