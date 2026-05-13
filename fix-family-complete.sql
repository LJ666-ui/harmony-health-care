-- ========================================
-- 家属功能完整解决方案
-- 问题：家属看不到数据
-- 原因：1. 家属关联的是医生 2. 家属不在user表中
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

-- 查看家属关联的用户类型
SELECT 
    fm.id AS 家属ID,
    fm.name AS 家属姓名,
    fm.user_id AS 关联用户ID,
    u.username AS 关联用户名,
    u.user_type AS 关联用户类型,
    CASE u.user_type 
        WHEN 0 THEN '患者'
        WHEN 1 THEN '医生'
        ELSE '其他'
    END AS 用户类型说明
FROM family_member fm
LEFT JOIN user u ON fm.user_id = u.id
WHERE fm.is_deleted = 0;

-- ========================================
-- 第二步：修正家属关联（关联到患者）
-- ========================================

SELECT '========================================' AS '';
SELECT '第二步：修正家属关联' AS '';
SELECT '========================================' AS '';
SELECT '⚠️ 请取消注释并执行UPDATE语句' AS '';

-- 将家属关联到患者21（马建国）
-- UPDATE family_member SET user_id = 21, update_time = NOW() WHERE id IN (1, 2, 3);

-- 将家属关联到患者22（任桂英）
-- UPDATE family_member SET user_id = 22, update_time = NOW() WHERE id IN (4, 5);

-- ========================================
-- 第三步：将家属添加到user表（可选）
-- ========================================

SELECT '========================================' AS '';
SELECT '第三步：将家属添加到user表（可选）' AS '';
SELECT '========================================' AS '';
SELECT '⚠️ 如果需要家属独立登录，请取消注释并执行INSERT语句' AS '';

-- 将家属添加到user表，使其可以独立登录
-- INSERT INTO user (
--     username, 
--     password, 
--     phone, 
--     age, 
--     id_card, 
--     user_type, 
--     create_time, 
--     is_deleted
-- ) 
-- SELECT 
--     fm.phone AS username,  -- 使用手机号作为用户名
--     '$2a$10$drI53FwlB2.tdaOYC4MkCOKlAW4PiYG0qLn.S7LoiJq07QcJpZEV.' AS password,  -- 默认密码123456
--     fm.phone,
--     fm.age,
--     fm.id_card,
--     0 AS user_type,  -- 设置为普通用户
--     NOW(),
--     0
-- FROM family_member fm
-- WHERE fm.is_deleted = 0 
--   AND fm.phone IS NOT NULL
--   AND NOT EXISTS (
--       SELECT 1 FROM user u WHERE u.phone = fm.phone
--   );

-- ========================================
-- 第四步：更新family_member表的登录凭证
-- ========================================

SELECT '========================================' AS '';
SELECT '第四步：更新family_member表的登录凭证' AS '';
SELECT '========================================' AS '';
SELECT '⚠️ 请取消注释并执行UPDATE语句' AS '';

-- 为家属设置登录凭证
-- UPDATE family_member 
-- SET 
--     username = phone,
--     password = '$2a$10$drI53FwlB2.tdaOYC4MkCOKlAW4PiYG0qLn.S7LoiJq07QcJpZEV.',
--     login_enabled = 1,
--     update_time = NOW()
-- WHERE is_deleted = 0 
--   AND phone IS NOT NULL
--   AND (username IS NULL OR username = '');

-- ========================================
-- 第五步：插入测试数据
-- ========================================

SELECT '========================================' AS '';
SELECT '第五步：插入测试数据' AS '';
SELECT '========================================' AS '';
SELECT '⚠️ 请取消注释并执行INSERT语句' AS '';

-- 为患者21插入病例数据
-- INSERT INTO medical_record (
--     user_id, hospital_id, doctor_id, 
--     diagnosis, treatment, record_time, 
--     is_desensitized, is_deleted, create_time, update_time
-- ) VALUES 
-- (21, 1, 1, '高血压病', '降压药物治疗', '2026-05-01 10:00:00', 0, 0, NOW(), NOW()),
-- (21, 1, 1, '2型糖尿病', '口服降糖药', '2026-04-15 14:30:00', 0, 0, NOW(), NOW());

-- 为患者21插入健康记录
-- INSERT INTO health_record (
--     user_id, blood_pressure, blood_sugar, heart_rate, 
--     weight, height, step_count, sleep_duration,
--     record_time, is_deleted, create_time, update_time
-- ) VALUES 
-- (21, '145/92', 7.2, 78, 72.5, 170, 8500, 7.5, '2026-05-10 08:00:00', 0, NOW(), NOW()),
-- (21, '138/85', 6.8, 82, 72.8, 170, 9200, 7.0, '2026-05-09 08:00:00', 0, NOW(), NOW());

-- ========================================
-- 第六步：验证结果
-- ========================================

SELECT '========================================' AS '';
SELECT '第六步：验证结果（执行上述语句后取消注释）' AS '';
SELECT '========================================' AS '';

-- 验证家属关联
-- SELECT 
--     '家属关联验证' AS 检查项,
--     fm.name AS 家属姓名,
--     fm.user_id AS 关联用户ID,
--     u.username AS 关联用户名,
--     u.user_type AS 用户类型,
--     CASE u.user_type 
--         WHEN 0 THEN '✅ 正确：关联患者'
--         ELSE '❌ 错误'
--     END AS 验证结果
-- FROM family_member fm
-- LEFT JOIN user u ON fm.user_id = u.id
-- WHERE fm.is_deleted = 0;

-- 验证家属能否查看数据
-- SELECT 
--     '家属查看能力验证' AS 检查项,
--     fm.name AS 家属姓名,
--     u.username AS 关联患者,
--     COUNT(DISTINCT mr.id) AS 可查看病例数,
--     COUNT(DISTINCT hr.id) AS 可查看健康记录数,
--     CASE 
--         WHEN COUNT(DISTINCT mr.id) > 0 OR COUNT(DISTINCT hr.id) > 0 THEN '✅ 可以查看数据'
--         ELSE '❌ 无法查看数据'
--     END AS 验证结果
-- FROM family_member fm
-- LEFT JOIN user u ON fm.user_id = u.id
-- LEFT JOIN medical_record mr ON u.id = mr.user_id AND mr.is_deleted = 0
-- LEFT JOIN health_record hr ON u.id = hr.user_id AND hr.is_deleted = 0
-- WHERE fm.is_deleted = 0
-- GROUP BY fm.id, fm.name, u.username;

-- ========================================
-- 完成
-- ========================================

SELECT '========================================' AS '';
SELECT '✅ 解决方案准备完成！' AS '';
SELECT '========================================' AS '';
SELECT '执行顺序：' AS '';
SELECT '1. 执行第二步：修正家属关联' AS '';
SELECT '2. 执行第三步：将家属添加到user表（可选）' AS '';
SELECT '3. 执行第四步：更新登录凭证' AS '';
SELECT '4. 执行第五步：插入测试数据' AS '';
SELECT '5. 执行第六步：验证结果' AS '';
SELECT '========================================' AS '';
