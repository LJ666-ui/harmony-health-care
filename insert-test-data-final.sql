-- ==========================================
-- 基于实际数据库结构的测试数据脚本
-- 版本: v6.0
-- 日期: 2026-05-11
-- 说明: 使用现有的医生和患者数据补充测试数据
-- ==========================================

USE medical_health;

-- ==========================================
-- 查看当前数据
-- ==========================================

SELECT '========================================' AS '';
SELECT '当前医生数据（user_type=1）:' AS message;
SELECT '========================================' AS '';
SELECT id, username, real_name, phone, user_type 
FROM user 
WHERE user_type = 1 
LIMIT 5;

SELECT '========================================' AS '';
SELECT '当前患者数据（user_type=0）:' AS message;
SELECT '========================================' AS '';
SELECT id, username, real_name, phone, user_type 
FROM user 
WHERE user_type = 0 
LIMIT 5;

-- ==========================================
-- 补充测试数据
-- ==========================================

-- 使用医生ID 1（王建国）作为测试医生
-- 使用患者ID 21-25 作为测试患者

-- 1. 补充患者分组数据（使用医生ID 1）
INSERT IGNORE INTO `patient_group` (`doctor_id`, `group_name`, `description`, `color`, `sort_order`)
VALUES 
(1, '高血压患者', '高血压慢病管理', '#FF6B6B', 1),
(1, '糖尿病患者', '糖尿病慢病管理', '#4ECDC4', 2),
(1, '重点关注', '需要特别关注的患者', '#FFE66D', 3);

-- 2. 补充分组关系数据
INSERT IGNORE INTO `patient_group_relation` (`group_id`, `patient_id`)
VALUES 
(1, 21), (1, 22),  -- 患者加入高血压组
(2, 23), (2, 24),  -- 患者加入糖尿病组
(3, 21), (3, 25);  -- 患者加入重点关注组

-- 3. 补充问诊消息数据（患者发给医生）
INSERT INTO `doctor_message` (`sender_id`, `receiver_id`, `content`, `send_time`, `expire_time`)
SELECT 21, 1, '医生您好，我最近血压有点高，需要调整药物吗？', DATE_SUB(NOW(), INTERVAL 2 HOUR), DATE_ADD(NOW(), INTERVAL 46 HOUR)
WHERE NOT EXISTS (SELECT 1 FROM doctor_message WHERE sender_id = 21 AND receiver_id = 1 LIMIT 1);

INSERT INTO `doctor_message` (`sender_id`, `receiver_id`, `content`, `send_time`, `expire_time`)
SELECT 1, 21, '您好，请问现在的血压是多少？有头晕、头痛等症状吗？', DATE_SUB(NOW(), INTERVAL 1 HOUR), DATE_ADD(NOW(), INTERVAL 47 HOUR)
WHERE NOT EXISTS (SELECT 1 FROM doctor_message WHERE sender_id = 1 AND receiver_id = 21 LIMIT 1);

INSERT INTO `doctor_message` (`sender_id`, `receiver_id`, `content`, `send_time`, `expire_time`)
SELECT 22, 1, '医生，我最近感觉心跳有点快，需要检查吗？', DATE_SUB(NOW(), INTERVAL 1 DAY), DATE_ADD(NOW(), INTERVAL 47 HOUR)
WHERE NOT EXISTS (SELECT 1 FROM doctor_message WHERE sender_id = 22 AND receiver_id = 1 LIMIT 1);

INSERT INTO `doctor_message` (`sender_id`, `receiver_id`, `content`, `send_time`, `expire_time`)
SELECT 23, 1, '医生您好，我的血糖控制得不太好', DATE_SUB(NOW(), INTERVAL 3 HOUR), DATE_ADD(NOW(), INTERVAL 45 HOUR)
WHERE NOT EXISTS (SELECT 1 FROM doctor_message WHERE sender_id = 23 AND receiver_id = 1 LIMIT 1);

-- 4. 补充排班数据（使用医生ID 1）
INSERT INTO `doctor_schedule` (`doctor_id`, `schedule_date`, `start_time`, `end_time`, `max_appointments`, `booked_appointments`, `status`)
SELECT 1, CURDATE(), '08:00:00', '12:00:00', 20, 15, 'available'
WHERE NOT EXISTS (SELECT 1 FROM doctor_schedule WHERE doctor_id = 1 AND schedule_date = CURDATE() LIMIT 1);

INSERT INTO `doctor_schedule` (`doctor_id`, `schedule_date`, `start_time`, `end_time`, `max_appointments`, `booked_appointments`, `status`)
SELECT 1, CURDATE(), '14:00:00', '17:00:00', 15, 10, 'available'
WHERE NOT EXISTS (SELECT 1 FROM doctor_schedule WHERE doctor_id = 1 AND schedule_date = CURDATE() AND start_time = '14:00:00' LIMIT 1);

INSERT INTO `doctor_schedule` (`doctor_id`, `schedule_date`, `start_time`, `end_time`, `max_appointments`, `booked_appointments`, `status`)
SELECT 1, DATE_ADD(CURDATE(), INTERVAL 1 DAY), '08:00:00', '12:00:00', 20, 8, 'available'
WHERE NOT EXISTS (SELECT 1 FROM doctor_schedule WHERE doctor_id = 1 AND schedule_date = DATE_ADD(CURDATE(), INTERVAL 1 DAY) LIMIT 1);

-- 5. 补充处方模板数据（使用医生ID 1）
INSERT IGNORE INTO `prescription_template` (`doctor_id`, `template_name`, `medicines`, `notes`, `is_public`, `usage_count`)
VALUES 
(1, '高血压常规处方', 
  '[{"medicineId":1,"medicineName":"氨氯地平","dosage":"5mg","frequency":"每日一次","duration":"30天"}]',
  '注意监测血压', 1, 5),
(1, '糖尿病常规处方',
  '[{"medicineId":2,"medicineName":"二甲双胍","dosage":"500mg","frequency":"每日三次","duration":"30天"}]',
  '控制饮食，监测血糖', 1, 3);

-- 6. 补充病历模板数据（使用医生ID 1）
INSERT IGNORE INTO `medical_record_template` (`doctor_id`, `template_name`, `diagnosis_template`, `treatment_template`, `notes_template`, `is_public`, `usage_count`)
VALUES 
(1, '高血压初诊病历', '高血压病', '1. 生活方式干预\n2. 药物治疗', '定期监测血压', 1, 10),
(1, '糖尿病初诊病历', '2型糖尿病', '1. 饮食控制\n2. 运动治疗\n3. 药物治疗', '定期监测血糖', 1, 8);

-- 7. 补充会诊数据（使用医生ID 1）
INSERT IGNORE INTO `consultation` (`initiator_id`, `patient_id`, `title`, `description`, `status`, `scheduled_time`)
VALUES 
(1, 21, '高血压伴糖尿病会诊', '患者血压血糖控制不佳，需要多学科会诊', 'pending', DATE_ADD(NOW(), INTERVAL 1 DAY));

-- ==========================================
-- 验证数据
-- ==========================================

SELECT '========================================' AS '';
SELECT '数据补充完成！' AS message;
SELECT '========================================' AS '';
SELECT CONCAT('患者分组: ', (SELECT COUNT(*) FROM patient_group WHERE doctor_id = 1), ' 个') AS stat;
SELECT CONCAT('分组关系: ', (SELECT COUNT(*) FROM patient_group_relation), ' 条') AS stat;
SELECT CONCAT('问诊消息: ', (SELECT COUNT(*) FROM doctor_message WHERE receiver_id = 1), ' 条') AS stat;
SELECT CONCAT('医生排班: ', (SELECT COUNT(*) FROM doctor_schedule WHERE doctor_id = 1), ' 条') AS stat;
SELECT CONCAT('处方模板: ', (SELECT COUNT(*) FROM prescription_template WHERE doctor_id = 1), ' 个') AS stat;
SELECT CONCAT('病历模板: ', (SELECT COUNT(*) FROM medical_record_template WHERE doctor_id = 1), ' 个') AS stat;
SELECT CONCAT('会诊记录: ', (SELECT COUNT(*) FROM consultation WHERE initiator_id = 1), ' 条') AS stat;
SELECT '========================================' AS '';
SELECT '测试账号信息:' AS message;
SELECT '医生账号: ID=1 (王建国)' AS info;
SELECT '患者账号: ID=21-25' AS info;
SELECT '========================================' AS '';
