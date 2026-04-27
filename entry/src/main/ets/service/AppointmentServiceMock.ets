import { AppointmentService, AppointmentStatus } from './AppointmentService'

export class AppointmentServiceMock implements AppointmentService {
  async getAppointmentStatus(): Promise<AppointmentStatus> {
    let appointmentStatus: AppointmentStatus = {
      pendingCount: 1,
      updateTime: Date.now()
    }
    return appointmentStatus
  }
}
