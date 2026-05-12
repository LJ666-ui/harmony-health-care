-- ==========================================
-- 星云医疗助手项目优化 - 数据库更新脚本
-- 版本: v1.0
-- 日期: 2026-05-10
-- 说明: 新建表和索引优化
-- ==========================================

-- ==========================================
-- 第一部分：新建数据表
-- ==========================================

-- 1. 医生排班表
CREATE TABLE IF NOT EXISTS `doctor_schedule` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `doctor_id` bigint NOT NULL COMMENT '医生ID',
  `hospital_id` bigint NOT NULL COMMENT '医院ID',
  `department_id` bigint NOT NULL COMMENT '科室ID',
  `schedule_date` date NOT NULL COMMENT '排班日期',
  `time_slot_id` bigint NOT NULL COMMENT '时间段ID',
  `start_time` time NOT NULL COMMENT '开始时间',
  `end_time` time NOT NULL COMMENT '结束时间',
  `max_appointments` int NOT NULL DEFAULT 20 COMMENT '最大预约数',
  `booked_appointments` int NOT NULL DEFAULT 0 COMMENT '已预约数',
  `status` varchar(20) NOT NULL DEFAULT 'available' COMMENT '状态：available-可预约, full-已满, cancelled-已取消',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_doctor_id` (`doctor_id`),
  KEY `idx_schedule_date` (`schedule_date`),
  KEY `idx_hospital_department` (`hospital_id`, `department_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='医生排班表';

-- 2. 处方模板表
CREATE TABLE IF NOT EXISTS `prescription_template` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `doctor_id` bigint NOT NULL COMMENT '医生ID',
  `template_name` varchar(100) NOT NULL COMMENT '模板名称',
  `medicines` json NOT NULL COMMENT '药品列表',
  `notes` text COMMENT '备注',
  `is_public` tinyint NOT NULL DEFAULT 0 COMMENT '是否公开：0-私有，1-公开',
  `usage_count` int NOT NULL DEFAULT 0 COMMENT '使用次数',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_doctor_id` (`doctor_id`),
  KEY `idx_is_public` (`is_public`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='处方模板表';

-- 3. 病历模板表
CREATE TABLE IF NOT EXISTS `medical_record_template` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `doctor_id` bigint NOT NULL COMMENT '医生ID',
  `template_name` varchar(100) NOT NULL COMMENT '模板名称',
  `diagnosis_template` text COMMENT '诊断模板',
  `treatment_template` text COMMENT '治疗方案模板',
  `notes_template` text COMMENT '备注模板',
  `is_public` tinyint NOT NULL DEFAULT 0 COMMENT '是否公开：0-私有，1-公开',
  `usage_count` int NOT NULL DEFAULT 0 COMMENT '使用次数',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_doctor_id` (`doctor_id`),
  KEY `idx_is_public` (`is_public`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='病历模板表';

-- 4. 会诊表
CREATE TABLE IF NOT EXISTS `consultation` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `initiator_id` bigint NOT NULL COMMENT '发起人ID',
  `patient_id` bigint NOT NULL COMMENT '患者ID',
  `title` varchar(200) NOT NULL COMMENT '会诊标题',
  `description` text COMMENT '会诊描述',
  `status` varchar(20) NOT NULL DEFAULT 'pending' COMMENT '状态：pending-待开始, in_progress-进行中, completed-已完成, cancelled-已取消',
  `scheduled_time` datetime COMMENT '预定开始时间',
  `started_time` datetime COMMENT '实际开始时间',
  `ended_time` datetime COMMENT '实际结束时间',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_initiator_id` (`initiator_id`),
  KEY `idx_patient_id` (`patient_id`),
  KEY `idx_status` (`status`),
  KEY `idx_scheduled_time` (`scheduled_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='会诊表';

-- 5. 会诊参与人表
CREATE TABLE IF NOT EXISTS `consultation_participant` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `consultation_id` bigint NOT NULL COMMENT '会诊ID',
  `doctor_id` bigint NOT NULL COMMENT '医生ID',
  `department_id` bigint NOT NULL COMMENT '科室ID',
  `status` varchar(20) NOT NULL DEFAULT 'invited' COMMENT '状态：invited-已邀请, accepted-已接受, declined-已拒绝',
  `joined_time` datetime COMMENT '加入时间',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_consultation_id` (`consultation_id`),
  KEY `idx_doctor_id` (`doctor_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='会诊参与人表';

-- 6. 会诊记录表
CREATE TABLE IF NOT EXISTS `consultation_record` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `consultation_id` bigint NOT NULL COMMENT '会诊ID',
  `doctor_id` bigint NOT NULL COMMENT '医生ID',
  `content` text NOT NULL COMMENT '记录内容',
  `record_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '记录时间',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `idx_consultation_id` (`consultation_id`),
  KEY `idx_doctor_id` (`doctor_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='会诊记录表';

-- 7. 数据访问申请表
CREATE TABLE IF NOT EXISTS `data_access_application` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `requester_id` bigint NOT NULL COMMENT '申请人ID',
  `requester_role` varchar(20) NOT NULL COMMENT '申请人角色',
  `approver_id` bigint COMMENT '审批人ID',
  `data_type` varchar(50) NOT NULL COMMENT '数据类型',
  `data_id` bigint NOT NULL COMMENT '数据ID',
  `reason` text NOT NULL COMMENT '申请原因',
  `duration` int NOT NULL COMMENT '访问时长（小时）',
  `status` varchar(20) NOT NULL DEFAULT 'pending' COMMENT '状态：pending-待审批, approved-已批准, rejected-已拒绝, expired-已过期',
  `approved_at` datetime COMMENT '审批时间',
  `expires_at` datetime COMMENT '过期时间',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_requester_id` (`requester_id`),
  KEY `idx_approver_id` (`approver_id`),
  KEY `idx_status` (`status`),
  KEY `idx_data` (`data_type`, `data_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='数据访问申请表';

-- 8. 敏感操作表
CREATE TABLE IF NOT EXISTS `sensitive_operation` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `operation_type` varchar(50) NOT NULL COMMENT '操作类型：delete, update, export',
  `resource_type` varchar(50) NOT NULL COMMENT '资源类型',
  `resource_id` bigint NOT NULL COMMENT '资源ID',
  `reason` text COMMENT '操作原因',
  `status` varchar(20) NOT NULL DEFAULT 'pending_confirmation' COMMENT '状态：pending_confirmation-待确认, confirmed-已确认, cancelled-已取消',
  `confirmation_code` varchar(10) NOT NULL COMMENT '确认码',
  `confirmed_at` datetime COMMENT '确认时间',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_status` (`status`),
  KEY `idx_resource` (`resource_type`, `resource_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='敏感操作表';

-- 9. 异常登录记录表
CREATE TABLE IF NOT EXISTS `abnormal_login` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `login_time` datetime NOT NULL COMMENT '登录时间',
  `login_location` varchar(100) COMMENT '登录地点',
  `device_info` varchar(200) COMMENT '设备信息',
  `ip_address` varchar(50) COMMENT 'IP地址',
  `abnormal_reason` varchar(100) NOT NULL COMMENT '异常原因：abnormal_location-异地登录, abnormal_device-异常设备, abnormal_time-异常时间',
  `risk_level` varchar(20) NOT NULL COMMENT '风险等级：low-低, medium-中, high-高',
  `is_handled` tinyint NOT NULL DEFAULT 0 COMMENT '是否已处理：0-未处理，1-已处理',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_login_time` (`login_time`),
  KEY `idx_risk_level` (`risk_level`),
  KEY `idx_is_handled` (`is_handled`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='异常登录记录表';

-- ==========================================
-- 第二部分：优化现有数据表索引
-- ==========================================

-- 优化 health_record 表
ALTER TABLE `health_record` ADD INDEX IF NOT EXISTS `idx_record_time` (`record_time`);
ALTER TABLE `health_record` ADD INDEX IF NOT EXISTS `idx_user_record_type` (`user_id`, `record_type`);

-- 优化 medical_record 表
ALTER TABLE `medical_record` ADD INDEX IF NOT EXISTS `idx_patient_doctor` (`patient_id`, `doctor_id`);
ALTER TABLE `medical_record` ADD INDEX IF NOT EXISTS `idx_created_at` (`created_at`);

-- 优化 prescription 表
ALTER TABLE `prescription` ADD INDEX IF NOT EXISTS `idx_patient_doctor` (`patient_id`, `doctor_id`);
ALTER TABLE `prescription` ADD INDEX IF NOT EXISTS `idx_created_at` (`created_at`);

-- 优化 medication_reminder 表
ALTER TABLE `medication_reminder` ADD INDEX IF NOT EXISTS `idx_patient_reminder_time` (`patient_id`, `reminder_time`);
ALTER TABLE `medication_reminder` ADD INDEX IF NOT EXISTS `idx_status` (`status`);

-- 优化 doctor_message 表
ALTER TABLE `doctor_message` ADD INDEX IF NOT EXISTS `idx_session_send_time` (`session_id`, `send_time`);
ALTER TABLE `doctor_message` ADD INDEX IF NOT EXISTS `idx_receiver_read_status` (`receiver_id`, `read_status`);

-- 优化 data_access_log 表
ALTER TABLE `data_access_log` ADD INDEX IF NOT EXISTS `idx_accessor_data` (`accessor_id`, `data_id`);
ALTER TABLE `data_access_log` ADD INDEX IF NOT EXISTS `idx_access_time` (`access_time`);

-- ==========================================
-- 第三部分：插入测试数据（可选）
-- ==========================================

-- 插入医生排班测试数据
INSERT INTO `doctor_schedule` (`doctor_id`, `hospital_id`, `department_id`, `schedule_date`, `time_slot_id`, `start_time`, `end_time`, `max_appointments`, `booked_appointments`, `status`)
VALUES
(1, 1, 1, CURDATE(), 1, '08:00:00', '12:00:00', 20, 15, 'available'),
(1, 1, 1, CURDATE(), 2, '14:00:00', '17:00:00', 15, 10, 'available');

-- 插入处方模板测试数据
INSERT INTO `prescription_template` (`doctor_id`, `template_name`, `medicines`, `notes`, `is_public`, `usage_count`)
VALUES
(1, '高血压常规处方', JSON_ARRAY(
  JSON_OBJECT('medicineId', '1', 'medicineName', '氨氯地平', 'dosage', '5mg', 'frequency', '每日一次', 'duration', '30天'),
  JSON_OBJECT('medicineId', '2', 'medicineName', '厄贝沙坦', 'dosage', '150mg', 'frequency', '每日一次', 'duration', '30天')
), '注意监测血压', 1, 5);

-- 插入病历模板测试数据
INSERT INTO `medical_record_template` (`doctor_id`, `template_name`, `diagnosis_template`, `treatment_template`, `notes_template`, `is_public`, `usage_count`)
VALUES
(1, '高血压初诊病历', '高血压病', '1. 生活方式干预\n2. 药物治疗', '注意监测血压，定期复查', 1, 3);

-- 插入会诊测试数据
INSERT INTO `consultation` (`initiator_id`, `patient_id`, `title`, `description`, `status`, `scheduled_time`)
VALUES
(1, 1, '多学科会诊', '患者病情复杂，需要多科室会诊', 'pending', DATE_ADD(NOW(), INTERVAL 1 DAY));

-- 插入会诊参与人测试数据
INSERT INTO `consultation_participant` (`consultation_id`, `doctor_id`, `department_id`, `status`)
VALUES
(1, 1, 1, 'accepted'),
(1, 2, 2, 'invited'),
(1, 3, 3, 'invited');

-- 插入会诊记录测试数据
INSERT INTO `consultation_record` (`consultation_id`, `doctor_id`, `content`)
VALUES
(1, 1, '患者血压控制不佳，建议调整用药');

-- ==========================================
-- 脚本执行完成
-- ==========================================
