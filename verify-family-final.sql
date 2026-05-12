-- ========================================
-- 家属功能最终验证脚本
-- 目的：验证家属是否能正常查看患者数据
-- 作者：CodeArts Agent
-- 日期：2026-05-11
-- ========================================

USE medical_health;

-- ========================================
-- 第一部分：验证家属登录凭证
-- ========================================

SELECT '========================================' AS '';
SELECT '第一部分：验证家属登录凭证' AS '';
SELECT '========================================' AS '';

-- 1. 查看家属的登录凭证
SELECT 
    '1. 家属登录凭证' AS 检查项,
    fm.id AS 家属ID,
    fm.name AS 家属姓名,
    fm.phone AS 手机号,
    fm.username AS 登录用户名,
    fm.login_enabled AS 是否允许登录,
    CASE 
        WHEN fm.username IS NOT NULL AND fm.login_enabled = 1 THEN '✅ 可以登录'
        ELSE '❌ 无法登录'
    END AS 登录状态
FROM family_member fm
WHERE fm.is_deleted = 0;

-- ========================================
-- 第二部分：验证家属关联
-- ========================================

SELECT '========================================' AS '';
SELECT '第二部分：验证家属关联' AS '';
SELECT '========================================' AS '';

-- 2. 查看家属关联的用户
SELECT 
    '2. 家属关联的用户' AS 检查项,
    fm.id AS 家属ID,
    fm.name AS 家属姓名,
    fm.user_id AS 关联用户ID,
    u.username AS 关联用户名,
    u.phone AS 关联用户手机号,
    u.user_type AS 用户类型,
    CASE u.user_type 
        WHEN 0 THEN '✅ 患者'
        WHEN 1 THEN '❌ 医生（错误）'
        ELSE '⚠️ 其他'
    END AS 用户类型说明
FROM family_member fm
LEFT JOIN user u ON fm.user_id = u.id
WHERE fm.is_deleted = 0;

-- ========================================
-- 第三部分：验证患者数据
-- ========================================

SELECT '========================================' AS '';
SELECT '第三部分：验证患者数据' AS '';
SELECT '========================================' AS '';

-- 3. 查看患者是否有病例数据
SELECT 
    '3. 患者病例数据' AS 检查项,
    u.id AS 患者ID,
    u.username AS 患者姓名,
    COUNT(mr.id) AS 病例数量,
    CASE 
        WHEN COUNT(mr.id) > 0 THEN '✅ 有病例数据'
        ELSE '❌ 无病例数据（需要插入）'
    END AS 验证结果
FROM user u
LEFT JOIN medical_record mr ON u.id = mr.user_id AND mr.is_deleted = 0
WHERE u.user_type = 0 AND u.is_deleted = 0
GROUP BY u.id, u.username
ORDER BY u.id
LIMIT 10;

-- 4. 查看患者是否有健康记录
SELECT 
    '4. 患者健康记录' AS 检查项,
    u.id AS 患者ID,
    u.username AS 患者姓名,
    COUNT(hr.id) AS 健康记录数量,
    CASE 
        WHEN COUNT(hr.id) > 0 THEN '✅ 有健康记录'
        ELSE '❌ 无健康记录（需要插入）'
    END AS 验证结果
FROM user u
LEFT JOIN health_record hr ON u.id = hr.user_id AND hr.is_deleted = 0
WHERE u.user_type = 0 AND u.is_deleted = 0
GROUP BY u.id, u.username
ORDER BY u.id
LIMIT 10;

-- ========================================
-- 第四部分：验证家属查看能力
-- ========================================

SELECT '========================================' AS '';
SELECT '第四部分：验证家属查看能力' AS '';
SELECT '========================================' AS '';

-- 5. 家属可查看的病例
SELECT 
    '5. 家属可查看的病例' AS 检查项,
    fm.name AS 家属姓名,
    fm.relation AS 关系,
    u.username AS 关联患者,
    COUNT(mr.id) AS 可查看病例数,
    CASE 
        WHEN COUNT(mr.id) > 0 THEN '✅ 可以查看病例'
        ELSE '❌ 无法查看病例'
    END AS 验证结果
FROM family_member fm
LEFT JOIN user u ON fm.user_id = u.id
LEFT JOIN medical_record mr ON u.id = mr.user_id AND mr.is_deleted = 0
WHERE fm.is_deleted = 0
GROUP BY fm.id, fm.name, fm.relation, u.username;

-- 6. 家属可查看的健康记录
SELECT 
    '6. 家属可查看的健康记录' AS 检查项,
    fm.name AS 家属姓名,
    fm.relation AS 关系,
    u.username AS 关联患者,
    COUNT(hr.id) AS 可查看健康记录数,
    CASE 
        WHEN COUNT(hr.id) > 0 THEN '✅ 可以查看健康记录'
        ELSE '❌ 无法查看健康记录'
    END AS 验证结果
FROM family_member fm
LEFT JOIN user u ON fm.user_id = u.id
LEFT JOIN health_record hr ON u.id = hr.user_id AND hr.is_deleted = 0
WHERE fm.is_deleted = 0
GROUP BY fm.id, fm.name, fm.relation, u.username;

-- ========================================
-- 第五部分：数据统计
-- ========================================

SELECT '========================================' AS '';
SELECT '第五部分：数据统计' AS '';
SELECT '========================================' AS '';

-- 7. 总体数据统计
SELECT 
    '7. 总体数据统计' AS 检查项,
    (SELECT COUNT(*) FROM family_member WHERE is_deleted = 0) AS 家属总数,
    (SELECT COUNT(*) FROM user WHERE user_type = 0 AND is_deleted = 0) AS 患者总数,
    (SELECT COUNT(*) FROM medical_record WHERE is_deleted = 0) AS 病例总数,
    (SELECT COUNT(*) FROM health_record WHERE is_deleted = 0) AS 健康记录总数;

-- ========================================
-- 第六部分：问题诊断
-- ========================================

SELECT '========================================' AS '';
SELECT '第六部分：问题诊断' AS '';
SELECT '========================================' AS '';

-- 8. 诊断：家属关联是否正确
SELECT 
    '8. 家属关联诊断' AS 检查项,
    CASE 
        WHEN EXISTS (
            SELECT 1 
            FROM family_member fm
            LEFT JOIN user u ON fm.user_id = u.id
            WHERE fm.is_deleted = 0 AND u.user_type = 1
        ) THEN '❌ 问题：有家属关联的是医生'
        ELSE '✅ 正常：所有家属都关联患者'
    END AS 诊断结果;

-- 9. 诊断：患者是否有数据
SELECT 
    '9. 患者数据诊断' AS 检查项,
    CASE 
        WHEN (SELECT COUNT(*) FROM medical_record WHERE is_deleted = 0) = 0 
        THEN '❌ 问题：没有病例数据'
        ELSE '✅ 正常：有病例数据'
    END AS 病例诊断,
    CASE 
        WHEN (SELECT COUNT(*) FROM health_record WHERE is_deleted = 0) = 0 
        THEN '❌ 问题：没有健康记录'
        ELSE '✅ 正常：有健康记录'
    END AS 健康记录诊断;

-- ========================================
-- 完成
-- ========================================

SELECT '========================================' AS '';
SELECT '✅ 验证完成！' AS '';
SELECT '========================================' AS '';
SELECT '如果所有检查项都显示 ✅，说明家属功能正常' AS '';
SELECT '如果出现 ❌，请根据提示修复' AS '';
SELECT '========================================' AS '';
