/**
 * 神经内科智能体
 * 专长：脑血管疾病、神经系统疾病、头痛眩晕、认知障碍
 * 
 * 根据项目规划V14.0 - 9.2提示词4开发
 */

import { MedicalAgent } from './MedicalAgent';
import { LLMClient } from './infrastructure/LLMClient';
import { RAGRetriever } from './RAGRetriever';
import { AgentConfig, MedicalSpecialty, AgentCapability } from './types/AgentTypes';

/**
 * 神经内科智能体
 * 
 * 【专业领域】
 * - 脑血管疾病：脑梗塞、脑出血、短暂性脑缺血发作
 * - 神经系统疾病：帕金森病、癫痫、多发性硬化
 * - 头痛眩晕：偏头痛、紧张性头痛、眩晕症
 * - 认知障碍：阿尔茨海默病、血管性痴呆
 * 
 * 【典型症状】
 * - 头痛、头晕、眩晕
 * - 肢体麻木、无力
 * - 记忆力减退、认知障碍
 * - 震颤、运动障碍
 * - 言语不清、吞咽困难
 * 
 * 【常用检查】
 * - 头颅CT/MRI
 * - 脑电图(EEG)
 * - 经颅多普勒(TCD)
 * - 脑血管造影
 * - 神经心理学评估
 * 
 * 【治疗方案】
 * - 药物治疗：抗血小板、抗凝、改善循环
 * - 康复训练：肢体康复、言语康复
 * - 生活方式干预：控制危险因素
 * - 手术治疗：特定情况下的外科干预
 */
export class NeurologyAgent extends MedicalAgent {
  constructor(llmClient: LLMClient, ragRetriever: RAGRetriever) {
    const config: AgentConfig = {
      agentId: 'neurology',
      agentName: '神经内科智能体',
      specialty: MedicalSpecialty.NEUROLOGY, // 需要在MedicalSpecialty枚举中添加
      description: '擅长脑血管疾病、神经系统疾病、头痛眩晕和认知障碍的诊疗',
      capabilities: [
        {
          name: '脑血管疾病诊疗',
          description: '脑梗塞、脑出血、TIA等脑血管疾病的诊断和治疗建议',
          keywords: ['脑梗', '脑出血', '中风', '脑血管', 'TIA', '脑缺血'],
          examples: ['脑梗塞怎么治疗', '中风后遗症', '脑血管堵塞']
        },
        {
          name: '头痛眩晕诊疗',
          description: '偏头痛、紧张性头痛、眩晕症的诊断和治疗',
          keywords: ['头痛', '偏头痛', '眩晕', '头晕', '偏头'],
          examples: ['经常头痛', '偏头痛怎么办', '眩晕症']
        },
        {
          name: '认知障碍评估',
          description: '阿尔茨海默病、血管性痴呆的认知功能评估',
          keywords: ['记忆力', '痴呆', '认知', '阿尔茨海默', '老年痴呆'],
          examples: ['记忆力下降', '老年痴呆症状', '认知障碍']
        },
        {
          name: '运动障碍诊疗',
          description: '帕金森病、特发性震颤等运动障碍疾病',
          keywords: ['帕金森', '震颤', '手抖', '运动障碍', '僵硬'],
          examples: ['手抖是什么病', '帕金森症状', '肢体震颤']
        }
      ],
      icon: '🧠',
      color: '#8E44AD'
    };

    super(config, llmClient, ragRetriever);
  }

  /**
   * 获取系统提示词
   * 定义神经内科医生的专业角色和回答规范
   */
  protected getSystemPrompt(): string {
    return `你是一位专业的神经内科医生，擅长脑血管疾病和神经系统疾病的诊疗。

【专业领域】
1. 脑血管疾病
   - 脑梗塞：急性期治疗、二级预防、康复指导
   - 脑出血：病因诊断、治疗原则、预后评估
   - 短暂性脑缺血发作(TIA)：风险评估、预防措施

2. 神经系统疾病
   - 帕金森病：药物治疗、康复训练、生活指导
   - 癫痫：发作类型、用药指导、生活注意事项
   - 多发性硬化：疾病管理、症状控制

3. 头痛眩晕
   - 偏头痛：诱发因素、急性治疗、预防用药
   - 紧张性头痛：病因分析、治疗建议
   - 眩晕症：病因诊断、对症治疗

4. 认知障碍
   - 阿尔茨海默病：早期识别、治疗延缓
   - 血管性痴呆：病因治疗、认知训练

【回答要求】
1. 仔细分析症状特点，考虑可能的病因
2. 评估病情严重程度，判断是否需要紧急就医
3. 提供专业的诊疗建议和注意事项
4. 强调危险因素控制和生活方式干预
5. 对于急性脑血管事件，强调及时就医的重要性
6. 不要给出具体用药剂量，建议在专科医生指导下用药
7. 语言通俗易懂，避免过多专业术语
8. 关注患者的心理状态，给予适当的心理支持

【紧急情况识别】
以下情况建议立即就医或拨打120：
- 突发剧烈头痛，伴恶心呕吐
- 突发肢体无力或麻木，尤其是一侧
- 突发言语不清或理解困难
- 突发视力障碍或复视
- 突发眩晕伴行走不稳
- 意识障碍或行为异常

【危险因素管理】
- 高血压：定期监测，规范用药
- 糖尿病：控制血糖，定期复查
- 高血脂：饮食控制，必要时用药
- 吸烟：强烈建议戒烟
- 缺乏运动：适度运动，循序渐进
- 肥胖：控制体重，健康饮食`;
  }

  /**
   * 计算置信度
   * 根据知识检索结果和问题相关性计算置信度
   */
  protected calculateConfidence(knowledge: any): number {
    // 基础置信度
    let confidence = 0.7;

    // 根据检索到的知识数量调整
    if (knowledge.references && knowledge.references.length > 0) {
      confidence += Math.min(knowledge.references.length * 0.05, 0.2);
    }

    // 确保置信度在0-1之间
    return Math.min(Math.max(confidence, 0), 1);
  }

  /**
   * 判断是否能处理该问题
   * @param question 用户问题
   * @returns 是否能处理
   */
  canHandle(question: string): boolean {
    const keywords = [
      '神经', '脑', '头痛', '头晕', '眩晕', '麻木', '震颤', 
      '帕金森', '癫痫', '痴呆', '认知', '记忆', '中风',
      '脑梗', '脑出血', '脑血管', 'TIA', '偏头痛'
    ];
    
    const lowerQuestion = question.toLowerCase();
    return keywords.some(keyword => lowerQuestion.includes(keyword));
  }

  /**
   * 获取置信度评分
   * @param question 用户问题
   * @returns 置信度评分(0-1)
   */
  getConfidenceScore(question: string): number {
    if (!this.canHandle(question)) {
      return 0;
    }

    // 根据关键词匹配程度计算置信度
    const keywords = [
      { words: ['脑梗', '脑出血', '中风', '脑血管'], score: 0.95 },
      { words: ['帕金森', '癫痫'], score: 0.9 },
      { words: ['头痛', '偏头痛', '眩晕'], score: 0.85 },
      { words: ['痴呆', '认知', '记忆'], score: 0.85 },
      { words: ['麻木', '震颤', '神经'], score: 0.8 }
    ];

    const lowerQuestion = question.toLowerCase();
    for (const group of keywords) {
      if (group.words.some(word => lowerQuestion.includes(word))) {
        return group.score;
      }
    }

    return 0.7; // 默认置信度
  }
}
