export interface SiliconFlowConfig {
  apiUrl: string;
  apiKey: string;
  model: string;
  maxTokens: number;
  temperature: number;
  timeout: number;
}

export const SILICONFLOW_CONFIG: SiliconFlowConfig = {
  apiUrl: 'https://api.siliconflow.cn/v1/chat/completions',
  apiKey: 'sk-hbucrijbdwvxzqjwvyenyqlejbmvciwelasphsafnftojvuo',
  model: 'deepseek-ai/DeepSeek-V3',
  maxTokens: 2048,
  temperature: 0.7,
  timeout: 30000
};
