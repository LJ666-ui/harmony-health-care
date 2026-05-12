-- ========================================
-- 家属功能数据诊断脚本
-- 目的：诊断为什么家属看不到数据
-- 作者：CodeArts Agent
-- 日期：2026-05-11
-- ========================================

USE medical_health;

-- ========================================
-- 第一部分：家属基本信息诊断
-- ========================================

SELECT '========================================' AS '';
SELECT '第一部分：家属基本信息诊断' AS '';
SELECT '========================================' AS '';

-- 1. 查看家属表的数据
SELECT 
    '1. 家属表数据' AS 检查项,
    fm.id AS 家属ID,
    fm.name AS 家属姓名,
    fm.relation AS 关系,
    fm.phone AS 手机号,
    fm.user_id AS 关联用户ID,
    fm.username AS 登录用户名,
    fm.password AS 登录密码,
    fm.login_enabled AS 是否允许登录,
    CASE 
        WHEN fm.username IS NULL OR fm.username = '' THEN '❌ 无登录凭证'
        ELSE '✅ 有登录凭证'
    END AS 登录状态
FROM family_member fm
WHERE fm.is_deleted = 0;

-- 2. 查看家属关联的用户信息
SELECT 
    '2. 家属关联的用户信息' AS 检查项,
    fm.id AS 家属ID,
    fm.name AS 家属姓名,
    fm.user_id AS 关联用户ID,
    u.id AS 用户ID,
    u.username AS 用户名,
    u.phone AS 用户手机号,
    u.user_type AS 用户类型,
    CASE u.user_type 
        WHEN 0 THEN '患者'
        WHEN 1 THEN '医生'
        WHEN 2 THEN '管理员'
        WHEN 3 THEN '护士'
        ELSE '未知'
    END AS 用户类型说明
FROM family_member fm
LEFT JOIN user u ON fm.user_id = u.id
WHERE fm.is_deleted = 0;

-- ========================================
-- 第二部分：数据关联诊断
-- ========================================

SELECT '========================================' AS '';
SELECT '第二部分：数据关联诊断' AS '';
SELECT '========================================' AS '';

-- 3. 检查关联用户是否有病例数据
SELECT 
    '3. 关联用户的病例数据' AS 检查项,
    fm.name AS 家属姓名,
    fm.user_id AS 关联用户ID,
    u.username AS 关联用户名,
    COUNT(mr.id) AS 病例数量,
    CASE 
        WHEN COUNT(mr.id) > 0 THEN '✅ 有病例数据'
        ELSE '❌ 无病例数据'
    END AS 验证结果
FROM family_member fm
LEFT JOIN user u ON fm.user_id = u.id
LEFT JOIN medical_record mr ON u.id = mr.user_id AND mr.is_deleted = 0
WHERE fm.is_deleted = 0
GROUP BY fm.id, fm.name, fm.user_id, u.username;

-- 4. 检查关联用户是否有健康记录
SELECT 
    '4. 关联用户的健康记录' AS 检查项,
    fm.name AS 家属姓名,
    fm.user_id AS 关联用户ID,
    u.username AS 关联用户名,
    COUNT(hr.id) AS 健康记录数量,
    CASE 
        WHEN COUNT(hr.id) > 0 THEN '✅ 有健康记录'
        ELSE '❌ 无健康记录'
    END AS 验证结果
FROM family_member fm
LEFT JOIN user u ON fm.user_id = u.id
LEFT JOIN health_record hr ON u.id = hr.user_id AND hr.is_deleted = 0
WHERE fm.is_deleted = 0
GROUP BY fm.id, fm.name, fm.user_id, u.username;

-- ========================================
-- 第三部分：问题诊断
-- ========================================

SELECT '========================================' AS '';
SELECT '第三部分：问题诊断' AS '';
SELECT '========================================' AS '';

-- 5. 诊断问题1：家属是否在user表中
SELECT 
    '5. 家属是否在user表中' AS 检查项,
    fm.id AS 家属ID,
    fm.name AS 家属姓名,
    fm.phone AS 家属手机号,
    u.id AS user表ID,
    u.username AS user表用户名,
    CASE 
        WHEN u.id IS NOT NULL THEN '✅ 家属在user表中'
        ELSE '❌ 家属不在user表中'
    END AS 验证结果
FROM family_member fm
LEFT JOIN user u ON fm.phone = u.phone
WHERE fm.is_deleted = 0;

-- 6. 诊断问题2：家属关联的用户类型是否正确
SELECT 
    '6. 家属关联用户类型诊断' AS 检查项,
    fm.name AS 家属姓名,
    fm.user_id AS 关联用户ID,
    u.username AS 关联用户名,
    u.user_type AS 用户类型,
    CASE u.user_type 
        WHEN 0 THEN '✅ 正确：关联患者'
        WHEN 1 THEN '❌ 错误：关联医生（医生没有病例数据）'
        ELSE '⚠️ 其他类型'
    END AS 诊断结果,
    CASE u.user_type 
        WHEN 1 THEN '建议：将user_id改为关联患者（user_type=0）'
        ELSE ''
    END AS 修复建议
FROM family_member fm
LEFT JOIN user u ON fm.user_id = u.id
WHERE fm.is_deleted = 0;

-- ========================================
-- 第四部分：解决方案建议
-- ========================================

SELECT '========================================' AS '';
SELECT '第四部分：解决方案建议' AS '';
SELECT '========================================' AS '';

-- 7. 查看可用的患者列表
SELECT 
    '7. 可用的患者列表（user_type=0）' AS 检查项,
    id AS 患者ID,
    username AS 用户名,
    phone AS 手机号,
    age AS 年龄,
    create_time AS 注册时间
FROM user
WHERE user_type = 0 AND is_deleted = 0
ORDER BY id
LIMIT 10;

-- ========================================
-- 完成
-- ========================================

SELECT '========================================' AS '';
SELECT '✅ 诊断完成！' AS '';
SELECT '========================================' AS '';
SELECT '根据诊断结果，可能的问题：' AS '';
SELECT '1. 家属关联的是医生，应该关联患者' AS '';
SELECT '2. 关联的患者没有病例或健康记录数据' AS '';
SELECT '3. 家属不在user表中，无法独立登录' AS '';
SELECT '========================================' AS '';
