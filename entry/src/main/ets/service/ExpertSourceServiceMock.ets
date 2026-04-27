import { ExpertSourceService, ExpertSourceInfo } from './ExpertSourceService'

export class ExpertSourceServiceMock implements ExpertSourceService {
  async getExpertSourceInfo(): Promise<ExpertSourceInfo> {
    let expertSourceInfo: ExpertSourceInfo = {
      hasAvailableSource: true,
      expert: {
        name: '张教授',
        department: '心内科',
        availableCount: 3,
        appointmentTime: '明天10:00'
      },
      updateTime: Date.now()
    }
    return expertSourceInfo
  }
}
