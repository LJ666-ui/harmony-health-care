-- ==========================================
-- 鸿蒙健康医疗应用 - 补充缺失数据脚本
-- 版本: v3.0
-- 日期: 2026-05-10
-- 说明: 只补充缺失的数据，不重复插入已有数据
-- ==========================================

USE medical_health;

-- ==========================================
-- 查看当前数据统计
-- ==========================================

SELECT '========================================' AS '';
SELECT '当前数据统计:' AS message;
SELECT '========================================' AS '';
SELECT CONCAT('患者分组: ', (SELECT COUNT(*) FROM patient_group), ' 个') AS stat;
SELECT CONCAT('分组关系: ', (SELECT COUNT(*) FROM patient_group_relation), ' 条') AS stat;
SELECT CONCAT('病历记录: ', (SELECT COUNT(*) FROM medical_record), ' 条') AS stat;
SELECT CONCAT('问诊消息: ', (SELECT COUNT(*) FROM doctor_message), ' 条') AS stat;
SELECT CONCAT('医生排班: ', (SELECT COUNT(*) FROM doctor_schedule), ' 条') AS stat;
SELECT CONCAT('处方模板: ', (SELECT COUNT(*) FROM prescription_template), ' 个') AS stat;
SELECT CONCAT('病历模板: ', (SELECT COUNT(*) FROM medical_record_template), ' 个') AS stat;
SELECT CONCAT('会诊记录: ', (SELECT COUNT(*) FROM consultation), ' 条') AS stat;
SELECT CONCAT('预约记录: ', (SELECT COUNT(*) FROM appointment), ' 条') AS stat;
SELECT '========================================' AS '';

-- ==========================================
-- 补充缺失的数据
-- ==========================================

-- 1. 如果分组关系太少，补充一些
INSERT IGNORE INTO `patient_group_relation` (`group_id`, `patient_id`)
SELECT 1, 10 WHERE NOT EXISTS (SELECT 1 FROM patient_group_relation WHERE group_id = 1 AND patient_id = 10);

INSERT IGNORE INTO `patient_group_relation` (`group_id`, `patient_id`)
SELECT 1, 11 WHERE NOT EXISTS (SELECT 1 FROM patient_group_relation WHERE group_id = 1 AND patient_id = 11);

INSERT IGNORE INTO `patient_group_relation` (`group_id`, `patient_id`)
SELECT 2, 12 WHERE NOT EXISTS (SELECT 1 FROM patient_group_relation WHERE group_id = 2 AND patient_id = 12);

INSERT IGNORE INTO `patient_group_relation` (`group_id`, `patient_id`)
SELECT 2, 13 WHERE NOT EXISTS (SELECT 1 FROM patient_group_relation WHERE group_id = 2 AND patient_id = 13);

-- 2. 如果预约记录太少，补充一些
INSERT IGNORE INTO `appointment` (`user_id`, `doctor_id`, `status`, `symptom`)
SELECT 10, 1, 1, '血压控制不佳，需要调整药物' 
WHERE NOT EXISTS (SELECT 1 FROM appointment WHERE user_id = 10 AND doctor_id = 1);

INSERT IGNORE INTO `appointment` (`user_id`, `doctor_id`, `status`, `symptom`)
SELECT 11, 1, 0, '心跳加快，需要检查' 
WHERE NOT EXISTS (SELECT 1 FROM appointment WHERE user_id = 11 AND doctor_id = 1);

INSERT IGNORE INTO `appointment` (`user_id`, `doctor_id`, `status`, `symptom`)
SELECT 12, 3, 1, '血糖控制不佳' 
WHERE NOT EXISTS (SELECT 1 FROM appointment WHERE user_id = 12 AND doctor_id = 3);

INSERT IGNORE INTO `appointment` (`user_id`, `doctor_id`, `status`, `symptom`)
SELECT 13, 3, 0, '糖尿病复查' 
WHERE NOT EXISTS (SELECT 1 FROM appointment WHERE user_id = 13 AND doctor_id = 3);

-- ==========================================
-- 最终数据统计
-- ==========================================

SELECT '========================================' AS '';
SELECT '补充完成！最终数据统计:' AS message;
SELECT '========================================' AS '';
SELECT CONCAT('患者分组: ', (SELECT COUNT(*) FROM patient_group), ' 个') AS stat;
SELECT CONCAT('分组关系: ', (SELECT COUNT(*) FROM patient_group_relation), ' 条') AS stat;
SELECT CONCAT('病历记录: ', (SELECT COUNT(*) FROM medical_record), ' 条') AS stat;
SELECT CONCAT('问诊消息: ', (SELECT COUNT(*) FROM doctor_message), ' 条') AS stat;
SELECT CONCAT('医生排班: ', (SELECT COUNT(*) FROM doctor_schedule), ' 条') AS stat;
SELECT CONCAT('处方模板: ', (SELECT COUNT(*) FROM prescription_template), ' 个') AS stat;
SELECT CONCAT('病历模板: ', (SELECT COUNT(*) FROM medical_record_template), ' 个') AS stat;
SELECT CONCAT('会诊记录: ', (SELECT COUNT(*) FROM consultation), ' 条') AS stat;
SELECT CONCAT('预约记录: ', (SELECT COUNT(*) FROM appointment), ' 条') AS stat;
SELECT '========================================' AS '';
SELECT '提示：您的数据库已经有足够的数据了！' AS message;
SELECT '如果前端页面没有显示数据，请检查：' AS message;
SELECT '1. 后端服务是否正常运行' AS message;
SELECT '2. API接口是否正确配置' AS message;
SELECT '3. 前端是否正确调用API' AS message;
SELECT '========================================' AS '';
