export interface AiConsultationService {
  checkAiConsultationUsed(): Promise<AiConsultationStatus>
}

export interface AiConsultationStatus {
  used: boolean,       // 是否使用过
  firstUseTime?: number  // 首次使用时间（未使用时为空）
}
