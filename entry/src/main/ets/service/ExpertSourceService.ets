export interface ExpertSourceService {
  getExpertSourceInfo(): Promise<ExpertSourceInfo>
}

export interface ExpertSourceInfo {
  hasAvailableSource: boolean,  // 是否有可用号源
  expert: {
    name: string,               // 专家姓名
    department: string,         // 科室
    availableCount: number,     // 可用号源数量
    appointmentTime: string     // 预约时间
  },
  updateTime: number
}
