export enum PatientGender {
  MALE = 'MALE',
  FEMALE = 'FEMALE',
  UNKNOWN = 'UNKNOWN'
}

export enum PatientStatus {
  IN_HOSPITAL = 'IN_HOSPITAL',
  DISCHARGED = 'DISCHARGED',
  OUTPATIENT = 'OUTPATIENT',
  TRANSFERRED = 'TRANSFERRED'
}

export enum BloodType {
  A_POSITIVE = 'A+',
  A_NEGATIVE = 'A-',
  B_POSITIVE = 'B+',
  B_NEGATIVE = 'B-',
  AB_POSITIVE = 'AB+',
  AB_NEGATIVE = 'AB-',
  O_POSITIVE = 'O+',
  O_NEGATIVE = 'O-'
}

export const GenderDisplayText: Record<PatientGender, string> = {
  [PatientGender.MALE]: '男',
  [PatientGender.FEMALE]: '女',
  [PatientGender.UNKNOWN]: '未知'
};

export const PatientStatusText: Record<PatientStatus, string> = {
  [PatientStatus.IN_HOSPITAL]: '在院',
  [PatientStatus.DISCHARGED]: '已出院',
  [PatientStatus.OUTPATIENT]: '门诊',
  [PatientStatus.TRANSFERRED]: '转院'
};

export interface PatientInfo {
  patientId: string;
  patientName: string;
  gender: PatientGender;
  age: number;
  phoneNumber?: string;
  idCardNumber?: string;
  medicalRecordNumber?: string;
  avatar?: string;
  status?: PatientStatus;
  department?: string;
  bedNumber?: string;
  diagnosis?: string;
  createTime?: number;
  updateTime?: number;
}

export interface EmergencyContact {
  name: string;
  phone: string;
  relationship: string;
}

export interface HospitalizationInfo {
  hospital: string;
  department: string;
  bedNumber: string;
  admissionDate: number;
  expectedDischargeDate?: number;
  attendingDoctor?: string;
  primaryDiagnosis?: string;
}

export interface PatientDetail extends PatientInfo {
  birthDate?: number;
  bloodType?: BloodType;
  address?: string;
  emergencyContact?: EmergencyContact;
  hospitalizationInfo?: HospitalizationInfo;
  allergies?: string[];
  medicalHistory?: string;
  updateTime: number;
}

export enum QueryType {
  ALL = 'ALL',
  SEARCH = 'SEARCH',
  FILTER = 'FILTER'
}

export enum SortField {
  PATIENT_NAME = 'patientName',
  CREATE_TIME = 'createTime',
  UPDATE_TIME = 'updateTime'
}

export enum SortOrder {
  ASC = 'ASC',
  DESC = 'DESC'
}

export enum DataSource {
  REMOTE = 'REMOTE',
  CACHE = 'CACHE',
  AUTO = 'AUTO'
}

export interface PatientListRequest {
  nurseId?: string;
  doctorId?: string;
  queryType: QueryType;
  searchKeyword?: string;
  sortField?: SortField;
  sortOrder?: SortOrder;
  pageNumber: number;
  pageSize: number;
}

export interface PatientDetailRequest {
  patientId: string;
  dataSource?: DataSource;
}

export interface PagedResponse<T> {
  data: T[];
  total: number;
  pageNumber: number;
  pageSize: number;
  hasMore: boolean;
}

export interface PatientListResponse {
  success: boolean;
  code?: number;
  message?: string;
  data?: PagedResponse<PatientInfo>;
}

export interface PatientDetailResponse {
  success: boolean;
  code?: number;
  message?: string;
  data?: PatientDetail;
}
