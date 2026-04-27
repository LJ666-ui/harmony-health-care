import { BannerModel } from '../model/BannerModel'
import { UserDeviceServiceMock } from '../service/UserDeviceServiceMock'
import { UserInpatientServiceMock } from '../service/UserInpatientServiceMock'
import { ExpertSourceServiceMock } from '../service/ExpertSourceServiceMock'
import { UserRegisterServiceMock } from '../service/UserRegisterServiceMock'
import { UserDeviceService } from '../service/UserDeviceService'
import { UserInpatientService } from '../service/UserInpatientService'
import { ExpertSourceService } from '../service/ExpertSourceService'
import { UserRegisterService } from '../service/UserRegisterService'

export class MedicalBannerManager {
  private bannerList: BannerModel[] = []
  private userDeviceService: UserDeviceService = new UserDeviceServiceMock()
  private userInpatientService: UserInpatientService = new UserInpatientServiceMock()
  private expertSourceService: ExpertSourceService = new ExpertSourceServiceMock()
  private userRegisterService: UserRegisterService = new UserRegisterServiceMock()

  async getFilteredBanners(): Promise<BannerModel[]> {
    let allBanners = await this.getAllBanners()
    let filteredBanners: BannerModel[] = []
    for (let banner of allBanners) {
      if (banner.condition()) {
        filteredBanners.push(banner)
      }
    }
    return filteredBanners
  }

  private async getAllBanners(): Promise<BannerModel[]> {
    let hasMultipleDevices = (await this.userDeviceService.getUserDeviceStatus()).hasMultipleDevices
    let isInpatient = (await this.userInpatientService.getUserInpatientStatus()).isInpatient
    let hasAvailableSource = (await this.expertSourceService.getExpertSourceInfo()).hasAvailableSource
    let registerTime = (await this.userRegisterService.getUserRegisterTime()).registerTime
    let now = Date.now()

    let banner1: BannerModel = new BannerModel()
    banner1.id = 'medical_banner_1'
    banner1.title = 'AR院内实景导航'
    banner1.subtitle = '摄像头指引方向 · 语音播报提示'
    banner1.startColor = '#4A90E2'
    banner1.endColor = '#357ABD'
    banner1.icon = '🗺️➡️'
    banner1.targetPage = 'ARNavigationPage'
    banner1.condition = () => true

    let banner2: BannerModel = new BannerModel()
    banner2.id = 'medical_banner_2'
    banner2.title = '跨院病历自动同步'
    banner2.subtitle = 'AES加密 · 三级权限隔离'
    banner2.startColor = '#9B59B6'
    banner2.endColor = '#8E44AD'
    banner2.icon = '🔗🔄'
    banner2.targetPage = 'MedicalRecordSyncPage'
    banner2.condition = () => hasMultipleDevices

    let banner3: BannerModel = new BannerModel()
    banner3.id = 'medical_banner_3'
    banner3.title = '智慧病房控制中心'
    banner3.subtitle = '病床/灯光/窗帘 · 一屏掌控'
    banner3.startColor = '#50C878'
    banner3.endColor = '#3DA35D'
    banner3.icon = '🏨⚙️'
    banner3.targetPage = 'SmartWardPage'
    banner3.condition = () => isInpatient

    let banner4: BannerModel = new BannerModel()
    banner4.id = 'medical_banner_4'
    banner4.title = '明日专家号源提醒'
    banner4.subtitle = '张教授 心内科 · 仅剩3个号'
    banner4.startColor = '#F39C12'
    banner4.endColor = '#E67E22'
    banner4.icon = '⏰📢'
    banner4.targetPage = 'AddAppointmentPage'
    banner4.condition = () => hasAvailableSource

    let banner5: BannerModel = new BannerModel()
    banner5.id = 'medical_banner_5'
    banner5.title = '就医全流程指南'
    banner5.subtitle = '预约→报到→就诊→取药·一步到位'
    banner5.startColor = '#1ABC9C'
    banner5.endColor = '#16A085'
    banner5.icon = '📋✅'
    banner5.targetPage = 'MedicalGuidePage'
    banner5.condition = () => now - registerTime <= 7 * 24 * 60 * 60 * 1000

    this.bannerList = [banner1, banner2, banner3, banner4, banner5]
    return this.bannerList
  }
}
