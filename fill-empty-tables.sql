-- ==========================================
-- 鸿蒙健康医疗应用 - 补充空表数据
-- 版本: v4.0
-- 日期: 2026-05-11
-- 说明: 只补充空表的数据
-- ==========================================

USE medical_health;

-- ==========================================
-- 1. 补充问诊消息数据（doctor_message表为空）
-- ==========================================

-- 先检查是否有患者数据
-- 如果没有患者，先创建患者
INSERT IGNORE INTO `user` (`id`, `username`, `password`, `user_type`, `real_name`, `phone`, `age`, `status`)
VALUES 
(10, 'patient001', '$2a$10$N.zmdr9k7uOCQv37uk7jO.9.Mq8P5x1KQJ5Z5Z5Z5Z5Z5Z5Z5Z5Z5', 0, '张三', '13900139001', 45, 1),
(11, 'patient002', '$2a$10$N.zmdr9k7uOCQv37uk7jO.9.Mq8P5x1KQJ5Z5Z5Z5Z5Z5Z5Z5Z5Z5', 0, '李四', '13900139002', 52, 1),
(12, 'patient003', '$2a$10$N.zmdr9k7uOCQv37uk7jO.9.Mq8P5x1KQJ5Z5Z5Z5Z5Z5Z5Z5Z5Z5', 0, '王五', '13900139003', 38, 1);

-- 插入问诊消息
INSERT INTO `doctor_message` (`sender_id`, `receiver_id`, `content`, `message_type`, `read_status`, `send_time`, `expire_time`)
SELECT 10, 1, '医生您好，我最近血压有点高，需要调整药物吗？', 'text', 0, DATE_SUB(NOW(), INTERVAL 2 HOUR), DATE_ADD(NOW(), INTERVAL 46 HOUR)
WHERE NOT EXISTS (SELECT 1 FROM doctor_message WHERE sender_id = 10 AND receiver_id = 1 LIMIT 1);

INSERT INTO `doctor_message` (`sender_id`, `receiver_id`, `content`, `message_type`, `read_status`, `send_time`, `expire_time`)
SELECT 1, 10, '您好，请问现在的血压是多少？有头晕、头痛等症状吗？', 'text', 1, DATE_SUB(NOW(), INTERVAL 1 HOUR), DATE_ADD(NOW(), INTERVAL 47 HOUR)
WHERE NOT EXISTS (SELECT 1 FROM doctor_message WHERE sender_id = 1 AND receiver_id = 10 LIMIT 1);

INSERT INTO `doctor_message` (`sender_id`, `receiver_id`, `content`, `message_type`, `read_status`, `send_time`, `expire_time`)
SELECT 10, 1, '早上测量是150/95，偶尔有点头晕', 'text', 0, DATE_SUB(NOW(), INTERVAL 30 MINUTE), DATE_ADD(NOW(), INTERVAL 47.5 HOUR)
WHERE NOT EXISTS (SELECT 1 FROM doctor_message WHERE sender_id = 10 AND receiver_id = 1 AND content LIKE '%150/95%' LIMIT 1);

INSERT INTO `doctor_message` (`sender_id`, `receiver_id`, `content`, `message_type`, `read_status`, `send_time`, `expire_time`)
SELECT 11, 1, '张医生，我最近感觉心跳有点快，需要检查吗？', 'text', 0, DATE_SUB(NOW(), INTERVAL 1 DAY), DATE_ADD(NOW(), INTERVAL 47 HOUR)
WHERE NOT EXISTS (SELECT 1 FROM doctor_message WHERE sender_id = 11 AND receiver_id = 1 LIMIT 1);

INSERT INTO `doctor_message` (`sender_id`, `receiver_id`, `content`, `message_type`, `read_status`, `send_time`, `expire_time`)
SELECT 12, 1, '医生您好，我的血糖控制得不太好，空腹血糖8.5', 'text', 0, DATE_SUB(NOW(), INTERVAL 3 HOUR), DATE_ADD(NOW(), INTERVAL 45 HOUR)
WHERE NOT EXISTS (SELECT 1 FROM doctor_message WHERE sender_id = 12 AND receiver_id = 1 LIMIT 1);

-- ==========================================
-- 2. 补充排班数据（doctor_schedule表为空）
-- ==========================================

INSERT INTO `doctor_schedule` (`doctor_id`, `schedule_date`, `start_time`, `end_time`, `max_appointments`, `booked_appointments`, `status`)
SELECT 1, CURDATE(), '08:00:00', '12:00:00', 20, 15, 'available'
WHERE NOT EXISTS (SELECT 1 FROM doctor_schedule WHERE doctor_id = 1 AND schedule_date = CURDATE() LIMIT 1);

INSERT INTO `doctor_schedule` (`doctor_id`, `schedule_date`, `start_time`, `end_time`, `max_appointments`, `booked_appointments`, `status`)
SELECT 1, CURDATE(), '14:00:00', '17:00:00', 15, 10, 'available'
WHERE NOT EXISTS (SELECT 1 FROM doctor_schedule WHERE doctor_id = 1 AND schedule_date = CURDATE() AND start_time = '14:00:00' LIMIT 1);

INSERT INTO `doctor_schedule` (`doctor_id`, `schedule_date`, `start_time`, `end_time`, `max_appointments`, `booked_appointments`, `status`)
SELECT 1, DATE_ADD(CURDATE(), INTERVAL 1 DAY), '08:00:00', '12:00:00', 20, 8, 'available'
WHERE NOT EXISTS (SELECT 1 FROM doctor_schedule WHERE doctor_id = 1 AND schedule_date = DATE_ADD(CURDATE(), INTERVAL 1 DAY) LIMIT 1);

INSERT INTO `doctor_schedule` (`doctor_id`, `schedule_date`, `start_time`, `end_time`, `max_appointments`, `booked_appointments`, `status`)
SELECT 1, DATE_ADD(CURDATE(), INTERVAL 1 DAY), '14:00:00', '17:00:00', 15, 5, 'available'
WHERE NOT EXISTS (SELECT 1 FROM doctor_schedule WHERE doctor_id = 1 AND schedule_date = DATE_ADD(CURDATE(), INTERVAL 1 DAY) AND start_time = '14:00:00' LIMIT 1);

-- ==========================================
-- 3. 补充分组关系数据
-- ==========================================

INSERT IGNORE INTO `patient_group_relation` (`group_id`, `patient_id`)
VALUES 
(1, 10), (1, 11),
(2, 12),
(3, 10);

-- ==========================================
-- 验证数据
-- ==========================================

SELECT '========================================' AS '';
SELECT '数据补充完成！' AS message;
SELECT '========================================' AS '';
SELECT CONCAT('问诊消息: ', (SELECT COUNT(*) FROM doctor_message), ' 条') AS stat;
SELECT CONCAT('医生排班: ', (SELECT COUNT(*) FROM doctor_schedule), ' 条') AS stat;
SELECT CONCAT('分组关系: ', (SELECT COUNT(*) FROM patient_group_relation), ' 条') AS stat;
SELECT '========================================' AS '';

-- 显示问诊消息
SELECT '问诊消息详情:' AS '';
SELECT id, sender_id, receiver_id, LEFT(content, 30) as content_preview, read_status, send_time 
FROM doctor_message 
WHERE receiver_id = 1 
ORDER BY send_time DESC 
LIMIT 5;

-- 显示排班数据
SELECT '排班数据详情:' AS '';
SELECT * FROM doctor_schedule WHERE doctor_id = 1 ORDER BY schedule_date;
