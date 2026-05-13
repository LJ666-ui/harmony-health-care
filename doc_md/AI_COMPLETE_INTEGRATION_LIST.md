# 🤖 AI完整集成清单 - 所有页面

> **项目**: Harmony Health Care - 智慧康养多设备协同平台  
> **版本**: v1.0  
> **日期**: 2026-05-13  
> **状态**: 进行中（8/150+ 页面已完成）

---

## 📊 当前进度总览

| 类别 | 总页面数 | 已集成AI | 待集成 | 完成率 |
|------|----------|----------|--------|--------|
| **核心AI页面** | 8 | 8 | 0 | ✅ 100% |
| **健康评估** | 5 | 1 | 4 | 20% |
| **康复训练** | 4 | 0 | 4 | 0% |
| **健康记录** | 5 | 0 | 5 | 0% |
| **用药管理** | 7 | 0 | 7 | 0% |
| **医疗聊天** | 12 | 0 | 12 | 0% |
| **Watch端** | 7 | 0 | 7 | 0% |
| **家庭端** | 10 | 0 | 10 | 0% |
| **智能病房** | 6 | 0 | 6 | 0% |
| **其他功能** | 20+ | 0 | 20+ | 0% |
| **总计** | **150+** | **9** | **140+** | **6%** |

---

## ✅ 已完成集成的页面 (8个)

### 1. 核心AI功能页面
| 页面 | 文件路径 | AI功能 | 集成方式 |
|------|----------|--------|----------|
| **AI测试页** | [AITestPage.ets](../entry/src/main/ets/pages/AITestPage.ets) | 测试所有AI Agent | AIOrchestrator |
| **AI聊天页** | [AiChatPage.ets](../entry/src/main/ets/pages/AiChatPage.ets) | AI对话 | AIOrchestrator |
| **AI助手页** | [AIAssistantPage.ets](../entry/src/main/ets/pages/AIAssistantPage.ess) | AI助手问答 | AIOrchestrator |
| **语音助手** | [VoiceAssistantPage.ets](../entry/src/main/ets/pages/VoiceAssistantPage.ets) | 语音交互 | AIOrchestrator |
| **紧急求助** | [EmergencyPage.ets](../entry/src/main/ets/pages/EmergencyPage.ets) | 紧急AI指导 | AIOrchestrator |
| **图像分析** | [ImageAnalysisPage.ets](../entry/src/main/ets/pages/ImageAnalysisPage.ets) | AI影像诊断 | AIOrchestrator |
| **风险评估** | [RiskAssessmentPage.ets](../entry/src/main/ets/pages/RiskAssessmentPage.ets) | AI风险评估 | AIOrchestrator |
| **浏览历史** | [BrowseHistoryPage.ets](../entry/src/main/ets/pages/BrowseHistoryPage.ets) | AI推荐 | AIOrchestrator |

---

## 🔴 高优先级 - 待集成页面 (按功能模块)

### 📋 模块1: 健康风险评估 (5个页面)
**对应架构文档**: MindSpore Lite 端侧推理 + HiAI NPU加速

| 页面 | 文件路径 | AI功能需求 | 使用的Agent | 优先级 |
|------|----------|------------|-------------|--------|
| **风险结果页** | [RiskResultPage.ets](../entry/src/main/ets/pages/RiskResultPage.ets) | AI解读风险报告、生成建议 | MindSpore + DeepSeek | 🔴 P0 |
| **风险详情页** | [RiskDetailPage.ets](../entry/src/main/ets/pages/RiskDetailPage.ets) | AI详细分析风险因素 | DeepSeek | 🔴 P0 |
| **风险历史页** | [RiskHistoryPage.ets](../entry/src/main/ets/pages/RiskHistoryPage.ets) | AI趋势分析、预测 | MindSpore | 🔴 P0 |
| **预测报告页** | [PredictionReportPage.ets](../entry/src/main/ets/pages/PredictionReportPage.ets) | AI生成预测报告 | DeepSeek + Coze | 🟡 P1 |

#### 集成代码示例:
```typescript
// RiskResultPage.ets
import { AIOrchestrator } from '../ai/orchestrator/AIOrchestrator';

@Entry
@Component
struct RiskResultPage {
  @State riskScore: number = 72;
  @State aiAnalysis: string = '';
  @State aiSuggestions: string[] = [];
  private orchestrator: AIOrchestrator = AIOrchestrator.getInstance();
  
  async analyzeRiskWithAI() {
    const response = await this.orchestrator.process({
      type: 'text',
      content: `分析风险评估结果：评分${this.riskScore}，请给出详细解读和建议`,
      intent: 'risk_analysis'
    });
    this.aiAnalysis = response.output.content;
    this.aiSuggestions = response.suggestions || [];
  }
}
```

---

### 🏃‍♂️ 模块2: 康复训练 (4个页面)
**对应架构文档**: 小艺Skill + Coze工作流 + 3D数字孪生

| 页面 | 文件路径 | AI功能需求 | 使用的Agent | 优先级 |
|------|----------|------------|-------------|--------|
| **康复主页** | [RehabilitationPage.ets](../entry/src/main/ets/pages/RehabilitationPage.ets) | AI个性化康复方案推荐 | Coze + DeepSeek | 🔴 P0 |
| **康复列表** | [RehabListPage.ets](../entry/src/main/ets/pages/RehabListPage.ets) | AI筛选合适训练项目 | DeepSeek | 🔴 P0 |
| **3D康复训练** | [Rehab3DPage.ets](../entry/src/main/ets/pages/Rehab3DPage.ets) | AI实时动作纠正指导 | 小艺 + HiAI NPU | 🔴 P0 |
| **康复详情** | [RehabPage.ets](../entry/src/main/ets/pages/RehabPage.ets) | AI生成训练计划 | Coze | 🟡 P1 |

#### 集成代码示例:
```typescript
// Rehab3DPage.ets - AI实时动作纠正
import { AIOrchestrator } from '../ai/orchestrator/AIOrchestrator';

@Entry
@Component
struct Rehab3DPage {
  @State currentExercise: string = '肩部旋转';
  @State aiCorrection: string = '';
  @State exerciseScore: number = 0;
  private orchestrator: AIOrchestrator = AIOrchestrator.getInstance();
  
  async analyzeMovement(sensorData: number[]) {
    const response = await this.orchestrator.process({
      type: 'sensor',
      content: sensorData,
      intent: 'movement_analysis',
      metadata: {
        exercise: this.currentExercise,
        deviceType: 'phone'
      }
    });
    this.aiCorrection = response.output.content;
    this.exerciseScore = response.output.confidence * 100;
  }
}
```

---

### 📊 模块3: 健康记录 (5个页面)
**对应架构文档**: MindSpore特征提取 + DeepSeek数据分析

| 页面 | 文件路径 | AI功能需求 | 使用的Agent | 优先级 |
|------|----------|------------|-------------|--------|
| **健康记录列表** | [HealthRecords.ets](../entry/src/main/ets/pages/HealthRecords.ets) | AI智能摘要、异常标记 | MindSpore | 🔴 P0 |
| **健康记录详情** | [HealthRecordDetail.ets](../entry/src/main/ets/pages/HealthRecordDetail.ets) | AI深度解读、趋势预测 | DeepSeek | 🔴 P0 |
| **健康数据页** | [HealthPage.ets](../entry/src/main/ets/pages/HealthPage.ets) | AI实时监测分析 | MindSpore + HiAI | 🔴 P0 |
| **添加记录** | [AddHealthRecord.ets](../entry/src/main/ets/pages/AddHealthRecord.ets) | AI自动填充、异常提醒 | MindSpore | 🟡 P1 |
| **家庭健康记录** | [FamilyHealthRecords.ets](../entry/src/main/ets/pages/FamilyHealthRecords.ets) | AI家庭成员对比分析 | DeepSeek | 🟡 P1 |

#### 集成代码示例:
```typescript
// HealthRecords.ets - AI智能摘要
import { AIOrchestrator } from '../ai/orchestrator/AIOrchestrator';

@Entry
@Component
struct HealthRecords {
  @State records: HealthRecord[] = [];
  @State aiSummary: string = '';
  @State abnormalItems: string[] = [];
  private orchestrator: AIOrchestrator = AIOrchestrator.getInstance();
  
  async generateAISummary() {
    const response = await this.orchestrator.process({
      type: 'data',
      content: JSON.stringify(this.records),
      intent: 'health_summary'
    });
    this.aiSummary = response.output.content;
    // 解析异常项
    this.abnormalItems = response.suggestions || [];
  }
}
```

---

### 💊 模块4: 用药管理 (7个页面)
**对应架构文档**: Coze知识库问答 + DeepSeek用药指导

| 页面 | 文件路径 | AI功能需求 | 使用的Agent | 优先级 |
|------|----------|------------|-------------|--------|
| **用药主页** | [MedicationPage.ets](../entry/src/main/ets/pages/MedicationPage.ets) | AI用药提醒优化 | Coze | 🔴 P0 |
| **药品列表** | [Medications.ets](../entry/src/main/ets/pages/Medications.ets) | AI药物相互作用检查 | Coze | 🔴 P0 |
| **用药详情** | [MedicationDetailPage.ets](../entry/src/main/ets/pages/MedicationDetailPage.ets) | AI详细用药指导 | DeepSeek + Coze | 🔴 P0 |
| **用药提醒列表** | [MedicationReminderListPage.ets](../entry/src/main/ets/pages/MedicationReminderListPage.ets) | AI智能提醒时间建议 | Coze | 🟡 P1 |
| **编辑提醒** | [MedicationReminderEditPage.ets](../entry/src/main/ets/pages/MedicationReminderEditPage.ets) | AI剂量计算建议 | DeepSeek | 🟡 P1 |
| **护士用药** | [NurseMedicationPage.ets](../entry/src/main/ets/pages/NurseMedicationPage.ets) | AI用药审核 | DeepSeek | 🟡 P1 |
| **家庭用药** | [FamilyMedication.ets](../entry/src/main/ets/pages/FamilyMedication.ets) | AI家庭成员用药管理 | Coze | 🟡 P1 |

#### 集成代码示例:
```typescript
// Medications.ets - AI药物相互作用检查
import { AIOrchestrator } from '../ai/orchestrator/AIOrchestrator';

@Entry
@Component
struct Medications {
  @State medications: Medication[] = [];
  @State interactionWarnings: string[] = [];
  private orchestrator: AIOrchestrator = AIOrchestrator.getInstance();
  
  async checkDrugInteractions() {
    const drugNames = this.medications.map(m => m.name).join(', ');
    const response = await this.orchestrator.process({
      type: 'text',
      content: `检查以下药物的相互作用：${drugNames}`,
      intent: 'drug_interaction_check'
    });
    this.interactionWarnings = response.output.content.split('\n');
  }
}
```

---

### 👨‍⚕️ 模块5: 医疗聊天/问诊 (12个页面)
**对应架构文档**: DeepSeek多轮对话 + Coze医疗知识库

| 页面 | 文件路径 | AI功能需求 | 使用的Agent | 优先级 |
|------|----------|------------|-------------|--------|
| **医生聊天** | [DoctorChatPage.ets](../entry/src/main/ets/pages/DoctorChatPage.ets) | AI辅助诊断建议 | DeepSeek | 🔴 P0 |
| **在线问诊** | [ConsultationPage.ets](../entry/src/main/ets/pages/ConsultationPage.ets) | AI预问诊、分诊 | DeepSeek + Coze | 🔴 P0 |
| **AI问诊页** | [AiConsultationPage.ets](../entry/src/main/ets/pages/AiConsultationPage.ets) | AI全流程问诊 | DeepSeek | 🔴 P0 |
| **患者-医生聊天** | [PatientDoctorChatPage.ets](../entry/src/main/ets/pages/PatientDoctorChatPage.ets) | AI聊天辅助 | DeepSeek | 🟡 P1 |
| **医生-家庭聊天** | [DoctorFamilyChatPage.ets](../entry/src/main/ets/pages/DoctorFamilyChatPage.ets) | AI翻译、摘要 | DeepSeek | 🟡 P1 |
| **家庭-医生聊天** | [FamilyDoctorChatPage.ets](../entry/src/main/ets/pages/FamilyDoctorChatPage.ets) | AI健康咨询 | DeepSeek | 🟡 P1 |
| **患者-护士聊天** | [PatientNurseChatPage.ets](../entry/src/main/ets/pages/PatientNurseChatPage.ets) | AI护理建议 | Coze | 🟡 P1 |
| **护士聊天** | [NurseChatPage.ets](../entry/src/main/ets/pages/NurseChatPage.ets) | AI护理知识库 | Coze | 🟡 P1 |
| **家庭-护士聊天** | [FamilyNurseChatPage.ets](../entry/src/main/ets/pages/FamilyNurseChatPage.ets) | AI护理指导 | Coze | 🟡 P1 |
| **护士-家庭聊天** | [NurseFamilyChatPage.ets](../entry/src/main/ets/pages/NurseFamilyChatPage.ets) | AI沟通辅助 | DeepSeek | 🟢 P2 |
| **护士-家庭聊天2** | [NurseFamilyChatPage.ets](../entry/src/main/ets/pages/NurseFamilyChatPage.ets) | AI沟通辅助 | DeepSeek | 🟢 P2 |
| **家庭聊天列表** | [FamilyChatListPage.ets](../entry/src/main/ets/pages/FamilyChatListPage.ets) | AI消息优先级排序 | DeepSeek | 🟢 P2 |

#### 集成代码示例:
```typescript
// ConsultationPage.ets - AI预问诊
import { AIOrchestrator } from '../ai/orchestrator/AIOrchestrator';

@Entry
@Component
struct ConsultationPage {
  @State symptoms: string = '';
  @State aiPreDiagnosis: string = '';
  @State suggestedDepartment: string = '';
  private orchestrator: AIOrchestrator = AIOrchestrator.getInstance();
  
  async preDiagnoseWithAI() {
    const response = await this.orchestrator.process({
      type: 'text',
      content: `症状描述：${this.symptoms}，请进行预问诊和分诊建议`,
      intent: 'pre_diagnosis'
    });
    this.aiPreDiagnosis = response.output.content;
    this.suggestedDepartment = response.suggestions?.[0] || '';
  }
}
```

---

## 🟡 中优先级 - 待集成页面

### ⌚ 模块6: Watch端 (7个页面)
**对应架构文档**: HiAI NPU低功耗推理 + 小艺语音唤醒

| 页面 | 文件路径 | AI功能需求 | 使用的Agent | 优先级 |
|------|----------|------------|-------------|--------|
| **Watch首页** | [WatchHomePage.ets](../entry/src/main/ets/pages/WatchHomePage.ets) | AI健康概览 | MindSpore | 🟡 P1 |
| **Watch紧急** | [WatchEmergencyPage.ets](../entry/src/main/ets/pages/WatchEmergencyPage.ets) | AI跌倒检测 | MindSpore + HiAI | 🔴 P0 |
| **健康监测** | [WatchHealthMonitorPage.ets](../entry/src/main/ets/pages/WatchHealthMonitorPage.ets) | AI实时异常检测 | HiAI NPU | 🔴 P0 |
| **用药提醒** | [WatchMedicationPage.ets](../entry/src/main/ets/pages/WatchMedicationPage.ets) | AI智能提醒 | 小艺 | 🟡 P1 |
| **睡眠监测** | [WatchSleepPage.ets](../entry/src/main/ets/pages/WatchSleepPage.ets) | AI睡眠质量分析 | MindSpore | 🟡 P1 |
| **运动监测** | [WatchSportPage.ets](../entry/src/main/ets/pages/WatchSportPage.ets) | AI运动数据分析 | HiAI NPU | 🟡 P1 |
| **消息中心** | [WatchMessagePage.ets](../entry/src/main/ets/pages/WatchMessagePage.ets) | AI消息过滤 | DeepSeek | 🟢 P2 |

---

### 👨‍👩‍👧‍👦 模块7: 家庭端 (10个页面)
**对应架构文档**: DeepSeek家庭健康管理 + Coze知识库

| 页面 | 文件路径 | AI功能需求 | 使用的Agent | 优先级 |
|------|----------|------------|-------------|--------|
| **家庭首页** | [FamilyHome.ets](../entry/src/main/ets/pages/FamilyHome.ets) | AI家庭成员健康概览 | DeepSeek | 🟡 P1 |
| **家庭诊断** | [FamilyDiagnosis.ets](../entry/src/main/ets/pages/FamilyDiagnosis.ets) | AI辅助家庭诊断 | DeepSeek + Coze | 🟡 P1 |
| **家庭病历** | [FamilyMedicalRecords.ets](../entry/src/main/ets/pages/FamilyMedicalRecords.ets) | AI病历分析 | DeepSeek | 🟡 P1 |
| **家庭成员详情** | [FamilyPatientDetail.ets](../entry/src/main/ets/pages/FamilyPatientDetail.ets) | AI个性化建议 | DeepSeek | 🟡 P1 |
| **家庭医生** | [FamilyDoctorPage.ets](../entry/src/main/ets/pages/FamilyDoctorPage.ets) | AI医生推荐 | Coze | 🟡 P1 |
| **家庭用药** | [FamilyMedication.ets](../entry/src/main/ets/pages/FamilyMedication.ets) | AI用药管理 | Coze | 🟡 P1 |
| **家庭处方** | [FamilyPrescription.ets](../entry/src/main/ets/pages/FamilyPrescription.ets) | AI处方解读 | DeepSeek | 🟢 P2 |
| **家庭护士列表** | [FamilyNurseListPage.ets](../entry/src/main/ets/pages/FamilyNurseListPage.ets) | AI护士匹配 | Coze | 🟢 P2 |
| **家庭随访** | [FamilyFollowUp.ets](../entry/src/main/ets/pages/FamilyFollowUp.ets) | AI随访计划 | DeepSeek | 🟢 P2 |
| **家庭登录** | [FamilyLogin.ets](../entry/src/main/ets/pages/FamilyLogin.ets) | AI身份验证辅助 | 小艺 | 🟢 P2 |

---

### 🏥 模块8: 智能病房 (6个页面)
**对应架构文档**: IoT传感器数据 + MindSpore实时监控 + HiAI加速

| 页面 | 文件路径 | AI功能需求 | 使用的Agent | 优先级 |
|------|----------|------------|-------------|--------|
| **病房设备** | [SmartWardDevices.ets](../entry/src/main/ets/pages/SmartWardDevices.ets) | AI设备状态预测 | MindSpore | 🟡 P1 |
| **病房设备(简)** | [SmartWardDevicesSimple.ets](../entry/src/main/ets/pages/SmartWardDevicesSimple.ets) | AI简化监控 | MindSpore | 🟡 P1 |
| **护理计划** | [SmartWardCarePlan.ets](../entry/src/main/ets/pages/SmartWardCarePlan.ets) | AI护理方案生成 | DeepSeek + Coze | 🟡 P1 |
| **护理计划(简)** | [SmartWardCarePlanSimple.ets](../entry/src/main/ets/pages/SmartWardCarePlanSimple.ets) | AI简化方案 | Coze | 🟡 P1 |
| **病房警报** | [SmartWardAlerts.ets](../entry/src/main/ets/pages/SmartWardAlerts.ets) | AI异常预警 | MindSpore + HiAI | 🔴 P0 |
| **病房警报(简)** | [SmartWardAlertsSimple.ets](../entry/src/main/ets/pages/SmartWardAlertsSimple.ets) | AI简化预警 | MindSpore | 🟡 P1 |

---

## 🟢 低优先级 - 其他功能页面 (20+个)

### 导航相关
| 页面 | 文件路径 | AI功能 | 优先级 |
|------|----------|--------|--------|
| **AR导航** | [ARNavigationPage.ets](../entry/src/main/ets/pages/ARNavigationPage.ets) | AI实时路径规划+物体识别 | 🟡 P1 |
| **目的地选择** | [DestinationSelectPage.ets](../entry/src/main/ets/pages/DestinationSelectPage.ets) | AI推荐目的地 | 🟢 P2 |
| **停车列表** | [ParkingListPage.ets](../entry/src/main/ets/pages/ParkingListPage.ets) | AI停车位推荐 | 🟢 P2 |
| **找车页面** | [FindCarPage.ets](../entry/src/main/ets/pages/FindCarPage.ets) | AI寻车路径 | 🟢 P2 |

### 医院相关
| 页面 | 文件路径 | AI功能 | 优先级 |
|------|----------|--------|--------|
| **医院首页** | [HospitalPage.ets](../entry/src/main/ets/pages/HospitalPage.ets) | AI医院推荐 | 🟡 P1 |
| **医院详情** | [HospitalDetailPage.ets](../entry/src/main/ets/pages/HospitalDetailPage.ets) | AI科室推荐 | 🟡 P1 |
| **科室列表** | [DepartmentPage.ets](../entry/src/main/ets/pages/DepartmentPage.ets) | AI科室匹配 | 🟡 P1 |
| **医院科室** | [HospitalDepartmentPage.ets](../entry/src/main/ets/pages/HospitalDepartmentPage.ets) | AI医生推荐 | 🟡 P1 |
| **医生列表** | [DoctorListPage.ets](../entry/src/main/ets/pages/DoctorListPage.ets) | AI医生评分 | 🟡 P1 |

### 预约挂号
| 页面 | 文件路径 | AI功能 | 优先级 |
|------|----------|--------|--------|
| **预约页面** | [BookingPage.ets](../entry/src/main/ets/pages/BookingPage.ets) | AI智能预约时间 | 🟡 P1 |
| **预约管理** | [Appointments.ets](../entry/src/main/ets/pages/Appointments.ets) | AI预约优化 | 🟢 P2 |
| **时间选择** | [AppointmentTimeSelectPage.ets](../entry/src/main/ets/pages/AppointmentTimeSelectPage.ets) | AI最佳时间推荐 | 🟢 P2 |
| **添加预约** | [AddAppointmentPage.ets](../entry/src/main/ets/pages/AddAppointmentPage.ets) | AI预约建议 | 🟢 P2 |

### 科普知识
| 页面 | 文件路径 | AI功能 | 优先级 |
|------|----------|--------|--------|
| **科普详情** | [ScienceDetailPage.ets](../entry/src/main/ets/pages/ScienceDetailPage.ets) | AI相关知识推荐 | 🟢 P2 |
| **科普列表** | [ScienceListPage.ets](../entry/src/main/ets/pages/ScienceListPage.ets) | AI个性化推荐 | 🟢 P2 |
| **科普页面** | [SciencePage.ets](../entry/src/main/ets/pages/SciencePage.ets) | AI内容分类 | 🟢 P2 |
| **知识图谱** | [KnowledgeGraphPage.ets](../entry/src/main/ets/pages/KnowledgeGraphPage.ets) | AI知识关联 | 🟢 P2 |
| **知识探索** | [KnowledgeExplorePage.ets](../entry/src/main/ets/pages/KnowledgeExplorePage.ets) | AI智能搜索 | 🟢 P2 |

### 中医中药
| 页面 | 文件路径 | AI功能 | 优先级 |
|------|----------|--------|--------|
| **草药列表** | [HerbalListPage.ets](../entry/src/main/ets/pages/HerbalListPage.ets) | AI草药识别 | 🟢 P2 |
| **草药详情** | [HerbalDetailPage.ets](../entry/src/main/ets/pages/HerbalDetailPage.ets) | AI草药功效解析 | 🟢 P2 |
| **草药对比** | [HerbalComparePage.ets](../entry/src/main/ets/pages/HerbalComparePage.ets) | AI对比分析 | 🟢 P2 |
| **食物百科** | [FoodEncyclopediaPage.ets](../entry/src/main/ets/pages/FoodEncyclopediaPage.ets) | AI食物营养分析 | 🟢 P2 |
| **食物详情** | [FoodDetailPage.ets](../entry/src/main/ets/pages/FoodDetailPage.ets) | AI食疗建议 | 🟢 P2 |
| **每日推荐** | [DailyRecommendPage.ets](../entry/src/main/ets/pages/DailyRecommendPage.ets) | AI个性化推荐 | 🟢 P2 |

### 其他重要页面
| 页面 | 文件路径 | AI功能 | 优先级 |
|------|----------|--------|--------|
| **数字孪生** | [DigitalTwinPage.ets](../entry/src/main/ets/pages/DigitalTwinPage.ets) | AI人体模型生成 | HiAI NPU | 🟡 P1 |
| **数字孪生查看器** | [DigitalTwinViewer.ets](../entry/src/main/ets/pages/DigitalTwinViewer.ets) | AI模型渲染优化 | HiAI NPU | 🟡 P1 |
| **图像修复** | [ImageRestorationPage.ets](../entry/src/main/ets/pages/ImageRestorationPage.ets) | AI医学图像增强 | MindSpore | 🟡 P1 |
| **古代医学影像** | [AncientMedicalImgPage.ets](../entry/src/main/ets/pages/AncientMedicalImgPage.ets) | AI古籍识别 | DeepSeek | 🟢 P2 |
| **剂量计算** | [DosageCalc.ets](../entry/src/main/ets/pages/DosageCalc.ets) | AI智能剂量计算 | DeepSeek | 🟡 P1 |
| **分布式协作** | [DistributedCollaborationPage.ets](../entry/src/main/ets/pages/DistributedCollaborationPage.ets) | AI多设备协同 | 小艺 | 🟡 P1 |
| **保险页面** | [InsurancePage.ets](../entry/src/main/ets/pages/InsurancePage.ets) | AI保险产品推荐 | Coze | 🟢 P2 |
| **监测仪表盘** | [MonitoringDashboard.ets](../entry/src/main/ets/pages/MonitoringDashboard.ets) | AI实时监控 | MindSpore | 🟡 P1 |
| **统计页面** | [StatisticsPage.ets](../entry/src/main/ets/pages/StatisticsPage.ets) | AI数据分析 | DeepSeek | 🟢 P2 |
| **报告页面** | [ReportPage.ets](../entry/src/main/ets/pages/ReportPage.ets) | AI报告生成 | DeepSeek | 🟢 P2 |
| **排名页面** | [RankingPage.ets](../entry/src/main/ets/pages/RankingPage.ets) | AI排名分析 | DeepSeek | 🟢 P2 |

---

## 🎯 快速集成模板

### 标准集成步骤（适用于所有页面）

#### Step 1: 导入AIOrchestrator
```typescript
import { AIOrchestrator } from '../ai/orchestrator/AIOrchestrator';
```

#### Step 2: 添加实例和状态变量
```typescript
@Entry
@Component
struct YourPageName {
  private orchestrator: AIOrchestrator = AIOrchestrator.getInstance();
  
  @State aiResponse: string = '';
  @State aiSuggestions: string[] = [];
  @State isLoading: boolean = false;
}
```

#### Step 3: 调用AI方法
```typescript
async callAI(userInput: string, intent: string) {
  this.isLoading = true;
  try {
    const response = await this.orchestrator.process({
      type: 'text',
      content: userInput,
      intent: intent,
      metadata: {
        deviceType: 'phone',
        timestamp: Date.now()
      }
    });
    
    this.aiResponse = response.output.content;
    this.aiSuggestions = response.suggestions || [];
  } catch (error) {
    console.error('AI调用失败:', error);
    this.aiResponse = 'AI服务暂时不可用';
  } finally {
    this.isLoading = false;
  }
}
```

#### Step 4: UI展示
```typescript
Column() {
  if (this.isLoading) {
    LoadingProgress()
      .width(50)
      .height(50)
  }
  
  if (this.aiResponse) {
    Text('AI分析结果')
      .fontSize(18)
      .fontWeight(FontWeight.Bold)
    
    Text(this.aiResponse)
      .fontSize(14)
      .margin({ top: 10 })
    
    if (this.aiSuggestions.length > 0) {
      ForEach(this.aiSuggestions, (suggestion: string) => {
        Text(`• ${suggestion}`)
          .fontSize(14)
          .fontColor('#007AFF')
          .margin({ top: 5 })
      })
    }
  }
}
```

---

## 📝 Intent类型定义

根据架构文档，支持的Intent类型：

| Intent名称 | 用途 | 推荐Agent |
|------------|------|-----------|
| `health_consultation` | 健康咨询 | DeepSeek |
| `risk_analysis` | 风险分析 | MindSpore + DeepSeek |
| `risk_assessment` | 风险评估 | MindSpore |
| `medical_image_analysis` | 医学影像分析 | Coze |
| `rehabilitation_guidance` | 康复指导 | Coze + DeepSeek |
| `movement_analysis` | 动作分析 | HiAI NPU |
| `drug_interaction_check` | 药物相互作用检查 | Coze |
| `medication_guidance` | 用药指导 | DeepSeek + Coze |
| `pre_diagnosis` | 预问诊 | DeepSeek |
| `emergency_handling` | 紧急处理 | MindSpore + 小艺 |
| `health_summary` | 健康摘要 | MindSpore + DeepSeek |
| `navigation_guide` | 导航引导 | 小艺 |
| `appointment_booking` | 预约挂号 | Coze |
| `voice_command` | 语音命令 | 小艺 |
| `general_chat` | 通用对话 | DeepSeek |

---

## 🚀 下一步行动

### 立即执行 (P0 - 本周完成)
1. ✅ 集成AI到 [WatchEmergencyPage.ets](../entry/src/main/ets/pages/WatchEmergencyPage.ets) - 跌倒检测
2. ✅ 集成AI到 [WatchHealthMonitorPage.ets](../entry/src/main/ets/pages/WatchHealthMonitorPage.ets) - 实时异常检测
3. ✅ 集成AI到 [SmartWardAlerts.ets](../entry/src/main/ets/pages/SmartWardAlerts.ets) - 异常预警
4. ✅ 集成AI到 [RiskResultPage.ets](../entry/src/main/ets/pages/RiskResultPage.ets) - 风险报告解读
5. ✅ 集成AI到 [Rehab3DPage.ets](../entry/src/main/ets/pages/Rehab3DPage.ets) - 动作纠正

### 短期目标 (P1 - 两周内)
6. 集成AI到康复训练模块 (4个页面)
7. 集成AI到健康记录模块 (5个页面)
8. 集成AI到用药管理模块 (7个页面)
9. 集成AI到医疗聊天模块 (12个页面)

### 中期目标 (P2 - 一个月内)
10. 集成AI到Watch端其他页面
11. 集成AI到家庭端页面
12. 集成AI到智能病房页面
13. 集成AI到其他功能页面

---

## 📞 测试验证

每个页面集成完成后，使用 [AITestPage.ets](../entry/src/main/ets/pages/AITestPage.ets) 进行测试：

1. 打开AITestPage
2. 选择对应的Agent
3. 输入测试用例
4. 验证返回结果
5. 检查UI展示是否正常

详细测试步骤见: [AI_TESTING_GUIDE.md](./AI_TESTING_GUIDE.md)

---

## 📚 相关文档

- [AI_MULTI_AGENT_ARCHITECTURE.md](./AI_MULTI_AGENT_ARCHITECTURE.md) - 架构设计
- [AI_INTEGRATION_GUIDE.md](./AI_INTEGRATION_GUIDE.md) - 集成指南
- [AI_TESTING_GUIDE.md](./AI_TESTING_GUIDE.md) - 测试指南
- [CONTINUATION_GUIDE.md](./CONTINUATION_GUIDE.md) - 继续开发指南
- [XIAOYI_3SKILL_CONFIG_GUIDE.md](./XIAOYI_3SKILL_CONFIG_GUIDE.md) - 小艺Skill配置

---

**文档版本**: v1.0  
**最后更新**: 2026-05-13  
**作者**: AI Assistant  
**审核状态**: 待用户确认
