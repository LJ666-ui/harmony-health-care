import { MedicalServiceModel } from '../model/MedicalServiceModel'
import { UserDeviceServiceMock } from '../service/UserDeviceServiceMock'
import { UserInpatientServiceMock } from '../service/UserInpatientServiceMock'
import { UserDeviceService } from '../service/UserDeviceService'
import { UserInpatientService } from '../service/UserInpatientService'

export class MedicalServiceManager {
  private serviceList: MedicalServiceModel[] = []
  private userDeviceService: UserDeviceService = new UserDeviceServiceMock()
  private userInpatientService: UserInpatientService = new UserInpatientServiceMock()

  async getFilteredServices(): Promise<MedicalServiceModel[]> {
    let allServices = await this.getAllServices()
    let filteredServices: MedicalServiceModel[] = []
    for (let service of allServices) {
      if (service.condition()) {
        filteredServices.push(service)
      }
    }
    return filteredServices
  }

  private async getAllServices(): Promise<MedicalServiceModel[]> {
    let hasMultipleDevices = false
    let isInpatient = false

    try {
      hasMultipleDevices = (await this.userDeviceService.getUserDeviceStatus()).hasMultipleDevices
    } catch (error) {
      console.warn('[MedicalServiceManager] 获取设备状态失败，使用默认值:', error)
    }

    try {
      isInpatient = (await this.userInpatientService.getUserInpatientStatus()).isInpatient
    } catch (error) {
      console.warn('[MedicalServiceManager] 获取住院状态失败，使用默认值:', error)
    }

    // ===== 核心医疗服务 =====
    let service1: MedicalServiceModel = new MedicalServiceModel()
    service1.id = 'find_hospital'
    service1.name = '找医院'
    service1.icon = '🏥'
    service1.targetPage = 'HospitalPage'
    service1.condition = () => true

    let service2: MedicalServiceModel = new MedicalServiceModel()
    service2.id = 'appointment'
    service2.name = '预约挂号'
    service2.icon = '📅'
    service2.targetPage = 'AddAppointmentPage'
    service2.condition = () => true

    let service3: MedicalServiceModel = new MedicalServiceModel()
    service3.id = 'consultation'
    service3.name = '在线问诊'
    service3.icon = '👨‍⚕️'
    service3.targetPage = 'ConsultationPage'
    service3.condition = () => true

    let service4: MedicalServiceModel = new MedicalServiceModel()
    service4.id = 'medication'
    service4.name = '用药管理'
    service4.icon = '💊'
    service4.targetPage = 'MedicationReminderListPage'
    service4.condition = () => true

    let service5: MedicalServiceModel = new MedicalServiceModel()
    service5.id = 'ar_navigation'
    service5.name = 'AR导航'
    service5.icon = '🗺️'
    service5.targetPage = 'ARNavigationPage'
    service5.condition = () => true

    // ===== 健康管理服务 =====
    let service6: MedicalServiceModel = new MedicalServiceModel()
    service6.id = 'health_records'
    service6.name = '健康档案'
    service6.icon = '📝'
    service6.targetPage = 'HealthRecords'
    service6.condition = () => true

    let service7: MedicalServiceModel = new MedicalServiceModel()
    service7.id = 'transfer'
    service7.name = '转院申请'
    service7.icon = '🔄'
    service7.targetPage = 'TransferApplyPage'
    service7.condition = () => true

    let service8: MedicalServiceModel = new MedicalServiceModel()
    service8.id = 'medical_record'
    service8.name = '我的病历'
    service8.icon = '📋'
    service8.targetPage = 'MedicalRecord'
    service8.condition = () => true

    let service9: MedicalServiceModel = new MedicalServiceModel()
    service9.id = 'prescription'
    service9.name = '处方管理'
    service9.icon = '💉'
    service9.targetPage = 'PrescriptionPage'
    service9.condition = () => true

    // ===== 智能应用服务 ⭐真实数据 =====
    let service10: MedicalServiceModel = new MedicalServiceModel()
    service10.id = 'smart_ward'
    service10.name = '智慧病房'
    service10.icon = '🏨'
    service10.targetPage = 'SmartWardDevicesSimple'
    service10.condition = () => isInpatient

    let service11: MedicalServiceModel = new MedicalServiceModel()
    service11.id = 'parking'
    service11.name = '智慧停车'
    service11.icon = '🅿️'
    service11.targetPage = 'ParkingListPage'
    service11.condition = () => true

    let service12: MedicalServiceModel = new MedicalServiceModel()
    service12.id = 'digital_twin'
    service12.name = '数字孪生'
    service12.icon = '🫀'
    service12.targetPage = 'DigitalTwinPage'
    service12.condition = () => true

    // ===== 数据与协同服务 =====
    let service13: MedicalServiceModel = new MedicalServiceModel()
    service13.id = 'record_sync'
    service13.name = '病历同步'
    service13.icon = '🔗'
    service13.targetPage = 'MedicalRecordSyncPage'
    service13.condition = () => hasMultipleDevices

    let service14: MedicalServiceModel = new MedicalServiceModel()
    service14.id = 'distributed'
    service14.name = '跨院协同'
    service14.icon = '🔗'
    service14.targetPage = 'DistributedCollaborationPage'
    service14.condition = () => true

    let service15: MedicalServiceModel = new MedicalServiceModel()
    service15.id = 'family_doctor'
    service15.name = '家庭医生'
    service15.icon = '🏥'
    service15.targetPage = 'FamilyDoctorPage'
    service15.condition = () => true

    let service16: MedicalServiceModel = new MedicalServiceModel()
    service16.id = 'more_services'
    service16.name = '更多服务'
    service16.icon = '⚙️'
    service16.targetPage = ''
    service16.condition = () => true

    this.serviceList = [service1, service2, service3, service4, service5, service6, service7, service8, service9, service10, service11, service12, service13, service14, service15, service16]
    return this.serviceList
  }
}
