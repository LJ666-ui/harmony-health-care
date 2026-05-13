/**
 * 智慧病房系统枚举定义
 * 包含设备类型、告警等级、风险等级、任务状态、规则类型等枚举
 */

/**
 * 设备类型枚举
 * 定义智慧病房支持的8种设备类型
 */
export enum DeviceType {
  HOSPITAL_BED = 'HOSPITAL_BED',         // 智能病床（升降/翻身/按铃）
  PATIENT_MONITOR = 'PATIENT_MONITOR',    // 患者监护仪（心率/血氧/血压）
  SMART_LIGHT = 'SMART_LIGHT',            // 智能灯光（亮度/色温/开关）
  SMART_CURTAIN = 'SMART_CURTAIN',        // 智能窗帘（开合度）
  SMART_TV = 'SMART_TV',                  // 智能电视（音量/频道/开关）
  AIR_CONDITIONER = 'AIR_CONDITIONER',    // 空调（温度/模式）
  CALL_BUTTON = 'CALL_BUTTON',            // 呼叫按钮
  INFUSION_PUMP = 'INFUSION_PUMP'         // 输液泵（滴速/余量）
}

/**
 * 告警等级枚举
 * 定义告警的4个等级，按紧急程度从高到低排序
 */
export enum AlertLevel {
  EMERGENCY = 'EMERGENCY',                // 急救（最高优先级）
  URGENT = 'URGENT',                      // 紧急
  WARNING = 'WARNING',                    // 警告
  INFO = 'INFO',                          // 信息
  CRITICAL = 'CRITICAL'                   // 危急（兼容旧代码）
}

/**
 * 告警类别枚举
 * 定义告警的7种类型
 */
export enum AlertCategory {
  VITAL_SIGN_ANOMALY = 'VITAL_SIGN_ANOMALY',  // 生命体征异常
  DEVICE_MALFUNCTION = 'DEVICE_MALFUNCTION',  // 设备故障
  CALL_REQUEST = 'CALL_REQUEST',              // 呼叫请求
  MEDICATION_REMINDER = 'MEDICATION_REMINDER', // 用药提醒
  INFUSION_ALERT = 'INFUSION_ALERT',          // 输液告警
  SCHEDULE_REMINDER = 'SCHEDULE_REMINDER',    // 计划提醒
  FALL_DETECTION = 'FALL_DETECTION',          // 跌倒检测
  VITAL_SIGN = 'VITAL_SIGN',                  // 兼容旧代码
  DEVICE_FAULT = 'DEVICE_FAULT',              // 兼容旧代码
  PATIENT_REQUEST = 'PATIENT_REQUEST',        // 兼容旧代码
  NETWORK_ISSUE = 'NETWORK_ISSUE',            // 兼容旧代码
  MAINTENANCE = 'MAINTENANCE'                 // 兼容旧代码
}

/**
 * 患者风险等级枚举
 * 定义患者的4个风险等级
 */
export enum PatientRiskLevel {
  CRITICAL = 'CRITICAL',                  // 重症（特级护理）
  HIGH = 'HIGH',                           // 高危（一级护理）
  MEDIUM = 'MEDIUM',                       // 中等（二级护理）
  LOW = 'LOW'                              // 低危（三级护理）
}

/**
 * 任务状态枚举
 * 定义护理任务的5种状态
 */
export enum TaskStatus {
  PENDING = 'PENDING',                    // 待处理
  IN_PROGRESS = 'IN_PROGRESS',            // 进行中
  COMPLETED = 'COMPLETED',                // 已完成
  SKIPPED = 'SKIPPED',                    // 已跳过
  OVERDUE = 'OVERDUE'                     // 已超期
}

/**
 * 规则类型枚举
 * 定义自动化规则的类型
 */
export enum RuleType {
  SAFETY = 'SAFETY',                      // 安全联动
  COMFORT = 'COMFORT',                    // 舒适联动
  SCHEDULE = 'SCHEDULE',                  // 定时触发
  EMERGENCY = 'EMERGENCY'                 // 紧急联动
}

/**
 * 触发条件类型枚举
 * 定义规则触发条件的类型
 */
export enum TriggerType {
  DEVICE_STATE_CHANGE = 'DEVICE_STATE_CHANGE',  // 设备状态变化
  VITAL_THRESHOLD = 'VITAL_THRESHOLD',          // 生命体征阈值
  SCHEDULE = 'SCHEDULE',                        // 定时触发
  MANUAL = 'MANUAL',                            // 手动触发
  COMBINATION = 'COMBINATION'                   // 组合条件
}

/**
 * 规则动作类型枚举
 * 定义规则执行的动作类型
 */
export enum ActionType {
  CONTROL_DEVICE = 'CONTROL_DEVICE',            // 控制设备
  SEND_ALERT = 'SEND_ALERT',                    // 发送告警
  RECORD_DATA = 'RECORD_DATA',                  // 录制数据
  VOICE_BROADCAST = 'VOICE_BROADCAST',          // 语音播报
  LIGHT_FLASH = 'LIGHT_FLASH',                  // 灯光闪烁
  ADJUST_BED = 'ADJUST_BED',                    // 调节病床
  CLOSE_CURTAIN = 'CLOSE_CURTAIN',              // 关闭窗帘
  MUTE_TV = 'MUTE_TV'                           // 电视静音
}

/**
 * 用户角色枚举
 * 定义系统用户的角色
 */
export enum UserRole {
  NURSE = 'NURSE',                              // 护士
  HEAD_NURSE = 'HEAD_NURSE',                    // 护士长
  PATIENT = 'PATIENT'                           // 患者
}
