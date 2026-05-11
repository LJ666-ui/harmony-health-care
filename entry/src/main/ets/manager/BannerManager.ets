import { BannerModel } from '../model/BannerModel'
import { AiConsultationServiceMock } from '../service/AiConsultationServiceMock'
import { LocationServiceMock } from '../service/LocationServiceMock'
import { DigitalTwinServiceMock } from '../service/DigitalTwinServiceMock'
import { AiConsultationService } from '../service/AiConsultationService'
import { LocationService } from '../service/LocationService'
import { DigitalTwinService } from '../service/DigitalTwinService'
import { UserDeviceServiceMock } from '../service/UserDeviceServiceMock'
import { UserInpatientServiceMock } from '../service/UserInpatientServiceMock'
import { UserDeviceService } from '../service/UserDeviceService'
import { UserInpatientService } from '../service/UserInpatientService'

export class BannerManager {
  private bannerList: BannerModel[] = []
  private aiConsultationService: AiConsultationService = new AiConsultationServiceMock()
  private locationService: LocationService = new LocationServiceMock()
  private digitalTwinService: DigitalTwinService = new DigitalTwinServiceMock()
  private userDeviceService: UserDeviceService = new UserDeviceServiceMock()
  private userInpatientService: UserInpatientService = new UserInpatientServiceMock()

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
    let aiUsed = false
    let location = null
    let digitalTwinReleaseTime = 0
    let hasMultipleDevices = false
    let isInpatient = false

    try {
      aiUsed = (await this.aiConsultationService.checkAiConsultationUsed()).used
    } catch (error) {
      console.warn('[BannerManager] 获取AI问诊状态失败，使用默认值:', error)
    }

    try {
      location = await this.locationService.getUserLocation()
    } catch (error) {
      console.warn('[BannerManager] 获取位置信息失败，使用默认值:', error)
    }

    try {
      digitalTwinReleaseTime = (await this.digitalTwinService.getDigitalTwinReleaseTime()).releaseTime
    } catch (error) {
      console.warn('[BannerManager] 获取数字孪生发布时间失败，使用默认值:', error)
    }

    try {
      hasMultipleDevices = (await this.userDeviceService.getUserDeviceStatus()).hasMultipleDevices
    } catch (error) {
      console.warn('[BannerManager] 获取设备状态失败，使用默认值:', error)
    }

    try {
      isInpatient = (await this.userInpatientService.getUserInpatientStatus()).isInpatient
    } catch (error) {
      console.warn('[BannerManager] 获取住院状态失败，使用默认值:', error)
    }

    let now = Date.now()
    let date = new Date()
    let dayOfWeek = date.getDay()
    let month = date.getMonth() + 1
    let season = ''
    if (month >= 3 && month <= 5) {
      season = '春季'
    } else if (month >= 6 && month <= 8) {
      season = '夏季'
    } else if (month >= 9 && month <= 11) {
      season = '秋季'
    } else {
      season = '冬季'
    }

    // ===== 核心功能推广 =====
    let banner1: BannerModel = new BannerModel()
    banner1.id = 'banner_1'
    banner1.title = 'AI智能体全流程问诊'
    banner1.subtitle = '多智能体会诊 · 24小时在线'
    banner1.startColor = '#9B59B6'
    banner1.endColor = '#8E44AD'
    banner1.icon = '🤖'
    banner1.targetPage = 'AiConsultationPage'
    banner1.condition = () => !aiUsed

    let banner2: BannerModel = new BannerModel()
    banner2.id = 'banner_2'
    banner2.title = season + '健康体检特惠'
    banner2.subtitle = '限时8折 · 专家一对一解读'
    banner2.startColor = '#50C878'
    banner2.endColor = '#3DA35D'
    let seasonIcon = ''
    if (season === '春季') {
      seasonIcon = '🌸'
    } else if (season === '夏季') {
      seasonIcon = '☀️'
    } else if (season === '秋季') {
      seasonIcon = '🍂'
    } else {
      seasonIcon = '❄️'
    }
    banner2.icon = seasonIcon
    banner2.targetPage = 'MedicalPage'
    banner2.condition = () => true

    // ===== 智能应用 ⭐真实数据 =====
    let banner3: BannerModel = new BannerModel()
    banner3.id = 'banner_3'
    banner3.title = '患者数字孪生系统'
    banner3.subtitle = '3D身体模型 · 可视化健康数据'
    banner3.startColor = '#4A90E2'
    banner3.endColor = '#357ABD'
    banner3.icon = '👤🔄'
    banner3.targetPage = 'DigitalTwinPage'
    banner3.condition = () => now - digitalTwinReleaseTime <= 30 * 24 * 60 * 60 * 1000

    let banner4: BannerModel = new BannerModel()
    banner4.id = 'banner_4'
    banner4.title = '院内智慧停车'
    banner4.subtitle = '车位查询 · AR寻车 · 无感支付'
    banner4.startColor = '#F39C12'
    banner4.endColor = '#E67E22'
    banner4.icon = '🅿️'
    banner4.targetPage = 'ParkingListPage'  // 修正为实际存在的页面
    banner4.condition = () => true  // 启用显示

    let banner5: BannerModel = new BannerModel()
    banner5.id = 'banner_5'
    banner5.title = '千年古医图谱AI复原'
    banner5.subtitle = '高清重现 · 智能识别 · 文化传承'
    banner5.startColor = '#1ABC9C'
    banner5.endColor = '#16A085'
    banner5.icon = '📜'
    banner5.targetPage = 'AncientMedicalImgPage'
    banner5.condition = () => dayOfWeek === 5 || dayOfWeek === 6  // 周五或周六

    // ===== 新增功能推广 =====
    let banner6: BannerModel = new BannerModel()
    banner6.id = 'banner_6'
    banner6.title = '智慧病房控制系统'
    banner6.subtitle = '病床/灯光/窗帘 · 一屏掌控'
    banner6.startColor = '#27AE60'
    banner6.endColor = '#229954'
    banner6.icon = '🏨⚙️'
    banner6.targetPage = 'SmartWardDevicesSimple'
    banner6.condition = () => isInpatient ?? false  // 仅住院患者可见

    let banner7: BannerModel = new BannerModel()
    banner7.id = 'banner_7'
    banner7.title = 'AR院内导航'
    banner7.subtitle = '实时定位 · 智能路径规划'
    banner7.startColor = '#E67E22'
    banner7.endColor = '#D35400'
    banner7.icon = '🗺️'
    banner7.targetPage = 'ARNavigationPage'
    banner7.condition = () => location !== null && location !== undefined  // 有位置信息时显示

    let banner8: BannerModel = new BannerModel()
    banner8.id = 'banner_8'
    banner8.title = '跨院医疗协同'
    banner8.subtitle = '数据共享 · 远程会诊 · 转诊绿色通道'
    banner8.startColor = '#3498DB'
    banner8.endColor = '#2980B9'
    banner8.icon = '🔗'
    banner8.targetPage = 'DistributedCollaborationPage'
    banner8.condition = () => hasMultipleDevices ?? false  // 多设备用户可见

    this.bannerList = [banner1, banner2, banner3, banner4, banner5, banner6, banner7, banner8]
    return this.bannerList
  }
}
