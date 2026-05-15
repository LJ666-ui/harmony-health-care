-- ========================================
-- 修复家属登录功能：开启所有家属账号的登录权限
-- 问题：family_member 表 login_enabled 默认为 0（不允许登录）
-- 日期：2026-05-15
-- ========================================

USE medical_health;

-- ========================================
-- 第一步：查看当前状态
-- ========================================
SELECT '=== 家属登录状态检查 ===' AS '';
SELECT 
    id AS 家属ID,
    name AS 姓名,
    phone AS 手机号,
    relation AS 关系,
    login_enabled AS 登录权限,
    CASE login_enabled 
        WHEN 1 THEN '✅ 可登录'
        WHEN 0 THEN '❌ 未开启'
        ELSE '❓ NULL'
    END AS 状态,
    password IS NOT NULL AND password != '' AS 是否有密码
FROM family_member 
WHERE is_deleted = 0;

-- ========================================
-- 第二步：开启所有家属的登录权限
-- ========================================
UPDATE family_member 
SET 
    login_enabled = 1,
    update_time = NOW()
WHERE is_deleted = 0;

SELECT CONCAT('✅ 已更新 ', ROW_COUNT(), ' 条家属记录，login_enabled 设为 1') AS 结果;

-- ========================================
-- 第三步：为没有密码的家属设置默认密码 (admin123)
-- ========================================
UPDATE family_member 
SET 
    password = '$2a$10$drI53FwlB2.tdaOYC4MkCOKlAW4PiYG0qLn.S7LoiJq07QcJpZEV.',
    update_time = NOW()
WHERE is_deleted = 0 
  AND (password IS NULL OR password = '');

SELECT CONCAT('✅ 已设置默认密码(admin123)给 ', ROW_COUNT(), ' 条无密码家属记录') AS 结果;

-- ========================================
-- 第四步：验证最终结果
-- ========================================
SELECT '' AS '';
SELECT '=== 修复后最终状态 ===' AS '';
SELECT 
    id AS 家属ID,
    name AS 姓名,
    phone AS 手机号,
    relation AS 关系,
    user_id AS 关联患者ID,
    login_enabled AS 登录权限,
    CASE login_enabled 
        WHEN 1 THEN '✅ 可登录'
        ELSE '❌ 未开启'
    END AS 状态
FROM family_member 
WHERE is_deleted = 0;
