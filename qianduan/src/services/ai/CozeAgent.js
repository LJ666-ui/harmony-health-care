import AGENT_CONFIG from '@/config/agentConfig'

class CozeAgent {
  constructor() {
    this.config = AGENT_CONFIG.coze
    this.chatHistory = []
  }

  async workflowQuery(query, options = {}) {
    const { conversationId } = options

    try {
      const response = await fetch(`${this.config.apiUrl}${this.config.endpoints.workflowRun}`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${this.config.token}`
        },
        body: JSON.stringify({
          workflow_id: this.config.workflowId,
          parameters: { query },
          conversation_id: conversationId
        }),
        signal: AbortSignal.timeout(this.config.timeout)
      })

      if (!response.ok) {
        throw new Error(`Coze API错误: ${response.status}`)
      }

      const data = await response.json()

      if (data.code === 0) {
        const result = data.data.output || data.data.content || JSON.stringify(data.data)
        this.chatHistory.push({ role: 'user', content: query }, { role: 'assistant', content: result })
        return { success: true, data: result, conversationId: data.data?.conversation_id }
      } else {
        throw new Error(data.msg || 'Coze工作流执行失败')
      }
    } catch (error) {
      console.error('[CozeAgent] 工作流调用失败:', error.message)
      return { success: false, error: error.message }
    }
  }

  async botChat(query, options = {}) {
    const { userId = 'default_user', stream = false, onChunk } = options

    try {
      const response = await fetch(`${this.config.apiUrl}${this.config.endpoints.botChat}`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${this.config.token}`
        },
        body: JSON.stringify({
          bot_id: this.config.botId,
          user_id: userId,
          query,
          stream
        }),
        signal: AbortSignal.timeout(this.config.timeout)
      })

      if (!response.ok) {
        throw new Error(`Coze API错误: ${response.status}`)
      }

      if (stream && onChunk) {
        return this._handleStreamResponse(response, query)
      }

      const data = await response.json()

      if (data.code === 0) {
        const result = data.messages?.find(m => m.type === 'answer')?.content || ''
        this.chatHistory.push({ role: 'user', content: query }, { role: 'assistant', content: result })
        return { success: true, data: result }
      } else {
        throw new Error(data.msg || 'Coze Bot对话失败')
      }
    } catch (error) {
      console.error('[CozeAgent] Bot对话失败:', error.message)
      return { success: false, error: error.message }
    }
  }

  async _handleStreamResponse(response, query) {
    const reader = response.body.getReader()
    const decoder = new TextDecoder()
    let fullContent = ''

    while (true) {
      const { done, value } = await reader.read()
      if (done) break

      const chunk = decoder.decode(value)
      const lines = chunk.split('\n').filter(line => line.trim())

      for (const line of lines) {
        try {
          const data = JSON.parse(line)
          if (data.event === 'message' && data.message?.type === 'answer') {
            const content = data.message.content || ''
            fullContent = content
            if (typeof onChunk === 'function') onChunk(content, fullContent)
          }
        } catch (e) {}
      }
    }

    this.chatHistory.push({ role: 'user', content: query }, { role: 'assistant', content: fullContent })
    return { success: true, data: fullContent }
  }

  clearHistory() {
    this.chatHistory = []
  }

  getHistory() {
    return [...this.chatHistory]
  }
}

export default CozeAgent
