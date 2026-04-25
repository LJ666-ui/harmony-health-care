import { DeviceInfo, TransferApplication, MedicalRecordData, LabResult, ImagingReport, DeviceType, TransferStatus } from '../models/DistributedModels';

export const mockDevices: DeviceInfo[] = [
  {
    deviceId: 'device_001_hospital_a',
    deviceName: '协和医院终端-A',
    deviceType: DeviceType.HOSPITAL_TERMINAL,
    isOnline: true,
    lastConnectTime: Date.now() - 300000
  },
  {
    deviceId: 'device_002_hospital_b',
    deviceName: '同济医院终端-B',
    deviceType: DeviceType.HOSPITAL_TERMINAL,
    isOnline: true,
    lastConnectTime: Date.now() - 600000
  }
];

export const mockTransferApplications: TransferApplication[] = [
  {
    applicationId: 'TA20260424001',
    patientId: 'P001',
    patientName: '张三',
    sourceHospitalId: 'H001',
    sourceHospitalName: '市第一人民医院',
    targetHospitalId: 'H002',
    targetHospitalName: '协和医院',
    reason: '病情需要更专业的神经外科治疗，患者诊断为脑胶质瘤，需要进行微创手术',
    status: TransferStatus.PENDING,
    submitTime: Date.now() - 86400000,
    medicalRecordId: 'MR20260420001'
  },
  {
    applicationId: 'TA20260424002',
    patientId: 'P002',
    patientName: '李四',
    sourceHospitalId: 'H001',
    sourceHospitalName: '市第一人民医院',
    targetHospitalId: 'H003',
    targetHospitalName: '同济医院',
    reason: '患者心脏瓣膜病变严重，需要心胸外科专家会诊及手术治疗',
    status: TransferStatus.PENDING,
    submitTime: Date.now() - 172800000,
    medicalRecordId: 'MR20260418001'
  },
  {
    applicationId: 'TA20260424003',
    patientId: 'P003',
    patientName: '王五',
    sourceHospitalId: 'H004',
    sourceHospitalName: '省中医院',
    targetHospitalId: 'H002',
    targetHospitalName: '协和医院',
    reason: '患者糖尿病并发症严重，需要内分泌科和肾内科联合诊疗',
    status: TransferStatus.PENDING,
    submitTime: Date.now() - 259200000,
    medicalRecordId: 'MR20260415001'
  }
];

export const mockMedicalRecord: MedicalRecordData = {
  recordId: 'MR20260420001',
  patientId: 'P001',
  patientName: '张三',
  idCard: '110101199001011234',
  phone: '13812345678',
  address: '北京市东城区帅府园1号3号楼2单元501室',
  diagnosis: '脑胶质瘤（WHO III级），位于左侧额叶，大小约3.5cm×2.8cm',
  treatmentPlan: '建议行显微镜下肿瘤切除术，术后辅以放疗和化疗。术前需完善相关检查，评估手术风险。',
  medications: [
    '甘露醇注射液 125ml ivgtt q8h',
    '地塞米松磷酸钠注射液 5mg ivgtt qd',
    '丙戊酸钠缓释片 0.5g po bid'
  ],
  labResults: [
    {
      id: 'LAB001',
      testName: '血常规',
      resultValue: 'WBC 12.3×10^9/L',
      unit: '×10^9/L',
      referenceRange: '3.5-9.5',
      testDate: '2026-04-20',
      isAbnormal: true
    },
    {
      id: 'LAB002',
      testName: '肝功能',
      resultValue: 'ALT 45 U/L',
      unit: 'U/L',
      referenceRange: '9-50',
      testDate: '2026-04-20',
      isAbnormal: false
    },
    {
      id: 'LAB003',
      testName: '肾功能',
      resultValue: 'Cr 78 μmol/L',
      unit: 'μmol/L',
      referenceRange: '57-111',
      testDate: '2026-04-20',
      isAbnormal: false
    }
  ],
  imagingReports: [
    {
      id: 'IMG001',
      reportType: '头部MRI',
      reportUrl: '/storage/images/mri_brain_001.dcm',
      description: '左侧额叶可见不规则异常信号影，T1WI呈低信号，T2WI呈高信号，周围可见水肿带。',
      conclusion: '左侧额叶占位性病变，考虑胶质瘤可能性大，建议进一步检查明确诊断。',
      reportDate: '2026-04-19'
    },
    {
      id: 'IMG002',
      reportType: '头部CT',
      reportUrl: '/storage/images/ct_brain_001.dcm',
      description: '左侧额叶可见高密度结节影，边界欠清，周围低密度水肿带，中线结构无明显移位。',
      conclusion: '颅内占位性病变，结合MRI考虑胶质瘤。',
      reportDate: '2026-04-18'
    }
  ],
  createTime: Date.now() - 345600000,
  updateTime: Date.now() - 86400000,
  hospitalId: 'H001',
  hospitalName: '市第一人民医院',
  doctorId: 'D001',
  doctorName: '王医生'
};

export function getMockDevices(): DeviceInfo[] {
  return mockDevices;
}

export function getMockTransferApplications(): TransferApplication[] {
  return mockTransferApplications;
}

export function getMockMedicalRecord(): MedicalRecordData {
  return mockMedicalRecord;
}

export function getMockDeviceById(deviceId: string): DeviceInfo | undefined {
  for (let i = 0; i < mockDevices.length; i++) {
    if (mockDevices[i].deviceId === deviceId) {
      return mockDevices[i];
    }
  }
  return undefined;
}

export function getMockTransferApplicationById(applicationId: string): TransferApplication | undefined {
  for (let i = 0; i < mockTransferApplications.length; i++) {
    if (mockTransferApplications[i].applicationId === applicationId) {
      return mockTransferApplications[i];
    }
  }
  return undefined;
}
