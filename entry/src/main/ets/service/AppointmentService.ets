export interface AppointmentService {
  getAppointmentStatus(): Promise<AppointmentStatus>
}

export interface AppointmentStatus {
  pendingCount: number,  // 待确认预约数量
  updateTime: number     // 更新时间戳
}
