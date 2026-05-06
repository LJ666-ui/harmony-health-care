export interface AdminInfo {
  id: number;
  username: string;
  password: string;
  real_name: string;
  phone: string;
  email: string;
  avatar: string;
  role: number;
  status: number;
  last_login_time: string;
  last_login_ip: string;
  create_time: string;
  is_deleted: number;
}

export interface UserInfo {
  id: number;
  username: string;
  password: string;
  phone: string;
  age: number;
  id_card: string;
  user_type: number;
  create_time: string;
  is_deleted: number;
}

export interface FamilyMemberInfo {
  id: number;
  user_id: number;
  name: string;
  relation: string;
  phone: string;
  id_card: string;
  gender: number;
  age: number;
  address: string;
  is_emergency_contact: number;
  health_condition: string;
  create_time: string;
  update_time: string;
  is_deleted: number;
}

export class AdminMock {
  static admins: AdminInfo[] = [
    { id: 1, username: 'admin', password: 'admin123', real_name: '超级管理员', phone: '13800000000', email: 'admin@medical.com', avatar: '', role: 1, status: 1, last_login_time: '2026-05-06 15:39:16', last_login_ip: '127.0.0.1', create_time: '2026-05-06 15:39:16', is_deleted: 0 },
    { id: 2, username: 'admin2', password: 'admin123', real_name: '普通管理员', phone: '13900000000', email: 'admin2@medical.com', avatar: '', role: 2, status: 1, last_login_time: '2026-05-06 10:20:30', last_login_ip: '192.168.1.100', create_time: '2026-05-06 15:39:16', is_deleted: 0 }
  ];

  static users: UserInfo[] = [
    { id: 1, username: '王建国', password: '123456', phone: '13812345001', age: 52, id_card: '440102197407062361', user_type: 1, create_time: '2026-01-15 09:30:00', is_deleted: 0 },
    { id: 2, username: '李淑琴', password: '123456', phone: '13912345002', age: 50, id_card: '110101197604071918', user_type: 1, create_time: '2026-01-20 14:25:00', is_deleted: 0 },
    { id: 3, username: '张志强', password: '123456', phone: '13712345003', age: 48, id_card: '110102197807281102', user_type: 1, create_time: '2026-02-05 10:10:00', is_deleted: 0 },
    { id: 4, username: '刘美华', password: '123456', phone: '13612345004', age: 49, id_card: '310101197711021737', user_type: 1, create_time: '2026-02-10 16:40:00', is_deleted: 0 },
    { id: 5, username: '陈海涛', password: '123456', phone: '13512345005', age: 43, id_card: '510104198307251187', user_type: 1, create_time: '2026-02-15 11:20:00', is_deleted: 0 },
    { id: 6, username: '杨桂兰', password: '123456', phone: '13412345006', age: 31, id_card: '310101199503121716', user_type: 1, create_time: '2026-02-20 08:50:00', is_deleted: 0 },
    { id: 7, username: '赵伟明', password: '123456', phone: '13312345007', age: 33, id_card: '610101199304012665', user_type: 1, create_time: '2026-02-25 15:30:00', is_deleted: 0 },
    { id: 8, username: '黄秀芳', password: '123456', phone: '13212345008', age: 59, id_card: '110102196709112650', user_type: 1, create_time: '2026-03-01 12:00:00', is_deleted: 0 },
    { id: 9, username: '周小军', password: '123456', phone: '13112345009', age: 57, id_card: '110101196907062897', user_type: 1, create_time: '2026-03-05 09:15:00', is_deleted: 0 },
    { id: 10, username: '吴艳红', password: '123456', phone: '13012345010', age: 39, id_card: '510104198701121727', user_type: 1, create_time: '2026-03-10 17:00:00', is_deleted: 0 },
    { id: 11, username: '徐正华', password: '123456', phone: '15812345011', age: 37, id_card: '110105198904162694', user_type: 1, create_time: '2026-03-12 10:45:00', is_deleted: 0 },
    { id: 12, username: '孙丽娟', password: '123456', phone: '15912345012', age: 37, id_card: '510104198906222169', user_type: 1, create_time: '2026-03-14 13:20:00', is_deleted: 0 },
    { id: 13, username: '朱志远', password: '123456', phone: '15712345013', age: 30, id_card: '310101199601201795', user_type: 1, create_time: '2026-03-16 11:30:00', is_deleted: 0 },
    { id: 14, username: '胡秀莲', password: '123456', phone: '15612345014', age: 45, id_card: '610101198107182417', user_type: 1, create_time: '2026-03-18 08:40:00', is_deleted: 0 },
    { id: 15, username: '林志刚', password: '123456', phone: '15512345015', age: 41, id_card: '440106198511082513', user_type: 0, create_time: '2026-03-20 14:15:00', is_deleted: 0 },
    { id: 16, username: '郑美玲', password: '123456', phone: '15412345016', age: 36, id_card: '330102199003152428', user_type: 0, create_time: '2026-03-22 09:50:00', is_deleted: 0 },
    { id: 17, username: '何建平', password: '123456', phone: '15312345017', age: 55, id_card: '510104197105201837', user_type: 0, create_time: '2026-03-25 16:30:00', is_deleted: 0 },
    { id: 18, username: '罗小红', password: '123456', phone: '15212345018', age: 28, id_card: '440102199805061624', user_type: 0, create_time: '2026-03-28 11:10:00', is_deleted: 0 },
    { id: 19, username: '谢国强', password: '123456', phone: '15112345019', age: 62, id_card: '110101196403152718', user_type: 0, create_time: '2026-04-01 08:30:00', is_deleted: 0 },
    { id: 20, username: '邓丽芳', password: '123456', phone: '15012345020', age: 44, id_card: '310101198208142846', user_type: 0, create_time: '2026-04-03 13:45:00', is_deleted: 0 }
  ];

  static familyMembers: FamilyMemberInfo[] = [
    { id: 1, user_id: 1, name: '王秀英', relation: '配偶', phone: '13912345001', id_card: '440102197601012365', gender: 2, age: 52, address: '北京市朝阳区建国路88号', is_emergency_contact: 1, health_condition: '身体健康，无慢性病', create_time: '2026-05-06 15:39:17', update_time: '2026-05-06 15:39:17', is_deleted: 0 },
    { id: 2, user_id: 1, name: '王明', relation: '子女', phone: '13712345002', id_card: '440102200001012366', gender: 1, age: 26, address: '北京市海淀区中关村大街1号', is_emergency_contact: 0, health_condition: '良好', create_time: '2026-05-06 15:39:17', update_time: '2026-05-06 15:39:17', is_deleted: 0 },
    { id: 3, user_id: 1, name: '王建国（父亲）', relation: '父母', phone: '', id_card: '440102195001012367', gender: 1, age: 76, address: '北京市朝阳区建国路88号', is_emergency_contact: 0, health_condition: '高血压、糖尿病，需定期复查', create_time: '2026-05-06 15:39:17', update_time: '2026-05-06 15:39:17', is_deleted: 0 },
    { id: 4, user_id: 2, name: '李强', relation: '配偶', phone: '13812345003', id_card: '110101197802023456', gender: 1, age: 48, address: '北京市西城区金融街15号', is_emergency_contact: 1, health_condition: '健康', create_time: '2026-05-06 15:39:17', update_time: '2026-05-06 15:39:17', is_deleted: 0 },
    { id: 5, user_id: 2, name: '李小雨', relation: '子女', phone: '13612345004', id_card: '110101200103023457', gender: 2, age: 25, address: '北京市东城区王府井大街18号', is_emergency_contact: 0, health_condition: '良好', create_time: '2026-05-06 15:39:17', update_time: '2026-05-06 15:39:17', is_deleted: 0 },
    { id: 6, user_id: 3, name: '张丽华', relation: '配偶', phone: '13612345055', id_card: '110101198005062345', gender: 2, age: 46, address: '北京市丰台区南三环西路16号', is_emergency_contact: 1, health_condition: '健康', create_time: '2026-05-06 16:00:00', update_time: '2026-05-06 16:00:00', is_deleted: 0 },
    { id: 7, user_id: 4, name: '刘志远', relation: '子女', phone: '13512345066', id_card: '310101200208152846', gender: 1, age: 24, address: '上海市浦东新区陆家嘴环路1000号', is_emergency_contact: 1, health_condition: '良好', create_time: '2026-05-06 16:00:00', update_time: '2026-05-06 16:00:00', is_deleted: 0 },
    { id: 8, user_id: 5, name: '陈美珍', relation: '配偶', phone: '13412345077', id_card: '510104198508121187', gender: 2, age: 41, address: '成都市锦江区红星路三段1号', is_emergency_contact: 1, health_condition: '健康', create_time: '2026-05-06 16:00:00', update_time: '2026-05-06 16:00:00', is_deleted: 0 },
    { id: 9, user_id: 8, name: '黄建国', relation: '配偶', phone: '13212345088', id_card: '110102196505112650', gender: 1, age: 61, address: '北京市东城区安定门外大街56号', is_emergency_contact: 1, health_condition: '高血压，服药控制中', create_time: '2026-05-06 16:00:00', update_time: '2026-05-06 16:00:00', is_deleted: 0 },
    { id: 10, user_id: 9, name: '周美兰', relation: '配偶', phone: '13112345099', id_card: '110101197203062897', gender: 2, age: 54, address: '北京市西城区广安门外大街168号', is_emergency_contact: 1, health_condition: '健康', create_time: '2026-05-06 16:00:00', update_time: '2026-05-06 16:00:00', is_deleted: 0 }
  ];

  static getRoleName(role: number): string {
    return role === 1 ? '超级管理员' : '普通管理员';
  }

  static getRoleColor(role: number): string {
    return role === 1 ? '#8B5CF6' : '#1677FF';
  }

  static getStatusName(status: number): string {
    return status === 1 ? '启用' : '禁用';
  }

  static getStatusColor(status: number): string {
    return status === 1 ? '#52C41A' : '#FF4D4F';
  }

  static getUserTypeName(type: number): string {
    return type === 1 ? '医生' : '普通用户';
  }

  static getUserTypeColor(type: number): string {
    return type === 1 ? '#1677FF' : '#999999';
  }

  static getGenderName(gender: number): string {
    if (gender === 1) return '男';
    if (gender === 2) return '女';
    return '未知';
  }

  static getGenderColor(gender: number): string {
    if (gender === 1) return '#1677FF';
    if (gender === 2) return '#EC4899';
    return '#999999';
  }

  static getRelationColor(relation: string): string {
    const map: Record<string, string> = {
      '配偶': '#52C41A',
      '子女': '#1677FF',
      '父母': '#FAAD14',
      '兄弟姐妹': '#8B5CF6',
      '其他': '#999999'
    };
    return map[relation] || '#999999';
  }

  static getUserNameById(userId: number): string {
    const user: UserInfo | undefined = AdminMock.users.find(u => u.id === userId);
    return user ? user.username : '未知用户';
  }

  static login(username: string, password: string): AdminInfo | null {
    const admin: AdminInfo | undefined = AdminMock.admins.find(
      a => a.username === username && a.password === password && a.status === 1
    );
    return admin || null;
  }
}
