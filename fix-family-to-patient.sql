-- ========================================
-- 家属关联修正脚本（关联到真正的患者）
-- 问题：家属关联的是医生，应该关联患者
-- 作者：CodeArts Agent
-- 日期：2026-05-11
-- ========================================

USE medical_health;

-- ========================================
-- 第一步：诊断当前问题
-- ========================================

SELECT '========================================' AS '';
SELECT '第一步：诊断当前问题' AS '';
SELECT '========================================' AS '';

-- 1. 查看当前家属关联的用户类型
SELECT 
    '当前家属关联状态' AS 分析项,
    fm.id AS 家属ID,
    fm.name AS 家属姓名,
    fm.relation AS 关系,
    fm.user_id AS 关联用户ID,
    u.username AS 关联用户名,
    u.user_type AS 关联用户类型,
    CASE u.user_type 
        WHEN 0 THEN '患者'
        WHEN 1 THEN '医生'
        WHEN 2 THEN '管理员'
        WHEN 3 THEN '护士'
        ELSE '未知'
    END AS 用户类型说明,
    CASE u.user_type 
        WHEN 0 THEN '✅ 正确'
        ELSE '❌ 错误：应该关联患者'
    END AS 验证结果
FROM family_member fm
LEFT JOIN user u ON fm.user_id = u.id
WHERE fm.is_deleted = 0;

-- 2. 查看可用的患者列表（user_type=0）
SELECT 
    '可用患者列表' AS 分析项,
    id AS 患者ID,
    username AS 用户名,
    phone AS 手机号,
    age AS 年龄,
    create_time AS 注册时间
FROM user
WHERE user_type = 0 AND is_deleted = 0
ORDER BY id
LIMIT 20;

-- ========================================
-- 第二步：修正家属关联
-- ========================================

SELECT '========================================' AS '';
SELECT '第二步：修正家属关联' AS '';
SELECT '========================================' AS '';
SELECT '⚠️ 请根据上述查询结果，取消注释并执行UPDATE语句' AS '';

-- 方案：将家属关联到真正的患者（user_type=0）
-- 建议将家属关联到ID 21-30的患者

-- 将family_member表中id=1,2,3的家属关联到患者21（马建国，64岁）
-- UPDATE family_member SET user_id = 21, update_time = NOW() WHERE id IN (1, 2, 3);

-- 将family_member表中id=4,5的家属关联到患者22（任桂英，36岁）
-- UPDATE family_member SET user_id = 22, update_time = NOW() WHERE id IN (4, 5);

-- 或者批量更新：将所有关联到医生的家属重新分配到患者
-- SET @patient_id = 21;
-- UPDATE family_member 
-- SET user_id = @patient_id, 
--     update_time = NOW() 
-- WHERE user_id IN (SELECT id FROM user WHERE user_type = 1 AND is_deleted = 0)
--   AND is_deleted = 0;

-- ========================================
-- 第三步：验证修正结果
-- ========================================

SELECT '========================================' AS '';
SELECT '第三步：验证修正结果（执行UPDATE后取消注释查看）' AS '';
SELECT '========================================' AS '';

-- SELECT 
--     '修正后关联状态' AS 分析项,
--     fm.id AS 家属ID,
--     fm.name AS 家属姓名,
--     fm.relation AS 关系,
--     fm.user_id AS 关联用户ID,
--     u.username AS 关联用户名,
--     u.user_type AS 关联用户类型,
--     CASE u.user_type 
--         WHEN 0 THEN '✅ 正确：关联患者'
--         ELSE '❌ 仍然错误'
--     END AS 验证结果
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
