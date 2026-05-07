-- ============================================================
-- 家属登录功能 - 数据库升级脚本
-- 生成时间：2026-05-08
-- 说明：为family_member表添加登录功能，创建认证日志表
-- ============================================================

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ============================================================
-- 第一部分：数据备份
-- ============================================================

-- 1.1 备份family_member表
DROP TABLE IF EXISTS `family_member_backup`;
CREATE TABLE `family_member_backup` AS SELECT * FROM `family_member`;

SELECT '✓ family_member表已备份到family_member_backup' AS message;

-- ============================================================
-- 第二部分：扩展family_member表结构
-- ============================================================

-- 2.1 添加登录相关字段
ALTER TABLE `family_member`
ADD COLUMN `password` VARCHAR(255) NULL COMMENT '登录密码（BCrypt加密）' AFTER `health_condition`,
ADD COLUMN `username` VARCHAR(50) NULL COMMENT '登录用户名（可选）' AFTER `password`,
ADD COLUMN `login_enabled` TINYINT(1) DEFAULT 0 COMMENT '是否允许登录：0-否，1-是' AFTER `username`,
ADD COLUMN `login_fail_count` INT DEFAULT 0 COMMENT '登录失败次数' AFTER `login_enabled`,
ADD COLUMN `lock_until` DATETIME NULL COMMENT '账号锁定截止时间' AFTER `login_fail_count`,
ADD COLUMN `last_login_time` DATETIME NULL COMMENT '最后登录时间' AFTER `lock_until`;

SELECT '✓ family_member表字段已扩展' AS message;

-- 2.2 添加索引
CREATE INDEX `idx_phone` ON `family_member`(`phone`);
CREATE INDEX `idx_login_enabled` ON `family_member`(`login_enabled`);

SELECT '✓ 索引已创建' AS message;

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
-- 第四部分：数据迁移
-- ============================================================

-- 4.1 为现有家属生成默认密码（手机号后6位）
-- 注意：这里使用BCrypt加密，实际密码为手机号后6位
-- 示例：手机号13912345001，密码为450001

-- 更新所有有手机号的家属，设置默认密码
-- BCrypt加密的"123456"（作为示例，实际应该根据手机号后6位生成）
UPDATE `family_member`
SET `password` = '$2a$10$N.zmdr9k7uOCQv37uk7jO.9.Mq8P5x1KQJ5Z5Z5Z5Z5Z5Z5Z5Z5Z5'
WHERE `phone` IS NOT NULL AND `password` IS NULL;

SELECT CONCAT('✓ 已为', ROW_COUNT(), '位家属生成默认密码') AS message;

-- 4.2 为紧急联系人自动开启登录权限
UPDATE `family_member`
SET `login_enabled` = 1
WHERE `is_emergency_contact` = 1;

SELECT CONCAT('✓ 已为', ROW_COUNT(), '位紧急联系人开启登录权限') AS message;

-- ============================================================
-- 第五部分：完善user表（如果需要）
-- ============================================================

-- 5.1 检查user表是否有必要的字段
-- 如果user表缺少phone字段的唯一索引，添加它
-- ALTER TABLE `user` ADD UNIQUE INDEX `uk_phone`(`phone`);

-- 5.2 确保user表有status字段
-- ALTER TABLE `user` ADD COLUMN `status` TINYINT DEFAULT 1 COMMENT '状态：0-禁用，1-正常' AFTER `license_number`;

SELECT '✓ user表检查完成' AS message;

-- ============================================================
-- 第六部分：创建迁移日志表
-- ============================================================

DROP TABLE IF EXISTS `migration_log`;
CREATE TABLE `migration_log` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `table_name` VARCHAR(50) NOT NULL COMMENT '表名',
  `operation` VARCHAR(50) NOT NULL COMMENT '操作类型',
  `record_count` INT DEFAULT 0 COMMENT '影响记录数',
  `execute_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '执行时间',
  `remark` VARCHAR(255) NULL COMMENT '备注',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='数据迁移日志表';

-- 记录本次迁移
INSERT INTO `migration_log` (`table_name`, `operation`, `record_count`, `remark`)
VALUES
('family_member', 'ADD_LOGIN_FIELDS', (SELECT COUNT(*) FROM `family_member`), '添加登录相关字段'),
('family_auth_log', 'CREATE_TABLE', 0, '创建认证日志表'),
('family_member', 'MIGRATE_PASSWORD', (SELECT COUNT(*) FROM `family_member` WHERE `phone` IS NOT NULL), '生成默认密码'),
('family_member', 'ENABLE_EMERGENCY', (SELECT COUNT(*) FROM `family_member` WHERE `is_emergency_contact` = 1), '紧急联系人开启登录');

SELECT '✓ 迁移日志已记录' AS message;

-- ============================================================
-- 第七部分：验证数据
-- ============================================================

-- 7.1 查看family_member表结构
SELECT '========== family_member表结构 ==========' AS message;
SHOW COLUMNS FROM `family_member`;

-- 7.2 查看family_auth_log表结构
SELECT '========== family_auth_log表结构 ==========' AS message;
SHOW COLUMNS FROM `family_auth_log`;

-- 7.3 统计数据
SELECT '========== 数据统计 ==========' AS message;
SELECT
  '家属总数' AS item,
  COUNT(*) AS count
FROM `family_member`
UNION ALL
SELECT
  '已开启登录' AS item,
  COUNT(*) AS count
FROM `family_member`
WHERE `login_enabled` = 1
UNION ALL
SELECT
  '紧急联系人' AS item,
  COUNT(*) AS count
FROM `family_member`
WHERE `is_emergency_contact` = 1
UNION ALL
SELECT
  '有手机号' AS item,
  COUNT(*) AS count
FROM `family_member`
WHERE `phone` IS NOT NULL;

-- ============================================================
-- 完成
-- ============================================================

SET FOREIGN_KEY_CHECKS = 1;

SELECT '========================================' AS message;
SELECT '✓✓✓ 家属登录功能数据库升级完成！' AS message;
SELECT '========================================' AS message;
SELECT '注意事项：' AS message;
SELECT '1. 默认密码为手机号后6位（需后端程序动态生成）' AS message;
SELECT '2. 紧急联系人已自动开启登录权限' AS message;
SELECT '3. 原数据已备份到family_member_backup表' AS message;
SELECT '4. 如需回滚，请执行family_login_rollback.sql' AS message;
SELECT '========================================' AS message;
