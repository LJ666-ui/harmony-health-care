import AGENT_CONFIG from '@/config/agentConfig'
import DeepSeekAgent from './DeepSeekAgent'
import CozeAgent from './CozeAgent'
import LocalAgentManager from './LocalAgentManager'

const FALLBACK_CHAIN = {
  xiaoyi: ['deepseek', 'mindspore'],
  deepseek: ['xiaoyi', 'mindspore'],
  coze: ['deepseek', 'xiaoyi', 'mindspore'],
  mindspore: ['hiai', 'xiaoyi', 'deepseek'],
  hiai: ['mindspore', 'xiaoyi', 'deepseek']
}

class AIService {
  constructor() {
    this.agents = {
      deepseek: new DeepSeekAgent(),
      coze: new CozeAgent(),
      xiaoyi: new LocalAgentManager('xiaoyi'),
      mindspore: new LocalAgentManager('mindspore'),
      hiai: new LocalAgentManager('hiai')
    }
    this.currentAgentId = 'deepseek'
    this.agentStatus = {}
    this._initAgentStatus()
  }

  _initAgentStatus() {
    Object.keys(AGENT_CONFIG).forEach(id => {
      this.agentStatus[id] = { available: true, lastError: null, failCount: 0 }
    })
  }

  getBestAgent(options = {}) {
    const { inputType = 'text', requiresPrivacy = false, hasNetwork = navigator.onLine, preferredLatency } = options

    if (requiresPrivacy) {
      return hasNetwork ? 'mindspore' : 'hiai'
    }

    if (!hasNetwork) {
      return inputType === 'sensor' ? 'hiai' : 'xiaoyi'
    }

    if (preferredLatency && preferredLatency <= 50) {
      return 'hiai'
    }

    if (preferredLatency && preferredLatency <= 500) {
      return this.agents.xiaoyi.isAvailable() ? 'xiaoyi' : 'deepseek'
    }

    return this.currentAgentId || 'deepseek'
  }

  async chat(message, options = {}) {
    const { agentId, type = 'chat', stream = false, onChunk, systemPrompt } = options
    let targetAgent = agentId || this.getBestAgent(options)

    for (let attempt = 0; attempt <= (FALLBACK_CHAIN[targetAgent]?.length || 0); attempt++) {
      if (!this.agentStatus[targetAgent]?.available && attempt === 0) {
        targetAgent = FALLBACK_CHAIN[targetAgent]?.[0] || 'deepseek'
        continue
      }

      try {
        const result = await this._callAgent(targetAgent, message, { type, stream, onChunk, systemPrompt })

        if (result.success) {
          this._markSuccess(targetAgent)
          return result
        }

        this._markFailure(targetAgent, result.error)

        if (attempt < (FALLBACK_CHAIN[targetAgent]?.length || 0)) {
          targetAgent = FALLBACK_CHAIN[targetAgent][attempt]
          console.warn(`[AIService] ${targetAgent}失败，降级到: ${FALLBACK_CHAIN[targetAgent][attempt]}`)
        }
      } catch (error) {
        this._markFailure(targetAgent, error.message)

        if (attempt < (FALLBACK_CHAIN[targetAgent]?.length || 0)) {
          targetAgent = FALLBACK_CHAIN[targetAgent][attempt]
        }
      }
    }

    return { success: false, error: '所有智能体均不可用' }
  }

  async _callAgent(agentId, message, options) {
    switch (agentId) {
      case 'deepseek':
        return this.agents.deepseek.chat(message, options)
      case 'coze':
        return this.agents.coze.workflowQuery(message, options)
      case 'xiaoyi':
        return this.agents.xiaoyi.process({ input: message, intent: 'HEALTH_QUERY' })
      case 'mindspore':
        return this.agents.mindspore.process({ inputData: { query: message }, modelType: 'health_risk_assessment' })
      case 'hiai':
        return this.agents.hiai.process({ sensorData: { query: message }, modelType: 'health_risk_assessment' })
      default:
        throw new Error(`未知智能体: ${agentId}`)
    }
  }

  async healthConsult(question, healthProfile) {
    return this.chat(question, {
      type: 'health_consult',
      systemPrompt: `你是一位专业的健康咨询AI助手。用户健康档案：${JSON.stringify(healthProfile || {})}。请根据用户健康状况提供专业、易懂的健康建议。`
    })
  }

  async riskAnalysis(riskData) {
    const agentId = this.getBestAgent({ requiresPrivacy: true })
    const result = await this._callAgent(agentId, riskData, { type: 'risk_analysis' })
    return result
  }

  async rehabGuide(rehabInfo) {
    return this.chat(rehabInfo, {
      type: 'rehab_guide',
      systemPrompt: '你是一位专业的康复指导AI助手，请根据患者情况提供详细的康复训练计划，包括热身、核心动作、放松和注意事项。'
    })
  }

  setPrimaryAgent(agentId) {
    if (AGENT_CONFIG[agentId]) {
      this.currentAgentId = agentId
      return true
    }
    return false
  }

  getCurrentAgent() {
    return {
      id: this.currentAgentId,
      config: AGENT_CONFIG[this.currentAgentId],
      status: this.agentStatus[this.currentAgentId]
    }
  }

  getAllAgentsStatus() {
    return Object.keys(AGENT_CONFIG).map(id => ({
      id,
      name: AGENT_CONFIG[id].name,
      type: AGENT_CONFIG[id].type,
      available: this.agentStatus[id]?.available ?? true,
      isCurrent: id === this.currentAgentId
    }))
  }

  _markSuccess(agentId) {
    if (this.agentStatus[agentId]) {
      this.agentStatus[agentId].available = true
      this.agentStatus[agentId].failCount = 0
      this.agentStatus[agentId].lastError = null
    }
  }

  _markFailure(agentId, error) {
    if (this.agentStatus[agentId]) {
      this.agentStatus[agentId].failCount++
      this.agentStatus[agentId].lastError = error

      if (this.agentStatus[agentId].failCount >= 3) {
        this.agentStatus[agentId].available = false
        console.warn(`[AIService] ${agentId} 连续失败3次，暂时标记为不可用`)
      }
    }
  }

  resetAgentStatus(agentId) {
    if (agentId) {
      if (this.agentStatus[agentId]) {
        this.agentStatus[agentId] = { available: true, lastError: null, failCount: 0 }
      }
    } else {
      this._initAgentStatus()
    }
  }

  clearAllHistory() {
    Object.values(this.agents).forEach(agent => {
      if (typeof agent.clearHistory === 'function') {
        agent.clearHistory()
      }
    })
  }
}

const aiService = new AIService()
export default aiService
export { AIService, FALLBACK_CHAIN, AGENT_CONFIG }
