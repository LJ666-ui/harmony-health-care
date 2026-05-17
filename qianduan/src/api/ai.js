import request from '@/utils/request'
import aiService from '@/services/ai'

export default {
  chat(data) {
    return request.post('/ai/chat', data)
  },
  getConversations(params) {
    return request.get('/ai/conversations', { params })
  },
  getConversationDetail(id) {
    return request.get(`/ai/conversation/${id}`)
  },
  deleteConversation(id) {
    return request.delete(`/ai/conversation/${id}`)
  },
  directChat(message, options = {}) {
    return aiService.chat(message, options)
  },
  healthConsult(question, healthProfile) {
    return aiService.healthConsult(question, healthProfile)
  },
  riskAnalysis(riskData) {
    return aiService.riskAnalysis(riskData)
  },
  rehabGuide(rehabInfo) {
    return aiService.rehabGuide(rehabInfo)
  },
  getCurrentAgent() {
    return aiService.getCurrentAgent()
  },
  getAllAgents() {
    return aiService.getAllAgentsStatus()
  },
  switchAgent(agentId) {
    return aiService.setPrimaryAgent(agentId)
  }
}
