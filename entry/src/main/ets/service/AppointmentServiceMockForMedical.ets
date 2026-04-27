import { AppointmentServiceForMedical, AppointmentInfo } from './AppointmentServiceForMedical'

export class AppointmentServiceMockForMedical implements AppointmentServiceForMedical {
  async getAppointmentInfo(): Promise<AppointmentInfo> {
    let appointmentInfo: AppointmentInfo = {
      weeklyCount: 3,
      nextAppointment: {
        date: '明天',
        time: '10:00'
      },
      updateTime: Date.now()
    }
    return appointmentInfo
  }
}
