<template>
  <div class="dialect-consultation">
    <el-card class="header-card">
      <div class="page-header">
        <div class="header-icon">🗣️</div>
        <div class="header-text">
          <h2>方言语音问诊</h2>
          <p>支持12种方言实时翻译，打破老年患者沟通障碍</p>
        </div>
      </div>
    </el-card>

    <div class="main-content">
      <el-card class="dialect-select-card">
        <template #header><span>🌐 选择方言</span></template>
        <div class="dialect-grid">
          <div v-for="d in dialects" :key="d.id"
               :class="['dialect-item', { active: selectedDialect === d.id }]"
               @click="selectDialect(d.id)">
            <span class="dialect-name">{{ d.name }}</span>
            <span class="dialect-region">{{ d.region }}</span>
            <span class="dialect-alias">{{ d.alias }}</span>
          </div>
        </div>
      </el-card>

      <el-card class="translate-card">
        <template #header>
          <div class="translate-header">
            <span>🔄 实时翻译</span>
            <el-switch v-model="autoTranslate" active-text="自动翻译" />
          </div>
        </template>

        <div class="translate-area">
          <div class="translate-box source-box">
            <div class="box-label">
              <span>{{ currentDialectName }}输入</span>
              <el-button size="small" @click="startRecording" :type="recording ? 'danger' : 'primary'" round>
                {{ recording ? '⏹ 停止' : '🎤 语音输入' }}
              </el-button>
            </div>
            <el-input v-model="sourceText" type="textarea" :rows="4"
                      :placeholder="`请输入${currentDialectName}或点击语音输入...`"
                      @input="onSourceInput" />
            <div class="quick-phrases" v-if="selectedDialect">
              <span class="phrases-label">常用症状：</span>
              <el-tag v-for="phrase in dialectPhrases" :key="phrase" size="small"
                      @click="sourceText = phrase; translateText()" class="phrase-tag">
                {{ phrase }}
              </el-tag>
            </div>
          </div>

          <div class="translate-arrow">
            <el-button circle @click="translateText" :loading="translating" type="primary">
              <span>⇄</span>
            </el-button>
          </div>

          <div class="translate-box target-box">
            <div class="box-label">
              <span>普通话翻译</span>
              <el-button size="small" @click="speakText(translatedText)" round>🔊 播报</el-button>
            </div>
            <el-input v-model="translatedText" type="textarea" :rows="4" readonly
                      placeholder="翻译结果将显示在这里..." />
          </div>
        </div>

        <div class="translate-direction">
          <el-radio-group v-model="translateDirection" @change="translateText">
            <el-radio-button value="to_mandarin">方言 → 普通话</el-radio-button>
            <el-radio-button value="to_dialect">普通话 → 方言</el-radio-button>
          </el-radio-group>
        </div>
      </el-card>

      <el-card class="consultation-card">
        <template #header><span>📋 方言问诊记录</span></template>
        <div class="consultation-flow">
          <div v-for="(record, index) in consultationRecords" :key="index" class="flow-item">
            <div :class="['flow-node', record.type]">
              <span class="flow-icon">{{ record.type === 'patient' ? '👴' : '👨‍⚕️' }}</span>
              <div class="flow-content">
                <div class="flow-original">{{ record.original }}</div>
                <div class="flow-translated" v-if="record.translated !== record.original">
                  → {{ record.translated }}
                </div>
              </div>
              <el-button size="small" circle @click="speakText(record.original)">🔊</el-button>
            </div>
          </div>
        </div>

        <div class="consultation-input">
          <el-input v-model="newMessage" placeholder="输入问诊内容..." @keyup.enter="addRecord('patient')">
            <template #append>
              <el-button @click="addRecord('patient')" type="primary">发送</el-button>
            </template>
          </el-input>
        </div>
      </el-card>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import request from '@/utils/request'
import { ElMessage } from 'element-plus'

const dialects = ref([])
const selectedDialect = ref('')
const sourceText = ref('')
const translatedText = ref('')
const translateDirection = ref('to_mandarin')
const autoTranslate = ref(true)
const translating = ref(false)
const recording = ref(false)
const dialectPhrases = ref([])
const consultationRecords = ref([])
const newMessage = ref('')
let translateTimer = null

const currentDialectName = computed(() => {
  const d = dialects.value.find(d => d.id === selectedDialect.value)
  return d ? d.name : '方言'
})

onMounted(() => loadDialects())

async function loadDialects() {
  try {
    const res = await request.get('/dialect/list')
    dialects.value = res || []
    if (dialects.value.length) selectDialect(dialects.value[0].id)
  } catch (e) { console.error(e) }
}

async function selectDialect(id) {
  selectedDialect.value = id
  try {
    const res = await request.get(`/dialect/phrases/${id}`)
    dialectPhrases.value = res || []
  } catch (e) { dialectPhrases.value = [] }
}

async function translateText() {
  if (!sourceText.value.trim() || !selectedDialect.value) return
  translating.value = true
  try {
    const res = await request.post('/dialect/translate', {
      text: sourceText.value,
      dialectId: selectedDialect.value,
      direction: translateDirection.value
    })
    if (res) translatedText.value = res.translated
  } catch (e) {
    ElMessage.error('翻译失败')
  } finally {
    translating.value = false
  }
}

function onSourceInput() {
  if (!autoTranslate.value) return
  clearTimeout(translateTimer)
  translateTimer = setTimeout(translateText, 800)
}

function startRecording() {
  if (recording.value) {
    recording.value = false
    return
  }
  if (!('webkitSpeechRecognition' in window) && !('SpeechRecognition' in window)) {
    ElMessage.warning('当前浏览器不支持语音识别，请使用Chrome')
    return
  }
  try {
    const SpeechRecognition = window.SpeechRecognition || window.webkitSpeechRecognition
    const recognition = new SpeechRecognition()
    recognition.lang = 'zh-CN'
    recognition.continuous = false
    recognition.interimResults = false
    recognition.onresult = (event) => {
      const transcript = event.results[0][0].transcript
      sourceText.value = transcript
      if (autoTranslate.value) translateText()
      recording.value = false
    }
    recognition.onerror = () => {
      ElMessage.error('语音识别失败')
      recording.value = false
    }
    recognition.onend = () => { recording.value = false }
    recognition.start()
    recording.value = true
    ElMessage.info('正在聆听...')
  } catch (e) {
    ElMessage.error('无法启动语音识别')
  }
}

function speakText(text) {
  if (!text) return
  const utterance = new SpeechSynthesisUtterance(text)
  utterance.lang = 'zh-CN'
  utterance.rate = 0.9
  speechSynthesis.speak(utterance)
}

async function addRecord(type) {
  if (!newMessage.value.trim()) return
  const original = newMessage.value
  let translated = original

  if (selectedDialect.value && type === 'patient') {
    try {
      const res = await request.post('/dialect/translate', {
        text: original, dialectId: selectedDialect.value, direction: 'to_mandarin'
      })
      if (res) translated = res.translated
    } catch (e) { /* keep original */ }
  }

  consultationRecords.value.push({ type, original, translated })
  newMessage.value = ''
}
</script>

<style scoped>
.dialect-consultation { padding: 20px; }

.page-header {
  display: flex;
  align-items: center;
  gap: 16px;
}
.header-icon { font-size: 48px; }
.header-text h2 { margin: 0; font-size: 22px; color: #333; }
.header-text p { margin: 4px 0 0; color: #999; font-size: 14px; }

.main-content { display: flex; flex-direction: column; gap: 20px; margin-top: 20px; }

.dialect-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(160px, 1fr));
  gap: 10px;
}

.dialect-item {
  padding: 12px;
  border: 2px solid #e2e8f0;
  border-radius: 10px;
  cursor: pointer;
  text-align: center;
  transition: all 0.3s;
}
.dialect-item:hover { border-color: #667eea; background: #f0f0ff; }
.dialect-item.active { border-color: #667eea; background: linear-gradient(135deg, #667eea20, #764ba220); }
.dialect-name { display: block; font-weight: bold; font-size: 16px; color: #333; }
.dialect-region { display: block; font-size: 11px; color: #999; margin-top: 4px; }
.dialect-alias { display: block; font-size: 11px; color: #667eea; margin-top: 2px; }

.translate-header { display: flex; justify-content: space-between; align-items: center; }

.translate-area {
  display: flex;
  align-items: center;
  gap: 16px;
  margin-bottom: 16px;
}

.translate-box { flex: 1; }
.box-label {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 8px;
  font-weight: bold;
  color: #666;
}

.quick-phrases { margin-top: 8px; display: flex; flex-wrap: wrap; gap: 6px; align-items: center; }
.phrases-label { font-size: 12px; color: #999; white-space: nowrap; }
.phrase-tag { cursor: pointer; }

.translate-arrow { flex-shrink: 0; }

.translate-direction { text-align: center; }

.consultation-flow { margin-bottom: 16px; max-height: 300px; overflow-y: auto; }

.flow-item { margin-bottom: 10px; }
.flow-node {
  display: flex;
  align-items: flex-start;
  gap: 10px;
  padding: 10px 14px;
  border-radius: 10px;
}
.flow-node.patient { background: #f0f9eb; }
.flow-node.doctor { background: #f0f0ff; }
.flow-icon { font-size: 24px; flex-shrink: 0; }
.flow-content { flex: 1; }
.flow-original { font-size: 14px; color: #333; }
.flow-translated { font-size: 13px; color: #667eea; margin-top: 4px; font-style: italic; }
</style>