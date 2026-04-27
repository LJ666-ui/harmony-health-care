import { MoreServiceModel } from '../model/MoreServiceModel'

export class MoreServiceManager {
  private serviceList: MoreServiceModel[] = []

  async getMoreServices(): Promise<MoreServiceModel[]> {
    let service1: MoreServiceModel = new MoreServiceModel()
    service1.id = 'medical_guide'
    service1.name = '就诊指南'
    service1.icon = '📋'
    service1.content = '预约→报到→就诊→取药·一步到位'
    service1.targetPage = 'MedicalGuidePage'
    service1.isExpanded = false

    let service2: MoreServiceModel = new MoreServiceModel()
    service2.id = 'report_query'
    service2.name = '报告查询'
    service2.icon = '🔍'
    service2.content = '查看检查报告、检验结果'
    service2.targetPage = 'ReportQueryPage'
    service2.isExpanded = false

    let service3: MoreServiceModel = new MoreServiceModel()
    service3.id = 'expense_detail'
    service3.name = '费用明细'
    service3.icon = '💰'
    service3.content = '查看医疗费用明细'
    service3.targetPage = 'ExpenseDetailPage'
    service3.isExpanded = false

    this.serviceList = [service1, service2, service3]
    return this.serviceList
  }
}
