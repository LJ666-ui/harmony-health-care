import AGENT_CONFIG from '@/config/agentConfig'

class LocalAgentManager {
  constructor(agentType) {
    this.agentType = agentType
    this.config = AGENT_CONFIG[agentType]
  }

  isAvailable() {
    if (this.agentType === 'xiaoyi') {
      return typeof window !== 'undefined' && window.harmony?.xiaoyi
    }
    if (this.agentType === 'mindspore') {
      return typeof window !== 'undefined' && window.harmony?.mindspore
    }
    if (this.agentType === 'hiai') {
      return typeof window !== 'undefined' && window.harmony?.hiai
    }
    return false
  }

  async process(request) {
    if (!this.isAvailable()) {
      return { success: false, error: `${this.config.name}不可用，请确认HarmonyOS环境` }
    }

    try {
      let result
      switch (this.agentType) {
        case 'xiaoyi':
          result = await this._processXiaoyi(request)
          break
        case 'mindspore':
          result = await this._processMindSpore(request)
          break
        case 'hiai':
          result = await this._processHiAI(request)
          break
        default:
          throw new Error('未知本地智能体类型')
      }
      return { success: true, data: result }
    } catch (error) {
      console.error(`[${this.config.name}] 处理失败:`, error.message)
      return { success: false, error: error.message }
    }
  }

  async _processXiaoyi(request) {
    const harmonyAPI = window.harmony.xiaoyi
    return harmonyAPI.process({
      intent: request.intent || 'HEALTH_QUERY',
      params: request.params || {},
      input: request.input || '',
      voiceMode: request.voiceMode || false
    })
  }

  async _processMindSpore(request) {
    const harmonyAPI = window.harmony.mindspore
    return harmonyAPI.infer({
      modelType: request.modelType || 'health_risk_assessment',
      inputData: request.inputData || {},
      deviceType: this.config.deviceType
    })
  }

  async _processHiAI(request) {
    const harmonyAPI = window.harmony.hiai
    return harmonyAPI.infer({
      modelType: request.modelType || 'health_risk_assessment',
      imageData: request.imageData || null,
      sensorData: request.sensorData || null,
      preferNPU: true
    })
  }

  getCapabilities() {
    return this.config.capabilities || this.config.scenarios || this.config.supportedIntents || []
  }
}

export default LocalAgentManager
