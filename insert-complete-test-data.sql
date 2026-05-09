-- ========================================
-- 完整测试数据插入脚本
-- 包括：病例数据 + 健康记录（血压、血糖、心率等）
-- 作者：CodeArts Agent
-- 日期：2026-05-11
-- ========================================

USE medical_health;

-- ========================================
-- 第一部分：插入病例数据
-- ========================================

SELECT '========================================' AS '';
SELECT '第一部分：插入病例数据' AS '';
SELECT '========================================' AS '';
SELECT '⚠️ 请取消注释并执行INSERT语句' AS '';

-- 为患者21（马建国）添加病例
-- INSERT INTO medical_record (
--     user_id, hospital_id, doctor_id, 
--     diagnosis, treatment, record_time, 
--     is_desensitized, is_deleted, create_time, update_time
-- ) VALUES 
-- (21, 1, 1, '高血压病3级（极高危）', 
--  '降压药物治疗：氨氯地平5mg qd + 缬沙坦80mg qd\n低盐低脂饮食\n定期监测血压', 
--  '2026-05-01 10:00:00', 0, 0, NOW(), NOW()),
--  
-- (21, 1, 1, '2型糖尿病', 
--  '口服降糖药：二甲双胍0.5g tid\n饮食控制\n定期监测血糖', 
--  '2026-04-15 14:30:00', 0, 0, NOW(), NOW()),
--  
-- (21, 1, 1, '冠心病', 
--  '抗血小板治疗：阿司匹林100mg qd\n调脂治疗：阿托伐他汀20mg qn', 
--  '2026-03-20 09:00:00', 0, 0, NOW(), NOW());

-- 为患者22（任桂英）添加病例
-- INSERT INTO medical_record (
--     user_id, hospital_id, doctor_id, 
--     diagnosis, treatment, record_time, 
--     is_desensitized, is_deleted, create_time, update_time
-- ) VALUES 
-- (22, 1, 1, '慢性浅表性胃炎', 
--  '抑酸治疗：奥美拉唑20mg qd\n胃黏膜保护：铝碳酸镁1g tid', 
--  '2026-04-28 11:00:00', 0, 0, NOW(), NOW()),
--  
-- (22, 1, 1, '颈椎病', 
--  '物理治疗：颈椎牵引\n避免长时间低头', 
--  '2026-04-10 15:00:00', 0, 0, NOW(), NOW());

-- ========================================
-- 第二部分：插入健康记录（血压、血糖、心率等）
-- ========================================

SELECT '========================================' AS '';
SELECT '第二部分：插入健康记录' AS '';
SELECT '========================================' AS '';
SELECT '⚠️ 请取消注释并执行INSERT语句' AS '';

-- 为患者21（马建国）添加健康记录
-- INSERT INTO health_record (
--     user_id, record_type, value, unit, 
--     record_time, is_deleted, create_time, update_time
-- ) VALUES 
-- -- 血压记录
-- (21, 'BLOOD_PRESSURE', '145/92', 'mmHg', '2026-05-10 08:00:00', 0, NOW(), NOW()),
-- (21, 'BLOOD_PRESSURE', '138/85', 'mmHg', '2026-05-09 08:00:00', 0, NOW(), NOW()),
-- (21, 'BLOOD_PRESSURE', '142/88', 'mmHg', '2026-05-08 08:00:00', 0, NOW(), NOW()),
-- 
-- -- 血糖记录
-- (21, 'BLOOD_SUGAR', '7.2', 'mmol/L', '2026-05-10 07:00:00', 0, NOW(), NOW()),
-- (21, 'BLOOD_SUGAR', '6.8', 'mmol/L', '2026-05-09 07:00:00', 0, NOW(), NOW()),
-- (21, 'BLOOD_SUGAR', '7.5', 'mmol/L', '2026-05-08 07:00:00', 0, NOW(), NOW()),
-- 
-- -- 心率记录
-- (21, 'HEART_RATE', '78', 'bpm', '2026-05-10 08:00:00', 0, NOW(), NOW()),
-- (21, 'HEART_RATE', '82', 'bpm', '2026-05-09 08:00:00', 0, NOW(), NOW()),
-- (21, 'HEART_RATE', '76', 'bpm', '2026-05-08 08:00:00', 0, NOW(), NOW()),
-- 
-- -- 体重记录
-- (21, 'WEIGHT', '72.5', 'kg', '2026-05-10 08:00:00', 0, NOW(), NOW()),
-- (21, 'WEIGHT', '72.8', 'kg', '2026-05-03 08:00:00', 0, NOW(), NOW());

-- 为患者22（任桂英）添加健康记录
-- INSERT INTO health_record (
--     user_id, record_type, value, unit, 
--     record_time, is_deleted, create_time, update_time
-- ) VALUES 
-- -- 血压记录
-- (22, 'BLOOD_PRESSURE', '118/76', 'mmHg', '2026-05-10 08:00:00', 0, NOW(), NOW()),
-- (22, 'BLOOD_PRESSURE', '120/78', 'mmHg', '2026-05-09 08:00:00', 0, NOW(), NOW()),
-- 
-- -- 血糖记录
-- (22, 'BLOOD_SUGAR', '5.6', 'mmol/L', '2026-05-10 07:00:00', 0, NOW(), NOW()),
-- (22, 'BLOOD_SUGAR', '5.8', 'mmol/L', '2026-05-09 07:00:00', 0, NOW(), NOW()),
-- 
-- -- 心率记录
-- (22, 'HEART_RATE', '72', 'bpm', '2026-05-10 08:00:00', 0, NOW(), NOW()),
-- (22, 'HEART_RATE', '70', 'bpm', '2026-05-09 08:00:00', 0, NOW(), NOW()),
-- 
-- -- 体重记录
-- (22, 'WEIGHT', '58.5', 'kg', '2026-05-10 08:00:00', 0, NOW(), NOW()),
-- 
-- -- 体温记录
-- (22, 'BODY_TEMPERATURE', '36.5', '℃', '2026-05-10 08:00:00', 0, NOW(), NOW());

-- ========================================
-- 第三部分：验证插入结果
-- ========================================

SELECT '========================================' AS '';
SELECT '第三部分：验证插入结果（执行INSERT后取消注释）' AS '';
SELECT '========================================' AS '';

-- 验证病例数据
-- SELECT 
--     '病例数据验证' AS 检查项,
--     mr.user_id AS 患者ID,
--     u.username AS 患者姓名,
--     mr.diagnosis AS 诊断,
--     mr.record_time AS 就诊时间
-- FROM medical_record mr
-- LEFT JOIN user u ON mr.user_id = u.id
-- WHERE mr.is_deleted = 0
-- ORDER BY mr.record_time DESC;

-- 验证健康记录
-- SELECT 
--     '健康记录验证' AS 检查项,
--     hr.user_id AS 患者ID,
--     u.username AS 患者姓名,
--     hr.record_type AS 记录类型,
--     hr.value AS 数值,
--     hr.unit AS 单位,
--     hr.record_time AS 记录时间
-- FROM health_record hr
-- LEFT JOIN user u ON hr.user_id = u.id
-- WHERE hr.is_deleted = 0
-- ORDER BY hr.record_time DESC
-- LIMIT 20;

-- ========================================
-- 第四部分：验证家属查看能力
-- ========================================

SELECT '========================================' AS '';
SELECT '第四部分：验证家属查看能力（执行INSERT后取消注释）' AS '';
SELECT '========================================' AS '';

-- SELECT 
--     '家属查看能力验证' AS 检查项,
--     fm.name AS 家属姓名,
--     fm.relation AS 关系,
--     u.username AS 关联患者,
--     COUNT(DISTINCT mr.id) AS 可查看病例数,
--     COUNT(DISTINCT hr.id) AS 可查看健康记录数,
--     CASE 
--         WHEN COUNT(DISTINCT mr.id) > 0 AND COUNT(DISTINCT hr.id) > 0 THEN '✅ 完整'
--         WHEN COUNT(DISTINCT mr.id) > 0 OR COUNT(DISTINCT hr.id) > 0 THEN '⚠️ 部分'
--         ELSE '❌ 无数据'
--     END AS 数据完整性
-- FROM family_member fm
-- LEFT JOIN user u ON fm.user_id = u.id
-- LEFT JOIN medical_record mr ON u.id = mr.user_id AND mr.is_deleted = 0
-- LEFT JOIN health_record hr ON u.id = hr.user_id AND hr.is_deleted = 0
-- WHERE fm.is_deleted = 0
-- GROUP BY fm.id, fm.name, fm.relation, u.username;

-- ========================================
-- 完成
-- ========================================

SELECT '========================================' AS '';
SELECT '✅ 测试数据准备完成！' AS '';
SELECT '========================================' AS '';
SELECT '执行步骤：' AS '';
SELECT '1. 取消注释并执行所有INSERT语句' AS '';
SELECT '2. 执行verify-family-data-flow.sql验证数据流通' AS '';
SELECT '3. 重启后端服务' AS '';
SELECT '4. 测试前端家属功能' AS '';
SELECT '========================================' AS '';
