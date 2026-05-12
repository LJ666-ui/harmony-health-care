-- ==========================================
-- 鸿蒙健康医疗应用 - 补充缺失表脚本
-- 版本: v1.0
-- 日期: 2026-05-10
-- 说明: 基于现有medical_health(5).sql数据库，只增加缺失的表
--       不修改现有表结构
-- ==========================================

USE medical_health;

-- ==========================================
-- 检查并创建缺失的表
-- ==========================================

-- 1. 科室表（如果不存在）
CREATE TABLE IF NOT EXISTS `department` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '科室ID',
  `hospital_id` bigint NOT NULL COMMENT '医院ID',
  `name` varchar(50) NOT NULL COMMENT '科室名称',
  `introduction` text COMMENT '简介',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `is_deleted` tinyint DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `idx_hospital_id` (`hospital_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='科室表';

-- 2. 患者分组表（如果不存在）
CREATE TABLE IF NOT EXISTS `patient_group` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '分组ID',
  `doctor_id` bigint NOT NULL COMMENT '医生ID',
  `group_name` varchar(50) NOT NULL COMMENT '分组名称',
  `description` varchar(255) DEFAULT NULL COMMENT '分组描述',
  `color` varchar(10) DEFAULT NULL COMMENT '分组颜色',
  `sort_order` int DEFAULT 0 COMMENT '排序',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `is_deleted` tinyint DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `idx_doctor_id` (`doctor_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='患者分组表';

-- 3. 患者分组关系表（如果不存在）
CREATE TABLE IF NOT EXISTS `patient_group_relation` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '关系ID',
  `group_id` bigint NOT NULL COMMENT '分组ID',
  `patient_id` bigint NOT NULL COMMENT '患者ID',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_group_patient` (`group_id`, `patient_id`),
  KEY `idx_group_id` (`group_id`),
  KEY `idx_patient_id` (`patient_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='患者分组关系表';

-- 4. 处方模板表（如果不存在）
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

-- 5. 病历模板表（如果不存在）
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

-- 6. 会诊表（如果不存在）
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

-- 7. 会诊参与人表（如果不存在）
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

-- 8. 会诊记录表（如果不存在）
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

-- 9. 用药提醒表（如果不存在）
CREATE TABLE IF NOT EXISTS `medication_reminder` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '提醒ID',
  `patient_id` bigint NOT NULL COMMENT '患者ID',
  `medication_name` varchar(100) NOT NULL COMMENT '药品名称',
  `dosage` varchar(50) DEFAULT NULL COMMENT '剂量',
  `frequency` varchar(50) DEFAULT NULL COMMENT '频次',
  `time_of_day` varchar(100) DEFAULT NULL COMMENT '服药时间',
  `status` varchar(20) DEFAULT 'PENDING' COMMENT '状态：PENDING/CONFIRMED/SKIPPED',
  `start_date` date DEFAULT NULL COMMENT '开始日期',
  `end_date` date DEFAULT NULL COMMENT '结束日期',
  `notes` text COMMENT '备注',
  `confirm_time` datetime DEFAULT NULL COMMENT '确认时间',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `is_deleted` tinyint NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `idx_patient_id` (`patient_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用药提醒表';

-- ==========================================
-- 插入测试数据（可选）
-- ==========================================

-- 插入处方模板测试数据
INSERT IGNORE INTO `prescription_template` (`doctor_id`, `template_name`, `medicines`, `notes`, `is_public`, `usage_count`)
VALUES
(1, '高血压常规处方', JSON_ARRAY(
  JSON_OBJECT('medicineId', '1', 'medicineName', '氨氯地平', 'dosage', '5mg', 'frequency', '每日一次', 'duration', '30天'),
  JSON_OBJECT('medicineId', '2', 'medicineName', '厄贝沙坦', 'dosage', '150mg', 'frequency', '每日一次', 'duration', '30天')
), '注意监测血压', 1, 5);

-- 插入病历模板测试数据
INSERT IGNORE INTO `medical_record_template` (`doctor_id`, `template_name`, `diagnosis_template`, `treatment_template`, `notes_template`, `is_public`, `usage_count`)
VALUES
(1, '高血压初诊病历', '高血压病', '1. 生活方式干预\n2. 药物治疗', '注意监测血压，定期复查', 1, 3);

-- 插入会诊测试数据
INSERT IGNORE INTO `consultation` (`initiator_id`, `patient_id`, `title`, `description`, `status`, `scheduled_time`)
VALUES
(1, 1, '多学科会诊', '患者病情复杂，需要多科室会诊', 'pending', DATE_ADD(NOW(), INTERVAL 1 DAY));

-- ==========================================
-- 验证表创建
-- ==========================================

SELECT '========================================' AS '';
SELECT '缺失表补充完成！' AS message;
SELECT '========================================' AS '';
SELECT '新增表清单:' AS '';
SELECT '1. department (科室表)' AS table_name;
SELECT '2. patient_group (患者分组表)' AS table_name;
SELECT '3. patient_group_relation (患者分组关系表)' AS table_name;
SELECT '4. prescription_template (处方模板表)' AS table_name;
SELECT '5. medical_record_template (病历模板表)' AS table_name;
SELECT '6. consultation (会诊表)' AS table_name;
SELECT '7. consultation_participant (会诊参与人表)' AS table_name;
SELECT '8. consultation_record (会诊记录表)' AS table_name;
SELECT '9. medication_reminder (用药提醒表)' AS table_name;
SELECT '========================================' AS '';

-- 显示所有表
SELECT 
  TABLE_NAME AS '表名',
  TABLE_COMMENT AS '表说明',
  CREATE_TIME AS '创建时间'
FROM information_schema.TABLES 
WHERE TABLE_SCHEMA = 'medical_health' 
ORDER BY TABLE_NAME;
