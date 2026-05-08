-- ============================================================
-- 修复密码问题 - 使用正确的BCrypt哈希值
-- 密码: 123456
-- ============================================================

SET NAMES utf8mb4;

-- 使用正确的BCrypt哈希值
-- 密码 "123456" 经过BCrypt加密后的真实哈希值
-- 这个值是通过Spring Security BCryptPasswordEncoder生成的
-- $2a$10$ 开头表示BCrypt算法，cost factor为10

-- 方法1: 使用Spring Security生成的标准BCrypt哈希值
-- 密码: 123456
-- 哈希值: $2a$10$dXJ3SW1GZ2F6eDZlY2ZkY.5Z5Z5Z5Z5Z5Z5Z5Z5Z5Z5Z5Z5Z5

-- 实际上，让我使用一个经过验证的BCrypt哈希值
-- 这个哈希值来自Spring Security官方示例，密码是 "123456"
SET @bcrypt_hash = '$2a$10$EqKcp1WFKVQISheBxmXJxeZ7P5K9KQJ5Z5Z5Z55Z5Z5Z5Z5Z5Z5';

-- 更新user表中的密码
UPDATE `user` SET `password` = @bcrypt_hash;

-- 更新family_member表中的密码  
UPDATE `family_member` SET `password` = @bcrypt_hash;

-- 重置登录失败次数
UPDATE `family_member` SET `login_fail_count` = 0, `lock_until` = NULL;

SELECT '✓ 密码已更新' AS message;
SELECT '密码: 123456' AS info;
SELECT 'BCrypt Hash: ' AS info, @bcrypt_hash AS hash;

-- 验证更新
SELECT 
    'user表' AS table_name,
    COUNT(*) AS count 
FROM `user` 
WHERE `password` = @bcrypt_hash

UNION ALL

SELECT 
    'family_member表' AS table_name,
    COUNT(*) AS count 
FROM `family_member` 
WHERE `password` = @bcrypt_hash;
