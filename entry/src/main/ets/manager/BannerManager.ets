import { BannerModel } from '../model/BannerModel'
import { AiConsultationServiceMock } from '../service/AiConsultationServiceMock'
import { LocationServiceMock } from '../service/LocationServiceMock'
import { DigitalTwinServiceMock } from '../service/DigitalTwinServiceMock'
import { AiConsultationService } from '../service/AiConsultationService'
import { LocationService } from '../service/LocationService'
import { DigitalTwinService } from '../service/DigitalTwinService'

export class BannerManager {
  private bannerList: BannerModel[] = []
  private aiConsultationService: AiConsultationService = new AiConsultationServiceMock()
  private locationService: LocationService = new LocationServiceMock()
  private digitalTwinService: DigitalTwinService = new DigitalTwinServiceMock()

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
    let aiUsed = (await this.aiConsultationService.checkAiConsultationUsed()).used
    let location = await this.locationService.getUserLocation()
    let digitalTwinReleaseTime = (await this.digitalTwinService.getDigitalTwinReleaseTime()).releaseTime
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
    banner4.targetPage = 'ParkingLotPage'
    banner4.condition = () => false  // 暂时不显示

    let banner5: BannerModel = new BannerModel()
    banner5.id = 'banner_5'
    banner5.title = '千年古医图谱AI复原'
    banner5.subtitle = '高清重现 · 智能识别 · 文化传承'
    banner5.startColor = '#1ABC9C'
    banner5.endColor = '#16A085'
    banner5.icon = '📜'
    banner5.targetPage = 'AncientMedicalImgPage'
    banner5.condition = () => dayOfWeek === 5 || dayOfWeek === 6  // 周五或周六

    this.bannerList = [banner1, banner2, banner3, banner4, banner5]
    return this.bannerList
  }
}
