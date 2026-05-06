-- ========================================
-- 鸿蒙健康医疗应用 - 数据库初始化脚本
-- ========================================

-- 创建数据库
CREATE DATABASE IF NOT EXISTS medical_health 
DEFAULT CHARACTER SET utf8mb4 
COLLATE utf8mb4_general_ci;

-- 使用数据库
USE medical_health;

-- 用户表
CREATE TABLE IF NOT EXISTS `user` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '用户ID',
  `username` varchar(50) NOT NULL COMMENT '用户名/手机号',
  `password` varchar(100) NOT NULL COMMENT '密码',
  `nickname` varchar(50) DEFAULT NULL COMMENT '昵称',
  `avatar` varchar(255) DEFAULT NULL COMMENT '头像',
  `gender` tinyint DEFAULT NULL COMMENT '性别：0-女，1-男',
  `age` int DEFAULT NULL COMMENT '年龄',
  `id_card` varchar(18) DEFAULT NULL COMMENT '身份证号',
  `phone` varchar(20) DEFAULT NULL COMMENT '手机号',
  `email` varchar(50) DEFAULT NULL COMMENT '邮箱',
  `user_type` tinyint DEFAULT 0 COMMENT '用户类型：0-普通用户，1-医生',
  `real_name` varchar(50) DEFAULT NULL COMMENT '真实姓名',
  `hospital` varchar(100) DEFAULT NULL COMMENT '所属医院',
  `department` varchar(50) DEFAULT NULL COMMENT '科室',
  `license_number` varchar(50) DEFAULT NULL COMMENT '执业证号',
  `status` tinyint DEFAULT 1 COMMENT '状态：0-禁用，1-正常',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `is_deleted` tinyint DEFAULT 0 COMMENT '是否删除：0-否，1-是',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户表';

-- 医院表
CREATE TABLE IF NOT EXISTS `hospital` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '医院ID',
  `name` varchar(100) NOT NULL COMMENT '医院名称',
  `level` varchar(20) DEFAULT NULL COMMENT '医院等级',
  `address` varchar(255) DEFAULT NULL COMMENT '地址',
  `phone` varchar(20) DEFAULT NULL COMMENT '电话',
  `introduction` text COMMENT '简介',
  `image` varchar(255) DEFAULT NULL COMMENT '图片',
  `latitude` decimal(10,6) DEFAULT NULL COMMENT '纬度',
  `longitude` decimal(10,6) DEFAULT NULL COMMENT '经度',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `is_deleted` tinyint DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='医院表';

-- 科室表
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

-- 医生表
CREATE TABLE IF NOT EXISTS `doctor` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '医生ID',
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `hospital_id` bigint DEFAULT NULL COMMENT '医院ID',
  `department_id` bigint DEFAULT NULL COMMENT '科室ID',
  `name` varchar(50) NOT NULL COMMENT '姓名',
  `title` varchar(50) DEFAULT NULL COMMENT '职称',
  `specialty` varchar(255) DEFAULT NULL COMMENT '擅长',
  `introduction` text COMMENT '简介',
  `image` varchar(255) DEFAULT NULL COMMENT '头像',
  `license_no` varchar(50) DEFAULT NULL COMMENT '执业证号',
  `status` tinyint DEFAULT 1 COMMENT '状态：0-禁用，1-正常',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `is_deleted` tinyint DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_hospital_id` (`hospital_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='医生表';

-- 预约表
CREATE TABLE IF NOT EXISTS `appointment` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '预约ID',
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `doctor_id` bigint NOT NULL COMMENT '医生ID',
  `hospital_id` bigint NOT NULL COMMENT '医院ID',
  `appointment_time` datetime NOT NULL COMMENT '预约时间',
  `status` tinyint DEFAULT 0 COMMENT '状态：0-待确认，1-已确认，2-已完成，3-已取消',
  `symptom` text COMMENT '症状描述',
  `remark` varchar(255) DEFAULT NULL COMMENT '备注',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `is_deleted` tinyint DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_doctor_id` (`doctor_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='预约表';

-- 健康记录表
CREATE TABLE IF NOT EXISTS `health_record` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '记录ID',
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `record_type` varchar(20) NOT NULL COMMENT '记录类型',
  `title` varchar(100) DEFAULT NULL COMMENT '标题',
  `content` text COMMENT '内容',
  `value` decimal(10,2) DEFAULT NULL COMMENT '数值',
  `unit` varchar(20) DEFAULT NULL COMMENT '单位',
  `record_time` datetime DEFAULT NULL COMMENT '记录时间',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `is_deleted` tinyint DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='健康记录表';

-- 插入测试数据
-- 测试用户（密码：123456，已加密）
INSERT INTO `user` (`username`, `password`, `nickname`, `user_type`, `status`) VALUES
('13800138000', '$2a$10$N.zmdr9k7uOCQv37uk7jO.9.Mq8P5x1KQJ5Z5Z5Z5Z5Z5Z5Z5Z5Z5', '测试用户', 0, 1),
('13900139000', '$2a$10$N.zmdr9k7uOCQv37uk7jO.9.Mq8P5x1KQJ5Z5Z5Z5Z5Z5Z5Z5Z5Z5', '测试医生', 1, 1);

-- 测试医院
INSERT INTO `hospital` (`name`, `level`, `address`, `phone`, `introduction`) VALUES
('北京协和医院', '三甲', '北京市东城区帅府园1号', '010-69156699', '中国医学科学院北京协和医院是集医疗、教学、科研于一体的大型三级甲等综合医院'),
('北京大学第一医院', '三甲', '北京市西城区西什库大街8号', '010-83572211', '北京大学第一医院是一所融医疗、教学、科研、预防为一体的大型综合性三级甲等医院');

-- ========================================
-- 初始化完成
-- ========================================
SELECT '数据库初始化完成！' AS message;
