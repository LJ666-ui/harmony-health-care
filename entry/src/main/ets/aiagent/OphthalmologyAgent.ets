/**
 * 眼科智能体
 * Ophthalmology Agent
 *
 * 专长：眼部疾病诊断、视力保健、用眼卫生指导
 *
 * @author Nebula Medical Team
 * @date 2026-05-06
 */

import { MedicalAgent } from './MedicalAgent';
import { LLMClient } from './infrastructure/LLMClient';
import { RAGRetriever } from './RAGRetriever';
import { AgentConfig, MedicalSpecialty, AgentCapability } from './types/AgentTypes';

/**
 * 眼科智能体
 * 专长：眼部疾病诊断、视力保健、用眼卫生
 */
export class OphthalmologyAgent extends MedicalAgent {
  constructor(llmClient: LLMClient, ragRetriever: RAGRetriever) {
    const config: AgentConfig = {
      agentId: 'ophthalmology',
      agentName: '眼科智能体',
      specialty: MedicalSpecialty.OPHTHALMOLOGY,
      description: '擅长眼部疾病诊断、视力保健和用眼卫生指导',
      capabilities: [
        {
          name: '眼部疾病诊断',
          description: '常见眼部疾病的诊断和建议',
          keywords: ['眼睛', '眼部', '红肿', '干涩', '疼痛', '流泪', '分泌物'],
          examples: ['眼睛红肿怎么办', '眼睛干涩疼痛', '眼睛有分泌物']
        },
        {
          name: '视力保健',
          description: '视力保护和眼部保健建议',
          keywords: ['视力', '近视', '远视', '散光', '老花', '弱视'],
          examples: ['近视怎么预防', '视力下降怎么办', '散光能治吗']
        },
        {
          name: '用眼卫生',
          description: '科学用眼和眼部护理',
          keywords: ['用眼', '护眼', '眼保健操', '蓝光', '疲劳', '干眼'],
          examples: ['怎么保护眼睛', '眼睛疲劳怎么缓解', '蓝光对眼睛有害吗']
        },
        {
          name: '眼部护理',
          description: '日常眼部护理和保养',
          keywords: ['眼药水', '热敷', '按摩', '护理', '保养'],
          examples: ['眼药水怎么用', '眼睛热敷好吗', '眼部按摩方法']
        }
      ],
      icon: '👁️',
      color: '#3498DB'
    };

    super(config, llmClient, ragRetriever);
  }

  /**
   * 获取系统提示词
   * 定义眼科Agent的专业知识和回答规范
   */
  protected getSystemPrompt(): string {
    return `你是一位专业的眼科医生，擅长眼部疾病诊断和视力保健。

【专业领域】
- 常见眼病：结膜炎、角膜炎、干眼症、麦粒肿（针眼）、沙眼等
- 屈光不正：近视、远视、散光、老花眼
- 眼部保健：用眼卫生、视力保护、眼保健操
- 眼科急症：眼外伤、急性青光眼、视网膜脱落等
- 儿童眼病：弱视、斜视、先天性眼病

【回答要求】
1. 评估症状严重程度，判断是否需要紧急就医
2. 提供初步诊断建议和可能的原因分析
3. 给出护理建议和预防措施
4. 推荐合适的检查或治疗方式
5. 强调定期眼科检查的重要性
6. 语言通俗易懂，避免过多专业术语

【安全提示】
- 眼部急症（如眼外伤、突然视力下降、剧烈眼痛）建议立即就医
- 不要自行使用处方眼药水
- 儿童视力问题建议及时就医检查
- 慢性眼病需要定期复查

【常见建议】
- 用眼卫生：每用眼1小时休息10分钟
- 眼保健操：每天做1-2次眼保健操
- 环境光线：保持适当的光线，避免过亮或过暗
- 屏幕使用：保持适当距离，使用防蓝光措施
- 定期检查：每年至少一次眼科检查`;
  }

  /**
   * 处理特定类型的眼科问题
   * 可以根据问题类型提供更专业的回答
   */
  protected async handleSpecialCase(query: string): Promise<string | null> {
    // 检测是否为视力检查相关
    if (query.includes('视力检查') || query.includes('验光')) {
      return this.getVisionExamAdvice();
    }

    // 检测是否为用眼疲劳相关
    if (query.includes('疲劳') || query.includes('累')) {
      return this.getEyeStrainAdvice();
    }

    // 检测是否为近视预防相关
    if (query.includes('近视') && query.includes('预防')) {
      return this.getMyopiaPreventionAdvice();
    }

    // 返回null表示使用默认处理
    return null;
  }

  /**
   * 视力检查建议
   */
  private getVisionExamAdvice(): string {
    return `【视力检查建议】

1. **检查频率**
   - 儿童：每6个月一次
   - 成年人：每年一次
   - 老年人：每半年一次

2. **检查项目**
   - 视力检查（远视力、近视力）
   - 屈光检查（验光）
   - 眼压检查
   - 眼底检查

3. **注意事项**
   - 检查前避免过度用眼
   - 如实告知医生用眼习惯
   - 携带既往检查报告

建议到正规医院眼科或专业眼科机构进行检查。`;
  }

  /**
   * 用眼疲劳缓解建议
   */
  private getEyeStrainAdvice(): string {
    return `【缓解用眼疲劳建议】

1. **20-20-20法则**
   - 每用眼20分钟
   - 向20英尺（约6米）外看
   - 持续20秒

2. **眼保健操**
   - 每天做1-2次
   - 动作要标准、到位
   - 配合深呼吸

3. **热敷缓解**
   - 使用热毛巾敷眼
   - 温度40-42℃
   - 每次10-15分钟

4. **环境调整**
   - 调整屏幕亮度和对比度
   - 保持适当距离（50-70cm）
   - 确保环境光线充足

5. **人工泪液**
   - 可使用人工泪液缓解干涩
   - 选择不含防腐剂的产品
   - 遵医嘱使用

如果疲劳症状持续不缓解，建议就医检查。`;
  }

  /**
   * 近视预防建议
   */
  private getMyopiaPreventionAdvice(): string {
    return `【近视预防建议】

1. **科学用眼**
   - 保持正确读写姿势
   - 读写距离保持33cm以上
   - 每用眼40分钟休息10分钟

2. **户外活动**
   - 每天户外活动2小时以上
   - 自然光有助于预防近视
   - 多进行远眺活动

3. **光线环境**
   - 读写时光线要充足
   - 避免在强光或暗光下用眼
   - 使用护眼台灯

4. **营养均衡**
   - 补充维生素A、C、E
   - 多吃绿叶蔬菜和水果
   - 适量补充DHA

5. **定期检查**
   - 儿童每6个月检查一次视力
   - 建立视力健康档案
   - 发现问题及时干预

6. **控制电子产品使用**
   - 2岁以下避免使用
   - 2-5岁每天不超过1小时
   - 5岁以上合理控制时间

预防近视需要长期坚持，家长要以身作则。`;
  }
}
