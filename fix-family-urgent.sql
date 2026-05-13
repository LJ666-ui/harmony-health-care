-- ========================================
-- 紧急修复：将家属关联到患者21
-- 问题：家属userId=1(错误)，应该是21
-- ========================================

USE medical_health;

-- 第一步：查看当前状态
SELECT '=== 修复前状态 ===' AS '';
SELECT id, name, relation, user_id FROM family_member WHERE is_deleted = 0;

-- 第二步：强制修正 - 将所有家属关联到患者21
UPDATE family_member 
SET user_id = 21, update_time = NOW() 
WHERE is_deleted = 0;

SELECT '=== 修复后状态 ===' AS '';
SELECT id, name, relation, user_id FROM family_member WHERE is_deleted = 0;

-- 第三步：验证患者21是否存在
SELECT '=== 验证患者21 ===' AS '';
SELECT id, username, user_type, phone FROM user WHERE id = 21 AND is_deleted = 0;

-- 第四步：如果患者21没有数据，添加测试数据
-- 4.1 添加病历记录
INSERT IGNORE INTO medical_record (user_id, hospital_name, department, doctor_name, diagnosis, treatment_plan, medication_advice, visit_time, record_time, is_deleted, create_time, update_time)
VALUES 
(21, '北京协和医院', '心内科', '张医生', '高血压', '降压治疗', '每日服用降压药', NOW(), NOW(), 0, NOW(), NOW()),
(21, '北京协和医院', '内分泌科', '李医生', '2型糖尿病', '控制血糖', '注意饮食', DATE_SUB(NOW(), INTERVAL 30 DAY), DATE_SUB(NOW(), INTERVAL 30 DAY), 0, NOW(), NOW());

-- 4.2 添加处方记录  
INSERT IGNORE INTO prescription (patient_id, patient_name, doctor_id, doctor_name, diagnosis, medications, notes, status, created_at, valid_until)
VALUES 
(21, '马建军', 1, '张医生', '高血压', '[{"medicineName":"硝苯地平","specification":"30mg","dosage":"1片","frequency":"每日1次","quantity":30,"unit":"片"}]', '按时服药', 'ACTIVE', NOW(), DATE_ADD(NOW(), INTERVAL 30 DAY)),
(21, '马建军', 2, '李医生', '2型糖尿病', '[{"medicineName":"二甲双胍","specification":"500mg","dosage":"1片","frequency":"每日3次","quantity":90,"unit":"片"}]', '餐后服用', 'ACTIVE', NOW(), DATE_ADD(NOW(), INTERVAL 60 DAY));

-- 第五步：验证数据
SELECT '=== 验证病历数据 ===' AS '';
SELECT COUNT(*) AS 病历数量 FROM medical_record WHERE user_id = 21 AND is_deleted = 0;

SELECT '=== 验证处方数据 ===' AS '';
SELECT COUNT(*) AS 处方数量 FROM prescription WHERE patient_id = 21;

SELECT '✅ 修复完成！请重启后端服务并刷新前端页面' AS '';