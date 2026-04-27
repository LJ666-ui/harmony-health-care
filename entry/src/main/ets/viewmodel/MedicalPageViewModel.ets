import { BannerModel } from '../model/BannerModel'
import { AppointmentCalendarModel } from '../model/AppointmentCalendarModel'
import { MedicalServiceModel } from '../model/MedicalServiceModel'
import { RecommendedHospitalModel } from '../model/RecommendedHospitalModel'
import { MoreServiceModel } from '../model/MoreServiceModel'

@Observed
export class MedicalPageViewModel {
  bannerList: BannerModel[] = []                    // Banner列表
  appointmentCalendar: AppointmentCalendarModel = new AppointmentCalendarModel()  // 就诊日历
  medicalServices: MedicalServiceModel[] = []        // 常用服务列表
  recommendedHospitals: RecommendedHospitalModel[] = []  // 推荐医院列表
  moreServices: MoreServiceModel[] = []              // 更多服务列表
  isRefreshing: boolean = false                      // 是否正在刷新
}
