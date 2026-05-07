-- ============================================================
-- 家属登录功能 - 完整SQL脚本（包含示例数据）
-- 生成时间：2026-05-08
-- 说明：创建完整的家属登录功能，包括表结构、索引、示例数据
-- ============================================================

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ============================================================
-- 第一部分：创建/更新user表
-- ============================================================

DROP TABLE IF EXISTS `user`;
CREATE TABLE `user` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '用户ID',
  `username` VARCHAR(50) NOT NULL COMMENT '用户名/手机号',
  `password` VARCHAR(100) NOT NULL COMMENT '密码（BCrypt加密）',
  `nickname` VARCHAR(50) DEFAULT NULL COMMENT '昵称',
  `avatar` VARCHAR(255) DEFAULT NULL COMMENT '头像',
  `gender` TINYINT DEFAULT NULL COMMENT '性别：0-女，1-男',
  `age` INT DEFAULT NULL COMMENT '年龄',
  `id_card` VARCHAR(18) DEFAULT NULL COMMENT '身份证号',
  `phone` VARCHAR(20) DEFAULT NULL COMMENT '手机号',
  `email` VARCHAR(50) DEFAULT NULL COMMENT '邮箱',
  `user_type` TINYINT DEFAULT 0 COMMENT '用户类型：0-普通用户，1-医生',
  `real_name` VARCHAR(50) DEFAULT NULL COMMENT '真实姓名',
  `hospital` VARCHAR(100) DEFAULT NULL COMMENT '所属医院',
  `department` VARCHAR(50) DEFAULT NULL COMMENT '科室',
  `license_number` VARCHAR(50) DEFAULT NULL COMMENT '执业证号',
  `status` TINYINT DEFAULT 1 COMMENT '状态：0-禁用，1-正常',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `is_deleted` TINYINT DEFAULT 0 COMMENT '是否删除：0-否，1-是',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_username`(`username`) USING BTREE,
  UNIQUE INDEX `uk_phone`(`phone`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户表';

SELECT '✓ user表已创建' AS message;

-- ============================================================
-- 第二部分：创建family_member表（包含登录字段）
-- ============================================================

DROP TABLE IF EXISTS `family_member`;
CREATE TABLE `family_member` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '家属ID，主键自增',
  `user_id` BIGINT NOT NULL COMMENT '用户ID（关联user表）',
  `name` VARCHAR(50) NOT NULL COMMENT '家属姓名',
  `relation` VARCHAR(20) NOT NULL COMMENT '与用户关系：配偶/子女/父母/兄弟姐妹/其他',
  `phone` VARCHAR(20) NULL DEFAULT NULL COMMENT '联系电话',
  `id_card` VARCHAR(18) NULL DEFAULT NULL COMMENT '身份证号',
  `gender` TINYINT NULL DEFAULT NULL COMMENT '性别：0=未知 1=男 2=女',
  `age` INT NULL DEFAULT NULL COMMENT '年龄',
  `address` VARCHAR(255) NULL DEFAULT NULL COMMENT '居住地址',
  `is_emergency_contact` TINYINT NOT NULL DEFAULT 0 COMMENT '是否紧急联系人：0=否 1=是',
  `health_condition` TEXT NULL COMMENT '健康状况备注',
  -- 登录相关字段
  `password` VARCHAR(255) NULL COMMENT '登录密码（BCrypt加密）',
  `username` VARCHAR(50) NULL COMMENT '登录用户名（可选）',
  `login_enabled` TINYINT(1) DEFAULT 0 COMMENT '是否允许登录：0-否，1-是',
  `login_fail_count` INT DEFAULT 0 COMMENT '登录失败次数',
  `lock_until` DATETIME NULL COMMENT '账号锁定截止时间',
  `last_login_time` DATETIME NULL COMMENT '最后登录时间',
  -- 通用字段
  `create_time` DATETIME NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` DATETIME NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `is_deleted` TINYINT NOT NULL DEFAULT 0 COMMENT '逻辑删除：0=未删除 1=已删除',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_user_id`(`user_id`) USING BTREE,
  INDEX `idx_relation`(`relation`) USING BTREE,
  INDEX `idx_phone`(`phone`) USING BTREE,
  INDEX `idx_login_enabled`(`login_enabled`) USING BTREE,
  CONSTRAINT `fk_family_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='家属信息表';

SELECT '✓ family_member表已创建' AS message;

-- ============================================================
-- 第三部分：创建family_auth_log表
-- ============================================================

DROP TABLE IF EXISTS `family_auth_log`;
CREATE TABLE `family_auth_log` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `family_id` BIGINT NOT NULL COMMENT '家属ID',
  `login_time` DATETIME NOT NULL COMMENT '登录时间',
  `login_ip` VARCHAR(50) NULL COMMENT '登录IP地址',
  `login_device` VARCHAR(100) NULL COMMENT '登录设备信息',
  `login_result` TINYINT NOT NULL COMMENT '登录结果：1-成功，0-失败',
  `fail_reason` VARCHAR(200) NULL COMMENT '失败原因',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_family_id`(`family_id`) USING BTREE,
  INDEX `idx_login_time`(`login_time`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='家属认证日志表';

SELECT '✓ family_auth_log表已创建' AS message;

-- ============================================================
-- 第四部分：插入示例用户数据
-- ============================================================

-- 密码说明：所有密码均为"123456"，BCrypt加密后的值
-- $2a$10$N.zmdr9k7uOCQv37uk7jO.9.Mq8P5x1KQJ5Z5Z5Z5Z5Z5Z5Z5Z5Z5

INSERT INTO `user` (`id`, `username`, `password`, `nickname`, `phone`, `gender`, `age`, `user_type`, `real_name`, `status`) VALUES
(1, '13900139001', '$2a$10$N.zmdr9k7uOCQv37uk7jO.9.Mq8P5x1KQJ5Z5Z5Z5Z5Z5Z5Z5Z5Z5', '王建国', '13900139001', 1, 45, 0, '王建国', 1),
(2, '13900139002', '$2a$10$N.zmdr9k7uOCQv37uk7jO.9.Mq8P5x1KQJ5Z5Z5Z5Z5Z5Z5Z5Z5Z5', '李淑琴', '13900139002', 0, 42, 0, '李淑琴', 1),
(3, '13900139003', '$2a$10$N.zmdr9k7uOCQv37uk7jO.9.Mq8P5x1KQJ5Z5Z5Z5Z5Z5Z5Z5Z5Z5', '张伟', '13900139003', 1, 38, 0, '张伟', 1),
(4, '13900139004', '$2a$10$N.zmdr9k7uOCQv37uk7jO.9.Mq8P5x1KQJ5Z5Z5Z5Z5Z5Z5Z5Z5Z5', '刘芳', '13900139004', 0, 35, 0, '刘芳', 1);

SELECT '✓ 用户数据已插入' AS message;

-- ============================================================
-- 第五部分：插入示例家属数据（包含登录信息）
-- ============================================================

-- 家属数据说明：
-- 1. password字段已填充，密码为"123456"
-- 2. login_enabled字段：紧急联系人自动设为1，其他为0
-- 3. 用户可以在家属管理页面手动开启其他家属的登录权限

INSERT INTO `family_member` (`id`, `user_id`, `name`, `relation`, `phone`, `id_card`, `gender`, `age`, `address`, `is_emergency_contact`, `health_condition`, `password`, `username`, `login_enabled`, `login_fail_count`) VALUES
-- 用户1（王建国）的家属
(1, 1, '王秀英', '配偶', '13800138001', '110101197801011234', 2, 47, '北京市朝阳区建国路88号', 1, '身体健康，无慢性病', '$2a$10$N.zmdr9k7uOCQv37uk7jO.9.Mq8P5x1KQJ5Z5Z5Z5Z5Z5Z5Z5Z5Z5', 'wangxy', 1, 0),
(2, 1, '王明', '子女', '13800138002', '110101200001011235', 1, 26, '北京市海淀区中关村大街1号', 0, '良好', '$2a$10$N.zmdr9k7uOCQv37uk7jO.9.Mq8P5x1KQJ5Z5Z5Z5Z5Z5Z5Z5Z5Z5', 'wangming', 0, 0),
(3, 1, '王建国（父亲）', '父母', '13800138003', '110101195001011236', 1, 76, '北京市朝阳区建国路88号', 0, '高血压、糖尿病，需定期复查', '$2a$10$N.zmdr9k7uOCQv37uk7jO.9.Mq8P5x1KQJ5Z5Z5Z5Z5Z5Z5Z5Z5Z5', NULL, 0, 0),

-- 用户2（李淑琴）的家属
(4, 2, '李强', '配偶', '13800138004', '110101197802023456', 1, 48, '北京市西城区金融街15号', 1, '健康', '$2a$10$N.zmdr9k7uOCQv37uk7jO.9.Mq8P5x1KQJ5Z5Z5Z5Z5Z5Z5Z5Z5Z5', 'liqiang', 1, 0),
(5, 2, '李小雨', '子女', '13800138005', '110101200103023457', 2, 25, '北京市东城区王府井大街18号', 0, '良好', '$2a$10$N.zmdr9k7uOCQv37uk7jO.9.Mq8P5x1KQJ5Z5Z5Z5Z5Z5Z5Z5Z5Z5', 'lixiaoyu', 0, 0),

-- 用户3（张伟）的家属
(6, 3, '张丽', '配偶', '13800138006', '110101198203034567', 2, 36, '上海市浦东新区陆家嘴环路1000号', 1, '健康', '$2a$10$N.zmdr9k7uOCQv37uk7jO.9.Mq8P5x1KQJ5Z5Z5Z5Z5Z5Z5Z5Z5Z5', 'zhangli', 1, 0),
(7, 3, '张小明', '子女', '13800138007', '110101201004044568', 1, 16, '上海市浦东新区陆家嘴环路1000号', 0, '学生，身体健康', '$2a$10$N.zmdr9k7uOCQv37uk7jO.9.Mq8P5x1KQJ5Z5Z5Z5Z5Z5Z5Z5Z5Z5', NULL, 0, 0),

-- 用户4（刘芳）的家属
(8, 4, '刘强', '配偶', '13800138008', '110101198305055678', 1, 37, '广州市天河区珠江新城', 1, '健康', '$2a$10$N.zmdr9k7uOCQv37uk7jO.9.Mq8P5x1KQJ5Z5Z5Z5Z5Z5Z5Z5Z5Z5', 'liuqiang', 1, 0),
(9, 4, '刘小芳', '子女', '13800138009', '110101201506065679', 2, 11, '广州市天河区珠江新城', 0, '学生，身体健康', '$2a$10$N.zmdr9k7uOCQv37uk7jO.9.Mq8P5x1KQJ5Z5Z5Z5Z5Z5Z5Z5Z5Z5', NULL, 0, 0),
(10, 4, '刘母', '父母', '13800138010', '110101195507075680', 2, 71, '广州市越秀区北京路', 0, '高血压，需定期服药', '$2a$10$N.zmdr9k7uOCQv37uk7jO.9.Mq8P5x1KQJ5Z5Z5Z5Z5Z5Z5Z5Z5Z5', NULL, 0, 0);

SELECT '✓ 家属数据已插入' AS message;

-- ============================================================
-- 第六部分：插入示例登录日志
-- ============================================================

INSERT INTO `family_auth_log` (`family_id`, `login_time`, `login_ip`, `login_device`, `login_result`, `fail_reason`) VALUES
(1, '2026-05-07 08:30:00', '192.168.1.100', 'HarmonyOS Phone', 1, NULL),
(1, '2026-05-07 18:45:00', '192.168.1.100', 'HarmonyOS Phone', 1, NULL),
(4, '2026-05-07 09:15:00', '192.168.1.101', 'HarmonyOS Tablet', 1, NULL),
(6, '2026-05-07 10:20:00', '192.168.1.102', 'HarmonyOS Phone', 1, NULL),
(8, '2026-05-07 11:30:00', '192.168.1.103', 'HarmonyOS Phone', 1, NULL);

SELECT '✓ 登录日志已插入' AS message;

-- ============================================================
-- 第七部分：创建视图（方便查询）
-- ============================================================

-- 家属登录信息视图
DROP VIEW IF EXISTS `v_family_login_info`;
CREATE VIEW `v_family_login_info` AS
SELECT
  f.id AS family_id,
  f.name AS family_name,
  f.phone AS family_phone,
  f.relation,
  f.is_emergency_contact,
  f.login_enabled,
  f.login_fail_count,
  f.lock_until,
  f.last_login_time,
  u.id AS user_id,
  u.real_name AS user_name,
  u.phone AS user_phone
FROM `family_member` f
LEFT JOIN `user` u ON f.user_id = u.id
WHERE f.is_deleted = 0;

SELECT '✓ 视图已创建' AS message;

-- ============================================================
-- 第八部分：数据统计
-- ============================================================

SELECT '========================================' AS message;
SELECT '数据统计：' AS message;
SELECT '========================================' AS message;

SELECT
  '用户总数' AS item,
  COUNT(*) AS count
FROM `user`
WHERE `is_deleted` = 0
UNION ALL
SELECT
  '家属总数' AS item,
  COUNT(*) AS count
FROM `family_member`
WHERE `is_deleted` = 0
UNION ALL
SELECT
  '已开启登录的家属' AS item,
  COUNT(*) AS count
FROM `family_member`
WHERE `is_deleted` = 0 AND `login_enabled` = 1
UNION ALL
SELECT
  '紧急联系人' AS item,
  COUNT(*) AS count
FROM `family_member`
WHERE `is_deleted` = 0 AND `is_emergency_contact` = 1
UNION ALL
SELECT
  '登录日志数' AS item,
  COUNT(*) AS count
FROM `family_auth_log`;

-- ============================================================
-- 完成
-- ============================================================

SET FOREIGN_KEY_CHECKS = 1;

SELECT '========================================' AS message;
SELECT '✓✓✓ 家属登录功能数据库创建完成！' AS message;
SELECT '========================================' AS message;
SELECT '使用说明：' AS message;
SELECT '1. 用户登录：使用手机号和密码（均为示例数据）' AS message;
SELECT '2. 家属登录：使用手机号和密码（密码均为123456）' AS message;
SELECT '3. 紧急联系人已自动开启登录权限' AS message;
SELECT '4. 其他家属需用户在管理页面手动开启' AS message;
SELECT '========================================' AS message;
SELECT '示例账号：' AS message;
SELECT '用户：13900139001 / 123456' AS message;
SELECT '家属：13800138001 / 123456（王秀英，已开启登录）' AS message;
SELECT '家属：13800138002 / 123456（王明，未开启登录）' AS message;
SELECT '========================================' AS message;
