/**
 * 护士数据模型
 * 定义护士信息的数据结构
 */
export interface Nurse {
  id: number;
  userId: number;
  nurseNo: string;
  name: string;
  phone: string;
  department: string;
  title: string;
  avatar: string;
  status: number;
}
