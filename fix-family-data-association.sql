-- ========================================
-- 家属数据关联修复脚本
-- 问题：家属关联的是医生（user_type=1），应该关联患者（user_type=0）
-- 作者：CodeArts Agent
-- 日期：2026-05-11
-- ========================================

USE medical_health;

-- ========================================
-- 第一步：诊断问题
-- ========================================

SELECT '========================================' AS '';
SELECT '第一步：诊断当前数据关联问题' AS '';
SELECT '========================================' AS '';

-- 1. 查看user表的user_type分布
SELECT 
    '用户类型分布' AS 分析项,
    user_type AS 用户类型代码,
    COUNT(*) AS 用户数量,
    CASE user_type 
        WHEN 0 THEN '普通用户/患者（根据设计文档）'
        WHEN 1 THEN '医生（根据设计文档）'
        WHEN 2 THEN '管理员'
        WHEN 3 THEN '护士'
        ELSE '未知'
    END AS 类型说明
FROM user
WHERE is_deleted = 0
GROUP BY user_type
ORDER BY user_type;

-- 2. 查看doctor表关联的user_id（验证user_type=1是否真的是医生）
SELECT 
    '医生表关联验证' AS 分析项,
    d.id AS doctor_id,
    d.real_name AS doctor_name,
    d.user_id,
    u.username AS user_username,
    u.user_type,
    CASE u.user_type 
        WHEN 1 THEN '✅ 确认：user_type=1是医生'
        ELSE '❌ 错误：user_type定义混乱'
    END AS 验证结果
FROM doctor d
LEFT JOIN user u ON d.user_id = u.id
WHERE d.is_deleted = 0
LIMIT 10;

-- 3. 查看当前家属关联的用户类型
SELECT 
    '当前家属关联问题' AS 分析项,
    fm.id AS family_id,
    fm.name AS family_name,
    fm.relation,
    fm.user_id AS 关联用户ID,
    u.username AS 关联用户名,
    u.user_type AS 关联用户类型,
    CASE u.user_type 
        WHEN 0 THEN '✅ 正确：关联患者'
        WHEN 1 THEN '❌ 错误：关联医生'
        WHEN 2 THEN '❌ 错误：关联管理员'
        WHEN 3 THEN '❌ 错误：关联护士'
        ELSE '❌ 错误：未知类型'
    END AS 关联状态
FROM family_member fm
LEFT JOIN user u ON fm.user_id = u.id
WHERE fm.is_deleted = 0;

-- 4. 查看medical_record表的数据分布
SELECT 
    '病例数据分布' AS 分析项,
    mr.user_id,
    u.username AS patient_name,
    u.user_type,
    COUNT(*) AS case_count,
    CASE u.user_type 
        WHEN 0 THEN '✅ 正确：患者病例'
        WHEN 1 THEN '❌ 错误：医生病例（医生不应该有病例）'
        ELSE '⚠️ 其他类型'
    END AS 数据状态
FROM medical_record mr
LEFT JOIN user u ON mr.user_id = u.id
WHERE mr.is_deleted = 0
GROUP BY mr.user_id, u.username, u.user_type;

-- ========================================
-- 第二步：查找可用的患者
-- ========================================

SELECT '========================================' AS '';
SELECT '第二步：查找可用的患者（user_type=0）' AS '';
SELECT '========================================' AS '';

SELECT 
    id AS 患者ID,
    username AS 用户名,
    phone AS 手机号,
    age AS 年龄,
    id_card AS 身份证号,
    create_time AS 注册时间
FROM user
WHERE user_type = 0 AND is_deleted = 0
ORDER BY id
LIMIT 20;

-- ========================================
-- 第三步：执行修复（请根据实际情况修改）
-- ========================================

SELECT '========================================' AS '';
SELECT '第三步：执行数据修复' AS '';
SELECT '========================================' AS '';
SELECT '⚠️ 注意：以下UPDATE语句已注释，请根据实际情况取消注释并修改' AS '';

-- 方案A：将家属关联到真正的患者（user_type=0）
-- 建议将家属关联到ID 21-30的患者

-- 将family_member表中id=1,2,3的家属关联到患者21（马建军）
-- UPDATE family_member SET user_id = 21, update_time = NOW() WHERE id IN (1, 2, 3);

-- 将family_member表中id=4,5的家属关联到患者22（任桂英）
-- UPDATE family_member SET user_id = 22, update_time = NOW() WHERE id IN (4, 5);

-- 或者批量更新：将所有关联到医生的家属重新分配到患者
-- SET @patient_id = 21;
-- UPDATE family_member 
-- SET user_id = @patient_id, 
--     update_time = NOW() 
-- WHERE user_id IN (SELECT id FROM user WHERE user_type = 1 AND is_deleted = 0)
--   AND is_deleted = 0;

-- ========================================
-- 第四步：验证修复结果
-- ========================================

SELECT '========================================' AS '';
SELECT '第四步：验证修复结果（执行UPDATE后取消注释查看）' AS '';
SELECT '========================================' AS '';

-- SELECT 
--     '修复后关联状态' AS 分析项,
--     fm.id AS family_id,
--     fm.name AS family_name,
--     fm.relation,
--     fm.user_id AS 关联用户ID,
--     u.username AS 关联用户名,
--     u.user_type AS 关联用户类型,
--     CASE u.user_type 
--         WHEN 0 THEN '✅ 正确：关联患者'
--         WHEN 1 THEN '❌ 仍然错误：关联医生'
--         ELSE '⚠️ 其他类型'
--     END AS 关联状态
-- FROM family_member fm
-- LEFT JOIN user u ON fm.user_id = u.id
-- WHERE fm.is_deleted = 0;

-- ========================================
-- 完成
-- ========================================

SELECT '========================================' AS '';
SELECT '✅ 诊断完成！请根据上述分析结果执行修复' AS '';
SELECT '========================================' AS '';
