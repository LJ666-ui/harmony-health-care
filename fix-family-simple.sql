-- ========================================
-- 家属功能数据修复脚本（简化版）
-- 问题：家属关联的是医生，应该关联患者
-- 作者：CodeArts Agent
-- 日期：2026-05-11
-- ========================================

USE medical_health;

-- ========================================
-- 第一步：查看当前数据
-- ========================================

SELECT '========================================' AS '';
SELECT '第一步：查看当前数据关联' AS '';
SELECT '========================================' AS '';

-- 1. 查看user表的user_type分布
SELECT 
    user_type AS 用户类型,
    COUNT(*) AS 数量
FROM user
WHERE is_deleted = 0
GROUP BY user_type
ORDER BY user_type;

-- 2. 查看家属关联的用户
SELECT 
    fm.id AS 家属ID,
    fm.name AS 家属姓名,
    fm.relation AS 关系,
    fm.user_id AS 关联用户ID,
    u.username AS 关联用户名,
    u.user_type AS 关联用户类型
FROM family_member fm
LEFT JOIN user u ON fm.user_id = u.id
WHERE fm.is_deleted = 0;

-- 3. 查看可用的患者（user_type=0）
SELECT 
    id AS 患者ID,
    username AS 用户名,
    phone AS 手机号,
    age AS 年龄
FROM user
WHERE user_type = 0 AND is_deleted = 0
LIMIT 10;

-- ========================================
-- 第二步：修正数据关联
-- ========================================

SELECT '========================================' AS '';
SELECT '第二步：修正数据关联' AS '';
SELECT '========================================' AS '';
SELECT '⚠️ 请根据上述查询结果，取消注释并执行UPDATE语句' AS '';

-- 将家属关联到患者21（马建国）
-- UPDATE family_member SET user_id = 21, update_time = NOW() WHERE id IN (1, 2, 3);

-- 将家属关联到患者22（任桂英）
-- UPDATE family_member SET user_id = 22, update_time = NOW() WHERE id IN (4, 5);

-- ========================================
-- 第三步：验证修正结果
-- ========================================

SELECT '========================================' AS '';
SELECT '第三步：验证修正结果（执行UPDATE后取消注释）' AS '';
SELECT '========================================' AS '';

-- SELECT 
--     fm.id AS 家属ID,
--     fm.name AS 家属姓名,
--     fm.user_id AS 关联用户ID,
--     u.username AS 关联用户名,
--     u.user_type AS 关联用户类型
-- FROM family_member fm
-- LEFT JOIN user u ON fm.user_id = u.id
-- WHERE fm.is_deleted = 0;

-- ========================================
-- 完成
-- ========================================

SELECT '========================================' AS '';
SELECT '✅ 诊断完成！' AS '';
SELECT '请根据查询结果执行UPDATE语句修正关联' AS '';
SELECT '========================================' AS '';
