import AGENT_CONFIG from '@/config/agentConfig'

class DeepSeekAgent {
  constructor() {
    this.config = AGENT_CONFIG.deepseek
    this.history = []
  }

  async chat(message, options = {}) {
    const { systemPrompt, stream = false, onChunk } = options
    this.history.push({ role: 'user', content: message })
    if (this.history.length > this.config.maxHistoryRounds * 2) {
      this.history = this.history.slice(-this.config.maxHistoryRounds * 2)
    }

    const messages = [
      { role: 'system', content: systemPrompt || '你是一位专业的智慧康养AI助手，擅长医疗健康咨询、疾病预防指导、康复建议等。请用亲切、易懂的语言回答问题，特别是对老年用户要耐心细致。' },
      ...this.history
    ]

    if (stream) {
      return this._streamChat(messages, onChunk)
    }

    try {
      const response = await fetch(this.config.apiUrl, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${this.config.apiKey}`
        },
        body: JSON.stringify({
          model: this.config.model,
          messages,
          max_tokens: this.config.maxTokens,
          temperature: this.config.temperature,
          stream: false
        }),
        signal: AbortSignal.timeout(this.config.timeout)
      })

      if (!response.ok) {
        throw new Error(`DeepSeek API错误: ${response.status}`)
      }

      const data = await response.json()
      const assistantMessage = data.choices?.[0]?.message?.content || ''
      this.history.push({ role: 'assistant', content: assistantMessage })
      return { success: true, data: assistantMessage }
    } catch (error) {
      console.error('[DeepSeekAgent] 调用失败:', error.message)
      return { success: false, error: error.message }
    }
  }

  async _streamChat(messages, onChunk) {
    try {
      const response = await fetch(this.config.apiUrl, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${this.config.apiKey}`
        },
        body: JSON.stringify({
          model: this.config.model,
          messages,
          max_tokens: this.config.maxTokens,
          temperature: this.config.temperature,
          stream: true
        }),
        signal: AbortSignal.timeout(this.config.timeout)
      })

      if (!response.ok) {
        throw new Error(`DeepSeek API错误: ${response.status}`)
      }

      const reader = response.body.getReader()
      const decoder = new TextDecoder()
      let fullContent = ''

      while (true) {
        const { done, value } = await reader.read()
        if (done) break

        const chunk = decoder.decode(value)
        const lines = chunk.split('\n').filter(line => line.startsWith('data: '))
        for (const line of lines) {
          const data = line.replace('data: ', '')
          if (data === '[DONE]') continue

          try {
            const parsed = JSON.parse(data)
            const content = parsed.choices?.[0]?.delta?.content || ''
            if (content) {
              fullContent += content
              if (onChunk) onChunk(content, fullContent)
            }
          } catch (e) {}
        }
      }

      this.history.push({ role: 'assistant', content: fullContent })
      return { success: true, data: fullContent }
    } catch (error) {
      console.error('[DeepSeekAgent] 流式调用失败:', error.message)
      return { success: false, error: error.message }
    }
  }

  clearHistory() {
    this.history = []
  }

  getHistory() {
    return [...this.history]
  }
}

export default DeepSeekAgent
