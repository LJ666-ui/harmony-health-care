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
    let hasMultipleDevices = (await this.userDeviceService.getUserDeviceStatus()).hasMultipleDevices
    let isInpatient = (await this.userInpatientService.getUserInpatientStatus()).isInpatient

    let service1: MedicalServiceModel = new MedicalServiceModel()
    service1.id = 'find_hospital'
    service1.name = '找医院'
    service1.icon = '🏥'
    service1.targetPage = 'FindHospitalPage'
    service1.condition = () => true

    let service2: MedicalServiceModel = new MedicalServiceModel()
    service2.id = 'appointment'
    service2.name = '预约挂号'
    service2.icon = '📅'
    service2.targetPage = 'AddAppointmentPage'
    service2.condition = () => true

    let service3: MedicalServiceModel = new MedicalServiceModel()
    service3.id = 'medication'
    service3.name = '用药管理'
    service3.icon = '💊'
    service3.targetPage = 'MedicationReminderPage'
    service3.condition = () => true

    let service4: MedicalServiceModel = new MedicalServiceModel()
    service4.id = 'ar_navigation'
    service4.name = 'AR导航'
    service4.icon = '🗺️'
    service4.targetPage = 'ARNavigationPage'
    service4.condition = () => true

    let service5: MedicalServiceModel = new MedicalServiceModel()
    service5.id = 'transfer'
    service5.name = '转院申请'
    service5.icon = '🔄'
    service5.targetPage = 'TransferApplicationPage'
    service5.condition = () => true

    let service6: MedicalServiceModel = new MedicalServiceModel()
    service6.id = 'medical_record'
    service6.name = '我的病历'
    service6.icon = '📋'
    service6.targetPage = 'MyMedicalRecordPage'
    service6.condition = () => true

    let service7: MedicalServiceModel = new MedicalServiceModel()
    service7.id = 'smart_ward'
    service7.name = '智慧病房'
    service7.icon = '🏨'
    service7.targetPage = 'SmartWardPage'
    service7.condition = () => isInpatient

    let service8: MedicalServiceModel = new MedicalServiceModel()
    service8.id = 'record_sync'
    service8.name = '病历同步'
    service8.icon = '🔗'
    service8.targetPage = 'MedicalRecordSyncPage'
    service8.condition = () => hasMultipleDevices

    let service9: MedicalServiceModel = new MedicalServiceModel()
    service9.id = 'more_services'
    service9.name = '更多服务'
    service9.icon = '⚙️'
    service9.targetPage = ''
    service9.condition = () => true

    this.serviceList = [service1, service2, service3, service4, service5, service6, service7, service8, service9]
    return this.serviceList
  }
}
