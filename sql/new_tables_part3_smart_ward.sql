/*
 星云医疗助手 - 新增功能模块数据库表 (第三部分: 智慧病房系统模块)

 模块说明:
   三、智慧病房系统模块 (Smart Ward System Module)
   功能对应: 项目功能清单第8章 - 智慧病房系统
   页面: NurseStationDashboard, SmartWardDevices, SmartWardAlerts, MonitoringDashboard
   组件: SmartLightController, SmartCurtainController, SmartTVController, AirConditionerController等
   用途: IoT设备管理、实时监控、告警处理、自动化规则引擎、护理计划管理

 包含表:
   表7: ward_device (病房设备表) - 管理所有IoT智能设备(灯光/窗帘/空调/病床/监护仪等)
   表8: device_alert (设备告警表) - 记录设备异常、阈值超限、故障等告警事件
   表9: automation_rule (自动化规则表) - 存储场景联动和智能调节规则
   表10: care_plan (护理计划表) - 管理患者个性化护理方案

 依赖: 需要先执行 new_tables_part1_parking.sql 和 new_tables_part2_navigation.sql
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ============================================================================
-- 三、智慧病房系统模块 (Smart Ward System Module)
-- ============================================================================

-- ----------------------------
-- 表7: ward_device (病房设备表)
-- 用途: 管理智慧病房中的所有IoT智能设备，包括灯光、窗帘、空调、病床、输液泵、监护仪等
-- 支持设备状态监控、远程控制、配置管理
-- ----------------------------
DROP TABLE IF EXISTS `ward_device`;
CREATE TABLE `ward_device` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '设备ID，主键自增',
  `device_code` varchar(64) NOT NULL COMMENT '设备唯一编码(如MAC地址或设备序列号)',
  `ward_number` varchar(20) NOT NULL COMMENT '病房号，如"301"、"ICU-05"、"VIP-01"',
  `bed_number` varchar(10) DEFAULT NULL COMMENT '床位号，如"床1"、"床2"(公共设备为NULL)',
  `device_name` varchar(100) NOT NULL COMMENT '设备名称，如"床头灯"、"智能窗帘"、"心电监护仪"',
  `device_type` enum('LIGHT','CURTAIN','TV','AIR_CONDITIONER','BED','INFUSION_PUMP','PATIENT_MONITOR','CALL_BUTTON','WINDOW','OXYGEN','VACUUM','SCALE','OTHER') NOT NULL COMMENT '设备类型: LIGHT=灯光 CURTAIN=窗帘 TV=电视 AIR_CONDITIONER=空调 BED=智能病床 INFUSION_PUMP=输液泵 PATIENT_MONITOR=监护仪 CALL_BUTTON=呼叫按钮 WINDOW=窗户 OXYGEN=吸氧装置 VACUUM=负压吸引 SCALE=体重秤 OTHER=其他',
  `device_model` varchar(100) DEFAULT NULL COMMENT '设备型号，如"HL-SmartLight-Pro V2"',
  `manufacturer` varchar(100) DEFAULT NULL COMMENT '制造商',
  `firmware_version` varchar(50) DEFAULT NULL COMMENT '固件版本',
  `device_status` enum('ONLINE','OFFLINE','FAULT','MAINTENANCE','DECOMMISSIONED') NOT NULL DEFAULT 'ONLINE' COMMENT '设备状态: ONLINE=在线 OFFLINE=离线 FAULT=故障 MAINTENANCE=维护中 DECOMMISSIONED=已报废',
  `power_status` enum('ON','OFF','STANDBY') DEFAULT 'OFF' COMMENT '电源状态: ON=开启 OFF=关闭 STANDBY=待机',
  `current_config` json DEFAULT NULL COMMENT '当前配置参数(JSON): 根据设备类型不同而异',
  `default_config` json DEFAULT NULL COMMENT '默认配置参数(JSON)',
  `device_capabilities` json DEFAULT NULL COMMENT '设备能力列表(JSON): 支持的功能和控制指令',
  `last_heartbeat` datetime DEFAULT NULL COMMENT '最后心跳时间',
  `heartbeat_interval` int DEFAULT 30 COMMENT '心跳间隔(秒)',
  `battery_level` tinyint DEFAULT NULL COMMENT '电池电量%(仅无线设备，NULL表示有线供电)',
  `signal_strength` tinyint DEFAULT NULL COMMENT '信号强度(RSSI, -100~0，越大越好)',
  `install_date` date DEFAULT NULL COMMENT '安装日期',
  `last_maintenance_date` date DEFAULT NULL COMMENT '上次维护日期',
  `next_maintenance_date` date DEFAULT NULL COMMENT '下次计划维护日期',
  `warranty_expire_date` date DEFAULT NULL COMMENT '保修截止日期',
  `location_description` varchar(255) DEFAULT NULL COMMENT '安装位置描述，如"床头左侧墙壁"、"天花板中央"',
  `ip_address` varchar(45) DEFAULT NULL COMMENT 'IP地址(IPv4/IPv6)',
  `network_type` enum('WiFi','Zigbee','Bluetooth','Ethernet','LoRa','NB-IoT') DEFAULT 'WiFi' COMMENT '网络接入方式',
  `protocol_version` varchar(20) DEFAULT NULL COMMENT '通信协议版本',
  `is_controllable` tinyint NOT NULL DEFAULT 1 COMMENT '是否可远程控制: 0=只读 1=可控制',
  `patient_id` bigint DEFAULT NULL COMMENT '当前关联的患者ID(仅患者专用设备)',
  `assigned_nurse_id` bigint DEFAULT NULL COMMENT '负责护士ID',
  `notes` text COMMENT '备注信息',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `is_deleted` tinyint NOT NULL DEFAULT 0 COMMENT '逻辑删除: 0=未删除 1=已删除',
  PRIMARY KEY (`id`),
  UNIQUE INDEX `uk_device_code` (`device_code`),
  INDEX `idx_ward_bed` (`ward_number`, `bed_number`),
  INDEX `idx_device_type` (`device_type`),
  INDEX `idx_device_status` (`device_status`),
  INDEX `idx_last_heartbeat` (`last_heartbeat`),
  INDEX `idx_patient_id` (`patient_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='病房设备表';

-- 示例数据: 插入各类智慧病房设备
INSERT INTO `ward_device` (`id`, `device_code`, `ward_number`, `bed_number`, `device_name`, `device_type`, `device_model`, `manufacturer`, `firmware_version`, `device_status`, `power_status`, `current_config`, `default_config`, `device_capabilities`, `last_heartbeat`, `heartbeat_interval`, `battery_level`, `signal_strength`, `install_date`, `last_maintenance_date`, `next_maintenance_date`, `warranty_expire_date`, `location_description`, `ip_address`, `network_type`, `protocol_version`, `is_controllable`, `patient_id`, `assigned_nurse_id`, `notes`, `create_time`, `update_time`, `is_deleted`) VALUES
(1, 'LIGHT-301-001', '301', NULL, '301病房主灯', 'LIGHT', 'HL-SmartLED-Pro V3', '华为智选', 'v2.1.5', 'ONLINE', 'ON', '{"brightness":80,"colorTemp":4000,"colorMode":"white","sceneMode":"reading"}', '{"brightness":70,"colorTemp":4500,"colorMode":"white","sceneMode":"comfort"}', '["setBrightness","setColorTemp","setColor","toggle","setScene"]', NOW(), 30, NULL, -45, '2026-01-15', '2026-04-01', '2026-07-01', '2027-01-15', '病房天花板中央', '192.168.1.101', 'WiFi', 'MQTT-v3.1.1', 1, NULL, NULL, '主照明灯，支持调光调色', NOW(), NOW(), 0),

(2, 'CURTAIN-301-001', '301', NULL, '301病房智能窗帘', 'CURTAIN', 'HL-Curtain-Motor V2', '绿米联创', 'v1.8.3', 'ONLINE', 'ON', '{"position":70,"mode":"partial","direction":"stop"}', '{"position":50,"mode":"partial","direction":"stop"}', '["open","close","stop","setPosition"]', NOW(), 60, NULL, -52, '2026-01-15', '2026-04-01', '2026-07-01', '2027-01-15', '病房南侧窗户', '192.168.1.102', 'Zigbee', 'Zigbee-v3.0', 1, NULL, NULL, '电动开合帘，遮光率95%', NOW(), NOW(), 0),

(3, 'MONITOR-301-B1', '301', '床1', '床1多参数监护仪', 'PATIENT_MONITOR', 'HL-Monitor-Elite X1', '迈瑞医疗', 'v3.2.1', 'ONLINE', 'ON', '{"ecg":{"lead":"II","gain":10},"spo2":{"alarmHigh":99,"alarmLow":90},"bp":{"mode":"auto","interval":30},"hr":{"alarmHigh":120,"alarmLow":50},"rr":{"alarmHigh":25,"alarmLow":8},"temp":{"unit":"celsius"}}', '{}', '["getVitals","setAlarmLimits","startMonitoring","stopMonitoring","exportData"]', NOW(), 10, NULL, -38, '2026-01-15', '2026-04-10', '2026-05-10', '2027-01-15', '床1床头支架', '192.168.1.103', 'Ethernet', 'HL-Protocol-v2.0', 1, 201, 5, '正在监测患者张三的生命体征', NOW(), NOW(), 0),

(4, 'PUMP-301-B1', '301', '床1', '床1智能输液泵', 'INFUSION_PUMP', 'HL-Infusion-Smart V2', '科曼医疗', 'v2.0.8', 'ONLINE', 'ON', '{"rate":60,"volume":500,"remainingVolume":320,"drugName":"0.9%氯化钠注射液","mode":"volume","occlusionPressure":"normal","airDetection":true}', '{"rate":50,"volume":500,"mode":"volume","occlusionPressure":"normal","airDetection":true}', '["setRate","setVolume","start","stop","pause","setDrugInfo","clearAlarm"]', NOW(), 5, NULL, -42, '2026-01-15', '2026-04-05', '2026-06-05', '2027-01-15', '床1输液架', '192.168.1.104', 'WiFi', 'MQTT-v3.1.1', 1, 201, 5, '当前输液中，预计剩余约5小时', NOW(), NOW(), 0),

(5, 'BED-301-B1', '301', '床1', '床1电动护理床', 'BED', 'HL-Bed-Electric Pro V4', '鱼跃医疗', 'v2.5.2', 'ONLINE', 'ON', '{"headAngle":30,"footAngle":15,"height":45,"position":"fowler","backMassage":false,"sideRail":"up"}', '{"headAngle":0,"footAngle":0,"height":50,"position":"flat","backMassage":false,"sideRail":"down"}', '["setHeadAngle","setFootAngle","setHeight","setPosition","toggleMassage","setSideRail","callNurse","emergencyStop"]', NOW(), 15, NULL, -48, '2026-01-15', '2026-03-20', '2026-06-20', '2027-01-15', '床1主体', '192.168.1.105', 'Zigbee', 'Zigbee-v3.0', 1, 201, 5, '五功能电动床，支持体位调整', NOW(), NOW(), 0),

(6, 'AC-301-001', '301', NULL, '301病房空调', 'AIR_CONDITIONER', 'HL-AC-Inverter Plus V2', '格力', 'v1.9.7', 'ONLINE', 'ON', '{"temperature":24,"mode":"cool","fanSpeed":"low","swing":true,"ecoMode":false,"quietMode":true}', '{"temperature":26,"mode":"auto","fanSpeed":"auto","swing":false,"ecoMode":true,"quietMode":true}', '["setTemperature","setMode","setFanSpeed","toggleSwing","toggleEco","toggleQuiet","togglePower"]', NOW(), 60, NULL, -55, '2026-01-15', '2026-04-01', '2026-07-01', '2027-01-15', '病房墙上', '192.168.1.106', 'WiFi', 'IR+WiFi-v1.0', 1, NULL, NULL, '变频空调，静音模式运行中', NOW(), NOW(), 0),

(7, 'CALL-301-B1', '301', '床1', '床1呼叫按钮', 'CALL_BUTTON', 'HL-CallButton-Wireless V1', '华为智选', 'v1.2.3', 'ONLINE', 'STANDBY', '{"buttonType":"nurse_call","ledColor":"green","volume":80,"vibration":true}', '{"buttonType":"nurse_call","ledColor":"green","volume":80,"vibration":true}', '["press","cancel","setVolume","setLedColor","test"]', NOW(), 30, 95, -58, '2026-01-15', '2026-03-15', '2026-06-15', '2027-01-15', '床1床头扶手', NULL, 'Bluetooth', 'BLE-v4.2', 1, 201, 5, '无线呼叫按钮，带震动反馈', NOW(), NOW(), 0),

(8, 'TV-301-001', '301', NULL, '301病房智能电视', 'TV', 'HL-TV-Smart 55"', '海信', 'v2.3.1', 'ONLINE', 'STANDBY', '{"power":"standby","volume":30,"channel":1,"inputSource":"hdmi1","childLock":true}', '{"power":"off","volume":25,"channel":1,"inputSource":"tv","childLock":true}', '["togglePower","setVolume","setChannel","setInput","setChildLock"]', NOW(), 120, NULL, -50, '2026-01-15', '2026-04-01', '2026-07-01', '2027-01-15', '床尾对面墙壁', '192.168.1.107', 'WiFi', 'DLNA+v2.0', 1, NULL, NULL, '55寸智能电视，儿童锁已启用', NOW(), NOW(), 0);

-- ----------------------------
-- 表8: device_alert (设备告警表)
-- 用途: 记录IoT设备的所有告警事件，用于护士站实时监控、历史追溯、统计分析
-- 支持多级告警、自动升级、处理跟踪
-- 关联: ward_device表
-- ----------------------------
DROP TABLE IF EXISTS `device_alert`;
CREATE TABLE `device_alert` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '告警ID，主键自增',
  `device_id` bigint NOT NULL COMMENT '触发告警的设备ID',
  `alert_code` varchar(50) NOT NULL COMMENT '告警代码，如"ECG_HIGH"、"PUMP_OCCLUSION"、"OFFLINE_30MIN"',
  `alert_type` enum('ABNORMAL','FAULT','THRESHOLD_EXCEED','OFFLINE','LOW_BATTERY','MAINTENANCE_DUE','SECURITY','OTHER') NOT NULL COMMENT '告警类型: ABNORMAL=数据异常 FAULT=设备故障 THRESHOLD_EXCEED=阈值超限 OFFLINE=离线 LOW_BATTERY=低电量 MAINTENANCE_DUE=需维护 SECURITY=安全告警 OTHER=其他',
  `alert_level` enum('INFO','WARNING','CRITICAL','EMERGENCY') NOT NULL DEFAULT 'WARNING' COMMENT '告警级别: INFO=信息 WARNING=警告 CRITICAL=严重 EMERGENCY=紧急',
  `alert_title` varchar(200) NOT NULL COMMENT '告警标题，如"心率过高报警"、"输液泵堵塞"',
  `alert_message` text NOT NULL COMMENT '告警详细消息',
  `trigger_metric` varchar(50) DEFAULT NULL COMMENT '触发指标名，如"heart_rate"、"sp_o2"、"infusion_rate"',
  `trigger_value` varchar(100) DEFAULT NULL COMMENT '触发时的值',
  `threshold_value` varchar(100) DEFAULT NULL COMMENT '阈值/限值',
  `unit` varchar(20) DEFAULT NULL COMMENT '单位，如"bpm"、"%"、"ml/h"',
  `severity_score` int DEFAULT 50 COMMENT '严重程度评分(0-100)',
  `patient_id` bigint DEFAULT NULL COMMENT '关联的患者ID(如有)',
  `ward_number` varchar(20) DEFAULT NULL COMMENT '病房号(冗余存储)',
  `acknowledged_by` bigint DEFAULT NULL COMMENT '确认人ID(护士/医生)',
  `acknowledged_time` datetime DEFAULT NULL COMMENT '确认时间',
  `handled_by` bigint DEFAULT NULL COMMENT '处理人ID',
  `handle_time` datetime DEFAULT NULL COMMENT '处理完成时间',
  `handle_method` varchar(255) DEFAULT NULL COMMENT '处理方式描述',
  `handle_result` enum('SUCCESS','PARTIAL','FAILED','ESCALATED','FALSE_ALARM') DEFAULT NULL COMMENT '处理结果: SUCCESS=成功解决 PARTIAL=部分解决 FAILED=未解决 ESCALATED=已升级 FALSE_ALARM=误报',
  `status` enum('ACTIVE','ACKNOWLEDGED','IN_PROGRESS','RESOLVED','CLOSED','ESCALATED') NOT NULL DEFAULT 'ACTIVE' COMMENT '告警状态: ACTIVE=活跃 ACKNOWLEDGED=已确认 IN_PROGRESS=处理中 RESOLVED=已解决 CLOSED=已关闭 ESCALATED=已升级',
  `escalation_level` int DEFAULT 0 COMMENT '升级级别: 0=未升级 1=护士长 2=值班医生 3=科主任 4=院长',
  `escalation_time` datetime DEFAULT NULL COMMENT '升级时间',
  `auto_resolve_time` datetime DEFAULT NULL COMMENT '自动解决时间(如果告警自行消失)',
  `duration_seconds` int DEFAULT NULL COMMENT '持续时长(秒)，从触发到解决',
  `notification_sent` tinyint NOT NULL DEFAULT 0 COMMENT '是否已发送通知: 0=否 1=是',
  `notification_channels` json DEFAULT NULL COMMENT '通知渠道(JSON数组): ["app_push","sms","call","screen"]',
  `related_alert_ids` json DEFAULT NULL COMMENT '关联的其他告警ID',
  `root_cause_analysis` text COMMENT '根因分析(处理后填写)',
  `prevention_action` varchar(500) DEFAULT NULL COMMENT '预防措施',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '告警触发时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  INDEX `idx_device_id` (`device_id`),
  INDEX `idx_alert_type` (`alert_type`),
  INDEX `idx_alert_level` (`alert_level`),
  INDEX `idx_status` (`status`),
  INDEX `idx_create_time` (`create_time`),
  INDEX `idx_patient_id` (`patient_id`),
  INDEX `idx_ward_number` (`ward_number`),
  INDEX `idx_severity` (`severity_score`),
  CONSTRAINT `fk_alert_device` FOREIGN KEY (`device_id`) REFERENCES `ward_device` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='设备告警表';

-- 示例数据: 插入各种类型的设备告警
INSERT INTO `device_alert` (`id`, `device_id`, `alert_code`, `alert_type`, `alert_level`, `alert_title`, `alert_message`, `trigger_metric`, `trigger_value`, `threshold_value`, `unit`, `severity_score`, `patient_id`, `ward_number`, `acknowledged_by`, `acknowledged_time`, `handled_by`, `handle_time`, `handle_method`, `handle_result`, `status`, `escalation_level`, `escalation_time`, `auto_resolve_time`, `duration_seconds`, `notification_sent`, `notification_channels`, `related_alert_ids`, `root_cause_analysis`, `prevention_action`, `create_time`, `update_time`) VALUES
(1, 3, 'ECG_HIGH', 'THRESHOLD_EXCEED', 'CRITICAL', '心率过高报警', '患者张三(ID:201)心率异常升高至125 bpm，超过上限阈值(120 bpm)，持续时间超过3分钟。请立即检查患者状况！', 'heart_rate', '125', '120', 'bpm', 85, 201, '301', 5, DATE_ADD(NOW(), INTERVAL 2 MINUTE), 5, DATE_ADD(NOW(), INTERVAL 8 MINUTE), '护士到场评估，患者因疼痛导致心率加快，已通知医生并给予镇痛处理', 'SUCCESS', 'RESOLVED', 0, NULL, NULL, NULL, 480, 1, '["app_push", "screen"]', NULL, '术后疼痛导致一过性心动过速', '加强术后疼痛管理，密切监测心电变化', DATE_SUB(NOW(), INTERVAL 15 MINUTE), NOW()),

(2, 4, 'PUMP_OCCLUSION', 'ABNORMAL', 'WARNING', '输液泵堵塞报警', '床1输液泵检测到管路堵塞，压力异常。当前输液速率已自动暂停。请立即检查输液管路是否有折叠或针头脱出。', 'occlusion_pressure', 'high', 'normal', NULL, 65, 201, '301', 5, DATE_ADD(NOW(), INTERVAL 1 MINUTE), 5, DATE_ADD(NOW(), INTERVAL 5 MINUTE), '检查发现输液管路在床栏处被压折，重新整理管路后恢复正常', 'SUCCESS', 'RESOLVED', 0, NULL, NULL, NULL, 240, 1, '["app_push", "screen"]', NULL, '输液管路在床栏处受压折叠', '加强巡视，确保管路固定妥当', DATE_SUB(NOW(), INTERVAL 10 MINUTE), NOW()),

(3, 3, 'SPO2_LOW', 'THRESHOLD_EXCEED', 'CRITICAL', '血氧饱和度过低报警', '患者张三血氧饱和度降至88%，低于下限阈值(90%)。可能存在缺氧风险，请立即检查患者呼吸道及氧疗情况！', 'sp_o2', '88', '90', '%', 90, 201, '301', 5, DATE_ADD(NOW(), INTERVAL 30 SECOND), NULL, NULL, NULL, NULL, NULL, 'IN_PROGRESS', 1, DATE_ADD(NOW(), INTERVAL 1 MINUTE), NULL, NULL, NULL, 1, '["app_push", "sms", "call", "screen"]', NULL, NULL, NULL, DATE_SUB(NOW(), INTERVAL 3 MINUTE), NOW()),

(4, 7, 'CALL_BUTTON_PRESS', 'ABNORMAL', 'INFO', '患者呼叫请求', '床1患者按下呼叫按钮，请求护士到床服务。呼叫原因: 需要协助翻身。', 'button_event', 'press', NULL, NULL, 30, 201, '301', 5, DATE_ADD(NOW(), INTERVAL 1 MINUTE), 5, DATE_ADD(NOW(), INTERVAL 3 MINUTE), '护士到场协助患者翻身并调整舒适体位', 'SUCCESS', 'CLOSED', 0, NULL, NULL, NULL, 120, 1, '["app_push", "screen"]', NULL, '患者需要协助翻身', '增加巡视频次，关注患者舒适度', DATE_SUB(NOW(), INTERVAL 5 MINUTE), NOW()),

(5, 1, 'LIGHT_FAULT', 'FAULT', 'WARNING', '灯光设备故障', '301病房主灯通信不稳定，最近5分钟内有3次心跳超时。可能是网络信号问题或设备硬件故障。', 'heartbeat_timeout_count', '3', '2', '次/5min', 55, NULL, '301', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'ACKNOWLEDGED', 0, NULL, NULL, NULL, NULL, NULL, 1, '["app_push"]', NULL, 'WiFi信号不稳定或设备固件问题', '安排网络检测和设备维护', DATE_SUB(NOW(), INTERVAL 8 MINUTE), NOW()),

(6, 6, 'AC_FILTER_REMINDER', 'MAINTENANCE_DUE', 'INFO', '空调滤网更换提醒', '301病房空调已连续运行720小时，根据维护计划需要清洗或更换滤网。建议在本周内安排维护。', 'runtime_hours', '720', '720', 'hours', 25, NULL, '301', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'ACTIVE', 0, NULL, NULL, NULL, NULL, NULL, 0, '["app_push"]', NULL, NULL, '按计划执行空调维护保养', NOW(), NOW());

-- ----------------------------
-- 表9: automation_rule (自动化规则表)
-- 用途: 存储智慧病房的自动化规则配置，实现场景联动、智能调节
-- 支持时间触发、条件触发、手动触发等多种模式
-- ----------------------------
DROP TABLE IF EXISTS `automation_rule`;
CREATE TABLE `automation_rule` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '规则ID，主键自增',
  `rule_name` varchar(100) NOT NULL COMMENT '规则名称，如"夜间安静模式"、"查房模式"、"紧急响应"',
  `rule_description` text COMMENT '规则详细描述',
  `rule_type` enum('TIME_BASED','CONDITION_BASED','DEVICE_EVENT','MANUAL','GEO_FENCE','COMBINED') NOT NULL DEFAULT 'CONDITION_BASED' COMMENT '规则类型: TIME_BASED=时间触发 CONDITION_BASED=条件触发 DEVICE_EVENT=设备事件触发 MANUAL=手动执行 GEO_FENCE=地理围栏 COMBINED=组合触发',
  `trigger_condition` json NOT NULL COMMENT '触发条件(JSON): 定义何时触发规则',
  `action_list` json NOT NULL COMMENT '动作列表(JSON): 触发后执行的一系列操作',
  `target_devices` json DEFAULT NULL COMMENT '目标设备ID列表(JSON数组)',
  `target_wards` json DEFAULT NULL COMMENT '目标病房列表(JSON数组)',
  `execution_order` int DEFAULT 0 COMMENT '执行顺序(数字越小优先级越高)',
  `priority` enum('LOW','MEDIUM','HIGH','CRITICAL') NOT NULL DEFAULT 'MEDIUM' COMMENT '优先级: LOW=低 MEDIUM=中等 HIGH=高 CRITICAL=最高',
  `is_enabled` tinyint NOT NULL DEFAULT 1 COMMENT '是否启用: 0=禁用 1=启用',
  `schedule` json DEFAULT NULL COMMENT '调度配置(JSON): 时间窗口、重复周期等',
  `cooldown_seconds` int DEFAULT 60 COMMENT '冷却时间(秒): 避免频繁触发',
  `max_executions_per_day` int DEFAULT NULL COMMENT '每日最大执行次数(NULL=不限)',
  `execution_count_today` int DEFAULT 0 COMMENT '今日已执行次数',
  `last_execution_time` datetime DEFAULT NULL COMMENT '上次执行时间',
  `next_execution_time` datetime DEFAULT NULL COMMENT '下次预计执行时间',
  `success_count` int DEFAULT 0 COMMENT '累计成功执行次数',
  `failure_count` int DEFAULT 0 COMMENT '累计失败次数',
  `last_error_message` text COMMENT '最后一次错误信息',
  `created_by` bigint DEFAULT NULL COMMENT '创建人ID(管理员)',
  `modified_by` bigint DEFAULT NULL COMMENT '最后修改人ID',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `is_deleted` tinyint NOT NULL DEFAULT 0 COMMENT '逻辑删除: 0=未删除 1=已删除',
  PRIMARY KEY (`id`),
  INDEX `idx_rule_type` (`rule_type`),
  INDEX `idx_priority` (`priority`),
  INDEX `idx_is_enabled` (`is_enabled`),
  INDEX `idx_last_execution` (`last_execution_time`),
  INDEX `idx_created_by` (`created_by`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='自动化规则表';

-- 示例数据: 插入各种类型的自动化规则
INSERT INTO `automation_rule` (`id`, `rule_name`, `rule_description`, `rule_type`, `trigger_condition`, `action_list`, `target_devices`, `target_wards`, `execution_order`, `priority`, `is_enabled`, `schedule`, `cooldown_seconds`, `max_executions_per_day`, `execution_count_today`, `last_execution_time`, `success_count`, `failure_count`, `created_by`, `create_time`, `update_time`, `is_deleted`) VALUES
(1, '夜间安静模式(22:00-06:00)', '每晚22点自动将病房调整为夜间模式：灯光调暗、空调静音、窗帘关闭、电视待机，营造安静睡眠环境', 'TIME_BASED',
 '{"timeWindow":{"start":"22:00","end":"06:00"},"timezone":"Asia/Shanghai","repeat":["mon","tue","wed","thu","fri","sat","sun"]}',
 '[{"action":"setBrightness","params":{"brightness":20}},{"action":"setMode","params":{"mode":"night"}},{"action":"close"},{"action":"togglePower","params":{"power":"standby"}}]',
 '[1, 2, 6, 8]', '["301", "302", "303"]', 1, 'HIGH', 1,
 '{"cronExpression":"0 22 * * *","endCron":"0 6 * * *"}', 3600, 1, 0, DATE_SUB(NOW(), INTERVAL 12 HOUR), 45, 2, 1, NOW(), NOW(), 0),

(2, '紧急呼叫响应', '当患者按下呼叫按钮时，自动调亮床头灯到80%亮度，并打开房门指示灯引导护士快速定位', 'DEVICE_EVENT',
 '{"eventType":"BUTTON_PRESS","deviceIdPattern":"CALL-*","debounceMs":30000}',
 '[{"action":"setBrightness","params":{"brightness":80}},{"action":"sendNotification","params":{"channels":["app_push","screen"],"message":"患者呼叫请求"}}]',
 '[1, 7]', '["301", "302", "303", "ICU-*"]', 1, 'CRITICAL', 1, NULL, 30, NULL, 5, DATE_SUB(NOW(), INTERVAL 2 HOUR), 128, 3, 1, NOW(), NOW(), 0),

(3, '查房准备模式(08:45)', '每日上午08:45自动为查房做准备：打开窗帘让自然光照入、调整病床角度至平卧、调亮灯光至70%、开启监护仪大字体显示', 'TIME_BASED',
 '{"time":"08:45","repeat":["mon","tue","wed","thu","fri"]}',
 '[{"action":"open"},{"action":"setPosition","params":{"position":"flat"}},{"action":"setBrightness","params":{"brightness":70}},{"action":"setDisplayMode","params":{"mode":"rounds"}}]',
 '[2, 5, 1, 3]', '["301", "302", "303"]', 2, 'MEDIUM', 1,
 '{"cronExpression":"45 8 * * 1-5"}', 86400, 1, 0, DATE_SUB(NOW(), INTERVAL 18 HOUR), 18, 1, 2, NOW(), NOW(), 0),

(4, '生命体征异常联动', '当监护仪监测到生命体征异常时(心率>120或<50，血氧<90%)，自动提高灯光亮度、发送多渠道告警通知、记录事件日志', 'CONDITION_BASED',
 '{"conditions":[{"metric":"heart_rate","operator":">","value":120},{"metric":"heart_rate","operator":"<","value":50},{"metric":"sp_o2","operator":"<","value":90}],"logic":"OR","durationSeconds":180}',
 '[{"action":"setBrightness","params":{"brightness":100}},{"action":"sendAlert","params":{"level":"CRITICAL","channels":["app_push","sms","call","screen"]}},{"action":"logEvent","params":{"category":"vital_signs_abnormal"}}]',
 '[1, 3]', NULL, 1, 'CRITICAL', 1, NULL, 300, 10, 3, DATE_SUB(NOW(), INTERVAL 30 MINUTE), 56, 8, 1, NOW(), NOW(), 0),

(5, '节能模式(无人在场)', '当病房连续30分钟无人活动(通过人体传感器检测)且非治疗时段，自动关闭灯光、降低空调功率至节能模式、关闭电视', 'CONDITION_BASED',
 '{"conditions":[{"sensorType":"motion","operator":"==","value":"no_motion","durationMinutes":30},{"timeRange":{"start":"09:00","end":"17:00"}}],"logic":"AND"}',
 '[{"action":"togglePower","params":{"power":"off"}},{"action":"setMode","params":{"mode":"eco"}},{"action":"togglePower","params":{"power":"off"}}]',
 '[1, 6, 8]', '["301", "302", "303"]', 3, 'LOW', 1, NULL, 1800, NULL, 0, DATE_SUB(NOW(), INTERVAL 2 HOUR), 23, 1, 2, NOW(), NOW(), 0);

-- ----------------------------
-- 表10: care_plan (护理计划表)
-- 用途: 管理患者的个性化护理计划，包括护理内容、频次、执行记录等
-- 关联: patient(通过user关联)、nurse表
-- ----------------------------
DROP TABLE IF EXISTS `care_plan`;
CREATE TABLE `care_plan` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '护理计划ID，主键自增',
  `patient_id` bigint NOT NULL COMMENT '患者ID(user表)',
  `plan_name` varchar(100) NOT NULL COMMENT '计划名称，如"术后康复护理计划"、"糖尿病日常管理"',
  `plan_type` enum('POST_OPERATIVE','CHRONIC_DISEASE','PALLIATIVE','REHABILITATION','PREVENTIVE','CUSTOM') NOT NULL COMMENT '计划类型: POST_OPERATIVE=术后 CHRONIC_DISEASE=慢性病 PALLIATIVE=姑息 REHABILITATION=康复 PREVENTIVE=预防性 CUSTOM=自定义',
  `plan_content` text NOT NULL COMMENT '护理计划详细内容(Markdown格式)',
  `diagnosis` varchar(500) DEFAULT NULL COMMENT '主要诊断',
  `admission_date` date DEFAULT NULL COMMENT '入院日期',
  `expected_discharge_date` date DEFAULT NULL COMMENT '预计出院日期',
  `actual_discharge_date` date DEFAULT NULL COMMENT '实际出院日期',
  `primary_nurse_id` bigint DEFAULT NULL COMMENT '责任护士ID',
  `attending_doctor_id` bigint DEFAULT NULL COMMENT '主治医生ID',
  `ward_number` varchar(20) DEFAULT NULL COMMENT '病房号',
  `bed_number` varchar(10) DEFAULT NULL COMMENT '床位号',
  `acuity_level` enum('LOW','MODERATE','HIGH','CRITICAL') DEFAULT 'MODERATE' COMMENT '护理等级: LOW=轻度 MODERATE=中度 HIGH=重度 CRITICAL=危重',
  `fall_risk_level` enum('LOW','MODERATE','HIGH') DEFAULT 'LOW' COMMENT '跌倒风险等级: LOW=低 MODERATE=中 HIGH=高',
  `nutrition_plan` text COMMENT '营养饮食计划',
  `medication_schedule` json DEFAULT NULL COMMENT '用药计划(JSON): 包含药物名称、剂量、时间、途径等',
  `vital_signs_monitoring` json DEFAULT NULL COMMENT '生命体征监测要求(JSON): 监测项目、频率、阈值',
  `activity_restrictions` text COMMENT '活动限制说明',
  `special_instructions` text COMMENT '特殊注意事项',
  `goals` json DEFAULT NULL COMMENT '护理目标(JSON数组)',
  `interventions` json DEFAULT NULL COMMENT '护理干预措施(JSON数组)',
  `evaluation_criteria` json DEFAULT NULL COMMENT '评估标准(JSON)',
  `frequency_per_day` int DEFAULT 1 COMMENT '每日护理频次',
  `start_time` datetime NOT NULL COMMENT '计划开始时间',
  `end_time` datetime DEFAULT NULL COMMENT '计划结束时间(NULL表示长期)',
  `status` enum('DRAFT','ACTIVE','PAUSED','COMPLETED','CANCELLED') NOT NULL DEFAULT 'DRAFT' COMMENT '状态: DRAFT=草稿 ACTIVE=执行中 PAUSED=暂停 COMPLETED=已完成 CANCELLED=已取消',
  `approval_status` enum('PENDING','APPROVED','REJECTED','REVISED') DEFAULT 'PENDING' COMMENT '审批状态: PENDING=待审批 APPROVED=已批准 REJECTED=已拒绝 REVISED=需修订',
  `approved_by` bigint DEFAULT NULL COMMENT '审批人ID(护士长/科主任)',
  `approved_time` datetime DEFAULT NULL COMMENT '审批时间',
  `revision_notes` text COMMENT '修订说明',
  `created_by` bigint NOT NULL COMMENT '创建人ID(护士)',
  `modified_by` bigint DEFAULT NULL COMMENT '最后修改人ID',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `is_deleted` tinyint NOT NULL DEFAULT 0 COMMENT '逻辑删除: 0=未删除 1=已删除',
  PRIMARY KEY (`id`),
  INDEX `idx_patient_id` (`patient_id`),
  INDEX `idx_primary_nurse` (`primary_nurse_id`),
  INDEX `idx_ward_bed` (`ward_number`, `bed_number`),
  INDEX `idx_status` (`status`),
  INDEX `idx_acuity` (`acuity_level`),
  INDEX `idx_start_end` (`start_time`, `end_time`),
  INDEX `idx_created_by` (`created_by`),
  CONSTRAINT `fk_careplan_patient` FOREIGN KEY (`patient_id`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_careplan_nurse` FOREIGN KEY (`primary_nurse_id`) REFERENCES `nurse` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='护理计划表';

-- 示例数据: 插入不同状态的护理计划
INSERT INTO `care_plan` (`id`, `patient_id`, `plan_name`, `plan_type`, `plan_content`, `diagnosis`, `admission_date`, `expected_discharge_date`, `actual_discharge_date`, `primary_nurse_id`, `attending_doctor_id`, `ward_number`, `bed_number`, `acuity_level`, `fall_risk_level`, `nutrition_plan`, `medication_schedule`, `vital_signs_monitoring`, `activity_restrictions`, `special_instructions`, `goals`, `interventions`, `evaluation_criteria`, `frequency_per_day`, `start_time`, `end_time`, `status`, `approval_status`, `approved_by`, `approved_time`, `revision_notes`, `created_by`, `modified_by`, `create_time`, `update_time`, `is_deleted`) VALUES
(1, 201, '膝关节置换术后康复护理计划', 'POST_OPERATIVE',
 '# 膝关节置换术后康复护理计划\n\n## 一、术后早期(0-3天)\n### 疼痛管理\n- 按医嘱给予镇痛药(PCIA泵)\n- 冰敷患膝20min/次，每2h一次\n- 抬高患肢20°\n\n### 伤口护理\n- 观察切口渗血情况\n- 保持敷料干燥清洁\n- 每4h观察肢体血运\n\n## 二、功能锻炼\n### 第1天\n- 踝泵运动：10次/组×3组/天\n- 股四头肌等长收缩：15次/组×3组/天\n\n### 第2-3天\n- CPM机被动屈曲：0-30°开始，每天增加10°\n- 直腿抬高训练：10次/组×3组/天\n\n## 三、并发症预防\n- DVT预防：气压治疗+抗凝药物\n- 压疮预防：每2h翻身\n- 肺部感染：深呼吸+有效咳嗽',
 '左膝关节骨性关节炎(KL III级)', '2026-05-08', '2026-05-18', NULL, 5, NULL, '301', '床1', 'HIGH', 'MODERATE',
 '高蛋白饮食(鸡蛋、鱼肉、牛奶)\n富含维生素C食物促进伤口愈合\n控制盐摄入(<6g/日)',
 '[{"drugName":"低分子肝素钙注射液","dose":"4100 IU","route":"皮下注射","frequency":"QD","time":"09:00"},{"drugName":"塞来昔布胶囊","dose":"200mg","route":"PO","frequency":"BID","time":"08:00,20:00"},{"drugName":"氨酚羟考酮片","dose":"1片","route":"PO","frequency":"PRN","time":"疼痛时","maxDose":"6片/日"}]',
 '{"items":[{"name":"体温","frequency":"Q4H","range":"36.0-37.3°C"},{"name":"心率","frequency":"Q4H","range":"60-100bpm"},{"name":"血压","frequency":"Q4H","range":"90-140/60-90mmHg"},{"name":"血氧","frequency":"Q4H","range":"≥95%"},{"name":"疼痛评分(VAS)","frequency":"PRN","range":"0-10分"},{"name":"患肢肿胀度","frequency":"Q8H"}]}',
 '术后3天内绝对卧床，床上活动\n3天后可在助行器辅助下站立\n避免盘腿、跪坐动作\n禁止患肢负重',
 '密切观察DVT征象(肿胀、疼痛、皮温升高)\n注意神经损伤表现(麻木、感觉异常)\n保持引流管通畅固定',
 '["术后3天VAS评分<4分","术后7天主动屈膝达90°","术后14天独立完成ADL","无DVT、感染等并发症"]',
 '["疼痛评估与干预(Q4H)","冰敷护理(Q2H)","CPM机训练(BID)","踝泵运动指导(TID)","抗凝药物给药(QD)","DVT风险评估(QD)","健康教育及心理支持(QD)]',
 '{"painControl":{"VAS<4@day3":true,"VAS<2@week1":true},"mobility":{"ROM_90@week1":true,"ADL_independent@week2":true},"complications":{"dvt":false,"infection":false}}',
 6, '2026-05-08 10:00:00', '2026-05-18 17:00:00', 'ACTIVE', 'APPROVED', 3, '2026-05-08 11:00:00', NULL, NULL, 5, NULL, '2026-05-08 09:30:00', NOW(), NOW(), 0),

(2, 202, '2型糖尿病综合管理护理计划', 'CHRONIC_DISEASE',
 '# 2型糖尿病综合管理护理计划\n\n## 一、血糖监测\n- 空腹血糖：每日早餐前\n- 餐后2h血糖：早、午、晚餐后2h\n- 睡前血糖：22:00前\n- 目标范围：空腹4.4-7.0mmol/L，餐后<10.0mmol/L\n\n## 二、用药管理\n- 二甲双胍缓释片 0.5g BID(早晚餐前)\n- 格列美脲片 2mg QD(早餐前)\n- 根据血糖调整剂量\n\n## 三、饮食管理\n- 控制总热量：25kcal/kg理想体重\n- 碳水化合物占50-60%\n- 低GI饮食为主\n- 少量多餐(3主餐+2加餐)\n\n## 四、运动处方\n- 快走/慢跑：30min/次，每周5次\n- 运动后测血糖防低血糖\n- 避免空腹运动\n\n## 五、并发症筛查\n- 每周测血压\n- 每月测体重、腰围\n- 每季度查糖化血红蛋白\n- 每年查眼底、尿微量白蛋白、足部神经病变',
 '2型糖尿病(病程8年)，糖尿病周围神经病变(早期)', NULL, NULL, NULL, 6, NULL, '302', '床2', 'MODERATE', 'HIGH',
 '糖尿病饮食处方(详见营养科会诊单)\n主食选择全谷物(燕麦、糙米)\n蔬菜≥500g/日\n水果在两餐之间食用\n严格限制精制糖和含糖饮料',
 '[{"drugName":"二甲双胍缓释片","dose":"0.5g","route":"PO","frequency":"BID","time":"07:30,17:30","withMeal":true},{"drugName":"格列美脲片","dose":"2mg","route":"PO","frequency":"QD","time":"07:30","beforeMeal":true}]',
 '{"items":[{"name":"空腹血糖","frequency":"QD","time":"06:30","range":"4.4-7.0mmol/L"},{"name":"早餐后2h","frequency":"QD","time":"09:30","range":"<10.0mmol/L"},{"name":"午餐后2h","frequency":"QD","time":"13:30","range":"<10.0mmol/L"},{"name":"晚餐后2h","frequency":"QD","time":"19:30","range":"<10.0mmol/L"},{"name":"睡前血糖","frequency":"QD","time":"21:30","range":"6.0-9.0mmol/L"},{"name":"血压","frequency":"QW","range":"<130/80mmHg"},{"name":"体重","frequency":"QM"},{"name":"足部检查","frequency":"QD"}]}',
 '避免长时间站立或久坐\n穿宽松透气鞋袜\n避免赤脚行走\n运动时随身携带糖果',
 '警惕低血糖症状(心悸、出汗、手抖)\n出现低血糖立即进食15g快起碳水化合物\n定期检查足部有无破损、水泡\n外出携带糖尿病急救卡',
 '["糖化血红蛋白(HbA1c)<7.0%","空腹血糖达标率>80%","无严重低血糖事件(HBG<3.9mmol/L)","体重下降5-10%","掌握自我管理技能"]',
 '["血糖监测技术指导","胰岛素注射技术培训(备用)","饮食教育(QW)","运动处方制定与监督","低血糖识别与处理教育","足部护理指导(QD)","心理支持(BIW)","家属同步教育"]',
 '{"glycemicControl":{"hba1c<7%":true,"fbg_80%target":true},"hypoglycemia":{"severe":0,"awareness":"preserved"},"complications":{"neuropathy_stable":true,"no_ulcer":true},"selfManagement":{"skills_mastered":true,"adherence>90%":true}}',
 4, '2026-05-01 00:00:00', NULL, 'ACTIVE', 'APPROVED', 3, '2026-05-01 16:00:00', NULL, NULL, 6, NULL, '2026-04-30 14:00:00', NOW(), NOW(), 0);

SET FOREIGN_KEY_CHECKS = 1;

/*
 ============================================================================
 智慧病房系统模块说明:

 表7 - ward_device (病房设备表):
   存储8台示例设备，覆盖301病房的完整IoT生态系统:
     - LIGHT(1台): 智能LED主灯，支持调光调色和场景模式
     - CURTAIN(1台): 电动开合帘，遮光率95%
     - PATIENT_MONITOR(1台): 多参数监护仪(ECG/SPO2/BP/HR/RR/TEMP)
     - INFUSION_PUMP(1台): 智能输液泵，支持堵塞检测和空气检测
     - BED(1台): 五功能电动护理床(头/脚升降、高度调节、按摩)
     - AIR_CONDITIONER(1台): 变频空调，支持ECO和静音模式
     - CALL_BUTTON(1台): 无线蓝牙呼叫按钮，带震动反馈
     - TV(1台): 55寸智能电视，儿童锁保护
   设备状态全部为ONLINE，展示完整的配置JSON和能力列表

 表8 - device_alert (设备告警表):
   存储6条示例告警，涵盖所有告警类型:
     - THRESHOLD_EXCEED(2条): 心率过高(CRITICAL)、血氧过低(CRITICAL)
     - ABNORMAL(2条): 输液泵堵塞(WARNING)、患者呼叫(INFO)
     - FAULT(1条): 灯光通信不稳定(WARNING)
     - MAINTENANCE_DUE(1条): 空调滤网更换提醒(INFO)
   展示完整生命周期: ACTIVE→ACKNOWLEDGED→IN_PROGRESS→RESOLVED→CLOSED
   包含多级升级机制(0-4级)和多渠道通知(app_push/sms/call/screen)

 表9 - automation_rule (自动化规则表):
   存储5条示例规则，展示不同触发类型:
     - TIME_BASED(2条): 夜间安静模式(22:00-06:00)、查房准备(08:45)
     - DEVICE_EVENT(1条): 紧急呼叫响应(最高优先级)
     - CONDITION_BASED(2条): 生命体征异常联动、节能模式
   规则优先级从LOW到CRITICAL，包含冷却时间和执行频率限制
   动作列表使用JSON格式，支持多设备协同控制

 表10 - care_plan (护理计划表):
   存储2条示例护理计划:
     - 术后康复计划(膝关节置换): 高护理等级，详细的康复阶段划分
     - 慢性病管理计划(2型糖尿病): 中等护理等级，长期管理方案
   包含完整的护理要素: 诊断、用药计划、监测要求、营养方案、活动限制
   支持审批流程(DRAFT→APPROVED)和状态跟踪(ACTIVE/PAUSED/COMPLETED)
*/
