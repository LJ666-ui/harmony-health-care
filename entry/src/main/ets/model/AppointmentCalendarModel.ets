@Observed
export class AppointmentCalendarModel {
  weeklyCount: number = 0          // 本周预约次数
  nextAppointment: NextAppointment = new NextAppointment()  // 下次就诊
  updateTime: number = 0           // 更新时间戳
}

@Observed
export class NextAppointment {
  date: string = ''                // 就诊日期
  time: string = ''                // 就诊时间
}
