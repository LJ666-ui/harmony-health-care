-- ============================================
-- 修复登录问题 SQL 脚本
-- 问题1: 医生账号 13812345001 被禁用 (status=0)
-- 问题2: 管理员 admin 密码验证失败
-- ============================================

-- 1. 修复医生账号状态：将 status 从 0 改为 1 (启用)
UPDATE `doctor` SET `status` = 1 WHERE `id` = 1;

-- 2. 修复管理员密码：使用与user表相同的BCrypt hash (对应密码 123456)
-- 原hash: $2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iAt6Z5E (验证失败)
-- 使用user表中已验证可用的hash: $2a$10$drI53FwlB2.tdaOYC4MkCOKlAW4PiYG0qLn.S7LoiJq07QcJpZEV.
-- 这个hash对应的密码是: 123456
UPDATE `admin` SET `password` = '$2a$10$drI53FwlB2.tdaOYC4MkCOKlAW4PiYG0qLn.S7LoiJq07QcJpZEV.' WHERE `username` = 'admin';

-- 验证修改
SELECT '========================================' AS '';
SELECT 'Doctor Status Check:' AS Info;
SELECT '========================================' AS '';
SELECT id, user_id, phone, status FROM `doctor` WHERE id = 1;

SELECT '' AS '';
SELECT '========================================' AS '';
SELECT 'Admin Password Check:' AS Info;
SELECT '========================================' AS '';
SELECT id, username, LEFT(password, 30) AS password_prefix, status FROM `admin` WHERE username = 'admin';

-- ============================================
-- 说明：
-- 1. 医生登录逻辑在 DoctorController.java:68-70
--    检查 doctor.getStatus() != 1，如果不等于1则返回"账号已被禁用"
--    修复：将status从0改为1
-- 
-- 2. 管理员登录逻辑在 AdminController.java:66
--    使用 BCryptUtil.matches(password, admin.getPassword()) 验证密码
--    修复：使用已知正确的BCrypt hash (密码: 123456)
-- 
-- 修复后的登录信息：
-- - 医生登录: 手机号 13812345001, 密码 123456
-- - 管理员登录: 用户名 admin, 密码 123456
-- ============================================
