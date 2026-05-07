export enum FamilyRelation {
  SPOUSE = '配偶',
  CHILD = '子女',
  PARENT = '父母',
  SIBLING = '兄弟姐妹',
  OTHER = '其他'
}

export class FamilyMember {
  id: number = 0;
  userId: number = 0;
  name: string = '';
  relation: string = FamilyRelation.OTHER;
  phone: string = '';
  idCard: string = '';
  gender: string = '';
  age: number = 0;
  address: string = '';
  isEmergencyContact: boolean = false;
  remark: string = '';
  createTime: string = '';
  updateTime: string = '';

  constructor() {}
}

export class FamilyMemberHelper {
  static fromJson(raw: Record<string, Object>): FamilyMember {
    const member: FamilyMember = new FamilyMember();
    if (raw['id'] !== undefined) { member.id = raw['id'] as number; }
    if (raw['userId'] !== undefined) { member.userId = raw['userId'] as number; }
    if (raw['name'] !== undefined) { member.name = raw['name'] as string; }
    if (raw['relation'] !== undefined) { member.relation = raw['relation'] as string; }
    if (raw['phone'] !== undefined) { member.phone = raw['phone'] as string; }
    if (raw['idCard'] !== undefined) { member.idCard = raw['idCard'] as string; }
    if (raw['gender'] !== undefined) { member.gender = raw['gender'] as string; }
    if (raw['age'] !== undefined) { member.age = raw['age'] as number; }
    if (raw['address'] !== undefined) { member.address = raw['address'] as string; }
    if (raw['isEmergencyContact'] !== undefined) { member.isEmergencyContact = raw['isEmergencyContact'] as boolean; }
    if (raw['remark'] !== undefined) { member.remark = raw['remark'] as string; }
    if (raw['createTime'] !== undefined) { member.createTime = raw['createTime'] as string; }
    if (raw['updateTime'] !== undefined) { member.updateTime = raw['updateTime'] as string; }
    return member;
  }

  static toJson(member: FamilyMember): Record<string, Object> {
    const map: Record<string, Object> = {};
    map['id'] = member.id;
    map['userId'] = member.userId;
    map['name'] = member.name;
    map['relation'] = member.relation;
    map['phone'] = member.phone;
    map['idCard'] = member.idCard;
    map['gender'] = member.gender;
    map['age'] = member.age;
    map['address'] = member.address;
    map['isEmergencyContact'] = member.isEmergencyContact;
    map['remark'] = member.remark;
    return map;
  }

  static getDisplayName(member: FamilyMember): string {
    if (member.name && member.name.trim() !== '') {
      return member.name;
    }
    return '家属';
  }

  static getRelationLabel(relation: string): string {
    return relation || FamilyRelation.OTHER;
  }

  static getEmergencyLabel(member: FamilyMember): string {
    return member.isEmergencyContact ? '是' : '否';
  }

  static maskPhone(phone: string): string {
    if (!phone || phone.length < 7) {
      return phone;
    }
    return phone.substring(0, 3) + '****' + phone.substring(phone.length - 4);
  }

  static maskIdCard(idCard: string): string {
    if (!idCard || idCard.length < 8) {
      return idCard;
    }
    return idCard.substring(0, 4) + '**********' + idCard.substring(idCard.length - 4);
  }
}

export interface CreateFamilyRequest {
  name: string;
  relation: string;
  phone: string;
  idCard?: string;
  gender?: string;
  age?: number;
  address?: string;
  isEmergencyContact?: boolean;
  remark?: string;
}

export interface UpdateFamilyRequest {
  id: number;
  name?: string;
  relation?: string;
  phone?: string;
  idCard?: string;
  gender?: string;
  age?: number;
  address?: string;
  isEmergencyContact?: boolean;
  remark?: string;
}

export interface QueryFamilyParams {
  userId?: number;
  page?: number;
  pageSize?: number;
  keyword?: string;
}
