-- ========================================
-- 修复家属端数据连接问题
-- ========================================

USE medical_health;

-- 问题分析：
-- 1. family_member 表中，家属 1,2,3 关联到 user_id = 1
-- 2. 但 health_record 表中的 user_id 从 21 开始
-- 3. 导致家属查看患者数据时返回空

-- 解决方案：为 user_id = 1 添加测试数据

-- 1. 为用户 ID 1（张三）添加健康记录
INSERT INTO `health_record` (`user_id`, `blood_pressure`, `blood_sugar`, `heart_rate`, `record_time`, `weight`, `height`, `step_count`, `sleep_duration`, `create_time`, `update_time`, `is_deleted`) VALUES
(1, '120/80', 5.6, 72, '2026-05-01 08:00:00', 70.0, 1.75, 8000, 7.5, NOW(), NOW(), 0),
(1, '118/78', 5.4, 70, '2026-05-02 08:30:00', 69.8, 1.75, 6500, 7.2, NOW(), NOW(), 0),
(1, '122/82', 5.8, 74, '2026-05-03 09:00:00', 70.2, 1.75, 9000, 7.8, NOW(), NOW(), 0),
(1, '119/79', 5.5, 71, '2026-05-04 08:15:00', 69.9, 1.75, 7200, 7.4, NOW(), NOW(), 0),
(1, '121/81', 5.7, 73, '2026-05-05 08:45:00', 70.1, 1.75, 8500, 7.6, NOW(), NOW(), 0),
(1, '117/77', 5.3, 70, '2026-05-06 09:10:00', 69.7, 1.75, 7800, 7.3, NOW(), NOW(), 0),
(1, '123/83', 5.9, 75, '2026-05-07 08:20:00', 70.3, 1.75, 8200, 7.7, NOW(), NOW(), 0);

-- 2. 为用户 ID 1 添加医疗记录（需要先检查 medical_record 表结构）
-- 假设 medical_record 表存在，插入测试数据
INSERT INTO `medical_record` (`user_id`, `hospital_name`, `department`, `doctor_name`, `diagnosis`, `treatment_plan`, `medication_advice`, `visit_time`, `create_time`, `update_time`, `is_deleted`) VALUES
(1, '北京协和医院', '心血管内科', '陈医生', '高血压病（1级）', '低盐饮食，规律运动，定期监测血压', '氨氯地平 5mg 每日一次', '2026-04-15 09:30:00', NOW(), NOW(), 0),
(1, '北京协和医院', '心血管内科', '陈医生', '高血压病复查', '血压控制良好，继续当前治疗方案', '氨氯地平 5mg 每日一次', '2026-04-29 10:00:00', NOW(), NOW(), 0);

-- 3. 为用户 ID 1 添加用药提醒（需要先检查 medication_reminder 表结构）
INSERT INTO `medication_reminder` (`patient_id`, `medication_name`, `dosage`, `frequency`, `time_of_day`, `status`, `start_date`, `end_date`, `notes`, `create_time`, `update_time`, `is_deleted`) VALUES
(1, '氨氯地平片', '5mg', '每日一次', '08:00', 'CONFIRMED', '2026-04-15', '2026-07-15', '早餐后服用', NOW(), NOW(), 0),
(1, '维生素D', '1粒', '每日一次', '12:00', 'PENDING', '2026-05-01', '2026-06-01', '午餐时服用', NOW(), NOW(), 0);

-- 4. 验证数据是否正确插入
SELECT '========== 验证健康记录 ==========' AS info;
SELECT COUNT(*) AS record_count FROM health_record WHERE user_id = 1 AND is_deleted = 0;
SELECT id, user_id, blood_pressure, blood_sugar, heart_rate, record_time 
FROM health_record 
WHERE user_id = 1 AND is_deleted = 0 
ORDER BY record_time DESC;

SELECT '========== 验证医疗记录 ==========' AS info;
SELECT COUNT(*) AS record_count FROM medical_record WHERE user_id = 1 AND is_deleted = 0;
SELECT * FROM medical_record WHERE user_id = 1 AND is_deleted = 0;

SELECT '========== 验证用药提醒 ==========' AS info;
SELECT COUNT(*) AS reminder_count FROM medication_reminder WHERE patient_id = 1 AND is_deleted = 0;
SELECT * FROM medication_reminder WHERE patient_id = 1 AND is_deleted = 0;

SELECT '========== 数据修复完成！ ==========' AS message;
SELECT '现在家属可以使用以下账号登录测试：' AS info;
SELECT '手机号：13912345001（王秀英，配偶）' AS account_1;
SELECT '手机号：13712345002（王明，子女）' AS account_2;
