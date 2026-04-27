import { AiConsultationService, AiConsultationStatus } from './AiConsultationService'

export class AiConsultationServiceMock implements AiConsultationService {
  async checkAiConsultationUsed(): Promise<AiConsultationStatus> {
    let aiConsultationStatus: AiConsultationStatus = {
      used: false,
      firstUseTime: undefined
    }
    return aiConsultationStatus
  }
}
