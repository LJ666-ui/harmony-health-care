export interface UserBehaviorService {
  getRecentVisits(): Promise<RecentVisits>
}

export interface RecentVisits {
  visits: Array<{
    id: string,
    pageTitle: string,
    pagePath: string,
    visitTime: number
  }>,
  updateTime: number
}
