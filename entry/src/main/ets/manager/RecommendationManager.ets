import { RecommendationModel, RecommendationType } from '../model/RecommendationModel'
import { RecommendationServiceMock } from '../service/RecommendationServiceMock'
import { AppointmentServiceMock } from '../service/AppointmentServiceMock'
import { RecommendationService } from '../service/RecommendationService'
import { AppointmentService } from '../service/AppointmentService'

export class RecommendationManager {
  private recommendationService: RecommendationService = new RecommendationServiceMock()
  private appointmentService: AppointmentService = new AppointmentServiceMock()

  async getRecommendations(): Promise<RecommendationModel[]> {
    let recommendations: RecommendationModel[] = []

    let recommendationData = await this.recommendationService.getRecommendations()
    let appointmentStatus = await this.appointmentService.getAppointmentStatus()

    let articleRecommendation = new RecommendationModel()
    articleRecommendation.id = recommendationData.article.id
    articleRecommendation.type = RecommendationType.ARTICLE
    articleRecommendation.title = recommendationData.article.title
    articleRecommendation.targetPage = 'ArticleDetailPage'
    articleRecommendation.updateTime = recommendationData.article.updateTime
    recommendations.push(articleRecommendation)

    let herbRecommendation = new RecommendationModel()
    herbRecommendation.id = recommendationData.herb.id
    herbRecommendation.type = RecommendationType.HERB
    herbRecommendation.title = recommendationData.herb.name + '的功效与用法'
    herbRecommendation.targetPage = 'HerbDetailPage'
    herbRecommendation.updateTime = recommendationData.herb.updateTime
    recommendations.push(herbRecommendation)

    let appointmentRecommendation = new RecommendationModel()
    appointmentRecommendation.id = 'appointment'
    appointmentRecommendation.type = RecommendationType.APPOINTMENT
    if (appointmentStatus.pendingCount > 0) {
      appointmentRecommendation.title = '您有' + appointmentStatus.pendingCount + '条预约待确认'
    } else {
      appointmentRecommendation.title = '暂无待确认预约'
    }
    appointmentRecommendation.targetPage = 'MyAppointmentPage'
    appointmentRecommendation.updateTime = appointmentStatus.updateTime
    recommendations.push(appointmentRecommendation)

    return recommendations
  }
}
