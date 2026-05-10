-- 患者端功能扩展表结构
-- 创建时间: 2026-05-10
-- 说明: 添加问诊会话、处方、体检报告、健康预警、用药记录等表

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for consultation_session (问诊会话表)
-- ----------------------------
DROP TABLE IF EXISTS `consultation_session`;
CREATE TABLE `consultation_session` (
  `session_id` bigint NOT NULL AUTO_INCREMENT COMMENT '会话ID',
  `user_id` bigint NOT NULL COMMENT '患者用户ID',
  `doctor_id` bigint NOT NULL COMMENT '医生ID',
  `consultation_type` varchar(20) NOT NULL COMMENT '问诊类型: text=图文, voice=语音, video=视频',
  `status` varchar(20) NOT NULL DEFAULT 'active' COMMENT '会话状态: active=进行中, ended=已结束, cancelled=已取消',
  `start_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '开始时间',
  `end_time` datetime NULL DEFAULT NULL COMMENT '结束时间',
  `last_message_time` datetime NULL DEFAULT NULL COMMENT '最后消息时间',
  `consultation_fee` decimal(10, 2) NULL DEFAULT NULL COMMENT '问诊费用',
  `rating` int NULL DEFAULT NULL COMMENT '患者评分: 1-5',
  `rating_comment` text NULL COMMENT '评价内容',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`session_id`) USING BTREE,
  INDEX `idx_user_id` (`user_id`) USING BTREE,
  INDEX `idx_doctor_id` (`doctor_id`) USING BTREE,
  INDEX `idx_status` (`status`) USING BTREE,
  INDEX `idx_start_time` (`start_time`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '问诊会话表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for consultation_message (问诊消息表)
-- ----------------------------
DROP TABLE IF EXISTS `consultation_message`;
CREATE TABLE `consultation_message` (
  `message_id` bigint NOT NULL AUTO_INCREMENT COMMENT '消息ID',
  `session_id` bigint NOT NULL COMMENT '会话ID',
  `sender_id` bigint NOT NULL COMMENT '发送者ID',
  `sender_type` varchar(20) NOT NULL COMMENT '发送者类型: patient=患者, doctor=医生',
  `content` text NULL COMMENT '消息内容',
  `message_type` varchar(20) NOT NULL DEFAULT 'text' COMMENT '消息类型: text=文字, image=图片, voice=语音, video=视频',
  `media_url` varchar(255) NULL DEFAULT NULL COMMENT '媒体文件URL',
  `duration` int NULL DEFAULT NULL COMMENT '语音/视频时长(秒)',
  `status` varchar(20) NOT NULL DEFAULT 'sent' COMMENT '消息状态: sending=发送中, sent=已发送, failed=发送失败',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`message_id`) USING BTREE,
  INDEX `idx_session_id` (`session_id`) USING BTREE,
  INDEX `idx_sender_id` (`sender_id`) USING BTREE,
  INDEX `idx_create_time` (`create_time`) USING BTREE,
  CONSTRAINT `fk_message_session` FOREIGN KEY (`session_id`) REFERENCES `consultation_session` (`session_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '问诊消息表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for prescription (处方表)
-- ----------------------------
DROP TABLE IF EXISTS `prescription`;
CREATE TABLE `prescription` (
  `prescription_id` bigint NOT NULL AUTO_INCREMENT COMMENT '处方ID',
  `session_id` bigint NULL DEFAULT NULL COMMENT '问诊会话ID',
  `user_id` bigint NOT NULL COMMENT '患者用户ID',
  `doctor_id` bigint NOT NULL COMMENT '医生ID',
  `prescription_no` varchar(50) NOT NULL COMMENT '处方编号',
  `diagnosis` text NULL COMMENT '诊断结果',
  `prescription_content` text NOT NULL COMMENT '处方内容JSON',
  `usage_instruction` text NULL COMMENT '用法说明',
  `valid_days` int NOT NULL DEFAULT 30 COMMENT '有效期(天)',
  `status` varchar(20) NOT NULL DEFAULT 'active' COMMENT '状态: active=有效, expired=已过期, cancelled=已取消',
  `prescription_fee` decimal(10, 2) NULL DEFAULT NULL COMMENT '处方费用',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`prescription_id`) USING BTREE,
  INDEX `idx_user_id` (`user_id`) USING BTREE,
  INDEX `idx_doctor_id` (`doctor_id`) USING BTREE,
  INDEX `idx_session_id` (`session_id`) USING BTREE,
  INDEX `idx_status` (`status`) USING BTREE,
  CONSTRAINT `fk_prescription_session` FOREIGN KEY (`session_id`) REFERENCES `consultation_session` (`session_id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '处方表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for checkup_report (体检报告表)
-- ----------------------------
DROP TABLE IF EXISTS `checkup_report`;
CREATE TABLE `checkup_report` (
  `report_id` bigint NOT NULL AUTO_INCREMENT COMMENT '报告ID',
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `report_no` varchar(50) NOT NULL COMMENT '报告编号',
  `report_type` varchar(50) NOT NULL COMMENT '报告类型: annual=年度体检, special=专项检查, follow_up=复查',
  `hospital_id` bigint NULL DEFAULT NULL COMMENT '医院ID',
  `hospital_name` varchar(100) NULL DEFAULT NULL COMMENT '医院名称',
  `checkup_date` date NOT NULL COMMENT '体检日期',
  `report_url` varchar(255) NULL DEFAULT NULL COMMENT '报告PDF URL',
  `report_summary` text NULL COMMENT '报告摘要',
  `abnormal_items` text NULL COMMENT '异常项JSON',
  `doctor_advice` text NULL COMMENT '医生建议',
  `status` varchar(20) NOT NULL DEFAULT 'completed' COMMENT '状态: pending=待出报告, completed=已完成, reviewed=已查看',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`report_id`) USING BTREE,
  INDEX `idx_user_id` (`user_id`) USING BTREE,
  INDEX `idx_checkup_date` (`checkup_date`) USING BTREE,
  INDEX `idx_status` (`status`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '体检报告表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for health_alert (健康预警表)
-- ----------------------------
DROP TABLE IF EXISTS `health_alert`;
CREATE TABLE `health_alert` (
  `alert_id` bigint NOT NULL AUTO_INCREMENT COMMENT '预警ID',
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `alert_type` varchar(50) NOT NULL COMMENT '预警类型: blood_pressure=血压, blood_sugar=血糖, heart_rate=心率, medication=用药, appointment=预约',
  `alert_level` varchar(20) NOT NULL COMMENT '预警级别: low=低, medium=中, high=高, critical=严重',
  `alert_title` varchar(200) NOT NULL COMMENT '预警标题',
  `alert_content` text NOT NULL COMMENT '预警内容',
  `threshold_value` varchar(100) NULL DEFAULT NULL COMMENT '阈值',
  `actual_value` varchar(100) NULL DEFAULT NULL COMMENT '实际值',
  `status` varchar(20) NOT NULL DEFAULT 'active' COMMENT '状态: active=活跃, handled=已处理, ignored=已忽略',
  `handle_time` datetime NULL DEFAULT NULL COMMENT '处理时间',
  `handle_note` text NULL COMMENT '处理备注',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`alert_id`) USING BTREE,
  INDEX `idx_user_id` (`user_id`) USING BTREE,
  INDEX `idx_alert_type` (`alert_type`) USING BTREE,
  INDEX `idx_alert_level` (`alert_level`) USING BTREE,
  INDEX `idx_status` (`status`) USING BTREE,
  INDEX `idx_create_time` (`create_time`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '健康预警表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for medication_record (用药记录表)
-- ----------------------------
DROP TABLE IF EXISTS `medication_record`;
CREATE TABLE `medication_record` (
  `record_id` bigint NOT NULL AUTO_INCREMENT COMMENT '记录ID',
  `reminder_id` bigint NULL DEFAULT NULL COMMENT '提醒ID',
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `medication_name` varchar(100) NOT NULL COMMENT '药品名称',
  `dosage` varchar(50) NOT NULL COMMENT '剂量',
  `medication_time` datetime NOT NULL COMMENT '用药时间',
  `status` varchar(20) NOT NULL DEFAULT 'taken' COMMENT '状态: taken=已服用, skipped=已跳过, missed=漏服',
  `note` text NULL COMMENT '备注',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`record_id`) USING BTREE,
  INDEX `idx_user_id` (`user_id`) USING BTREE,
  INDEX `idx_reminder_id` (`reminder_id`) USING BTREE,
  INDEX `idx_medication_time` (`medication_time`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '用药记录表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- 优化现有表结构
-- ----------------------------

-- 优化appointment表
ALTER TABLE `appointment` 
ADD COLUMN IF NOT EXISTS `cancel_reason` varchar(200) NULL DEFAULT NULL COMMENT '取消原因' AFTER `status`;

-- 添加索引（如果不存在）
CREATE INDEX IF NOT EXISTS `idx_appointment_time` ON `appointment` (`appointment_time`);

-- 优化medical_record表
ALTER TABLE `medical_record`
ADD COLUMN IF NOT EXISTS `record_type` varchar(20) NULL DEFAULT 'outpatient' COMMENT '记录类型: outpatient=门诊, inpatient=住院' AFTER `user_id`;

-- 添加索引（如果不存在）
CREATE INDEX IF NOT EXISTS `idx_visit_time` ON `medical_record` (`visit_time`);

-- 优化health_record表
ALTER TABLE `health_record`
ADD COLUMN IF NOT EXISTS `data_source` varchar(20) NULL DEFAULT 'manual' COMMENT '数据来源: manual=手动录入, device=设备同步' AFTER `value`;

-- 添加索引（如果不存在）
CREATE INDEX IF NOT EXISTS `idx_record_date` ON `health_record` (`record_date`);

SET FOREIGN_KEY_CHECKS = 1;
