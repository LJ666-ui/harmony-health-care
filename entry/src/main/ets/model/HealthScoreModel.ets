@Observed
export class HealthScoreModel {
  score: number = 0            // 健康评分（0-100）
  trend: number = 0            // 变化趋势（正数上升，负数下降）
  updateTime: number = 0       // 更新时间戳
}
