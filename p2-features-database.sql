-- ========================================
-- P2优先级功能 - 数据库表创建
-- ========================================

USE medical_health;

-- 患者分组表
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

-- 患者分组关系表
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

-- 医学影像表
CREATE TABLE IF NOT EXISTS `medical_image` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '影像ID',
  `patient_id` bigint NOT NULL COMMENT '患者ID',
  `doctor_id` bigint NOT NULL COMMENT '医生ID',
  `image_type` varchar(50) NOT NULL COMMENT '影像类型：CT、MRI、X光、超声等',
  `image_url` varchar(255) NOT NULL COMMENT '影像URL',
  `thumbnail_url` varchar(255) DEFAULT NULL COMMENT '缩略图URL',
  `description` text COMMENT '影像描述',
  `diagnosis` text COMMENT '诊断结果',
  `image_time` datetime DEFAULT NULL COMMENT '影像时间',
  `status` tinyint DEFAULT 0 COMMENT '状态：0-待分析，1-已分析',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `is_deleted` tinyint DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `idx_patient_id` (`patient_id`),
  KEY `idx_doctor_id` (`doctor_id`),
  KEY `idx_image_time` (`image_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='医学影像表';

-- 检验报告表
CREATE TABLE IF NOT EXISTS `lab_report` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '报告ID',
  `patient_id` bigint NOT NULL COMMENT '患者ID',
  `doctor_id` bigint DEFAULT NULL COMMENT '医生ID',
  `report_type` varchar(50) NOT NULL COMMENT '报告类型：血常规、尿常规、生化等',
  `report_no` varchar(50) DEFAULT NULL COMMENT '报告编号',
  `report_data` text COMMENT '报告数据（JSON格式）',
  `conclusion` text COMMENT '结论',
  `is_abnormal` tinyint DEFAULT 0 COMMENT '是否有异常',
  `report_time` datetime DEFAULT NULL COMMENT '报告时间',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `is_deleted` tinyint DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `idx_patient_id` (`patient_id`),
  KEY `idx_report_time` (`report_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='检验报告表';

-- 转诊记录表
CREATE TABLE IF NOT EXISTS `referral` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '转诊ID',
  `patient_id` bigint NOT NULL COMMENT '患者ID',
  `from_doctor_id` bigint NOT NULL COMMENT '转出医生ID',
  `to_doctor_id` bigint DEFAULT NULL COMMENT '转入医生ID',
  `from_hospital_id` bigint DEFAULT NULL COMMENT '转出医院ID',
  `to_hospital_id` bigint DEFAULT NULL COMMENT '转入医院ID',
  `from_department_id` bigint DEFAULT NULL COMMENT '转出科室ID',
  `to_department_id` bigint DEFAULT NULL COMMENT '转入科室ID',
  `reason` text COMMENT '转诊原因',
  `diagnosis` text COMMENT '诊断',
  `status` tinyint DEFAULT 0 COMMENT '状态：0-待接收，1-已接收，2-已完成，3-已取消',
  `referral_time` datetime DEFAULT NULL COMMENT '转诊时间',
  `receive_time` datetime DEFAULT NULL COMMENT '接收时间',
  `complete_time` datetime DEFAULT NULL COMMENT '完成时间',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `is_deleted` tinyint DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `idx_patient_id` (`patient_id`),
  KEY `idx_from_doctor_id` (`from_doctor_id`),
  KEY `idx_to_doctor_id` (`to_doctor_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='转诊记录表';

-- 随访记录表
CREATE TABLE IF NOT EXISTS `follow_up` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '随访ID',
  `patient_id` bigint NOT NULL COMMENT '患者ID',
  `doctor_id` bigint NOT NULL COMMENT '医生ID',
  `follow_type` varchar(20) NOT NULL COMMENT '随访类型：门诊、电话、上门',
  `plan_time` datetime NOT NULL COMMENT '计划时间',
  `actual_time` datetime DEFAULT NULL COMMENT '实际时间',
  `content` text COMMENT '随访内容',
  `result` text COMMENT '随访结果',
  `next_plan_time` datetime DEFAULT NULL COMMENT '下次计划时间',
  `status` tinyint DEFAULT 0 COMMENT '状态：0-待随访，1-已完成，2-已取消',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `is_deleted` tinyint DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `idx_patient_id` (`patient_id`),
  KEY `idx_doctor_id` (`doctor_id`),
  KEY `idx_plan_time` (`plan_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='随访记录表';

-- 患者评价表
CREATE TABLE IF NOT EXISTS `patient_review` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '评价ID',
  `patient_id` bigint NOT NULL COMMENT '患者ID',
  `doctor_id` bigint NOT NULL COMMENT '医生ID',
  `appointment_id` bigint DEFAULT NULL COMMENT '预约ID',
  `rating` int NOT NULL COMMENT '评分：1-5',
  `content` text COMMENT '评价内容',
  `tags` varchar(255) DEFAULT NULL COMMENT '标签（JSON格式）',
  `is_anonymous` tinyint DEFAULT 0 COMMENT '是否匿名',
  `reply` text COMMENT '医生回复',
  `reply_time` datetime DEFAULT NULL COMMENT '回复时间',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `is_deleted` tinyint DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `idx_patient_id` (`patient_id`),
  KEY `idx_doctor_id` (`doctor_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='患者评价表';

-- 数据统计表
CREATE TABLE IF NOT EXISTS `data_statistics` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '统计ID',
  `stat_type` varchar(50) NOT NULL COMMENT '统计类型',
  `stat_date` date NOT NULL COMMENT '统计日期',
  `stat_data` text COMMENT '统计数据（JSON格式）',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_type_date` (`stat_type`, `stat_date`),
  KEY `idx_stat_date` (`stat_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='数据统计表';

-- ========================================
-- 创建完成
-- ========================================
SELECT 'P2功能数据表创建完成！' AS message;
