-- ==========================================
-- 完整诊断脚本
-- ==========================================

USE medical_health;

-- 1. 检查医生数据
SELECT '========================================' AS '';
SELECT '1. 医生数据检查' AS message;
SELECT '========================================' AS '';
SELECT COUNT(*) as doctor_count FROM doctor WHERE is_deleted = 0;
SELECT id, user_id, real_name, phone, hospital, department FROM doctor WHERE id = 1;

-- 2. 检查患者分组数据
SELECT '========================================' AS '';
SELECT '2. 患者分组数据检查' AS message;
SELECT '========================================' AS '';
SELECT COUNT(*) as group_count FROM patient_group WHERE doctor_id = 1 AND is_deleted = 0;
SELECT id, doctor_id, group_name, description FROM patient_group WHERE doctor_id = 1 AND is_deleted = 0 LIMIT 5;

-- 3. 检查分组关系数据
SELECT '========================================' AS '';
SELECT '3. 分组关系数据检查' AS message;
SELECT '========================================' AS '';
SELECT COUNT(*) as relation_count FROM patient_group_relation;
SELECT * FROM patient_group_relation LIMIT 5;

-- 4. 检查用户数据
SELECT '========================================' AS '';
SELECT '4. 用户数据检查（医生）' AS message;
SELECT '========================================' AS '';
SELECT id, username, real_name, phone, user_type FROM user WHERE user_type = 1 LIMIT 5;

-- 5. 检查用户数据（患者）
SELECT '========================================' AS '';
SELECT '5. 用户数据检查（患者）' AS message;
SELECT '========================================' AS '';
SELECT id, username, real_name, phone, user_type FROM user WHERE user_type = 0 LIMIT 5;

-- 6. 总结
SELECT '========================================' AS '';
SELECT '诊断总结:' AS message;
SELECT '========================================' AS '';
SELECT '如果上面都有数据，说明数据库正常' AS info;
SELECT '问题可能在于:' AS info;
SELECT '1. 后端服务未启动' AS info;
SELECT '2. API接口路径不匹配' AS info;
SELECT '3. 前端请求失败' AS info;
SELECT '========================================' AS '';
