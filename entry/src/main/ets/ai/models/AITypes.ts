export type InputType = 'text' | 'voice' | 'image' | 'sensor';
export type OutputType = 'text' | 'action' | 'data';
export type AgentId = 'xiaoyi' | 'deepseek' | 'coze' | 'mindspore' | 'hiai';
export type Priority = 'speed' | 'accuracy' | 'privacy';

export interface GeoLocation {
  latitude: number;
  longitude: number;
  address?: string;
}

export interface MetadataContext {
  [key: string]: string | number | boolean | MetadataContext | (string | number | boolean | MetadataContext)[];
}

export interface AIRequestInput {
  type: InputType;
  content: string | ArrayBuffer | number[];
  metadata?: object;
}

export interface AIRequestPreferences {
  priority?: Priority;
  maxLatency?: number;
  offlineMode?: boolean;
  preferredAgent?: AgentId;
}

export interface AIRequest {
  requestId: string;
  userId: string;
  input: AIRequestInput;
  preferences?: AIRequestPreferences;
  conversationHistory?: ConversationMessage[];
}

export interface ActionCommand {
  type: 'navigate' | 'open_app' | 'call' | 'send_data' | 'trigger_device';
  target: string;
  params?: MetadataContext;
}

export interface HealthDataResult {
  riskScore: number;
  riskLevel: 'low' | 'medium' | 'high' | 'critical';
  metrics: MetadataContext;
  suggestions: string[];
}

export interface AIOutput {
  type: OutputType;
  content: string | ActionCommand | HealthDataResult;
  confidence: number;
}

export interface AIMetadata {
  processingTime: number;
  modelUsed?: string;
  tokensUsed?: number;
  isOffline: boolean;
  agentVersion: string;
}

export interface AIResponse {
  requestId: string;
  agentId: AgentId;
  output: AIOutput;
  metadata: AIMetadata;
  suggestions?: string[];
  error?: string;
}

export interface ConversationMessage {
  role: 'user' | 'assistant' | 'system';
  content: string;
  timestamp: number;
  agentId?: AgentId;
}

export interface AgentCapability {
  id: AgentId;
  name: string;
  description: string;
  supportedInputTypes: InputType[];
  maxLatency: number;
  requiresNetwork: boolean;
  privacyLevel: 'low' | 'medium' | 'high' | 'extreme';
  isAvailable: boolean;
  currentLoad: number;
}
