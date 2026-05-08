/**
 * 智慧病房护理任务相关接口定义
 * 包含护理任务、护理计划等接口
 */

import { TaskStatus } from './SmartWardEnums';

export { TaskStatus };

/**
 * 护理任务接口
 * 描述单个护理任务的信息
 */
export interface CareTask {
  taskId: string;                      // 任务唯一ID
  taskName: string;                    // 任务名称（如"测量血压"、"输液更换"、"协助翻身"）
  taskType: string;                    // 任务类型
  scheduledTime: number;               // 计划执行时间戳
  frequency: string;                   // 执行频率（如"q4h"每4小时、"qd"每日一次、"prn"必要时）
  assignedNurse: string;               // 负责护士
  roomId: string;                      // 房间ID
  roomNumber: string;                  // 房间号
  patientId: string;                   // 患者ID
  patientName: string;                 // 患者姓名（脱敏）
  status: TaskStatus;                  // 任务状态
  completedAt?: number;                // 完成时间戳
  completedBy?: string;                // 完成人
  notes?: string;                      // 备注
  isRecurring: boolean;                // 是否重复任务
  estimatedDuration?: number;          // 预计耗时（分钟）
  priority: number;                    // 优先级（1-10）
}

/**
 * 护理计划接口
 * 描述患者的完整护理计划
 */
export interface CarePlan {
  planId: string;                      // 计划唯一ID
  patientId: string;                   // 患者ID
  patientName: string;                 // 患者姓名
  roomId: string;                      // 房间ID
  roomNumber: string;                  // 房间号
  planName: string;                    // 计划名称
  startDate: number;                   // 开始日期
  endDate?: number;                    // 结束日期
  tasks: CareTask[];                   // 任务列表
  createdDate: number;                 // 创建日期
  createdBy: string;                   // 创建人
  notes?: string;                      // 备注
}
