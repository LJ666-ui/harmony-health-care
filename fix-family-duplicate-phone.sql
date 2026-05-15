-- ========================================
-- 修复家属登录 TooManyResultsException
-- 问题：family_member 表存在重复手机号记录，selectByPhone 返回多条导致异常
-- 日期：2026-05-15
-- ========================================

USE medical_health;

-- ========================================
-- 第一步：查看重复手机号的家属记录
-- ========================================
SELECT '=== 检查重复手机号 ===' AS '';
SELECT 
    phone AS 手机号,
    COUNT(*) AS 重复数量,
    GROUP_CONCAT(id ORDER BY id) AS 家属ID列表,
    GROUP_CONCAT(name ORDER BY id) AS 姓名列表
FROM family_member 
WHERE is_deleted = 0 AND phone IS NOT NULL AND phone != ''
GROUP BY phone
HAVING COUNT(*) > 1;

-- ========================================
-- 第二步：查看所有家属记录（用于确认）
-- ========================================
SELECT '' AS '';
SELECT '=== 所有家属记录 ===' AS '';
SELECT id, name, phone, relation, user_id, login_enabled, is_deleted, create_time
FROM family_member 
ORDER BY phone, id;

-- ========================================
-- 第三步：删除重复记录（保留每个手机号最新的那条）
-- ========================================
DELETE f1 FROM family_member f1
INNER JOIN family_member f2
ON f1.phone = f2.phone 
AND f1.id < f2.id
WHERE f1.is_deleted = 0 
  AND f2.is_deleted = 0
  AND f1.phone IS NOT NULL 
  AND f1.phone != '';

SELECT CONCAT('✅ 已删除 ', ROW_COUNT(), ' 条重复家属记录') AS 结果;

-- ========================================
-- 第四步：验证修复结果
-- ========================================
SELECT '' AS '';
SELECT '=== 修复后验证 ===' AS '';
SELECT 
    phone AS 手机号,
    COUNT(*) AS 数量
FROM family_member 
WHERE is_deleted = 0 AND phone IS NOT NULL AND phone != ''
GROUP BY phone
HAVING COUNT(*) > 1;

SELECT CONCAT('✅ 如果上方无结果，说明已无重复记录') AS 验证;
