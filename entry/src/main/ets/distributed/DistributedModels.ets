/**
 * 分布式数据协同系统 - 数据模型定义
 * 
 * 包含所有分布式相关的接口、枚举、类型定义
 */

export enum DeviceType {
  PHONE = 'PHONE',                    // 手机
  TABLET = 'TABLET',                  // 平板
  WATCH = 'WATCH',                    // 智能手表/手环
  HOSPITAL_TERMINAL = 'HOSPITAL_TERMINAL'  // 医院终端设备
}

export enum PermissionLevel {
  DOCTOR_FULL = 'DOCTOR_FULL',        // 主治医生（完全访问）
  DOCTOR_PARTIAL = 'DOCTOR_PARTIAL',  // 其他医院医生（部分脱敏）
  FAMILY = 'FAMILY',                  // 家属（完全脱敏）
  SELF = 'SELF'                       // 本人（无脱敏）
}

export enum SyncStatus {
  PENDING = 'PENDING',                // 待同步
  SYNCING = 'SYNCING',                // 同步中
  SUCCESS = 'SUCCESS',                // 同步成功
  FAILED = 'FAILED',                  // 同步失败
  REVOKED = 'REVOKED'                 // 已撤销
}

export interface DeviceInfo {
  deviceId: string;
  deviceName: string;
  deviceType: DeviceType;
  isOnline: boolean;
  lastConnectTime: number;
}

export interface PairingResult {
  success: boolean;
  message: string;
  deviceId?: string;
  errorCode?: number;
}

export interface SyncResult {
  success: boolean;
  syncId?: string;
  timestamp?: number;
  targetDevice?: string;
  error?: string;
}

export interface TransferApplication {
  applicationId: string;              // 申请ID
  patientId: string;                  // 患者ID
  patientName: string;                // 患者姓名（已脱敏）
  sourceHospitalId: string;           // 转出医院ID
  sourceHospitalName: string;         // 转出医院名称
  targetHospitalId: string;           // 接收医院ID
  targetHospitalName: string;         // 接收医院名称
  applyReason: string;                // 转院原因
  applyTime: string;                  // 申请时间
  status: ApplicationStatus;          // 审批状态
  applicantName: string;              // 申请人姓名
  department: string;                 // 所属科室
  urgencyLevel: UrgencyLevel;         // 紧急程度
}

export enum ApplicationStatus {
  PENDING = 'PENDING',                // 待审批
  APPROVED = 'APPROVED',              // 已通过
  REJECTED = 'REJECTED',              // 已拒绝
  CANCELLED = 'CANCELLED'             // 已取消
}

export enum UrgencyLevel {
  NORMAL = 'NORMAL',                  // 普通
  URGENT = 'URGENT',                  // 紧急
  EMERGENCY = 'EMERGENCY'             // 急诊
}

export interface MedicalRecordForSync {
  recordId: string;                   // 病历ID
  patientBasicInfo: PatientBasicInfo; // 患者基本信息
  diagnosisInfo: DiagnosisInfo[];      // 诊断信息列表
  treatmentHistory: TreatmentRecord[]; // 治疗记录
  medicationList: MedicationItem[];   // 用药清单
  examinationResults: ExaminationResult[]; // 检查结果
  allergies: string[];                // 过敏史
  syncPermission: PermissionLevel;    // 同步权限等级
  createTime: string;                 // 创建时间
  updateTime: string;                 // 更新时间
}

export interface PatientBasicInfo {
  name: string;                       // 姓名
  gender: string;                     // 性别
  age: number;                        // 年龄
  idCard: string;                     // 身份证号
  phone: string;                      // 手机号
  address: string;                    // 地址
  emergencyContact: string;           // 紧急联系人
  emergencyPhone: string;             // 紧急联系电话
  bloodType: string;                  // 血型
  insuranceNumber: string;            // 医保号
}

export interface DiagnosisInfo {
  diagnosisId: string;                // 诊断ID
  diseaseName: string;                // 疾病名称
  diagnosisDate: string;              // 诊断日期
  doctorName: string;                 // 诊断医生
  hospitalName: string;               // 诊断医院
  status: string;                     // 状态（治愈/好转/未愈）
  description: string;                // 详细描述
}

export interface TreatmentRecord {
  treatmentId: string;                // 治疗记录ID
  treatmentDate: string;              // 治疗日期
  treatmentType: string;              // 治疗类型（手术/药物/康复等）
  description: string;                // 治疗描述
  result: string;                     // 治疗结果
  doctorName: string;                 // 主治医生
  hospitalName: string;               // 治疗医院
}

export interface MedicationItem {
  medicationId: string;               // 药物ID
  name: string;                       // 药品名称
  dosage: string;                     // 剂量
  frequency: string;                  // 频次
  startDate: string;                  // 开始日期
  endDate: string;                    // 结束日期
  prescribingDoctor: string;          // 开具医生
  notes: string;                      // 备注
}

export interface ExaminationResult {
  examId: string;                     // 检查ID
  examType: string;                   // 检查类型（CT/X光/B超/血常规等）
  examDate: string;                   // 检查日期
  hospitalName: string;               // 检查医院
  resultSummary: string;              // 结果摘要
  imageUrl?: string;                  // 影像图片URL
  isAbnormal: boolean;                // 是否异常
  abnormalDescription?: string;       // 异常描述
}
