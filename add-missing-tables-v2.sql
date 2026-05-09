-- ==========================================
-- 鸿蒙健康医疗应用 - 补充真正缺失的表
-- 版本: v2.0
-- 日期: 2026-05-10
-- 说明: 根据实际数据库情况，只增加真正缺失的表
--       已存在的表：consultation, prescription_template
--       缺失的表：patient_group, patient_group_relation, 
--                medical_record_template, consultation_participant,
--                consultation_record, medication_reminder
-- ==========================================

USE medical_health;

-- ==========================================
-- 检查并创建真正缺失的表
-- ==========================================

-- 1. 患者分组表（如果不存在）
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

-- 2. 患者分组关系表（如果不存在）
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

-- 3. 病历模板表（如果不存在）
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

-- 4. 会诊参与人表（如果不存在）
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

-- 5. 会诊记录表（如果不存在）
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

-- 6. 用药提醒表（如果不存在）
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

-- 插入病历模板测试数据
INSERT IGNORE INTO `medical_record_template` (`doctor_id`, `template_name`, `diagnosis_template`, `treatment_template`, `notes_template`, `is_public`, `usage_count`)
VALUES
(1, '高血压初诊病历', '高血压病', '1. 生活方式干预\n2. 药物治疗', '注意监测血压，定期复查', 1, 3),
(1, '糖尿病初诊病历', '2型糖尿病', '1. 饮食控制\n2. 运动治疗\n3. 药物治疗', '定期监测血糖，注意低血糖反应', 1, 2);

-- 插入患者分组测试数据
INSERT IGNORE INTO `patient_group` (`doctor_id`, `group_name`, `description`, `color`, `sort_order`)
VALUES
(1, '高血压患者', '高血压慢病管理', '#FF6B6B', 1),
(1, '糖尿病患者', '糖尿病慢病管理', '#4ECDC4', 2),
(1, '重点关注', '需要特别关注的患者', '#FFE66D', 3);

-- ==========================================
-- 验证表创建
-- ==========================================

SELECT '========================================' AS '';
SELECT '缺失表补充完成！' AS message;
SELECT '========================================' AS '';
SELECT '新增表清单:' AS '';
SELECT '1. patient_group (患者分组表)' AS table_name;
SELECT '2. patient_group_relation (患者分组关系表)' AS table_name;
SELECT '3. medical_record_template (病历模板表)' AS table_name;
SELECT '4. consultation_participant (会诊参与人表)' AS table_name;
SELECT '5. consultation_record (会诊记录表)' AS table_name;
SELECT '6. medication_reminder (用药提醒表)' AS table_name;
SELECT '========================================' AS '';
SELECT '已存在的表（未重复创建）:' AS '';
SELECT '- consultation (会诊表)' AS table_name;
SELECT '- prescription_template (处方模板表)' AS table_name;
SELECT '- hospital_department (科室表，代替department)' AS table_name;
SELECT '========================================' AS '';

-- 显示新增的表结构
SELECT 
  TABLE_NAME AS '表名',
  TABLE_COMMENT AS '表说明',
  CREATE_TIME AS '创建时间'
FROM information_schema.TABLES 
WHERE TABLE_SCHEMA = 'medical_health' 
AND TABLE_NAME IN (
  'patient_group', 'patient_group_relation', 'medical_record_template',
  'consultation_participant', 'consultation_record', 'medication_reminder'
)
ORDER BY TABLE_NAME;
