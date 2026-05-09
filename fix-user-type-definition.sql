-- ========================================
-- user_type字段统一修复脚本
-- 问题：user_type定义混乱，需要统一标准
-- 作者：CodeArts Agent
-- 日期：2026-05-11
-- ========================================

USE medical_health;

-- ========================================
-- 当前问题分析
-- ========================================

SELECT '========================================' AS '';
SELECT '当前user_type定义问题分析' AS '';
SELECT '========================================' AS '';

-- 设计文档定义：0-普通用户，1-医生
-- 实际使用情况：需要验证

-- 1. 查看doctor表关联的user_type
SELECT 
    '医生表关联分析' AS 分析项,
    d.id AS doctor_id,
    d.real_name AS doctor_name,
    d.user_id,
    u.username,
    u.user_type,
    CASE u.user_type 
        WHEN 1 THEN '✅ 符合设计：user_type=1是医生'
        WHEN 2 THEN '⚠️ 建议：user_type=2是医生'
        ELSE '❌ 错误：user_type定义混乱'
    END AS 验证结果
FROM doctor d
LEFT JOIN user u ON d.user_id = u.id
WHERE d.is_deleted = 0
LIMIT 10;

-- 2. 查看nurse表关联的user_type
SELECT 
    '护士表关联分析' AS 分析项,
    n.id AS nurse_id,
    n.real_name AS nurse_name,
    n.user_id,
    u.username,
    u.user_type,
    CASE u.user_type 
        WHEN 3 THEN '✅ 符合设计：user_type=3是护士'
        ELSE '⚠️ 需要确认'
    END AS 验证结果
FROM nurse n
LEFT JOIN user u ON n.user_id = u.id
WHERE n.is_deleted = 0
LIMIT 10;

-- ========================================
-- 推荐的user_type标准定义
-- ========================================

SELECT '========================================' AS '';
SELECT '推荐的user_type标准定义' AS '';
SELECT '========================================' AS '';

SELECT 
    '标准定义' AS 说明,
    0 AS user_type, 
    '普通用户/家属' AS 类型名称,
    '可以查看关联患者的健康信息' AS 权限说明
UNION ALL
SELECT '标准定义', 1, '患者', '拥有自己的健康记录和病例信息'
UNION ALL
SELECT '标准定义', 2, '医生', '可以查看和管理患者的医疗信息'
UNION ALL
SELECT '标准定义', 3, '护士', '协助医生管理患者护理信息'
UNION ALL
SELECT '标准定义', 4, '管理员', '系统管理权限';

-- ========================================
-- 修复方案A：如果当前user_type=1确实是医生
-- ========================================

SELECT '========================================' AS '';
SELECT '修复方案A：确认user_type=1是医生（推荐）' AS '';
SELECT '========================================' AS '';

-- 这种情况下，需要修正family_member的关联
-- 已经在fix-family-data-association.sql中提供

-- ========================================
-- 修复方案B：如果当前user_type定义混乱，需要重新定义
-- ========================================

SELECT '========================================' AS '';
SELECT '修复方案B：重新定义user_type（谨慎使用）' AS '';
SELECT '========================================' AS '';
SELECT '⚠️ 注意：以下语句已注释，执行前请备份数据库' AS '';

-- 步骤1：将医生的用户类型改为2
-- UPDATE user u
-- INNER JOIN doctor d ON u.id = d.user_id
-- SET u.user_type = 2
-- WHERE u.is_deleted = 0 AND d.is_deleted = 0;

-- 步骤2：将护士的用户类型改为3
-- UPDATE user u
-- INNER JOIN nurse n ON u.id = n.user_id
-- SET u.user_type = 3
-- WHERE u.is_deleted = 0 AND n.is_deleted = 0;

-- 步骤3：将管理员的用户类型改为4
-- UPDATE user SET user_type = 4 
-- WHERE username IN ('admin', 'admin2') AND is_deleted = 0;

-- 步骤4：将普通用户/患者保持为0或1
-- 如果是患者，设置为1
-- 如果是普通用户/家属，设置为0

-- ========================================
-- 验证修复结果
-- ========================================

SELECT '========================================' AS '';
SELECT '验证修复结果（执行UPDATE后取消注释查看）' AS '';
SELECT '========================================' AS '';

-- SELECT 
--     '修复后user_type分布' AS 分析项,
--     user_type,
--     COUNT(*) AS count,
--     CASE user_type 
--         WHEN 0 THEN '普通用户/家属'
--         WHEN 1 THEN '患者'
--         WHEN 2 THEN '医生'
--         WHEN 3 THEN '护士'
--         WHEN 4 THEN '管理员'
--         ELSE '未知'
--     END AS type_desc
-- FROM user
-- WHERE is_deleted = 0
-- GROUP BY user_type
-- ORDER BY user_type;

-- ========================================
-- 更新设计文档
-- ========================================

SELECT '========================================' AS '';
SELECT '需要同步更新以下内容' AS '';
SELECT '========================================' AS '';

SELECT '1. 更新init-database.sql中的user表定义' AS 操作;
SELECT '   修改：`user_type` tinyint DEFAULT 0 COMMENT ''用户类型：0-普通用户/家属，1-患者，2-医生，3-护士，4-管理员''' AS 示例;

SELECT '2. 更新User.java实体类' AS 操作;
SELECT '   添加UserType枚举定义' AS 示例;

SELECT '3. 更新前端代码中的用户类型判断逻辑' AS 操作;
SELECT '   检查所有user_type相关的if判断' AS 示例;

-- ========================================
-- 完成
-- ========================================

SELECT '========================================' AS '';
SELECT '✅ user_type修复方案已生成！' AS '';
SELECT '请根据实际情况选择方案A或方案B' AS '';
SELECT '========================================' AS '';
