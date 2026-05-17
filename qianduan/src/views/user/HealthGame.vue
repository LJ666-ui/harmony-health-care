<template>
  <div class="health-game">
    <div class="game-top">
      <el-card class="profile-card">
        <div class="profile-content">
          <div class="level-badge">
            <div class="level-circle">Lv.{{ profile.level }}</div>
          </div>
          <div class="profile-info">
            <h3>{{ userName }}</h3>
            <div class="points-bar">
              <el-progress :percentage="pointsPercent" :stroke-width="16" :color="'#667eea'" :format="() => profile.points + ' 积分'" />
            </div>
            <div class="next-level">距下一级还需 {{ profile.nextLevelPoints - profile.points }} 积分</div>
          </div>
          <div class="check-in-area">
            <el-button type="primary" @click="checkIn" :disabled="checkedIn" round>
              {{ checkedIn ? '✅ 已签到' : '📅 签到' }}
            </el-button>
            <div class="streak">连续 {{ profile.checkInDays }} 天</div>
          </div>
        </div>
      </el-card>

      <el-card class="badge-card">
        <template #header><span>🏆 成就徽章</span></template>
        <div class="badge-grid">
          <div v-for="badge in allBadges" :key="badge.id"
               :class="['badge-item', { earned: isBadgeEarned(badge.id) }]">
            <span class="badge-icon">{{ badge.icon }}</span>
            <span class="badge-name">{{ badge.name }}</span>
            <span v-if="!isBadgeEarned(badge.id)" class="badge-lock">🔒</span>
          </div>
        </div>
      </el-card>
    </div>

    <div class="game-section">
      <h3>🎮 健康小游戏</h3>
      <div class="game-grid">
        <div v-for="game in games" :key="game.id" class="game-card" @click="openGame(game)">
          <div class="game-icon">{{ game.icon }}</div>
          <div class="game-info">
            <div class="game-name">{{ game.name }}</div>
            <div class="game-desc">{{ game.description }}</div>
            <div class="game-reward">+{{ game.pointsReward }} 积分</div>
          </div>
          <div class="game-difficulty">
            <span v-for="i in game.difficulty" :key="i">⭐</span>
          </div>
        </div>
      </div>
    </div>

    <div class="bottom-section">
      <el-card class="leaderboard-card">
        <template #header><span>🏅 积分排行榜</span></template>
        <div class="leaderboard">
          <div v-for="(player, index) in leaderboard" :key="player.userId"
               :class="['leaderboard-item', { me: player.userId === currentUserId }]">
            <span :class="['rank', { gold: index === 0, silver: index === 1, bronze: index === 2 }]">
              {{ index < 3 ? ['🥇','🥈','🥉'][index] : index + 1 }}
            </span>
            <span class="player-name">{{ player.username }}</span>
            <span class="player-level">Lv.{{ player.level }}</span>
            <span class="player-points">{{ player.points }} 分</span>
          </div>
        </div>
      </el-card>
    </div>

    <el-dialog v-model="gameDialogVisible" :title="currentGame?.name" width="600px" destroy-on-close>
      <div class="game-container">
        <MemoryGame v-if="currentGame?.id === 'memory'" @game-over="handleGameOver" />
        <QuizGame v-else-if="currentGame?.id === 'quiz'" @game-over="handleGameOver" />
        <BreatheGame v-else-if="currentGame?.id === 'breathe'" @game-over="handleGameOver" />
        <ReactionGame v-else-if="currentGame?.id === 'reaction'" @game-over="handleGameOver" />
        <StepsChallenge v-else-if="currentGame?.id === 'steps'" @game-over="handleGameOver" />
      </div>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import request from '@/utils/request'
import { ElMessage } from 'element-plus'
import MemoryGame from '@/components/games/MemoryGame.vue'
import QuizGame from '@/components/games/QuizGame.vue'
import BreatheGame from '@/components/games/BreatheGame.vue'
import ReactionGame from '@/components/games/ReactionGame.vue'
import StepsChallenge from '@/components/games/StepsChallenge.vue'

const profile = ref({ points: 0, level: 1, badges: [], checkInDays: 0, nextLevelPoints: 100 })
const allBadges = ref([])
const games = ref([])
const leaderboard = ref([])
const checkedIn = ref(false)
const gameDialogVisible = ref(false)
const currentGame = ref(null)

const currentUserId = computed(() => {
  const user = JSON.parse(localStorage.getItem('medical_user_info') || '{}')
  return user.userId || user.id
})

const userName = computed(() => {
  const user = JSON.parse(localStorage.getItem('medical_user_info') || '{}')
  return user.realName || user.username || '用户'
})

const pointsPercent = computed(() => {
  const nextPts = profile.value.nextLevelPoints || 100
  const prevPts = (profile.value.level - 1) * 100
  return Math.round(((profile.value.points - prevPts) / (nextPts - prevPts)) * 100)
})

onMounted(() => {
  loadProfile()
  loadBadges()
  loadGames()
  loadLeaderboard()
})

async function loadProfile() {
  try {
    const user = JSON.parse(localStorage.getItem('medical_user_info') || '{}')
    const res = await request.get(`/game/profile/${user.userId || 1}`)
    if (res) profile.value = res
  } catch (e) { console.error(e) }
}

async function loadBadges() {
  try {
    const res = await request.get('/game/badges')
    allBadges.value = res || []
  } catch (e) { console.error(e) }
}

async function loadGames() {
  try {
    const res = await request.get('/game/games')
    games.value = res || []
  } catch (e) { console.error(e) }
}

async function loadLeaderboard() {
  try {
    const res = await request.get('/game/leaderboard')
    leaderboard.value = res || []
  } catch (e) { console.error(e) }
}

async function checkIn() {
  try {
    const user = JSON.parse(localStorage.getItem('medical_user_info') || '{}')
    const res = await request.post(`/game/check-in/${user.userId || 1}`)
    if (res) {
      checkedIn.value = true
      ElMessage.success(res.message || '签到成功！')
      loadProfile()
      loadLeaderboard()
    }
  } catch (e) {
    checkedIn.value = true
    ElMessage.info('今日已签到')
  }
}

function isBadgeEarned(badgeId) {
  return (profile.value.badges || []).some(b => b.id === badgeId)
}

function openGame(game) {
  currentGame.value = game
  gameDialogVisible.value = true
}

async function handleGameOver(result) {
  gameDialogVisible.value = false
  try {
    const user = JSON.parse(localStorage.getItem('medical_user_info') || '{}')
    await request.post('/game/submit', {
      userId: user.userId || 1,
      gameId: currentGame.value.id,
      score: result.score
    })
    ElMessage.success(`获得 ${result.score} 分！积分 +${result.reward || 10}`)
    loadProfile()
    loadLeaderboard()
  } catch (e) {
    console.error(e)
  }
}
</script>

<style scoped>
.health-game { padding: 20px; }

.game-top {
  display: flex;
  gap: 20px;
  margin-bottom: 24px;
}

.profile-card { flex: 1; }
.badge-card { flex: 1; }

.profile-content {
  display: flex;
  align-items: center;
  gap: 20px;
}

.level-badge { flex-shrink: 0; }

.level-circle {
  width: 64px;
  height: 64px;
  border-radius: 50%;
  background: linear-gradient(135deg, #667eea, #764ba2);
  color: #fff;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 18px;
  font-weight: bold;
}

.profile-info { flex: 1; }
.profile-info h3 { margin: 0 0 8px; font-size: 18px; }
.next-level { font-size: 12px; color: #999; margin-top: 4px; }

.check-in-area { text-align: center; flex-shrink: 0; }
.streak { font-size: 12px; color: #e6a23c; margin-top: 6px; font-weight: bold; }

.badge-grid {
  display: grid;
  grid-template-columns: repeat(5, 1fr);
  gap: 10px;
}

.badge-item {
  text-align: center;
  padding: 10px 4px;
  border-radius: 10px;
  background: #f5f7fa;
  position: relative;
  transition: all 0.3s;
}

.badge-item.earned {
  background: linear-gradient(135deg, #f0f9eb, #e1f3d8);
  border: 1px solid #67c23a;
}

.badge-icon { display: block; font-size: 28px; margin-bottom: 4px; }
.badge-name { display: block; font-size: 11px; color: #333; }
.badge-lock { position: absolute; top: 4px; right: 4px; font-size: 10px; }

.game-section { margin-bottom: 24px; }
.game-section h3 { margin-bottom: 16px; }

.game-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
  gap: 16px;
}

.game-card {
  display: flex;
  align-items: center;
  gap: 14px;
  padding: 16px;
  background: #fff;
  border-radius: 12px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.06);
  cursor: pointer;
  transition: all 0.3s;
}

.game-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 8px 24px rgba(0,0,0,0.12);
}

.game-icon { font-size: 40px; flex-shrink: 0; }

.game-info { flex: 1; }
.game-name { font-weight: bold; font-size: 15px; color: #333; margin-bottom: 4px; }
.game-desc { font-size: 12px; color: #999; margin-bottom: 4px; }
.game-reward { font-size: 12px; color: #667eea; font-weight: bold; }

.game-difficulty { font-size: 10px; }

.bottom-section { margin-bottom: 20px; }

.leaderboard-item {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 10px 12px;
  border-radius: 8px;
  margin-bottom: 4px;
  transition: all 0.3s;
}

.leaderboard-item:hover { background: #f5f7fa; }
.leaderboard-item.me { background: #f0f0ff; border: 1px solid #667eea; }

.rank { width: 30px; text-align: center; font-weight: bold; font-size: 16px; }
.rank.gold, .rank.silver, .rank.bronze { font-size: 20px; }

.player-name { flex: 1; font-weight: 500; }
.player-level { font-size: 12px; color: #667eea; }
.player-points { font-weight: bold; color: #e6a23c; }

.game-container { min-height: 300px; }
</style>