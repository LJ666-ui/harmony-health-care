-- ============================================================
-- 修复护士端"暂无生命体征数据"问题
-- 问题1: 8位患者缺少生命体征数据
-- 问题2: 每个患者只有1条记录，需要生成更多历史数据
-- 执行环境: medical_health 数据库
-- ============================================================

-- 1. 为缺少数据的8位患者生成初始生命体征记录
INSERT INTO health_record (user_id, blood_pressure, blood_sugar, heart_rate, record_time, weight, height, step_count, sleep_duration)
SELECT 
    u.id as user_id,
    CONCAT(FLOOR(110 + RAND() * 30), '/', FLOOR(70 + RAND() * 20)) as blood_pressure,
    ROUND(4.0 + RAND() * 3.0, 1) as blood_sugar,
    FLOOR(60 + RAND() * 40) as heart_rate,
    DATE_SUB(NOW(), INTERVAL FLOOR(RAND() * 7) DAY) as record_time,
    ROUND(50.0 + RAND() * 30.0, 1) as weight,
    ROUND(1.55 + RAND() * 0.35, 2) as height,
    FLOOR(3000 + RAND() * 7000) as step_count,
    ROUND(5.0 + RAND() * 3.0, 1) as sleep_duration
FROM user u
WHERE u.user_type = 0 
  AND u.is_deleted = 0
  AND NOT EXISTS (SELECT 1 FROM health_record hr WHERE hr.user_id = u.id AND hr.is_deleted = 0);

-- 2. 为所有88位患者生成最近7天的完整生命体征数据（每人每天1条）
INSERT INTO health_record (user_id, blood_pressure, blood_sugar, heart_rate, record_time, weight, height, step_count, sleep_duration)
SELECT 
    u.id as user_id,
    CONCAT(FLOOR(110 + RAND() * 30), '/', FLOOR(70 + RAND() * 20)) as blood_pressure,
    ROUND(4.0 + RAND() * 3.0, 1) as blood_sugar,
    FLOOR(60 + RAND() * 40) as heart_rate,
    DATE_SUB(CURDATE(), INTERVAL d.day_num DAY) as record_time,
    ROUND(50.0 + RAND() * 30.0, 1) as weight,
    ROUND(1.55 + RAND() * 0.35, 2) as height,
    FLOOR(3000 + RAND() * 7000) as step_count,
    ROUND(5.0 + RAND() * 3.0, 1) as sleep_duration
FROM user u
CROSS JOIN (
    SELECT 1 as day_num UNION SELECT 2 UNION SELECT 3 UNION 
    SELECT 4 UNION SELECT 5 UNION SELECT 6 UNION SELECT 7
) d
WHERE u.user_type = 0 AND u.is_deleted = 0;

-- 3. 验证结果
SELECT '=== 数据统计 ===' as '';
SELECT COUNT(*) as '总记录数' FROM health_record WHERE is_deleted = 0;
SELECT COUNT(DISTINCT user_id) as '覆盖患者数' FROM health_record WHERE is_deleted = 0;

SELECT '' as '';
SELECT '=== 示例数据(最新10条) ===' as '';
SELECT hr.id, hr.user_id, u.real_name as patient_name, 
       hr.blood_pressure, hr.blood_sugar, hr.heart_rate,
       DATE_FORMAT(hr.record_time, '%Y-%m-%d %H:%i') as record_time
FROM health_record hr
JOIN user u ON hr.user_id = u.id
WHERE hr.is_deleted = 0
ORDER BY hr.record_time DESC
LIMIT 10;

SELECT '' as '';
SELECT '=== 每个患者的记录数 ===' as '';
SELECT hr.user_id, u.real_name, COUNT(*) as '记录数'
FROM health_record hr
JOIN user u ON hr.user_id = u.id
WHERE hr.is_deleted = 0
GROUP BY hr.user_id, u.real_name
ORDER BY hr.user_id
LIMIT 15;
