import { UserBehaviorService, RecentVisits } from './UserBehaviorService'

export class UserBehaviorServiceMock implements UserBehaviorService {
  async getRecentVisits(): Promise<RecentVisits> {
    let recentVisits: RecentVisits = {
      visits: [
        {
          id: 'visit_1',
          pageTitle: '健康记录',
          pagePath: 'HealthRecordPage',
          visitTime: Date.now() - 1000 * 60 * 30
        },
        {
          id: 'visit_2',
          pageTitle: 'AI顾问',
          pagePath: 'AiConsultationPage',
          visitTime: Date.now() - 1000 * 60 * 60 * 2
        },
        {
          id: 'visit_3',
          pageTitle: '我的预约',
          pagePath: 'MyAppointmentPage',
          visitTime: Date.now() - 1000 * 60 * 60 * 24
        },
        {
          id: 'visit_4',
          pageTitle: '用药提醒',
          pagePath: 'MedicationReminderPage',
          visitTime: Date.now() - 1000 * 60 * 60 * 48
        }
      ],
      updateTime: Date.now()
    }
    return recentVisits
  }
}
