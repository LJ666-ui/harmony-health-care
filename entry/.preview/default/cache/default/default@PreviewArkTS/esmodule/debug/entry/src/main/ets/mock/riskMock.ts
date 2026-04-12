export interface RiskIndicator {
    id: string;
    name: string;
    icon: string;
    level: string;
    levelColor: string;
    progress: number;
    description: string;
}
export const HEALTH_SCORE: number = 78;
export const SCORE_LEVEL: string = '良好';
export const SCORE_LEVEL_COLOR: string = '#52C41A';
export const RISK_INDICATORS: RiskIndicator[] = [
    {
        id: '1',
        name: '高血压风险',
        icon: '🩺',
        level: '低',
        levelColor: '#52C41A',
        progress: 25,
        description: '血压控制稳定，继续保持健康生活方式'
    },
    {
        id: '2',
        name: '糖尿病风险',
        icon: '💉',
        level: '中',
        levelColor: '#FAAD14',
        progress: 55,
        description: '血糖偏高，建议定期监测并调整饮食'
    },
    {
        id: '3',
        name: '跌倒风险',
        icon: '⚠️',
        level: '低',
        levelColor: '#52C41A',
        progress: 20,
        description: '平衡能力良好，可适当增加平衡训练'
    },
    {
        id: '4',
        name: '衰弱风险',
        icon: '📊',
        level: '中',
        levelColor: '#FAAD14',
        progress: 45,
        description: '肌肉力量略有下降，建议加强抗阻训练'
    },
    {
        id: '5',
        name: '肌少症风险',
        icon: '💪',
        level: '高',
        levelColor: '#FF4D4F',
        progress: 75,
        description: '肌肉量减少明显，需制定针对性康复计划'
    }
];
