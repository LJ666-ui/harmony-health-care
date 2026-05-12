-- ========================================
-- 家属功能快速修复脚本
-- 目的：确保家属能正常查看患者数据
-- 作者：CodeArts Agent
-- 日期：2026-05-11
-- ========================================

USE medical_health;

-- ========================================
-- 第一步：修正家属关联（关联到患者）
-- ========================================

SELECT '========================================' AS '';
SELECT '第一步：修正家属关联' AS '';
SELECT '========================================' AS '';

-- 查看当前关联状态
SELECT 
    '当前关联状态' AS 说明,
    fm.id AS 家属ID,
    fm.name AS 家属姓名,
    fm.user_id AS 关联用户ID,
    u.username AS 关联用户名,
    u.user_type AS 用户类型
FROM family_member fm
LEFT JOIN user u ON fm.user_id = u.id
WHERE fm.is_deleted = 0;

-- 执行修正（取消注释执行）
-- UPDATE family_member SET user_id = 21, update_time = NOW() WHERE id IN (1, 2, 3);
-- UPDATE family_member SET user_id = 22, update_time = NOW() WHERE id IN (4, 5);

-- ========================================
-- 第二步：插入病例数据
-- ========================================

SELECT '========================================' AS '';
SELECT '第二步：插入病例数据' AS '';
SELECT '========================================' AS '';
SELECT '⚠️ 取消注释并执行INSERT语句' AS '';

-- 为患者21插入病例
-- INSERT INTO medical_record (
--     user_id, hospital_id, doctor_id, 
--     diagnosis, treatment, record_time, 
--     is_desensitized, is_deleted, create_time, update_time
-- ) VALUES 
-- (21, 1, 1, '高血压病3级', '降压药物治疗：氨氯地平5mg qd', '2026-05-01 10:00:00', 0, 0, NOW(), NOW()),
-- (21, 1, 1, '2型糖尿病', '口服降糖药：二甲双胍0.5g tid', '2026-04-15 14:30:00', 0, 0, NOW(), NOW()),
-- (21, 1, 1, '冠心病', '抗血小板治疗：阿司匹林100mg qd', '2026-03-20 09:00:00', 0, 0, NOW(), NOW());

-- 为患者22插入病例
-- INSERT INTO medical_record (
--     user_id, hospital_id, doctor_id, 
--     diagnosis, treatment, record_time, 
--     is_desensitized, is_deleted, create_time, update_time
-- ) VALUES 
-- (22, 1, 1, '慢性胃炎', '抑酸治疗：奥美拉唑20mg qd', '2026-04-28 11:00:00', 0, 0, NOW(), NOW()),
-- (22, 1, 1, '颈椎病', '物理治疗：颈椎牵引', '2026-04-10 15:00:00', 0, 0, NOW(), NOW());

-- ========================================
-- 第三步：插入健康记录
-- ========================================

SELECT '========================================' AS '';
SELECT '第三步：插入健康记录' AS '';
SELECT '========================================' AS '';
SELECT '⚠️ 取消注释并执行INSERT语句' AS '';

-- 为患者21插入健康记录
-- INSERT INTO health_record (
--     user_id, blood_pressure, blood_sugar, heart_rate, 
--     weight, height, step_count, sleep_duration,
--     record_time, is_deleted, create_time, update_time
-- ) VALUES 
-- (21, '145/92', 7.2, 78, 72.5, 170, 8500, 7.5, '2026-05-10 08:00:00', 0, NOW(), NOW()),
-- (21, '138/85', 6.8, 82, 72.8, 170, 9200, 7.0, '2026-05-09 08:00:00', 0, NOW(), NOW()),
-- (21, '142/88', 7.5, 76, 72.6, 170, 7800, 8.0, '2026-05-08 08:00:00', 0, NOW(), NOW());

-- 为患者22插入健康记录
-- INSERT INTO health_record (
--     user_id, blood_pressure, blood_sugar, heart_rate, 
--     weight, height, step_count, sleep_duration,
--     record_time, is_deleted, create_time, update_time
-- ) VALUES 
-- (22, '118/76', 5.6, 72, 58.5, 165, 10000, 8.0, '2026-05-10 08:00:00', 0, NOW(), NOW()),
-- (22, '120/78', 5.8, 70, 58.3, 165, 9500, 7.5, '2026-05-09 08:00:00', 0, NOW(), NOW());

-- ========================================
-- 第四步：验证结果
-- ========================================

SELECT '========================================' AS '';
SELECT '第四步：验证结果（执行上述语句后取消注释）' AS '';
SELECT '========================================' AS '';

-- 验证家属查看能力
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
SELECT '✅ 快速修复脚本准备完成！' AS '';
SELECT '========================================' AS '';
SELECT '执行顺序：' AS '';
SELECT '1. 第一步：修正家属关联（取消注释执行UPDATE）' AS '';
SELECT '2. 第二步：插入病例数据（取消注释执行INSERT）' AS '';
SELECT '3. 第三步：插入健康记录（取消注释执行INSERT）' AS '';
SELECT '4. 第四步：验证结果（取消注释查看）' AS '';
SELECT '========================================' AS '';
