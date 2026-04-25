export enum DeviceType {
  PHONE = 'PHONE',
  TABLET = 'TABLET',
  WATCH = 'WATCH',
  HOSPITAL_TERMINAL = 'HOSPITAL_TERMINAL'
}

export enum PermissionLevel {
  DOCTOR = 'DOCTOR',
  FAMILY = 'FAMILY',
  PATIENT = 'PATIENT'
}

export enum DesensitizeLevel {
  FULL = 'FULL',
  PARTIAL = 'PARTIAL',
  MINIMAL = 'MINIMAL'
}

export enum SyncStatus {
  PENDING = 'PENDING',
  SYNCING = 'SYNCING',
  COMPLETED = 'COMPLETED',
  FAILED = 'FAILED'
}

export enum TransferStatus {
  PENDING = 'PENDING',
  APPROVED = 'APPROVED',
  REJECTED = 'REJECTED'
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

export interface MedicalRecordData {
  recordId: string;
  patientId: string;
  patientName: string;
  idCard: string;
  phone: string;
  address: string;
  diagnosis: string;
  treatmentPlan: string;
  medications: string[];
  labResults: LabResult[];
  imagingReports: ImagingReport[];
  createTime: number;
  updateTime: number;
  hospitalId: string;
  hospitalName: string;
  doctorId: string;
  doctorName: string;
}

export interface LabResult {
  id: string;
  testName: string;
  resultValue: string;
  unit: string;
  referenceRange: string;
  testDate: string;
  isAbnormal: boolean;
}

export interface ImagingReport {
  id: string;
  reportType: string;
  reportUrl: string;
  description: string;
  conclusion: string;
  reportDate: string;
}

export interface TransferApplication {
  applicationId: string;
  patientId: string;
  patientName: string;
  sourceHospitalId: string;
  sourceHospitalName: string;
  targetHospitalId: string;
  targetHospitalName: string;
  reason: string;
  status: TransferStatus;
  submitTime: number;
  reviewDoctorId?: string;
  reviewDoctorName?: string;
  reviewOpinion?: string;
  reviewTime?: number;
  medicalRecordId: string;
}

export interface SyncTask {
  taskId: string;
  recordId: string;
  targetDeviceId: string;
  permissionLevel: PermissionLevel;
  status: SyncStatus;
  progress: number;
  startTime: number;
  completeTime?: number;
  errorMessage?: string;
}
