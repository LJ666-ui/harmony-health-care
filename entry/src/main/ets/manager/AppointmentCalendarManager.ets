import { AppointmentCalendarModel, NextAppointment } from '../model/AppointmentCalendarModel'
import { AppointmentServiceMockForMedical } from '../service/AppointmentServiceMockForMedical'
import { AppointmentServiceForMedical } from '../service/AppointmentServiceForMedical'

export class AppointmentCalendarManager {
  private appointmentService: AppointmentServiceForMedical = new AppointmentServiceMockForMedical()

  async getAppointmentCalendar(): Promise<AppointmentCalendarModel> {
    let appointmentInfo = await this.appointmentService.getAppointmentInfo()
    let appointmentCalendar = new AppointmentCalendarModel()

    appointmentCalendar.weeklyCount = appointmentInfo.weeklyCount

    let nextAppointment = new NextAppointment()
    nextAppointment.date = appointmentInfo.nextAppointment.date
    nextAppointment.time = appointmentInfo.nextAppointment.time
    appointmentCalendar.nextAppointment = nextAppointment

    appointmentCalendar.updateTime = appointmentInfo.updateTime

    return appointmentCalendar
  }
}
