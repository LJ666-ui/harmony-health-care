/**
 * 医院数据模型
 * 定义医院信息的数据结构
 */
export interface Hospital {
  id: number;
  name: string;
  address: string;
  phone: string;
  level: string;
  department: string;
  description: string;
}

/**
 * 医院分页数据模型
 */
export interface HospitalPageData {
  records: Hospital[];
}
