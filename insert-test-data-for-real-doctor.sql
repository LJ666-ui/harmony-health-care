-- ==========================================
-- 基于实际数据库的测试数据补充脚本
-- 版本: v5.0
-- 日期: 2026-05-11
-- 说明: 基于现有的医生数据补充测试数据
-- ==========================================

USE medical_health;

-- ==========================================
-- 查看当前医生数据
-- ==========================================

SELECT '========================================' AS '';
SELECT '当前医生数据:' AS message;
SELECT '========================================' AS '';
SELECT d.id, d.user_id, d.real_name, d.phone, d.hospital, d.department, u.username
FROM doctor d
LEFT JOIN user u ON d.user_id = u.id
WHERE d.is_deleted = 0
LIMIT 10;

-- ==========================================
-- 使用现有的医生ID补充数据
-- ==========================================

-- 获取医生ID 21 的数据（刘二医生）
-- 如果需要为其他医生补充数据，可以修改 doctor_id

-- 1. 补充患者分组数据（使用医生ID 21）
INSERT IGNORE INTO `patient_group` (`doctor_id`, `group_name`, `description`, `color`, `sort_order`)
VALUES 
(21, '精神科患者', '精神科疾病管理', '#FF6B6B', 1),
(21, '重点关注', '需要特别关注的患者', '#FFE66D', 2),
(21, '复诊患者', '定期复诊患者', '#4ECDC4', 3);

-- 2. 补充问诊消息数据（使用医生ID 21，用户ID 103）
-- 先创建一些测试患者
INSERT IGNORE INTO `user` (`id`, `username`, `password`, `user_type`, `real_name`, `phone`, `age`, `status`)
VALUES 
(200, 'test_patient001', '$2a$10$N.zmdr9k7uOCQv37uk7jO.9.Mq8P5x1KQJ5Z5Z5Z5Z5Z5Z5Z5Z5Z5', 0, '测试患者A', '13900000001', 35, 1),
(201, 'test_patient002', '$2a$10$N.zmdr9k7uOCQv37uk7jO.9.Mq8P5x1KQJ5Z5Z5Z5Z5Z5Z5Z5Z5Z5', 0, '测试患者B', '13900000002', 42, 1),
(202, 'test_patient003', '$2a$10$N.zmdr9k7uOCQv37uk7jO.9.Mq8P5x1KQJ5Z5Z5Z5Z5Z5Z5Z5Z5Z5', 0, '测试患者C', '13900000003', 28, 1);

-- 插入问诊消息（患者发给医生）
INSERT INTO `doctor_message` (`sender_id`, `receiver_id`, `content`, `send_time`, `expire_time`)
SELECT 200, 103, '医生您好，我最近睡眠不好，需要调整药物吗？', DATE_SUB(NOW(), INTERVAL 2 HOUR), DATE_ADD(NOW(), INTERVAL 46 HOUR)
WHERE NOT EXISTS (SELECT 1 FROM doctor_message WHERE sender_id = 200 AND receiver_id = 103 LIMIT 1);

INSERT INTO `doctor_message` (`sender_id`, `receiver_id`, `content`, `send_time`, `expire_time`)
SELECT 103, 200, '您好，请问睡眠问题持续多久了？有其他症状吗？', DATE_SUB(NOW(), INTERVAL 1 HOUR), DATE_ADD(NOW(), INTERVAL 47 HOUR)
WHERE NOT EXISTS (SELECT 1 FROM doctor_message WHERE sender_id = 103 AND receiver_id = 200 LIMIT 1);

INSERT INTO `doctor_message` (`sender_id`, `receiver_id`, `content`, `send_time`, `expire_time`)
SELECT 201, 103, '刘医生，我最近情绪不太稳定，需要复查吗？', DATE_SUB(NOW(), INTERVAL 1 DAY), DATE_ADD(NOW(), INTERVAL 47 HOUR)
WHERE NOT EXISTS (SELECT 1 FROM doctor_message WHERE sender_id = 201 AND receiver_id = 103 LIMIT 1);

INSERT INTO `doctor_message` (`sender_id`, `receiver_id`, `content`, `send_time`, `expire_time`)
SELECT 202, 103, '医生您好，我想咨询一下用药问题', DATE_SUB(NOW(), INTERVAL 3 HOUR), DATE_ADD(NOW(), INTERVAL 45 HOUR)
WHERE NOT EXISTS (SELECT 1 FROM doctor_message WHERE sender_id = 202 AND receiver_id = 103 LIMIT 1);

-- 3. 补充排班数据（使用医生ID 21）
INSERT INTO `doctor_schedule` (`doctor_id`, `schedule_date`, `start_time`, `end_time`, `max_appointments`, `booked_appointments`, `status`)
SELECT 21, CURDATE(), '08:00:00', '12:00:00', 20, 15, 'available'
WHERE NOT EXISTS (SELECT 1 FROM doctor_schedule WHERE doctor_id = 21 AND schedule_date = CURDATE() LIMIT 1);

INSERT INTO `doctor_schedule` (`doctor_id`, `schedule_date`, `start_time`, `end_time`, `max_appointments`, `booked_appointments`, `status`)
SELECT 21, CURDATE(), '14:00:00', '17:00:00', 15, 10, 'available'
WHERE NOT EXISTS (SELECT 1 FROM doctor_schedule WHERE doctor_id = 21 AND schedule_date = CURDATE() AND start_time = '14:00:00' LIMIT 1);

INSERT INTO `doctor_schedule` (`doctor_id`, `schedule_date`, `start_time`, `end_time`, `max_appointments`, `booked_appointments`, `status`)
SELECT 21, DATE_ADD(CURDATE(), INTERVAL 1 DAY), '08:00:00', '12:00:00', 20, 8, 'available'
WHERE NOT EXISTS (SELECT 1 FROM doctor_schedule WHERE doctor_id = 21 AND schedule_date = DATE_ADD(CURDATE(), INTERVAL 1 DAY) LIMIT 1);

-- 4. 补充处方模板数据（使用医生ID 21）
INSERT IGNORE INTO `prescription_template` (`doctor_id`, `template_name`, `medicines`, `notes`, `is_public`, `usage_count`)
VALUES 
(21, '精神科常规处方', 
  '[{"medicineId":1,"medicineName":"奥氮平","dosage":"5mg","frequency":"每日一次","duration":"30天"}]',
  '注意监测副作用', 1, 5),
(21, '睡眠障碍处方',
  '[{"medicineId":2,"medicineName":"艾司唑仑","dosage":"1mg","frequency":"睡前服用","duration":"14天"}]',
  '短期使用，注意依赖性', 1, 3);

-- 5. 补充病历模板数据（使用医生ID 21）
INSERT IGNORE INTO `medical_record_template` (`doctor_id`, `template_name`, `diagnosis_template`, `treatment_template`, `notes_template`, `is_public`, `usage_count`)
VALUES 
(21, '精神科初诊病历', '精神障碍', '1. 完善相关检查\n2. 药物治疗\n3. 心理治疗', '定期复诊，监测病情', 1, 10),
(21, '睡眠障碍病历', '睡眠障碍', '1. 睡眠卫生教育\n2. 药物治疗', '短期用药，注意依赖性', 1, 8);

-- 6. 补充会诊数据（使用医生ID 21）
INSERT IGNORE INTO `consultation` (`initiator_id`, `patient_id`, `title`, `description`, `status`, `scheduled_time`)
VALUES 
(21, 200, '精神科会诊', '患者测试患者A，精神症状复杂，需要多学科会诊', 'pending', DATE_ADD(NOW(), INTERVAL 1 DAY));

-- ==========================================
-- 验证数据
-- ==========================================

SELECT '========================================' AS '';
SELECT '数据补充完成！' AS message;
SELECT '========================================' AS '';
SELECT CONCAT('患者分组: ', (SELECT COUNT(*) FROM patient_group WHERE doctor_id = 21), ' 个') AS stat;
SELECT CONCAT('问诊消息: ', (SELECT COUNT(*) FROM doctor_message WHERE receiver_id = 103), ' 条') AS stat;
SELECT CONCAT('医生排班: ', (SELECT COUNT(*) FROM doctor_schedule WHERE doctor_id = 21), ' 条') AS stat;
SELECT CONCAT('处方模板: ', (SELECT COUNT(*) FROM prescription_template WHERE doctor_id = 21), ' 个') AS stat;
SELECT CONCAT('病历模板: ', (SELECT COUNT(*) FROM medical_record_template WHERE doctor_id = 21), ' 个') AS stat;
SELECT CONCAT('会诊记录: ', (SELECT COUNT(*) FROM consultation WHERE initiator_id = 21), ' 条') AS stat;
SELECT '========================================' AS '';
SELECT '登录信息:' AS message;
SELECT '用户名: xclfz' AS info;
SELECT '密码: 123456 (或查看user表中的实际密码)' AS info;
SELECT '医生ID: 21' AS info;
SELECT '用户ID: 103' AS info;
SELECT '========================================' AS '';
