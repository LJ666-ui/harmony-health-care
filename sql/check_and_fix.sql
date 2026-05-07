-- ============================================================
-- 检查并修复family_member表结构
-- ============================================================

USE medical_health;

-- 1. 检查family_member表是否有登录字段
SELECT '检查family_member表结构：' AS message;
SHOW COLUMNS FROM family_member;

-- 2. 如果缺少字段，手动添加
-- 添加password字段
ALTER TABLE family_member
ADD COLUMN password VARCHAR(255) NULL COMMENT '登录密码（BCrypt加密）' AFTER health_condition;

-- 添加username字段
ALTER TABLE family_member
ADD COLUMN username VARCHAR(50) NULL COMMENT '登录用户名（可选）' AFTER password;

-- 添加login_enabled字段
ALTER TABLE family_member
ADD COLUMN login_enabled TINYINT(1) DEFAULT 0 COMMENT '是否允许登录：0-否，1-是' AFTER username;

-- 添加login_fail_count字段
ALTER TABLE family_member
ADD COLUMN login_fail_count INT DEFAULT 0 COMMENT '登录失败次数' AFTER login_enabled;

-- 添加lock_until字段
ALTER TABLE family_member
ADD COLUMN lock_until DATETIME NULL COMMENT '账号锁定截止时间' AFTER login_fail_count;

-- 添加last_login_time字段
ALTER TABLE family_member
ADD COLUMN last_login_time DATETIME NULL COMMENT '最后登录时间' AFTER lock_until;

SELECT '✓ 字段添加完成' AS message;

-- 3. 为现有家属生成密码
UPDATE family_member
SET password = '$2a$10$N.zmdr9k7uOCQv37uk7jO.9.Mq8P5x1KQJ5Z5Z5Z5Z5Z5Z5Z5Z5Z5'
WHERE password IS NULL;

SELECT CONCAT('✓ 已为', ROW_COUNT(), '位家属生成密码') AS message;

-- 4. 为紧急联系人开启登录权限
UPDATE family_member
SET login_enabled = 1
WHERE is_emergency_contact = 1;

SELECT CONCAT('✓ 已为', ROW_COUNT(), '位紧急联系人开启登录权限') AS message;

-- 5. 添加索引
ALTER TABLE family_member ADD INDEX idx_phone(phone);
ALTER TABLE family_member ADD INDEX idx_login_enabled(login_enabled);

SELECT '✓ 索引添加完成' AS message;

-- 6. 查看最终结果
SELECT '========== 最终结果 ==========' AS message;

SELECT
  id,
  name,
  phone,
  relation,
  is_emergency_contact AS '紧急联系人',
  login_enabled AS '登录权限',
  LEFT(password, 20) AS '密码(前20位)'
FROM family_member
WHERE is_deleted = 0;

SELECT '========================================' AS message;
SELECT '✓✓✓ 修复完成！' AS message;
SELECT '========================================' AS message;
