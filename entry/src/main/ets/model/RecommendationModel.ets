@Observed
export class RecommendationModel {
  id: string = ''              // 推荐ID
  type: RecommendationType = RecommendationType.ARTICLE  // 推荐类型
  title: string = ''           // 标题
  targetPage: string = ''      // 跳转目标页面
  updateTime: number = 0       // 更新时间戳
}

export enum RecommendationType {
  ARTICLE = '科普',
  HERB = '药材',
  APPOINTMENT = '就医'
}
