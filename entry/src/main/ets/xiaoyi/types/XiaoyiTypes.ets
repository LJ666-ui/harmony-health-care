/**
 * 小艺Skill类型定义
 * 定义小艺智能体交互的所有数据结构
 */

/**
 * Skill基础配置
 */
export interface XiaoyiSkillConfig {
  skillId: string;
  skillName: string;
  skillDescription: string;
  version: string;
  author: string;
}

/**
 * Skill意图模式
 * 定义触发该Skill的语音指令模式
 */
export interface IntentPattern {
  pattern: string;           // 正则表达式或关键词
  confidence: number;        // 匹配置信度 [0-1]
  parameters?: string[];     // 提取的参数名列表
  examples: string[];        // 示例语句
}

/**
 * Skill定义接口
 */
export interface XiaoyiSkillDefinition {
  config: XiaoyiSkillConfig;
  intentPatterns: IntentPattern[];
  handler: string;                    // 处理函数名
  needAuth: boolean;                  // 是否需要用户登录
  needPermission?: string[];          // 需要的权限列表
  responseType: 'voice' | 'ui' | 'voice+ui'; // 响应类型
  fallbackAction?: string;            // 失败时的降级操作
  estimatedTime?: number;             // 预计处理时间(ms)
}

/**
 * Skill请求
 */
export interface XiaoyiSkillRequest {
  skillId: string;
  sessionId: string;
  userId: string;
  query: string;                      // 用户原始输入（语音转文字后）
  intentText: string;                 // 意图文本（提取关键信息后）
  parameters: Record<string, string>; // 提取的参数
  context?: Record<string, any>;      // 上下文信息
  timestamp: number;
  sourceDevice: string;               // 来源设备类型
}

/**
 * Skill响应
 */
export interface XiaoyiSkillResponse {
  skillId: string;
  success: boolean;
  voiceResponse: string;              // 语音回复文本（TTS播报）
  uiResponse?: UIResponseData;        // UI展示数据
  action?: SkillAction;               // 需要执行的操作
  followUpSuggestions?: string[];     // 后续建议
  processingTime: number;             // 处理耗时
  errorCode?: string;                 // 错误码
  errorMessage?: string;              // 错误信息
}

/**
 * UI响应数据
 */
export interface UIResponseData {
  pageRoute?: string;                 // 要打开的页面路由
  pageTitle?: string;                 // 页面标题
  data: Record<string, any>;          // 页面数据
  displayMode?: 'card' | 'fullScreen' | 'popup'; // 展示模式
}

/**
 * Skill动作
 */
export interface SkillAction {
  type: 'navigate' | 'invoke' | 'broadcast' | 'distributed';
  target: string;                     // 目标（页面/方法/设备）
  params?: Record<string, any>;       // 动作参数
}

/**
 * MCP协议消息 (Model Context Protocol)
 */
export interface MCPMessage {
  id: string;
  type: 'request' | 'response' | 'notification';
  method: string;
  params?: Record<string, any>;
  result?: any;
  error?: MCPError;
  timestamp: number;
}

/**
 * MCP错误
 */
export interface MCPError {
  code: number;
  message: string;
  data?: any;
}

/**
 * MCP能力声明
 */
export interface MCPCapability {
  tools: MCPTool[];
  resources: MCPResource[];
  prompts: MCPPrompt[];
}

/**
 * MCP工具定义
 */
export interface MCPTool {
  name: string;
  description: string;
  inputSchema: Record<string, any>;
}

/**
 * MCP资源定义
 */
export interface MCPResource {
  uri: string;
  name: string;
  description: string;
  mimeType: string;
}

/**
 * MCP提示词模板
 */
export interface MCPPrompt {
  name: string;
  description: string;
  arguments?: Record<string, any>;
}

/**
 * 小艺会话上下文
 */
export interface XiaoyiSessionContext {
  sessionId: string;
  userId: string;
  startTime: number;
  lastActivityTime: number;
  messageHistory: XiaoyiMessage[];
  currentIntent?: string;
  accumulatedContext: Record<string, any>;
}

/**
 * 小艺消息
 */
export interface XiaoyiMessage {
  role: 'user' | 'assistant' | 'system';
  content: string;
  timestamp: number;
  skillId?: string;
  metadata?: Record<string, any>;
}
