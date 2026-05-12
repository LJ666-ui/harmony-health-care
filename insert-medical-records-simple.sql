-- ========================================
-- 测试病例数据插入脚本（简化版）
-- 目的：为患者添加病例数据
-- 作者：CodeArts Agent
-- 日期：2026-05-11
-- ========================================

USE medical_health;

-- ========================================
-- 第一步：查看现有数据
-- ========================================

SELECT '========================================' AS '';
SELECT '第一步：查看现有数据' AS '';
SELECT '========================================' AS '';

-- 查看患者
SELECT 
    id AS 患者ID,
    username AS 用户名,
    phone AS 手机号,
    age AS 年龄
FROM user
WHERE user_type = 0 AND is_deleted = 0
LIMIT 10;

-- 查看医生
SELECT 
    id AS 医生ID,
    real_name AS 医生姓名,
    title AS 职称
FROM doctor
WHERE is_deleted = 0
LIMIT 10;

-- ========================================
-- 第二步：插入测试病例数据
-- ========================================

SELECT '========================================' AS '';
SELECT '第二步：插入测试病例数据' AS '';
SELECT '========================================' AS '';
SELECT '⚠️ 请取消注释并执行INSERT语句' AS '';

-- 为患者21添加病例
-- INSERT INTO medical_record (
--     user_id, 
--     hospital_id, 
--     doctor_id, 
--     diagnosis, 
--     treatment, 
--     record_time, 
--     is_desensitized, 
--     is_deleted,
--     create_time,
--     update_time
-- ) VALUES 
-- (21, 1, 1, '高血压病', '降压药物治疗，定期监测血压', '2026-05-01 10:00:00', 0, 0, NOW(), NOW()),
-- (21, 1, 1, '2型糖尿病', '口服降糖药，饮食控制', '2026-04-15 14:30:00', 0, 0, NOW(), NOW()),
-- (21, 1, 1, '冠心病', '抗血小板治疗，调脂治疗', '2026-03-20 09:00:00', 0, 0, NOW(), NOW());

-- 为患者22添加病例
-- INSERT INTO medical_record (
--     user_id, 
--     hospital_id, 
--     doctor_id, 
--     diagnosis, 
--     treatment, 
--     record_time, 
--     is_desensitized, 
--     is_deleted,
--     create_time,
--     update_time
-- ) VALUES 
-- (22, 1, 1, '慢性胃炎', '抑酸治疗，胃黏膜保护', '2026-04-28 11:00:00', 0, 0, NOW(), NOW()),
-- (22, 1, 1, '颈椎病', '物理治疗，避免长时间低头', '2026-04-10 15:00:00', 0, 0, NOW(), NOW());

-- ========================================
-- 第三步：验证插入结果
-- ========================================

SELECT '========================================' AS '';
SELECT '第三步：验证插入结果（执行INSERT后取消注释）' AS '';
SELECT '========================================' AS '';

-- SELECT 
--     mr.id AS 病例ID,
--     mr.user_id AS 患者ID,
--     u.username AS 患者姓名,
--     mr.diagnosis AS 诊断,
--     mr.record_time AS 就诊时间
-- FROM medical_record mr
-- LEFT JOIN user u ON mr.user_id = u.id
-- WHERE mr.is_deleted = 0
-- ORDER BY mr.record_time DESC
-- LIMIT 20;

-- ========================================
-- 第四步：验证家属能否查看
-- ========================================

SELECT '========================================' AS '';
SELECT '第四步：验证家属能否查看病例' AS '';
SELECT '========================================' AS '';

-- SELECT 
--     fm.name AS 家属姓名,
--     fm.relation AS 关系,
--     u.username AS 关联患者,
--     COUNT(mr.id) AS 可查看病例数
-- FROM family_member fm
-- LEFT JOIN user u ON fm.user_id = u.id
-- LEFT JOIN medical_record mr ON u.id = mr.user_id AND mr.is_deleted = 0
-- WHERE fm.is_deleted = 0
-- GROUP BY fm.id, fm.name, fm.relation, u.username;

-- ========================================
-- 完成
-- ========================================

SELECT '========================================' AS '';
SELECT '✅ 脚本准备完成！' AS '';
SELECT '请按顺序执行：' AS '';
SELECT '1. 先执行fix-family-simple.sql修正关联' AS '';
SELECT '2. 再执行本脚本插入病例数据' AS '';
SELECT '========================================' AS '';
