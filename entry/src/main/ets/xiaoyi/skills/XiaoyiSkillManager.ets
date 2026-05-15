/**
 * Skill管理器 - XiaoyiSkillManager.ets
 * 
 * 统一管理所有 Skill 的注册、匹配和调用
 */

import { HealthQuerySkill } from './HealthQuerySkill';
import { AIConsultationSkill } from './AIConsultationSkill';
import { MedicalRiskAssessSkill } from './MedicalRiskAssessSkill';

interface SkillResult {
  skillId: string;
  success: boolean;
  result?: any;
  error?: string;
}

export class XiaoyiSkillManager {
  private static instance: XiaoyiSkillManager;
  private skills: Map<string, any> = new Map();
  
  private constructor() {
    this.registerSkills();
  }
  
  static getInstance(): XiaoyiSkillManager {
    if (!XiaoyiSkillManager.instance) {
      XiaoyiSkillManager.instance = new XiaoyiSkillManager();
    }
    return XiaoyiSkillManager.instance;
  }
  
  /**
   * 注册所有技能
   */
  private registerSkills(): void {
    // S1 - 健康数据查询
    this.skills.set('医疗.query.health', {
      id: '医疗.query.health',
      name: '健康数据查询',
      skillClass: HealthQuerySkill,
      priority: 1,
      estimatedTime: '~500ms'
    });
    
    // S2 - AI智能问诊
    this.skills.set('医疗.ai.consultation', {
      id: '医疗.ai.consultation',
      name: 'AI智能问诊',
      skillClass: AIConsultationSkill,
      priority: 2,
      estimatedTime: '~3000ms'
    });
    
    // S3 - 健康风险评估
    this.skills.set('medical.riskassess', {
      id: 'medical.riskassess',
      name: '健康风险评估',
      skillClass: MedicalRiskAssessSkill,
      priority: 3,
      estimatedTime: '~1500ms'
    });
    
    console.log(`✅ 已注册 ${this.skills.size} 个 Skill`);
  }
  
  /**
   * 匹配并执行技能
   */
  async processQuery(query: string): Promise<SkillResult> {
    console.log(`🔍 处理用户查询: "${query}"`);
    
    // 遍历所有已注册的技能，查找匹配项
    for (const [skillId, skillInfo] of this.skills) {
      const SkillClass = skillInfo.skillClass;
      
      if (SkillClass.match(query)) {
        console.log(`✅ 匹配到 Skill: ${skillInfo.name} (${skillId})`);
        
        try {
          const result = await SkillClass.execute(query);
          
          return {
            skillId,
            success: true,
            result: SkillClass.formatResult ? SkillClass.formatResult(result) : result
          };
        } catch (error) {
          console.error(`❌ Skill 执行失败 (${skillId}):`, error);
          return {
            skillId,
            success: false,
            error: `技能执行出错: ${error.message}`
          };
        }
      }
    }
    
    // 没有匹配到任何技能
    return {
      skillId: 'none',
      success: false,
      error: '未找到匹配的技能'
    };
  }
  
  /**
   * 获取所有已注册的技能信息
   */
  getRegisteredSkills(): Array<{id: string; name: string; priority: number; estimatedTime: string}> {
    return Array.from(this.skills.values()).map(skill => ({
      id: skill.id,
      name: skill.name,
      priority: skill.priority,
      estimatedTime: skill.estimatedTime
    }));
  }
  
  /**
   * 获取特定技能
   */
  getSkill(skillId: string): any {
    return this.skills.get(skillId);
  }
}
