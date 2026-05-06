export class DoctorInfo {
  id: number = 0;
  userId: number = 0;
  realName: string = '';
  phone: string = '';
  hospital: string = '';
  department: string = '';
  licenseNumber: string = '';
  title: string = '';
  specialty: string = '';
  avatar: string = '';
  description: string = '';
  rating: number = 0;
  status: number = 0;
  createTime: string = '';
  updateTime: string = '';

  constructor() {}
}

export class DoctorInfoHelper {
  static fromJson(raw: Record<string, Object>): DoctorInfo {
    const info: DoctorInfo = new DoctorInfo();
    if (raw['id'] !== undefined) { info.id = raw['id'] as number; }
    if (raw['userId'] !== undefined) { info.userId = raw['userId'] as number; }
    if (raw['realName'] !== undefined) { info.realName = raw['realName'] as string; }
    if (raw['phone'] !== undefined) { info.phone = raw['phone'] as string; }
    if (raw['hospital'] !== undefined) { info.hospital = raw['hospital'] as string; }
    if (raw['department'] !== undefined) { info.department = raw['department'] as string; }
    if (raw['licenseNumber'] !== undefined) { info.licenseNumber = raw['licenseNumber'] as string; }
    if (raw['title'] !== undefined) { info.title = raw['title'] as string; }
    if (raw['specialty'] !== undefined) { info.specialty = raw['specialty'] as string; }
    if (raw['avatar'] !== undefined) { info.avatar = raw['avatar'] as string; }
    if (raw['description'] !== undefined) { info.description = raw['description'] as string; }
    if (raw['rating'] !== undefined) { info.rating = raw['rating'] as number; }
    if (raw['status'] !== undefined) { info.status = raw['status'] as number; }
    if (raw['createTime'] !== undefined) { info.createTime = raw['createTime'] as string; }
    if (raw['updateTime'] !== undefined) { info.updateTime = raw['updateTime'] as string; }
    return info;
  }

  static toJson(info: DoctorInfo): Record<string, Object> {
    const map: Record<string, Object> = {};
    map['id'] = info.id;
    map['userId'] = info.userId;
    map['realName'] = info.realName;
    map['phone'] = info.phone;
    map['hospital'] = info.hospital;
    map['department'] = info.department;
    map['licenseNumber'] = info.licenseNumber;
    map['title'] = info.title;
    map['specialty'] = info.specialty;
    map['avatar'] = info.avatar;
    map['description'] = info.description;
    map['rating'] = info.rating;
    map['status'] = info.status;
    return map;
  }

  static getDisplayName(info: DoctorInfo): string {
    if (info.realName && info.realName.trim() !== '') {
      return info.realName;
    }
    return '医生';
  }

  static getDisplayTitle(info: DoctorInfo): string {
    const parts: string[] = [];
    if (info.title && info.title.trim() !== '') {
      parts.push(info.title);
    }
    if (info.department && info.department.trim() !== '') {
      parts.push(info.department);
    }
    return parts.length > 0 ? parts.join(' · ') : '';
  }

  static getDisplayHospital(info: DoctorInfo): string {
    if (info.hospital && info.hospital.trim() !== '') {
      return info.hospital;
    }
    return '';
  }
}

export interface DoctorRegisterRequest {
  realName: string;
  phone: string;
  hospital: string;
  department: string;
  licenseNumber: string;
}
