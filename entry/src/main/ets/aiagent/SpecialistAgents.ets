/**
 * 专科智能体实现
 * 包含内科、外科、中医、营养、康复五个专科智能体
 */

import { MedicalAgent } from './MedicalAgent';
import { LLMClient } from './infrastructure/LLMClient';
import { RAGRetriever } from './RAGRetriever';
import { AgentConfig, MedicalSpecialty, AgentCapability } from './types/AgentTypes';

/**
 * 内科智能体
 * 专长：慢性病管理、症状分析、常见病诊断建议
 */
export class InternalMedicineAgent extends MedicalAgent {
  constructor(llmClient: LLMClient, ragRetriever: RAGRetriever) {
    const config: AgentConfig = {
      agentId: 'internal_medicine',
      agentName: '内科智能体',
      specialty: MedicalSpecialty.INTERNAL_MEDICINE,
      description: '擅长慢性病管理、症状分析和常见病诊断建议',
      capabilities: [
        {
          name: '症状分析',
          description: '分析患者症状，提供可能的病因分析',
          keywords: ['症状', '头痛', '发烧', '咳嗽'],
          examples: ['我最近头痛', '有点发烧']
        },
        {
          name: '慢性病管理',
          description: '慢性病的长期管理和用药指导',
          keywords: ['高血压', '糖尿病', '冠心病'],
          examples: ['高血压怎么管理', '糖尿病饮食']
        }
      ],
      icon: '🏥',
      color: '#4A90E2'
    };

    super(config, llmClient, ragRetriever);
  }

  protected getSystemPrompt(): string {
    return `你是一位专业的内科医生，擅长慢性病管理和症状分析。

【专业领域】
- 常见病诊断：感冒、高血压、糖尿病、冠心病等
- 症状分析：头痛、发热、咳嗽、腹痛等
- 慢性病管理：长期用药指导、生活方式建议

【回答要求】
1. 分析可能的病因
2. 提供生活建议和注意事项
3. 建议是否需要就医
4. 不要给出具体用药剂量，建议遵医嘱
5. 语言通俗易懂，避免过多专业术语`;
  }
}

/**
 * 外科智能体
 * 专长：外伤处理、手术咨询、伤口护理
 */
export class SurgeryAgent extends MedicalAgent {
  constructor(llmClient: LLMClient, ragRetriever: RAGRetriever) {
    const config: AgentConfig = {
      agentId: 'surgery',
      agentName: '外科智能体',
      specialty: MedicalSpecialty.SURGERY,
      description: '擅长外伤处理、手术咨询和伤口护理',
      capabilities: [
        {
          name: '外伤处理',
          description: '外伤的紧急处理和护理建议',
          keywords: ['外伤', '伤口', '出血'],
          examples: ['手被割伤了', '摔倒擦伤']
        },
        {
          name: '手术咨询',
          description: '手术相关问题的咨询',
          keywords: ['手术', '术前', '术后'],
          examples: ['手术前要注意什么', '术后恢复']
        }
      ],
      icon: '🔪',
      color: '#E74C3C'
    };

    super(config, llmClient, ragRetriever);
  }

  protected getSystemPrompt(): string {
    return `你是一位专业的外科医生，擅长外伤处理和手术咨询。

【专业领域】
- 外伤处理：伤口清洁、止血、包扎
- 手术咨询：术前准备、术后护理
- 伤口护理：换药、防感染、愈合指导

【回答要求】
1. 评估伤情严重程度
2. 提供紧急处理建议
3. 判断是否需要就医
4. 伤口护理注意事项
5. 严重外伤建议立即就医`;
  }
}

/**
 * 中医智能体
 * 专长：中药调理、针灸指导、体质辨识
 */
export class TCMAgent extends MedicalAgent {
  constructor(llmClient: LLMClient, ragRetriever: RAGRetriever) {
    const config: AgentConfig = {
      agentId: 'tcm',
      agentName: '中医智能体',
      specialty: MedicalSpecialty.TCM,
      description: '擅长中药调理、针灸指导和体质辨识',
      capabilities: [
        {
          name: '体质辨识',
          description: '辨识中医体质类型',
          keywords: ['体质', '气虚', '阳虚'],
          examples: ['我是什么体质', '气虚怎么调理']
        },
        {
          name: '中药调理',
          description: '中药调理建议',
          keywords: ['中药', '调理', '养生'],
          examples: ['吃什么中药', '怎么调理身体']
        }
      ],
      icon: '🌿',
      color: '#27AE60'
    };

    super(config, llmClient, ragRetriever);
  }

  protected getSystemPrompt(): string {
    return `你是一位专业的中医师，擅长中药调理和体质辨识。

【专业领域】
- 体质辨识：九种体质类型的辨识和调理
- 中药调理：常见中药的功效和使用
- 针灸指导：针灸穴位和适应症
- 养生保健：四季养生、饮食调养

【回答要求】
1. 辨识体质类型
2. 提供调理建议
3. 推荐适合的中药或食疗
4. 注意禁忌和注意事项
5. 建议在专业中医师指导下使用中药`;
  }
}

/**
 * 营养智能体
 * 专长：饮食建议、食疗方案、营养素补充
 */
export class NutritionAgent extends MedicalAgent {
  constructor(llmClient: LLMClient, ragRetriever: RAGRetriever) {
    const config: AgentConfig = {
      agentId: 'nutrition',
      agentName: '营养智能体',
      specialty: MedicalSpecialty.NUTRITION,
      description: '擅长饮食建议、食疗方案和营养素补充',
      capabilities: [
        {
          name: '饮食建议',
          description: '健康饮食建议和搭配',
          keywords: ['饮食', '吃', '营养'],
          examples: ['怎么吃才健康', '饮食搭配']
        },
        {
          name: '食疗方案',
          description: '针对疾病的食疗方案',
          keywords: ['食疗', '糖尿病饮食'],
          examples: ['糖尿病吃什么', '高血压饮食']
        }
      ],
      icon: '🥗',
      color: '#F39C12'
    };

    super(config, llmClient, ragRetriever);
  }

  protected getSystemPrompt(): string {
    return `你是一位专业的营养师，擅长饮食建议和营养指导。

【专业领域】
- 健康饮食：均衡营养、合理搭配
- 食疗方案：针对疾病的饮食调理
- 营养素补充：维生素、矿物质补充建议
- 特殊人群：孕妇、儿童、老年人营养

【回答要求】
1. 提供均衡饮食建议
2. 推荐适合的食物
3. 注意饮食禁忌
4. 营养素补充建议
5. 个性化饮食方案`;
  }
}

/**
 * 康复智能体
 * 专长：运动处方、康复训练、功能恢复
 */
export class RehabAgent extends MedicalAgent {
  constructor(llmClient: LLMClient, ragRetriever: RAGRetriever) {
    const config: AgentConfig = {
      agentId: 'rehab',
      agentName: '康复智能体',
      specialty: MedicalSpecialty.REHAB,
      description: '擅长运动处方、康复训练和功能恢复',
      capabilities: [
        {
          name: '运动处方',
          description: '个性化的运动建议',
          keywords: ['运动', '锻炼', '健身'],
          examples: ['怎么运动', '适合什么运动']
        },
        {
          name: '康复训练',
          description: '疾病或术后的康复训练',
          keywords: ['康复', '恢复', '训练'],
          examples: ['术后怎么康复', '骨折康复训练']
        }
      ],
      icon: '💪',
      color: '#9B59B6'
    };

    super(config, llmClient, ragRetriever);
  }

  protected getSystemPrompt(): string {
    return `你是一位专业的康复治疗师，擅长运动处方和康复训练。

【专业领域】
- 运动处方：个性化运动方案
- 康复训练：术后康复、疾病康复
- 功能恢复：运动功能、生活能力恢复
- 运动损伤：预防和处理

【回答要求】
1. 评估身体状况
2. 制定运动方案
3. 循序渐进指导
4. 注意运动安全
5. 观察身体反应，不适即停`;
  }
}

/**
 * 创建所有专科智能体
 * @param llmClient LLM客户端
 * @param ragRetriever RAG检索器
 * @returns 智能体列表
 */
export function createSpecialistAgents(
  llmClient: LLMClient,
  ragRetriever: RAGRetriever
): MedicalAgent[] {
  return [
    new InternalMedicineAgent(llmClient, ragRetriever),
    new SurgeryAgent(llmClient, ragRetriever),
    new TCMAgent(llmClient, ragRetriever),
    new NutritionAgent(llmClient, ragRetriever),
    new RehabAgent(llmClient, ragRetriever)
  ];
}
