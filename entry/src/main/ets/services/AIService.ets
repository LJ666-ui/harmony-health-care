import { HttpUtil } from '../common/utils/HttpUtil';
import { ToastUtil } from '../common/utils/ToastUtil';

export interface AIConversation {
  id: number;
  userId: number;
  question: string;
  answer: string;
  type: 'chat' | 'health_consult' | 'risk_analysis' | 'rehab_guide';
  createTime: string;
}

export interface AIDiagnosisResult {
  possibleDiseases: DiseaseItem[];
  urgency: 'low' | 'medium' | 'high' | 'critical';
  suggestedDepartment: string;
  advice: string;
}

export interface DiseaseItem {
  name: string;
  probability: number;
  description: string;
}

export interface HealthConsultResult {
  answer: string;
  relatedTopics?: string[];
  references?: string[];
}

export interface RiskAssessmentResult {
  overallRisk: 'low' | 'medium' | 'high' | 'critical';
  riskItems: RiskItem[];
  recommendations: string[];
  alertLevel: string;
}

export interface RiskItem {
  category: string;
  risk: string;
  score: number;
  description: string;
}

export interface RehabGuideResult {
  warmUp: ExerciseItem[];
  mainExercises: ExerciseItem[];
  coolDown: ExerciseItem[];
  precautions: string[];
  duration: string;
}

export interface ExerciseItem {
  name: string;
  description: string;
  duration: string;
  repetitions: number;
  sets: number;
}

export interface HealthData {
  bloodPressure?: string;
  bloodSugar?: string;
  heartRate?: number;
  weight?: number;
  height?: number;
  age?: number;
  gender?: string;
  medicalHistory?: string[];
  currentMedications?: string[];
}

interface ChatRequest {
  userId: number;
  question: string;
  type: string;
}

interface DiagnosisRequest {
  userId: number;
  symptoms: string;
}

interface ConsultRequest {
  userId: number;
  question: string;
}

interface RiskAssessmentRequest {
  userId: number;
  healthData: HealthData;
}

interface RehabGuideRequest {
  userId: number;
  condition: string;
}

interface ImageAnalysisRequest {
  userId: number;
  imageUrl: string;
}

export class AIService {
  private static instance: AIService | null = null;
  
  private constructor() {}
  
  static getInstance(): AIService {
    if (!AIService.instance) {
      AIService.instance = new AIService();
    }
    return AIService.instance;
  }
  
  async chat(userId: number, message: string): Promise<string> {
    try {
      const request: ChatRequest = {
        userId: userId,
        question: message,
        type: 'chat'
      };
      const response = await HttpUtil.post<AIConversation>('/ai/chat', request);
      
      if (response.success && response.data) {
        return response.data.answer;
      }
      
      return '抱歉，AI服务暂时不可用，请稍后重试。';
    } catch (error) {
      console.error('[AIService] AI聊天失败:', error);
      return '抱歉，AI服务出现异常，请稍后重试。';
    }
  }
  
  async diagnosis(userId: number, symptoms: string): Promise<AIDiagnosisResult | null> {
    try {
      const request: DiagnosisRequest = {
        userId: userId,
        symptoms: symptoms
      };
      const response = await HttpUtil.post<AIDiagnosisResult>('/ai/diagnosis', request);
      
      if (response.success && response.data) {
        return response.data;
      }
      
      ToastUtil.showError('智能问诊失败');
      return null;
    } catch (error) {
      console.error('[AIService] 智能问诊失败:', error);
      ToastUtil.showError('智能问诊失败');
      return null;
    }
  }
  
  async healthConsult(userId: number, question: string): Promise<HealthConsultResult | null> {
    try {
      const request: ConsultRequest = {
        userId: userId,
        question: question
      };
      const response = await HttpUtil.post<HealthConsultResult>('/ai/consult', request);
      
      if (response.success && response.data) {
        return response.data;
      }
      
      ToastUtil.showError('健康咨询失败');
      return null;
    } catch (error) {
      console.error('[AIService] 健康咨询失败:', error);
      ToastUtil.showError('健康咨询失败');
      return null;
    }
  }
  
  async riskAssessment(userId: number, healthData: HealthData): Promise<RiskAssessmentResult | null> {
    try {
      const request: RiskAssessmentRequest = {
        userId: userId,
        healthData: healthData
      };
      const response = await HttpUtil.post<RiskAssessmentResult>('/ai/risk-assessment', request);
      
      if (response.success && response.data) {
        return response.data;
      }
      
      ToastUtil.showError('风险评估失败');
      return null;
    } catch (error) {
      console.error('[AIService] 风险评估失败:', error);
      ToastUtil.showError('风险评估失败');
      return null;
    }
  }
  
  async rehabGuide(userId: number, condition: string): Promise<RehabGuideResult | null> {
    try {
      const request: RehabGuideRequest = {
        userId: userId,
        condition: condition
      };
      const response = await HttpUtil.post<RehabGuideResult>('/ai/rehabilitation', request);
      
      if (response.success && response.data) {
        return response.data;
      }
      
      ToastUtil.showError('康复指导失败');
      return null;
    } catch (error) {
      console.error('[AIService] 康复指导失败:', error);
      ToastUtil.showError('康复指导失败');
      return null;
    }
  }
  
  async getConversationHistory(userId: number, type?: string): Promise<AIConversation[]> {
    try {
      const url = type 
        ? `/ai/conversations?userId=${userId}&type=${type}` 
        : `/ai/conversations?userId=${userId}`;
      const response = await HttpUtil.get<AIConversation[]>(url);
      
      if (response.success && response.data) {
        return response.data;
      }
      
      return [];
    } catch (error) {
      console.error('[AIService] 获取对话历史失败:', error);
      return [];
    }
  }
  
  async deleteConversation(conversationId: number): Promise<boolean> {
    try {
      const response = await HttpUtil.delete<boolean>(`/ai/conversation/${conversationId}`);
      
      if (response.success) {
        ToastUtil.showSuccess('删除成功');
        return true;
      }
      
      return false;
    } catch (error) {
      console.error('[AIService] 删除对话失败:', error);
      ToastUtil.showError('删除失败');
      return false;
    }
  }
  
  async analyzeMedicalImage(userId: number, imageUrl: string): Promise<string> {
    try {
      const request: ImageAnalysisRequest = {
        userId: userId,
        imageUrl: imageUrl
      };
      const response = await HttpUtil.post<string>('/ai/image-analysis', request);
      
      if (response.success && response.data) {
        return response.data;
      }
      
      return '图片分析失败，请稍后重试。';
    } catch (error) {
      console.error('[AIService] 图片分析失败:', error);
      return '图片分析出现异常，请稍后重试。';
    }
  }
}
