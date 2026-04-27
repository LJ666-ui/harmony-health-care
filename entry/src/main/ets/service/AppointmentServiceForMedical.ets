export interface AppointmentServiceForMedical {
  getAppointmentInfo(): Promise<AppointmentInfo>
}

export interface AppointmentInfo {
  weeklyCount: number,    // 本周预约次数
  nextAppointment: {
    date: string,         // 就诊日期（如"明天"、"后天"）
    time: string          // 就诊时间（如"10:00"）
  },
  updateTime: number      // 更新时间戳
}
