-- ========================================
-- 用户表结构更新SQL
-- 请在MySQL命令行或Navicat中执行
-- ========================================

USE medical_health;

-- 添加缺失的字段
ALTER TABLE `user` 
ADD COLUMN `real_name` varchar(50) DEFAULT NULL COMMENT '真实姓名' AFTER `user_type`,
ADD COLUMN `id_card` varchar(18) DEFAULT NULL COMMENT '身份证号' AFTER `age`,
ADD COLUMN `hospital` varchar(100) DEFAULT NULL COMMENT '所属医院' AFTER `real_name`,
ADD COLUMN `department` varchar(50) DEFAULT NULL COMMENT '科室' AFTER `hospital`,
ADD COLUMN `license_number` varchar(50) DEFAULT NULL COMMENT '执业证号' AFTER `department`;

-- 验证表结构
DESC user;

-- 显示成功信息
SELECT '数据库表结构更新成功！' AS message;
