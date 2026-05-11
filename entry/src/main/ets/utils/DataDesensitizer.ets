import { PatientDetail } from '../model/PatientModel';

export interface DesensitizationConfig {
  desensitizePhone: boolean;
  desensitizeIdCard: boolean;
  desensitizeAddress: boolean;
}

export const DefaultDesensitizationConfig: DesensitizationConfig = {
  desensitizePhone: true,
  desensitizeIdCard: true,
  desensitizeAddress: true
};

export class DataDesensitizer {
  static readonly DefaultDesensitizationConfig: DesensitizationConfig = DefaultDesensitizationConfig;

  static desensitizePhoneNumber(phone: string): string {
    if (!phone || phone.length < 7) {
      return phone;
    }
    const prefix = phone.substring(0, 3);
    const suffix = phone.substring(phone.length - 4);
    return `${prefix}****${suffix}`;
  }

  static desensitizeIdCard(idCard: string): string {
    if (!idCard || idCard.length < 8) {
      return idCard;
    }
    const prefix = idCard.substring(0, 3);
    const suffix = idCard.substring(idCard.length - 4);
    const middle = '*'.repeat(idCard.length - 7);
    return `${prefix}${middle}${suffix}`;
  }

  static desensitizeAddress(address: string): string {
    if (!address || address.length === 0) {
      return address;
    }
    const parts = address.split(/省|市|区|县/);
    if (parts.length >= 2) {
      return parts[0] + (address.includes(parts[0] + '省') ? '省' : '') +
             (parts[1] ? parts[1] + '市****' : '****');
    }
    return address.substring(0, Math.min(6, address.length)) + '****';
  }

  static desensitizePatientDetail(
    detail: PatientDetail,
    config: DesensitizationConfig = DefaultDesensitizationConfig
  ): PatientDetail {
    const desensitized: PatientDetail = {
      patientId: detail.patientId,
      patientName: detail.patientName,
      gender: detail.gender,
      age: detail.age,
      phoneNumber: detail.phoneNumber,
      idCardNumber: detail.idCardNumber,
      medicalRecordNumber: detail.medicalRecordNumber,
      avatar: detail.avatar,
      status: detail.status,
      department: detail.department,
      bedNumber: detail.bedNumber,
      diagnosis: detail.diagnosis,
      createTime: detail.createTime,
      updateTime: detail.updateTime,
      birthDate: detail.birthDate,
      bloodType: detail.bloodType,
      address: detail.address,
      emergencyContact: detail.emergencyContact,
      hospitalizationInfo: detail.hospitalizationInfo,
      allergies: detail.allergies,
      medicalHistory: detail.medicalHistory
    };
    
    if (config.desensitizePhone && desensitized.phoneNumber) {
      desensitized.phoneNumber = DataDesensitizer.desensitizePhoneNumber(desensitized.phoneNumber);
    }
    
    if (config.desensitizeIdCard && desensitized.idCardNumber) {
      desensitized.idCardNumber = DataDesensitizer.desensitizeIdCard(desensitized.idCardNumber);
    }
    
    if (config.desensitizeAddress && desensitized.address) {
      desensitized.address = DataDesensitizer.desensitizeAddress(desensitized.address);
    }
    
    if (desensitized.emergencyContact) {
      desensitized.emergencyContact = {
        name: desensitized.emergencyContact.name,
        phone: desensitized.emergencyContact.phone,
        relationship: desensitized.emergencyContact.relationship
      };
      if (config.desensitizePhone && desensitized.emergencyContact.phone) {
        desensitized.emergencyContact.phone = DataDesensitizer.desensitizePhoneNumber(
          desensitized.emergencyContact.phone
        );
      }
    }
    
    return desensitized;
  }
}
