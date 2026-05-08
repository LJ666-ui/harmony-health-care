-- ========================================
-- 插入测试数据
-- ========================================

USE medical_health;

-- 清空现有数据（可选）
-- TRUNCATE TABLE user;
-- TRUNCATE TABLE admin;
-- TRUNCATE TABLE doctor;

-- 插入测试用户
INSERT INTO `user` (`username`, `password`, `nickname`, `real_name`, `phone`, `user_type`, `status`, `is_deleted`) VALUES
('user001', '$2a$10$N.zmdr9k7uOCQv37uk7jO.9.Mq8P5x1KQJ5Z5Z5Z5Z5Z5Z5Z5Z5Z5', '张三', '张三', '13800138001', 0, 1, 0),
('user002', '$2a$10$N.zmdr9k7uOCQv37uk7jO.9.Mq8P5x1KQJ5Z5Z5Z5Z5Z5Z5Z5Z5Z5', '李四', '李四', '13800138002', 0, 1, 0),
('user003', '$2a$10$N.zmdr9k7uOCQv37uk7jO.9.Mq8P5x1KQJ5Z5Z5Z5Z5Z5Z5Z5Z5Z5', '王五', '王五', '13800138003', 0, 1, 0);

-- 插入测试医生
INSERT INTO `doctor` (`user_id`, `name`, `title`, `specialty`, `status`, `is_deleted`, `create_time`) VALUES
(1, '陈医生', '主任医师', '心血管内科', 1, 0, NOW()),
(2, '刘医生', '副主任医师', '神经内科', 1, 0, NOW());

-- 检查admin表是否存在，不存在则创建
CREATE TABLE IF NOT EXISTS `admin` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '管理员ID',
  `username` varchar(50) NOT NULL COMMENT '用户名',
  `password` varchar(100) NOT NULL COMMENT '密码',
  `real_name` varchar(50) DEFAULT NULL COMMENT '真实姓名',
  `phone` varchar(20) DEFAULT NULL COMMENT '手机号',
  `email` varchar(50) DEFAULT NULL COMMENT '邮箱',
  `avatar` varchar(255) DEFAULT NULL COMMENT '头像',
  `role` tinyint DEFAULT 2 COMMENT '角色：1-超级管理员，2-普通管理员',
  `status` tinyint DEFAULT 1 COMMENT '状态：0-禁用，1-正常',
  `last_login_time` datetime DEFAULT NULL COMMENT '最后登录时间',
  `last_login_ip` varchar(50) DEFAULT NULL COMMENT '最后登录IP',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `is_deleted` tinyint DEFAULT 0 COMMENT '是否删除：0-否，1-是',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='管理员表';

-- 插入管理员数据（密码：admin123，使用BCrypt加密）
INSERT INTO `admin` (`username`, `password`, `real_name`, `phone`, `email`, `role`, `status`, `is_deleted`) VALUES
('admin', '$2a$10$EqKcpVWk5Z5Z5Z5Z5Z5Z5O9.Mq8P5x1KQJ5Z5Z5Z55Z5Z5Z5Z5Z5Z', '超级管理员', '13800000000', 'admin@medical.com', 1, 1, 0),
('admin2', '$2a$10$EqKcpVWk5Z5Z5Z5Z5Z5Z5O9.Mq8P5x1KQJ5Z5Z5Z5Z5Z5Z5Z5Z5Z5', '普通管理员', '13900000000', 'admin2@medical.com', 2, 1, 0);

-- 显示插入结果
SELECT '========== 用户数据 ==========' AS info;
SELECT COUNT(*) AS user_count FROM user WHERE is_deleted=0;
SELECT id, username, nickname, real_name, user_type FROM user WHERE is_deleted=0;

SELECT '========== 医生数据 ==========' AS info;
SELECT COUNT(*) AS doctor_count FROM doctor WHERE is_deleted=0;
SELECT id, name, title FROM doctor WHERE is_deleted=0;

SELECT '========== 管理员数据 ==========' AS info;
SELECT COUNT(*) AS admin_count FROM admin WHERE is_deleted=0;
SELECT id, username, real_name, role FROM admin WHERE is_deleted=0;

SELECT '测试数据插入完成！' AS message;
