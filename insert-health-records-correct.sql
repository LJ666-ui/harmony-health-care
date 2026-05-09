-- ========================================
-- 健康记录数据插入脚本（修正版）
-- 注意：health_record表的字段是blood_pressure, blood_sugar, heart_rate等
-- 不是record_type和value
-- 作者：CodeArts Agent
-- 日期：2026-05-11
-- ========================================

USE medical_health;

-- ========================================
-- 第一步：查看表结构
-- ========================================

SELECT '========================================' AS '';
SELECT '第一步：查看health_record表结构' AS '';
SELECT '========================================' AS '';

DESC health_record;

-- ========================================
-- 第二步：插入健康记录数据
-- ========================================

SELECT '========================================' AS '';
SELECT '第二步：插入健康记录数据' AS '';
SELECT '========================================' AS '';
SELECT '⚠️ 请取消注释并执行INSERT语句' AS '';

-- 为患者21（马建国）添加健康记录
-- INSERT INTO health_record (
--     user_id, 
--     blood_pressure, 
--     blood_sugar, 
--     heart_rate, 
--     weight, 
--     height,
--     step_count,
--     sleep_duration,
--     record_time, 
--     is_deleted, 
--     create_time, 
--     update_time
-- ) VALUES 
-- -- 2026-05-10的记录
-- (21, '145/92', 7.2, 78, 72.5, 170, 8500, 7.5, '2026-05-10 08:00:00', 0, NOW(), NOW()),
-- 
-- -- 2026-05-09的记录
-- (21, '138/85', 6.8, 82, 72.8, 170, 9200, 7.0, '2026-05-09 08:00:00', 0, NOW(), NOW()),
-- 
-- -- 2026-05-08的记录
-- (21, '142/88', 7.5, 76, 72.6, 170, 7800, 8.0, '2026-05-08 08:00:00', 0, NOW(), NOW()),
-- 
-- -- 2026-05-07的记录
-- (21, '140/86', 7.0, 80, 72.7, 170, 8800, 7.2, '2026-05-07 08:00:00', 0, NOW(), NOW()),
-- 
-- -- 2026-05-06的记录
-- (21, '148/94', 7.8, 84, 72.9, 170, 6500, 6.5, '2026-05-06 08:00:00', 0, NOW(), NOW());

-- 为患者22（任桂英）添加健康记录
-- INSERT INTO health_record (
--     user_id, 
--     blood_pressure, 
--     blood_sugar, 
--     heart_rate, 
--     weight, 
--     height,
--     step_count,
--     sleep_duration,
--     record_time, 
--     is_deleted, 
--     create_time, 
--     update_time
-- ) VALUES 
-- -- 2026-05-10的记录
-- (22, '118/76', 5.6, 72, 58.5, 165, 10000, 8.0, '2026-05-10 08:00:00', 0, NOW(), NOW()),
-- 
-- -- 2026-05-09的记录
-- (22, '120/78', 5.8, 70, 58.3, 165, 9500, 7.5, '2026-05-09 08:00:00', 0, NOW(), NOW()),
-- 
-- -- 2026-05-08的记录
-- (22, '116/74', 5.5, 68, 58.4, 165, 11000, 8.2, '2026-05-08 08:00:00', 0, NOW(), NOW()),
-- 
-- -- 2026-05-07的记录
-- (22, '122/80', 5.9, 74, 58.6, 165, 8500, 7.8, '2026-05-07 08:00:00', 0, NOW(), NOW());

-- ========================================
-- 第三步：验证插入结果
-- ========================================

SELECT '========================================' AS '';
SELECT '第三步：验证插入结果（执行INSERT后取消注释）' AS '';
SELECT '========================================' AS '';

-- SELECT 
--     '健康记录验证' AS 检查项,
--     hr.id AS 记录ID,
--     hr.user_id AS 患者ID,
--     u.username AS 患者姓名,
--     hr.blood_pressure AS 血压,
--     hr.blood_sugar AS 血糖,
--     hr.heart_rate AS 心率,
--     hr.weight AS 体重,
--     hr.step_count AS 步数,
--     hr.sleep_duration AS 睡眠时长,
--     hr.record_time AS 记录时间
-- FROM health_record hr
-- LEFT JOIN user u ON hr.user_id = u.id
-- WHERE hr.is_deleted = 0
-- ORDER BY hr.record_time DESC
-- LIMIT 20;

-- ========================================
-- 第四步：验证家属能否查看
-- ========================================

SELECT '========================================' AS '';
SELECT '第四步：验证家属能否查看健康记录' AS '';
SELECT '========================================' AS '';

-- SELECT 
--     '家属查看能力验证' AS 检查项,
--     fm.name AS 家属姓名,
--     fm.relation AS 关系,
--     u.username AS 关联患者,
--     COUNT(hr.id) AS 可查看健康记录数,
--     CASE 
--         WHEN COUNT(hr.id) > 0 THEN '✅ 可以查看'
--         ELSE '❌ 无法查看'
--     END AS 验证结果
-- FROM family_member fm
-- LEFT JOIN user u ON fm.user_id = u.id
-- LEFT JOIN health_record hr ON u.id = hr.user_id AND hr.is_deleted = 0
-- WHERE fm.is_deleted = 0
-- GROUP BY fm.id, fm.name, fm.relation, u.username;

-- ========================================
-- 完成
-- ========================================

SELECT '========================================' AS '';
SELECT '✅ 健康记录数据准备完成！' AS '';
SELECT '========================================' AS '';
SELECT '执行步骤：' AS '';
SELECT '1. 先执行fix-family-to-patient.sql修正关联' AS '';
SELECT '2. 再执行本脚本插入健康记录' AS '';
SELECT '3. 重启后端服务测试' AS '';
SELECT '========================================' AS '';
