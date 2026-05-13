-- ==========================================
-- 鸿蒙健康医疗应用 - 测试数据插入脚本
-- 版本: v1.0
-- 日期: 2026-05-10
-- 说明: 为医生工作台的8个功能模块插入测试数据
-- ==========================================

USE medical_health;

-- ==========================================
-- 准备工作：确保基础数据存在
-- ==========================================

-- 1. 确保有医生数据
INSERT IGNORE INTO `user` (`id`, `username`, `password`, `nickname`, `user_type`, `real_name`, `phone`, `status`)
VALUES 
(1, 'doctor001', '$2a$10$N.zmdr9k7uOCQv37uk7jO.9.Mq8P5x1KQJ5Z5Z5Z5Z5Z5Z5Z5Z5Z5', '张医生', 1, '张伟', '13800138001', 1),
(2, 'doctor002', '$2a$10$N.zmdr9k7uOCQv37uk7jO.9.Mq8P5x1KQJ5Z5Z5Z5Z5Z5Z5Z5Z5Z5', '李医生', 1, '李明', '13800138002', 1),
(3, 'doctor003', '$2a$10$N.zmdr9k7uOCQv37uk7jO.9.Mq8P5x1KQJ5Z5Z5Z5Z5Z5Z5Z5Z5Z5', '王医生', 1, '王芳', '13800138003', 1);

INSERT IGNORE INTO `doctor` (`id`, `user_id`, `hospital_id`, `department_id`, `name`, `title`, `specialty`, `status`)
VALUES 
(1, 1, 1, 1, '张伟', '主任医师', '心血管内科', 1),
(2, 2, 1, 2, '李明', '副主任医师', '神经内科', 1),
(3, 3, 1, 3, '王芳', '主治医师', '内分泌科', 1);

-- 2. 确保有患者数据
INSERT IGNORE INTO `user` (`id`, `username`, `password`, `nickname`, `user_type`, `real_name`, `phone`, `age`, `gender`, `status`)
VALUES 
(10, 'patient001', '$2a$10$N.zmdr9k7uOCQv37uk7jO.9.Mq8P5x1KQJ5Z5Z5Z5Z5Z5Z5Z5Z5Z5', '患者A', 0, '张三', '13900139001', 45, 1, 1),
(11, 'patient002', '$2a$10$N.zmdr9k7uOCQv37uk7jO.9.Mq8P5x1KQJ5Z5Z5Z5Z5Z5Z5Z5Z5Z5', '患者B', 0, '李四', '13900139002', 52, 1, 1),
(12, 'patient003', '$2a$10$N.zmdr9k7uOCQv37uk7jO.9.Mq8P5x1KQJ5Z5Z5Z5Z5Z5Z5Z5Z5Z5', '患者C', 0, '王五', '13900139003', 38, 0, 1),
(13, 'patient004', '$2a$10$N.zmdr9k7uOCQv37uk7jO.9.Mq8P5x1KQJ5Z5Z5Z5Z5Z5Z5Z5Z5Z5', '患者D', 0, '赵六', '13900139004', 60, 1, 1),
(15, 'patient005', '$2a$10$N.zmdr9k7uOCQv37uk7jO.9.Mq8P5x1KQJ5Z5Z5Z5Z5Z5Z5Z5Z5Z5', '患者E', 0, '孙七', '13900139005', 48, 0, 1);

-- ==========================================
-- 1. 患者管理 - 插入患者分组数据
-- ==========================================

-- 创建患者分组
INSERT IGNORE INTO `patient_group` (`doctor_id`, `group_name`, `description`, `color`, `sort_order`)
VALUES 
(1, '高血压患者', '高血压慢病管理', '#FF6B6B', 1),
(1, '糖尿病患者', '糖尿病慢病管理', '#4ECDC4', 2),
(1, '重点关注', '需要特别关注的患者', '#FFE66D', 3),
(2, '神经内科患者', '神经系统疾病患者', '#95E1D3', 1);

-- 添加患者到分组
INSERT IGNORE INTO `patient_group_relation` (`group_id`, `patient_id`)
VALUES 
(1, 10), (1, 11),  -- 张三、李四加入高血压患者组
(2, 12), (2, 13),  -- 王五、赵六加入糖尿病患者组
(3, 10), (3, 13);  -- 张三、赵六加入重点关注组

-- ==========================================
-- 2. 病历管理 - 插入病历数据
-- ==========================================

INSERT IGNORE INTO `medical_record` (`user_id`, `hospital_name`, `department`, `doctor_name`, `diagnosis`, `treatment_plan`, `medication_advice`, `visit_time`)
VALUES 
(10, '北京协和医院', '心血管内科', '张伟', '高血压病3级（极高危）', '1. 生活方式干预\n2. 药物治疗\n3. 定期监测血压', '氨氯地平 5mg qd\n厄贝沙坦 150mg qd', DATE_SUB(NOW(), INTERVAL 5 DAY)),
(11, '北京协和医院', '心血管内科', '张伟', '高血压病2级', '1. 饮食控制\n2. 适量运动\n3. 药物治疗', '硝苯地平控释片 30mg qd', DATE_SUB(NOW(), INTERVAL 10 DAY)),
(12, '北京协和医院', '内分泌科', '王芳', '2型糖尿病', '1. 饮食控制\n2. 运动治疗\n3. 药物治疗', '二甲双胍 500mg tid\n阿卡波糖 50mg tid', DATE_SUB(NOW(), INTERVAL 7 DAY)),
(13, '北京协和医院', '内分泌科', '王芳', '2型糖尿病伴高血压', '1. 综合治疗\n2. 监测血糖血压', '二甲双胍 500mg bid\n氨氯地平 5mg qd', DATE_SUB(NOW(), INTERVAL 3 DAY));

-- ==========================================
-- 3. 处方管理 - 插入处方数据
-- ==========================================

INSERT IGNORE INTO `prescription` (`patient_id`, `patient_name`, `doctor_id`, `doctor_name`, `medications`, `diagnosis`, `notes`, `status`, `created_at`)
VALUES 
(10, '张三', 1, '张伟', 
  '[{"medicineId":1,"medicineName":"氨氯地平","dosage":"5mg","frequency":"每日一次","duration":"30天","quantity":1},{"medicineId":2,"medicineName":"厄贝沙坦","dosage":"150mg","frequency":"每日一次","duration":"30天","quantity":1}]',
  '高血压病3级（极高危）', '注意监测血压，定期复查', 'active', DATE_SUB(NOW(), INTERVAL 5 DAY)),
(11, '李四', 1, '张伟',
  '[{"medicineId":3,"medicineName":"硝苯地平控释片","dosage":"30mg","frequency":"每日一次","duration":"30天","quantity":1}]',
  '高血压病2级', '低盐饮食，适量运动', 'active', DATE_SUB(NOW(), INTERVAL 10 DAY)),
(12, '王五', 3, '王芳',
  '[{"medicineId":4,"medicineName":"二甲双胍","dosage":"500mg","frequency":"每日三次","duration":"30天","quantity":3},{"medicineId":5,"medicineName":"阿卡波糖","dosage":"50mg","frequency":"每日三次","duration":"30天","quantity":3}]',
  '2型糖尿病', '控制饮食，监测血糖', 'active', DATE_SUB(NOW(), INTERVAL 7 DAY));

-- ==========================================
-- 4. 在线问诊 - 插入医生消息数据
-- ==========================================

INSERT IGNORE INTO `doctor_message` (`session_id`, `sender_id`, `receiver_id`, `sender_type`, `receiver_type`, `content`, `message_type`, `read_status`, `send_time`, `expire_time`)
VALUES 
-- 患者张三发起咨询
('session_001', 10, 1, 'patient', 'doctor', '医生您好，我最近血压有点高，需要调整药物吗？', 'text', 0, DATE_SUB(NOW(), INTERVAL 2 HOUR), DATE_ADD(NOW(), INTERVAL 46 HOUR)),
('session_001', 1, 10, 'doctor', 'patient', '您好，请问现在的血压是多少？有头晕、头痛等症状吗？', 'text', 1, DATE_SUB(NOW(), INTERVAL 1 HOUR), DATE_ADD(NOW(), INTERVAL 47 HOUR)),
('session_001', 10, 1, 'patient', 'doctor', '早上测量是150/95，偶尔有点头晕', 'text', 0, DATE_SUB(NOW(), INTERVAL 30 MINUTE), DATE_ADD(NOW(), INTERVAL 47.5 HOUR)),
-- 患者李四发起咨询
('session_002', 11, 1, 'patient', 'doctor', '张医生，我最近感觉心跳有点快，需要检查吗？', 'text', 0, DATE_SUB(NOW(), INTERVAL 1 DAY), DATE_ADD(NOW(), INTERVAL 47 HOUR)),
-- 患者王五发起咨询
('session_003', 12, 3, 'patient', 'doctor', '王医生，我的血糖控制得不太好，空腹血糖8.5', 'text', 0, DATE_SUB(NOW(), INTERVAL 3 HOUR), DATE_ADD(NOW(), INTERVAL 45 HOUR)),
('session_003', 3, 12, 'doctor', 'patient', '您好，需要调整用药方案，建议来门诊复查', 'text', 1, DATE_SUB(NOW(), INTERVAL 2 HOUR), DATE_ADD(NOW(), INTERVAL 46 HOUR));

-- ==========================================
-- 5. 排班管理 - 插入医生排班数据
-- ==========================================

INSERT IGNORE INTO `doctor_schedule` (`doctor_id`, `hospital_id`, `department_id`, `schedule_date`, `time_slot_id`, `start_time`, `end_time`, `max_appointments`, `booked_appointments`, `status`)
VALUES 
-- 张医生的排班
(1, 1, 1, CURDATE(), 1, '08:00:00', '12:00:00', 20, 15, 'available'),
(1, 1, 1, CURDATE(), 2, '14:00:00', '17:00:00', 15, 10, 'available'),
(1, 1, 1, DATE_ADD(CURDATE(), INTERVAL 1 DAY), 1, '08:00:00', '12:00:00', 20, 8, 'available'),
(1, 1, 1, DATE_ADD(CURDATE(), INTERVAL 1 DAY), 2, '14:00:00', '17:00:00', 15, 5, 'available'),
-- 李医生的排班
(2, 1, 2, CURDATE(), 1, '08:00:00', '12:00:00', 15, 12, 'available'),
(2, 1, 2, DATE_ADD(CURDATE(), INTERVAL 2 DAY), 1, '08:00:00', '12:00:00', 15, 6, 'available'),
-- 王医生的排班
(3, 1, 3, CURDATE(), 2, '14:00:00', '17:00:00', 10, 7, 'available'),
(3, 1, 3, DATE_ADD(CURDATE(), INTERVAL 1 DAY), 2, '14:00:00', '17:00:00', 10, 3, 'available');

-- ==========================================
-- 6. 处方模板 - 插入处方模板数据
-- ==========================================

INSERT IGNORE INTO `prescription_template` (`doctor_id`, `template_name`, `medicines`, `notes`, `is_public`, `usage_count`)
VALUES 
(1, '高血压常规处方', 
  '[{"medicineId":1,"medicineName":"氨氯地平","dosage":"5mg","frequency":"每日一次","duration":"30天"},{"medicineId":2,"medicineName":"厄贝沙坦","dosage":"150mg","frequency":"每日一次","duration":"30天"}]',
  '注意监测血压，定期复查', 1, 15),
(1, '高血压伴糖尿病处方',
  '[{"medicineId":1,"medicineName":"氨氯地平","dosage":"5mg","frequency":"每日一次","duration":"30天"},{"medicineId":4,"medicineName":"二甲双胍","dosage":"500mg","frequency":"每日三次","duration":"30天"}]',
  '控制血压血糖，注意低血糖反应', 1, 8),
(3, '糖尿病常规处方',
  '[{"medicineId":4,"medicineName":"二甲双胍","dosage":"500mg","frequency":"每日三次","duration":"30天"},{"medicineId":5,"medicineName":"阿卡波糖","dosage":"50mg","frequency":"每日三次","duration":"30天"}]',
  '控制饮食，监测血糖', 1, 12),
(2, '神经内科常规处方',
  '[{"medicineId":6,"medicineName":"甲钴胺","dosage":"0.5mg","frequency":"每日三次","duration":"30天"}]',
  '营养神经治疗', 0, 5);

-- ==========================================
-- 7. 病历模板 - 插入病历模板数据
-- ==========================================

INSERT IGNORE INTO `medical_record_template` (`doctor_id`, `template_name`, `diagnosis_template`, `treatment_template`, `notes_template`, `is_public`, `usage_count`)
VALUES 
(1, '高血压初诊病历', '高血压病', '1. 生活方式干预\n2. 药物治疗\n3. 定期监测血压', '注意监测血压，定期复查', 1, 20),
(1, '高血压复诊病历', '高血压病（复诊）', '1. 评估血压控制情况\n2. 调整治疗方案', '询问用药情况，监测血压', 1, 15),
(3, '糖尿病初诊病历', '2型糖尿病', '1. 饮食控制\n2. 运动治疗\n3. 药物治疗', '定期监测血糖，注意低血糖反应', 1, 18),
(3, '糖尿病复诊病历', '2型糖尿病（复诊）', '1. 评估血糖控制情况\n2. 调整治疗方案', '询问用药情况，监测血糖', 1, 10),
(2, '神经内科初诊病历', '神经系统疾病', '1. 完善相关检查\n2. 对症治疗', '注意观察病情变化', 0, 8);

-- ==========================================
-- 8. 会诊管理 - 插入会诊数据
-- ==========================================

-- 插入会诊记录
INSERT IGNORE INTO `consultation` (`initiator_id`, `patient_id`, `title`, `description`, `status`, `scheduled_time`)
VALUES 
(1, 10, '高血压伴糖尿病多学科会诊', '患者张三，高血压病3级伴2型糖尿病，血压血糖控制不佳，需要心内科和内分泌科共同制定治疗方案', 'pending', DATE_ADD(NOW(), INTERVAL 1 DAY)),
(3, 13, '糖尿病并发症会诊', '患者赵六，2型糖尿病多年，出现视网膜病变，需要眼科会诊', 'in_progress', DATE_ADD(NOW(), INTERVAL 2 HOUR)),
(2, 11, '神经系统疾病会诊', '患者李四，出现头晕、记忆力减退，需要神经内科和心内科会诊', 'pending', DATE_ADD(NOW(), INTERVAL 3 DAY));

-- 插入会诊参与人
INSERT IGNORE INTO `consultation_participant` (`consultation_id`, `doctor_id`, `department_id`, `status`)
VALUES 
(1, 1, 1, 'accepted'),  -- 张医生（心内科）
(1, 3, 3, 'invited'),   -- 王医生（内分泌科）
(2, 3, 3, 'accepted'),  -- 王医生（内分泌科）
(2, 1, 1, 'invited'),   -- 张医生（心内科）
(3, 2, 2, 'accepted'),  -- 李医生（神经内科）
(3, 1, 1, 'invited');   -- 张医生（心内科）

-- 插入会诊记录
INSERT IGNORE INTO `consultation_record` (`consultation_id`, `doctor_id`, `content`)
VALUES 
(1, 1, '患者血压控制不佳，建议调整降压药物方案'),
(2, 3, '患者血糖控制不理想，已出现视网膜病变，建议加强血糖控制'),
(3, 2, '患者神经系统检查未见明显异常，建议完善头颅MRI检查');

-- ==========================================
-- 补充：预约数据
-- ==========================================

INSERT IGNORE INTO `appointment` (`user_id`, `doctor_id`, `hospital_id`, `appointment_time`, `status`, `symptom`)
VALUES 
(10, 1, 1, DATE_ADD(NOW(), INTERVAL 1 DAY), 1, '血压控制不佳，需要调整药物'),
(11, 1, 1, DATE_ADD(NOW(), INTERVAL 2 DAY), 0, '心跳加快，需要检查'),
(12, 3, 1, DATE_ADD(NOW(), INTERVAL 1 DAY), 1, '血糖控制不佳'),
(13, 3, 1, DATE_ADD(NOW(), INTERVAL 3 DAY), 0, '糖尿病复查');

-- ==========================================
-- 验证数据插入
-- ==========================================

SELECT '========================================' AS '';
SELECT '测试数据插入完成！' AS message;
SELECT '========================================' AS '';
SELECT '数据统计:' AS '';
SELECT CONCAT('患者分组: ', (SELECT COUNT(*) FROM patient_group), ' 个') AS stat;
SELECT CONCAT('分组关系: ', (SELECT COUNT(*) FROM patient_group_relation), ' 条') AS stat;
SELECT CONCAT('病历记录: ', (SELECT COUNT(*) FROM medical_record), ' 条') AS stat;
SELECT CONCAT('处方记录: ', (SELECT COUNT(*) FROM prescription), ' 条') AS stat;
SELECT CONCAT('问诊消息: ', (SELECT COUNT(*) FROM doctor_message), ' 条') AS stat;
SELECT CONCAT('医生排班: ', (SELECT COUNT(*) FROM doctor_schedule), ' 条') AS stat;
SELECT CONCAT('处方模板: ', (SELECT COUNT(*) FROM prescription_template), ' 个') AS stat;
SELECT CONCAT('病历模板: ', (SELECT COUNT(*) FROM medical_record_template), ' 个') AS stat;
SELECT CONCAT('会诊记录: ', (SELECT COUNT(*) FROM consultation), ' 条') AS stat;
SELECT CONCAT('预约记录: ', (SELECT COUNT(*) FROM appointment), ' 条') AS stat;
SELECT '========================================' AS '';
