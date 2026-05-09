/**
 * 患者基本信息
 */
export class PatientBasicInfo {
  id: number = 0;
  name: string = '';
  age: number = 0;
  gender: string = '';
  phone: string = '';
  idCard: string = '';
  avatar: string = '';

  constructor() {}
}

export class PatientBasicInfoHelper {
  static fromJson(raw: PatientBasicInfo): PatientBasicInfo {
    const info: PatientBasicInfo = new PatientBasicInfo();
    if (raw.id !== undefined) { info.id = raw.id; }
    if (raw.name !== undefined) { info.name = raw.name; }
    if (raw.age !== undefined) { info.age = raw.age; }
    if (raw.gender !== undefined) { info.gender = raw.gender; }
    if (raw.phone !== undefined) { info.phone = raw.phone; }
    if (raw.idCard !== undefined) { info.idCard = raw.idCard; }
    if (raw.avatar !== undefined) { info.avatar = raw.avatar; }
    return info;
  }

  static toJson(info: PatientBasicInfo): Record<string, Object> {
    const map: Record<string, Object> = {};
    map['id'] = info.id;
    map['name'] = info.name;
    map['age'] = info.age;
    map['gender'] = info.gender;
    map['phone'] = info.phone;
    map['idCard'] = info.idCard;
    map['avatar'] = info.avatar;
    return map;
  }
}

/**
 * 患者健康档案
 */
export class PatientHealthProfile {
  allergies: string = '';
  pastHistory: string = '';
  familyHistory: string = '';

  constructor() {}
}

export class PatientHealthProfileHelper {
  static fromJson(raw: PatientHealthProfile): PatientHealthProfile {
    const profile: PatientHealthProfile = new PatientHealthProfile();
    if (raw.allergies !== undefined) { profile.allergies = raw.allergies; }
    if (raw.pastHistory !== undefined) { profile.pastHistory = raw.pastHistory; }
    if (raw.familyHistory !== undefined) { profile.familyHistory = raw.familyHistory; }
    return profile;
  }

  static toJson(profile: PatientHealthProfile): Record<string, Object> {
    const map: Record<string, Object> = {};
    map['allergies'] = profile.allergies;
    map['pastHistory'] = profile.pastHistory;
    map['familyHistory'] = profile.familyHistory;
    return map;
  }
}

/**
 * 患者就诊记录
 */
export class PatientVisitRecord {
  id: number = 0;
  visitDate: string = '';
  hospital: string = '';
  department: string = '';
  doctor: string = '';
  diagnosis: string = '';
  chiefComplaint: string = '';

  constructor() {}
}

export class PatientVisitRecordHelper {
  static fromJson(raw: PatientVisitRecord): PatientVisitRecord {
    const record: PatientVisitRecord = new PatientVisitRecord();
    if (raw.id !== undefined) { record.id = raw.id; }
    if (raw.visitDate !== undefined) { record.visitDate = raw.visitDate; }
    if (raw.hospital !== undefined) { record.hospital = raw.hospital; }
    if (raw.department !== undefined) { record.department = raw.department; }
    if (raw.doctor !== undefined) { record.doctor = raw.doctor; }
    if (raw.diagnosis !== undefined) { record.diagnosis = raw.diagnosis; }
    if (raw.chiefComplaint !== undefined) { record.chiefComplaint = raw.chiefComplaint; }
    return record;
  }

  static toJson(record: PatientVisitRecord): Record<string, Object> {
    const map: Record<string, Object> = {};
    map['id'] = record.id;
    map['visitDate'] = record.visitDate;
    map['hospital'] = record.hospital;
    map['department'] = record.department;
    map['doctor'] = record.doctor;
    map['diagnosis'] = record.diagnosis;
    map['chiefComplaint'] = record.chiefComplaint;
    return map;
  }

  static fromJsonArray(rawArray: PatientVisitRecord[]): PatientVisitRecord[] {
    const result: PatientVisitRecord[] = [];
    rawArray.forEach((raw: PatientVisitRecord) => {
      result.push(PatientVisitRecordHelper.fromJson(raw));
    });
    return result;
  }
}

/**
 * 病历表单数据
 */
export class MedicalRecordFormData {
  id: number = 0;
  patientId: number = 0;
  patientName: string = '';
  doctorId: number = 0;
  doctorName: string = '';
  visitDate: string = '';
  chiefComplaint: string = '';
  presentIllness: string = '';
  pastHistory: string = '';
  personalHistory: string = '';
  familyHistory: string = '';
  physicalExam: string = '';
  auxiliaryExam: string = '';
  diagnosis: string = '';
  treatmentPlan: string = '';
  advice: string = '';
  createTime: string = '';
  updateTime: string = '';

  constructor() {}
}

export class MedicalRecordFormDataHelper {
  static fromJson(raw: MedicalRecordFormData): MedicalRecordFormData {
    const data: MedicalRecordFormData = new MedicalRecordFormData();
    if (raw.id !== undefined) { data.id = raw.id; }
    if (raw.patientId !== undefined) { data.patientId = raw.patientId; }
    if (raw.patientName !== undefined) { data.patientName = raw.patientName; }
    if (raw.doctorId !== undefined) { data.doctorId = raw.doctorId; }
    if (raw.doctorName !== undefined) { data.doctorName = raw.doctorName; }
    if (raw.visitDate !== undefined) { data.visitDate = raw.visitDate; }
    if (raw.chiefComplaint !== undefined) { data.chiefComplaint = raw.chiefComplaint; }
    if (raw.presentIllness !== undefined) { data.presentIllness = raw.presentIllness; }
    if (raw.pastHistory !== undefined) { data.pastHistory = raw.pastHistory; }
    if (raw.personalHistory !== undefined) { data.personalHistory = raw.personalHistory; }
    if (raw.familyHistory !== undefined) { data.familyHistory = raw.familyHistory; }
    if (raw.physicalExam !== undefined) { data.physicalExam = raw.physicalExam; }
    if (raw.auxiliaryExam !== undefined) { data.auxiliaryExam = raw.auxiliaryExam; }
    if (raw.diagnosis !== undefined) { data.diagnosis = raw.diagnosis; }
    if (raw.treatmentPlan !== undefined) { data.treatmentPlan = raw.treatmentPlan; }
    if (raw.advice !== undefined) { data.advice = raw.advice; }
    if (raw.createTime !== undefined) { data.createTime = raw.createTime; }
    if (raw.updateTime !== undefined) { data.updateTime = raw.updateTime; }
    return data;
  }

  static toJson(data: MedicalRecordFormData): Record<string, Object> {
    const map: Record<string, Object> = {};
    map['id'] = data.id;
    map['patientId'] = data.patientId;
    map['patientName'] = data.patientName;
    map['doctorId'] = data.doctorId;
    map['doctorName'] = data.doctorName;
    map['visitDate'] = data.visitDate;
    map['chiefComplaint'] = data.chiefComplaint;
    map['presentIllness'] = data.presentIllness;
    map['pastHistory'] = data.pastHistory;
    map['personalHistory'] = data.personalHistory;
    map['familyHistory'] = data.familyHistory;
    map['physicalExam'] = data.physicalExam;
    map['auxiliaryExam'] = data.auxiliaryExam;
    map['diagnosis'] = data.diagnosis;
    map['treatmentPlan'] = data.treatmentPlan;
    map['advice'] = data.advice;
    map['createTime'] = data.createTime;
    map['updateTime'] = data.updateTime;
    return map;
  }

  static fromJsonArray(rawArray: MedicalRecordFormData[]): MedicalRecordFormData[] {
    const result: MedicalRecordFormData[] = [];
    rawArray.forEach((raw: MedicalRecordFormData) => {
      result.push(MedicalRecordFormDataHelper.fromJson(raw));
    });
    return result;
  }
}

/**
 * 处方药品
 */
export class PrescriptionMedication {
  medicineId: number = 0;
  medicineName: string = '';
  specification: string = '';
  dosage: string = '';
  frequency: string = '';
  quantity: number = 0;

  constructor() {}
}

export class PrescriptionMedicationHelper {
  static fromJson(raw: Record<string, Object>): PrescriptionMedication {
    const medication: PrescriptionMedication = new PrescriptionMedication();
    if (raw['medicineId'] !== undefined) { medication.medicineId = raw['medicineId'] as number; }
    if (raw['medicineName'] !== undefined) { medication.medicineName = raw['medicineName'] as string; }
    if (raw['specification'] !== undefined) { medication.specification = raw['specification'] as string; }
    if (raw['dosage'] !== undefined) { medication.dosage = raw['dosage'] as string; }
    if (raw['frequency'] !== undefined) { medication.frequency = raw['frequency'] as string; }
    if (raw['quantity'] !== undefined) { medication.quantity = raw['quantity'] as number; }
    return medication;
  }

  static toJson(medication: PrescriptionMedication): Record<string, Object> {
    const map: Record<string, Object> = {};
    map['medicineId'] = medication.medicineId;
    map['medicineName'] = medication.medicineName;
    map['specification'] = medication.specification;
    map['dosage'] = medication.dosage;
    map['frequency'] = medication.frequency;
    map['quantity'] = medication.quantity;
    return map;
  }

  static fromJsonArray(rawArray: Record<string, Object>[]): PrescriptionMedication[] {
    const result: PrescriptionMedication[] = [];
    rawArray.forEach((raw: Record<string, Object>) => {
      result.push(PrescriptionMedicationHelper.fromJson(raw));
    });
    return result;
  }

  static toJsonArray(medications: PrescriptionMedication[]): Record<string, Object>[] {
    const result: Record<string, Object>[] = [];
    medications.forEach((medication: PrescriptionMedication) => {
      result.push(PrescriptionMedicationHelper.toJson(medication));
    });
    return result;
  }

  static fromJsonArrayFromObjectArray(rawArray: Object[]): PrescriptionMedication[] {
    const result: PrescriptionMedication[] = [];
    rawArray.forEach((raw: Object) => {
      result.push(PrescriptionMedicationHelper.fromJson(raw as Record<string, Object>));
    });
    return result;
  }
}

/**
 * 处方表单数据
 */
export class PrescriptionFormData {
  id: number = 0;
  patientId: number = 0;
  patientName: string = '';
  doctorId: number = 0;
  doctorName: string = '';
  diagnosis: string = '';
  medications: PrescriptionMedication[] = [];
  remarks: string = '';
  createTime: string = '';
  updateTime: string = '';

  constructor() {}
}

export class PrescriptionFormDataHelper {
  static fromJson(raw: Record<string, Object>): PrescriptionFormData {
    const data: PrescriptionFormData = new PrescriptionFormData();
    if (raw['id'] !== undefined) { data.id = raw['id'] as number; }
    if (raw['patientId'] !== undefined) { data.patientId = raw['patientId'] as number; }
    if (raw['patientName'] !== undefined) { data.patientName = raw['patientName'] as string; }
    if (raw['doctorId'] !== undefined) { data.doctorId = raw['doctorId'] as number; }
    if (raw['doctorName'] !== undefined) { data.doctorName = raw['doctorName'] as string; }
    if (raw['diagnosis'] !== undefined) { data.diagnosis = raw['diagnosis'] as string; }
    if (raw['medications'] !== undefined) {
      data.medications = PrescriptionMedicationHelper.fromJsonArrayFromObjectArray(raw['medications'] as Object[]);
    }
    if (raw['remarks'] !== undefined) { data.remarks = raw['remarks'] as string; }
    if (raw['createTime'] !== undefined) { data.createTime = raw['createTime'] as string; }
    if (raw['updateTime'] !== undefined) { data.updateTime = raw['updateTime'] as string; }
    return data;
  }

  static toJson(data: PrescriptionFormData): Record<string, Object> {
    const map: Record<string, Object> = {};
    map['id'] = data.id;
    map['patientId'] = data.patientId;
    map['patientName'] = data.patientName;
    map['doctorId'] = data.doctorId;
    map['doctorName'] = data.doctorName;
    map['diagnosis'] = data.diagnosis;
    map['medications'] = PrescriptionMedicationHelper.toJsonArray(data.medications);
    map['remarks'] = data.remarks;
    map['createTime'] = data.createTime;
    map['updateTime'] = data.updateTime;
    return map;
  }

  static fromJsonArray(rawArray: Record<string, Object>[]): PrescriptionFormData[] {
    const result: PrescriptionFormData[] = [];
    rawArray.forEach((raw: Record<string, Object>) => {
      result.push(PrescriptionFormDataHelper.fromJson(raw));
    });
    return result;
  }

  static fromJsonArrayFromObjectArray(rawArray: Object[]): PrescriptionFormData[] {
    const result: PrescriptionFormData[] = [];
    rawArray.forEach((raw: Object) => {
      result.push(PrescriptionFormDataHelper.fromJson(raw as Record<string, Object>));
    });
    return result;
  }
}
