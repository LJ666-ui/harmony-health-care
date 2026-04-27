export interface UserInpatientService {
  getUserInpatientStatus(): Promise<UserInpatientStatus>
}

export interface UserInpatientStatus {
  isInpatient: boolean,         // 是否为住院状态
  wardNumber: string,           // 病房号
  bedNumber: string,            // 床位号
  updateTime: number
}
