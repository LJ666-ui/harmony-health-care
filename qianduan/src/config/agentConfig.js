const AGENT_CONFIG = {
  xiaoyi: {
    id: 'xiaoyi',
    name: '小艺智能体',
    description: 'HarmonyOS原生语音助手，处理系统级命令和多设备联动',
    type: 'local',
    needNetwork: false,
    privacyLevel: 'high',
    maxLatency: 500,
    supportedIntents: [
      'APPOINTMENT_BOOKING',
      'NAVIGATION',
      'HEALTH_QUERY',
      'EMERGENCY',
      'MEDICATION_REMINDER',
      'REHAB_TRAINING',
      'DEVICE_CONTROL'
    ],
    triggerWords: ['小艺小艺', '你好小艺', '智慧康养'],
    available: true
  },
  deepseek: {
    id: 'deepseek',
    name: '硅基流动DeepSeek',
    description: '云端大语言模型，提供复杂语义理解和多轮对话能力',
    type: 'cloud',
    provider: 'SiliconFlow',
    apiUrl: import.meta.env.VITE_DEEPSEEK_API_URL || 'https://api.siliconflow.cn/v1/chat/completions',
    apiKey: import.meta.env.VITE_DEEPSEEK_API_KEY || '',
    model: import.meta.env.VITE_DEEPSEEK_MODEL || 'deepseek-ai/DeepSeek-V3',
    maxTokens: 2048,
    temperature: 0.7,
    timeout: 30000,
    needNetwork: true,
    privacyLevel: 'medium',
    maxLatency: 2000,
    supportStream: true,
    supportMultiTurn: true,
    maxHistoryRounds: 6
  },
  coze: {
    id: 'coze',
    name: 'Coze智能体',
    description: '字节跳动AI平台，提供知识库问答和工作流自动化',
    type: 'cloud',
    provider: 'ByteDance',
    apiUrl: import.meta.env.VITE_COZE_API_URL || 'https://api.coze.cn/v1',
    token: import.meta.env.VITE_COZE_TOKEN || '',
    botId: import.meta.env.VITE_COZE_BOT_ID || '7638946778641465396',
    workflowId: import.meta.env.VITE_COZE_WORKFLOW_ID || '7638960668070625343',
    endpoints: {
      botChat: '/bot/chat',
      workflowRun: '/workflow/run'
    },
    timeout: 30000,
    maxRetries: 2,
    needNetwork: true,
    privacyLevel: 'medium',
    maxLatency: 3000,
    supportKnowledgeBase: true,
    supportWorkflow: true
  },
  mindspore: {
    id: 'mindspore',
    name: 'MindSpore Lite',
    description: '华为端侧推理引擎，本地执行风险评估和健康监测',
    type: 'local',
    techStack: 'MindSpore',
    modelPath: '/models/mindspore/',
    deviceType: 'cpu',
    threadsNum: 4,
    enableDynamicBatch: false,
    needNetwork: false,
    privacyLevel: 'extreme',
    maxLatency: 100,
    offlineCapable: true,
    scenarios: ['health_risk_assessment', 'vital_signs_monitoring', 'fall_detection', 'anomaly_detection']
  },
  hiai: {
    id: 'hiai',
    name: 'HiAI NPU加速器',
    description: '华为NPU硬件加速，极致性能的端侧AI推理',
    type: 'local',
    techStack: 'HiAI SDK',
    modelPath: '',
    deviceType: 'npu',
    enableDynamicBatch: false,
    threadsNum: 4,
    needNetwork: false,
    privacyLevel: 'extreme',
    maxLatency: { npu: 50, cpuFallback: 150 },
    hardwareAccelerated: true,
    fallbackStrategy: 'auto_switch_to_cpu',
    capabilities: [
      'image_classification',
      'ocr_recognition',
      'pose_detection',
      'heart_anomaly_detection',
      'health_risk_assessment'
    ]
  }
}

export default AGENT_CONFIG
