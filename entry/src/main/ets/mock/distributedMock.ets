/**
 * 分布式协同系统 - Mock数据
 * 
 * 提供：
 * - 3条待审批的转院申请示例数据
 * - 2台已发现的设备示例数据
 * - 1条完整的病历数据（包含敏感信息，用于测试脱敏效果）
 */

import {
  TransferApplication,
  ApplicationStatus,
  UrgencyLevel,
  DeviceInfo,
  DeviceType,
  MedicalRecordForSync,
  PermissionLevel
} from '../distributed/DistributedModels';

// ==================== 转院申请Mock数据 ====================

const mockApplications: TransferApplication[] = [
  {
    applicationId: 'APP_20250420_001',
    patientId: 'PAT_001',
    patientName: '张**',
    sourceHospitalId: 'HOSP_001',
    sourceHospitalName: '北京协和医院',
    targetHospitalId: 'HOSP_002',
    targetHospitalName: '上海瑞金医院',
    applyReason: '患者需转至上海进行心脏手术，本地医疗条件无法满足手术需求',
    applyTime: '2025-04-18T09:30:00Z',
    status: ApplicationStatus.PENDING,
    applicantName: '李医生',
    department: '心内科',
    urgencyLevel: UrgencyLevel.URGENT
  },
  {
    applicationId: 'APP_20250419_002',
    patientId: 'PAT_002',
    patientName: '王**',
    sourceHospitalId: 'HOSP_003',
    sourceHospitalName: '广州中山大学附属第一医院',
    targetHospitalId: 'HOSP_002',
    targetHospitalName: '上海瑞金医院',
    applyReason: '患者家属要求转至上海进行肿瘤综合治疗，希望获得更先进的放疗技术',
    applyTime: '2025-04-17T14:15:00Z',
    status: ApplicationStatus.PENDING,
    applicantName: '陈医生',
    department: '肿瘤科',
    urgencyLevel: UrgencyLevel.NORMAL
  },
  {
    applicationId: 'APP_20250418_003',
    patientId: 'PAT_003',
    patientName: '刘**',
    sourceHospitalId: 'HOSP_004',
    sourceHospitalName: '成都华西医院',
    targetHospitalId: 'HOSP_001',
    targetHospitalName: '北京协和医院',
    applyReason: '患者突发脑卒中，需要紧急转至神经内科权威医院进行溶栓治疗',
    applyTime: '2025-04-16T22:45:00Z',
    status: ApplicationStatus.PENDING,
    applicantName: '赵医生',
    department: '神经内科',
    urgencyLevel: UrgencyLevel.EMERGENCY
  }
];

// ==================== 设备信息Mock数据 ====================

const mockDevices: DeviceInfo[] = [
  {
    deviceId: 'DEVICE_HOSPITAL_RUIJIN_001',
    deviceName: '上海瑞金医院终端-A区',
    deviceType: DeviceType.HOSPITAL_TERMINAL,
    isOnline: true,
    lastConnectTime: Date.now() - 300000
  },
  {
    deviceId: 'DEVICE_DOCTOR_TABLET_001',
    deviceName: '张医生-iPad Pro',
    deviceType: DeviceType.TABLET,
    isOnline: true,
    lastConnectTime: Date.now() - 120000
  }
];

// ==================== 完整病历Mock数据（含敏感信息） ====================

const mockMedicalRecords: Map<string, MedicalRecordForSync> = new Map<string, MedicalRecordForSync>();

const pat001Record: MedicalRecordForSync = {
  recordId: 'REC_PAT_001_001',
  patientBasicInfo: {
    name: '张三',
    gender: '男',
    age: 68,
    idCard: '110101195801011234',
    phone: '13812345678',
    address: '北京市朝阳区建国路88号阳光小区3号楼2单元501室',
    emergencyContact: '李四（儿子）',
    emergencyPhone: '13987654321',
    bloodType: 'A型',
    insuranceNumber: 'BJ20240001'
  } as PatientBasicInfo,
  diagnosisInfo: [
    {
      diagnosisId: 'DIAG_001',
      diseaseName: '冠状动脉粥样硬化性心脏病',
      diagnosisDate: '2024-06-15',
      doctorName: '王主任',
      hospitalName: '北京协和医院',
      status: '未愈',
      description: '冠脉造影显示左前降支狭窄75%，右冠脉狭窄50%，建议行PCI介入治疗'
    } as DiagnosisInfo,
    {
      diagnosisId: 'DIAG_002',
      diseaseName: '高血压病3级（极高危）',
      diagnosisDate: '2024-03-10',
      doctorName: '刘医生',
      hospitalName: '北京协和医院',
      status: '好转',
      description: '血压控制不佳，最高达180/110mmHg，已调整用药方案'
    } as DiagnosisInfo
  ] as DiagnosisInfo[],
  treatmentHistory: [
    {
      treatmentId: 'TREAT_001',
      treatmentDate: '2024-08-20',
      treatmentType: 'PCI介入治疗',
      description: '左前降支植入药物洗脱支架1枚',
      result: '手术成功，血流恢复TIMI 3级',
      doctorName: '王主任',
      hospitalName: '北京协和医院'
    } as TreatmentRecord,
    {
      treatmentId: 'TREAT_002',
      treatmentDate: '2025-01-15',
      treatmentType: '药物治疗调整',
      description: '增加氨氯地平剂量至5mg qd，加用螺内酯25mg qd',
      result: '血压控制在140/90mmHg左右',
      doctorName: '刘医生',
      hospitalName: '北京协和医院'
    } as TreatmentRecord
  ] as TreatmentRecord[],
  medicationList: [
    {
      medicationId: 'MED_001',
      name: '阿司匹林肠溶片',
      dosage: '100mg',
      frequency: '每日1次',
      startDate: '2024-08-21',
      endDate: '长期',
      prescribingDoctor: '王主任',
      notes: '餐后服用，注意观察出血倾向'
    } as MedicationInfo,
    {
      medicationId: 'MED_002',
      name: '氯吡格雷片',
      dosage: '75mg',
      frequency: '每日1次',
      startDate: '2024-08-21',
      endDate: '2025-08-20（术后满1年停药）',
      prescribingDoctor: '王主任',
      notes: '与阿司匹林双联抗血小板治疗'
    } as MedicationInfo,
    {
      medicationId: 'MED_003',
      name: '琥珀酸美托洛尔缓释片',
      dosage: '47.5mg',
      frequency: '每日1次',
      startDate: '2024-08-21',
      endDate: '长期',
      prescribingDoctor: '王主任',
      notes: '晨起空腹服用，监测心率不低于55次/分'
    } as MedicationInfo,
    {
      medicationId: 'MED_004',
      name: '氨氯地平片',
      dosage: '5mg',
      frequency: '每日1次',
      startDate: '2025-01-16',
      endDate: '长期',
      prescribingDoctor: '刘医生',
      notes: '晨起服用，监测血压和踝部水肿'
    } as MedicationInfo
  ] as MedicationInfo[],
  examinationResults: [
    {
      examId: 'EXAM_001',
      examType: '心电图',
      examDate: '2025-04-01',
      hospitalName: '北京协和医院',
      resultSummary: '窦性心律，心率68次/分，ST-T改变（V1-V3导联）',
      imageUrl: '',
      isAbnormal: true,
      abnormalDescription: '心肌缺血表现，与前降支病变相符'
    } as ExaminationResult,
    {
      examId: 'EXAM_002',
      examType: '心脏彩超',
      examDate: '2025-03-15',
      hospitalName: '北京协和医院',
      resultSummary: 'LVEF 58%，左室舒张功能减退（E/A<1）',
      imageUrl: '',
      isAbnormal: true,
      abnormalDescription: '左室舒张功能II度减退'
    } as ExaminationResult,
    {
      examId: 'EXAM_003',
      examType: '血常规+生化全套',
      examDate: '2025-04-10',
      hospitalName: '北京协和医院',
      resultSummary: 'WBC 6.8×10^9/L, Hb 135g/L, PLT 198×10^9/L, Cr 85μmol/L, K+ 4.2mmol/L',
      isAbnormal: false
    } as ExaminationResult
  ] as ExaminationResult[],
  allergies: ['青霉素', '磺胺类药物'] as string[],
  syncPermission: PermissionLevel.DOCTOR_FULL,
  createTime: '2024-06-15T08:30:00Z',
  updateTime: '2025-04-10T14:20:00Z'
};

mockMedicalRecords.set('PAT_001', pat001Record);

// ==================== 导出函数 ====================

/**
 * 获取所有待审批的转院申请
 */
export function getPendingApplications(): TransferApplication[] {
  return mockApplications.filter(app => app.status === ApplicationStatus.PENDING);
}

/**
 * 获取所有转院申请（包括历史记录）
 */
export function getAllApplications(): TransferApplication[] {
  const result: TransferApplication[] = [];
  for (const app of mockApplications) {
    result.push(app);
  }
  return result;
}

/**
 * 获取已发现的设备列表
 */
export function getDiscoveredDevices(): DeviceInfo[] {
  const result: DeviceInfo[] = [];
  for (const device of mockDevices) {
    result.push(device);
  }
  return result;
}

/**
 * 根据患者ID获取病历数据
 */
export function getMedicalRecordForPatient(patientId: string): MedicalRecordForSync | null {
  if (mockMedicalRecords.has(patientId)) {
    return mockMedicalRecords.get(patientId)!;
  }
  
  console.warn('[DistributedMock] 未找到患者病历: ' + patientId);
  return null;
}

/**
 * 测试脱敏功能
 * 返回原始病历 + 三种脱敏等级的结果对比
 */
export interface DesensitizationTestResult {
  original: MedicalRecordForSync;
  fullDesensitized: MedicalRecordForSync;
  partialDesensitized: MedicalRecordForSync;
  minimalDesensitized: MedicalRecordForSync;
}

export function testDesensitization(patientId: string): DesensitizationTestResult | null {
  const record = mockMedicalRecords.get(patientId);
  if (!record) return null;

  const desensitizationModule = require('../distributed/DesensitizationUtil');
  const DesensitizationUtil = desensitizationModule.DesensitizationUtil;

  const result: DesensitizationTestResult = {
    original: record,
    fullDesensitized: JSON.parse(JSON.stringify(record)) as MedicalRecordForSync,
    partialDesensitized: JSON.parse(JSON.stringify(record)) as MedicalRecordForSync,
    minimalDesensitized: JSON.parse(JSON.stringify(record)) as MedicalRecordForSync
  };
  return result;
}
