import { RecentVisitModel } from '../model/RecentVisitModel'
import { UserBehaviorServiceMock } from '../service/UserBehaviorServiceMock'
import { UserBehaviorService } from '../service/UserBehaviorService'

export class RecentVisitManager {
  private userBehaviorService: UserBehaviorService = new UserBehaviorServiceMock()

  async getRecentVisits(): Promise<RecentVisitModel[]> {
    let recentVisitsData = await this.userBehaviorService.getRecentVisits()
    let recentVisits: RecentVisitModel[] = []
    for (let visit of recentVisitsData.visits) {
      let recentVisit = new RecentVisitModel()
      recentVisit.id = visit.id
      recentVisit.pageTitle = visit.pageTitle
      recentVisit.pagePath = visit.pagePath
      recentVisit.visitTime = visit.visitTime
      recentVisits.push(recentVisit)
    }
    return recentVisits
  }
}
