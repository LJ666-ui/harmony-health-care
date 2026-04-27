import { BannerModel } from '../model/BannerModel'
import { HealthScoreModel } from '../model/HealthScoreModel'
import { HealthMetricModel } from '../model/HealthMetricModel'
import { RecommendationModel } from '../model/RecommendationModel'
import { RecentVisitModel } from '../model/RecentVisitModel'

@Observed
export class HomePageViewModel {
  bannerList: BannerModel[] = []              // Banner列表
  healthScore: HealthScoreModel = new HealthScoreModel()  // 健康评分
  healthMetric: HealthMetricModel = new HealthMetricModel()  // 健康指标
  recommendations: RecommendationModel[] = []  // 推荐内容列表
  recentVisits: RecentVisitModel[] = []        // 最近访问列表
  isRefreshing: boolean = false                // 是否正在刷新
}
