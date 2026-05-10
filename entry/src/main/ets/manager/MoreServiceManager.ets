import { MoreServiceModel } from '../model/MoreServiceModel'

export class MoreServiceManager {
  private serviceList: MoreServiceModel[] = []

  async getMoreServices(): Promise<MoreServiceModel[]> {
    // ===== 就诊指南与报告 =====
    let service1: MoreServiceModel = new MoreServiceModel()
    service1.id = 'medical_guide'
    service1.name = '就诊指南'
    service1.icon = '📋'
    service1.content = '预约→报到→就诊→取药·一步到位'
    service1.targetPage = 'MedicalPage'
    service1.isExpanded = false

    let service2: MoreServiceModel = new MoreServiceModel()
    service2.id = 'report_query'
    service2.name = '报告查询'
    service2.icon = '🔍'
    service2.content = '查看检查报告、检验结果'
    service2.targetPage = 'ReportPage'
    service2.isExpanded = false

    let service3: MoreServiceModel = new MoreServiceModel()
    service3.id = 'expense_detail'
    service3.name = '费用明细'
    service3.icon = '💰'
    service3.content = '查看医疗费用明细'
    service3.targetPage = 'StatisticsPage'
    service3.isExpanded = false

    // ===== 健康管理工具 =====
    let service4: MoreServiceModel = new MoreServiceModel()
    service4.id = 'risk_assessment'
    service4.name = '风险评估'
    service4.icon = '⚠️'
    service4.content = 'AI智能健康风险评估与预测'
    service4.targetPage = 'RiskAssessmentPage'
    service4.isExpanded = false

    let service5: MoreServiceModel = new MoreServiceModel()
    service5.id = 'rehab_3d'
    service5.name = '3D康复训练'
    service5.icon = '🧘'
    service5.content = '沉浸式康复动作指导'
    service5.targetPage = 'Rehab3DPage'
    service5.isExpanded = false

    let service6: MoreServiceModel = new MoreServiceModel()
    service6.id = 'dosage_calc'
    service6.name = '用药计算'
    service6.icon = '💊'
    service6.content = '精准药物剂量计算器'
    service6.targetPage = 'DosageCalc'
    service6.isExpanded = false

    // ===== 中医与营养 =====
    let service7: MoreServiceModel = new MoreServiceModel()
    service7.id = 'herbal encyclopedia'
    service7.name = '中医百科'
    service7.icon = '🌿'
    service7.content = '中草药知识库与功效查询'
    service7.targetPage = 'HerbalListPage'
    service7.isExpanded = false

    let service8: MoreServiceModel = new MoreServiceModel()
    service8.id = 'food_nutrition'
    service8.name = '食物营养'
    service8.icon = '🍎'
    service8.content = '食物营养成分与健康建议'
    service8.targetPage = 'FoodEncyclopediaPage'
    service8.isExpanded = false

    let service9: MoreServiceModel = new MoreServiceModel()
    service9.id = 'herbal_compare'
    service9.name = '中药对比'
    service9.icon = '⚖️'
    service9.content = '多维度中药材对比分析'
    service9.targetPage = 'HerbalComparePage'
    service9.isExpanded = false

    // ===== 智能应用 ⭐真实数据 =====
    let service10: MoreServiceModel = new MoreServiceModel()
    service10.id = 'smart_parking'
    service10.name = '智慧停车'
    service10.icon = '🅿️'
    service10.content = '车位查询·AR寻车·无感支付'
    service10.targetPage = 'ParkingListPage'
    service10.isExpanded = false

    let service11: MoreServiceModel = new MoreServiceModel()
    service11.id = 'voice_assistant'
    service11.name = '语音助手'
    service11.icon = '🎤'
    service11.content = '语音控制与智能问答'
    service11.targetPage = 'VoiceAssistantPage'
    service11.isExpanded = false

    let service12: MoreServiceModel = new MoreServiceModel()
    service12.id = 'ai_chat'
    service12.name = 'AI聊天'
    service12.icon = '🤖'
    service12.content = 'AI智能对话与咨询'
    service12.targetPage = 'AiChatPage'
    service12.isExpanded = false

    // ===== 知识与发现 =====
    let service13: MoreServiceModel = new MoreServiceModel()
    service13.id = 'knowledge_graph'
    service13.name = '知识图谱'
    service13.icon = '🧠'
    service13.content = '医学知识关联网络探索'
    service13.targetPage = 'KnowledgeGraphPage'
    service13.isExpanded = false

    let service14: MoreServiceModel = new MoreServiceModel()
    service14.id = 'knowledge_explore'
    service14.name = '知识探索'
    service14.icon = '🔬'
    service14.content = '交互式医学知识发现'
    service14.targetPage = 'KnowledgeExplorePage'
    service14.isExpanded = false

    let service15: MoreServiceModel = new MoreServiceModel()
    service15.id = 'ancient_medical'
    service15.name = '古医图谱'
    service15.icon = '📜'
    service15.content = '千年古医AI高清复原'
    service15.targetPage = 'AncientMedicalImgPage'
    service15.isExpanded = false

    // ===== 数据与设备 =====
    let service16: MoreServiceModel = new MoreServiceModel()
    service16.id = 'device_manage'
    service16.name = '设备管理'
    service16.icon = '📱'
    service16.content = '多设备连接与管理'
    service16.targetPage = 'DeviceManagePage'
    service16.isExpanded = false

    let service17: MoreServiceModel = new MoreServiceModel()
    service17.id = 'data_auth'
    service17.name = '数据授权'
    service17.icon = '🔐'
    service17.content = '隐私设置与数据权限管理'
    service17.targetPage = 'DataAuthPage'
    service17.isExpanded = false

    let service18: MoreServiceModel = new MoreServiceModel()
    service18.id = 'medical_imaging'
    service18.name = '医学影像'
    service18.icon = '🔬'
    service18.content = '医学影像AI分析与诊断'
    service18.targetPage = 'ImageAnalysisPage'
    service18.isExpanded = false

    let service19: MoreServiceModel = new MoreServiceModel()
    service19.id = 'image_restore'
    service19.name = '图像修复'
    service19.icon = '🖼️'
    service19.content = '古老医学图像AI复原增强'
    service19.targetPage = 'ImageRestorationPage'
    service19.isExpanded = false

    // ===== 社交与历史 =====
    let service20: MoreServiceModel = new MoreServiceModel()
    service20.id = 'browse_history'
    service20.name = '浏览历史'
    service20.icon = '🕐'
    service20.content = '查看最近浏览的内容记录'
    service20.targetPage = 'BrowseHistoryPage'
    service20.isExpanded = false

    this.serviceList = [service1, service2, service3, service4, service5, service6, service7, service8, service9, service10, service11, service12, service13, service14, service15, service16, service17, service18, service19, service20]
    return this.serviceList
  }
}
