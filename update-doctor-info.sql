-- ==========================================
-- 补充医生个人信息
-- 版本: v1.0
-- 日期: 2026-05-11
-- 说明: 为医生ID=1补充完整的个人信息
-- ==========================================

USE medical_health;

-- ==========================================
-- 查看当前医生信息
-- ==========================================

SELECT '========================================' AS '';
SELECT '当前医生信息:' AS message;
SELECT '========================================' AS '';
SELECT id, user_id, real_name, phone, hospital, department, title, license_number, specialty
FROM doctor
WHERE id = 1;

-- ==========================================
-- 更新医生信息
-- ==========================================

-- 更新doctor表
UPDATE doctor
SET 
    real_name = '王建国',
    hospital = '北京协和医院',
    department = '心血管内科',
    title = '主任医师',
    license_number = '110101198001011234',
    specialty = '高血压、冠心病、心律失常',
    status = 1,
    update_time = NOW()
WHERE id = 1;

-- 同时更新user表
UPDATE user
SET 
    real_name = '王建国',
    hospital = '北京协和医院',
    department = '心血管内科',
    title = '主任医师',
    license_number = '110101198001011234'
WHERE id = 1;

-- ==========================================
-- 验证更新结果
-- ==========================================

SELECT '========================================' AS '';
SELECT '更新完成！医生信息:' AS message;
SELECT '========================================' AS '';
SELECT d.id, d.user_id, d.real_name, d.phone, d.hospital, d.department, d.title, d.license_number, d.specialty, u.username
FROM doctor d
LEFT JOIN user u ON d.user_id = u.id
WHERE d.id = 1;

SELECT '========================================' AS '';
SELECT '现在可以测试了！' AS message;
SELECT '医生姓名: 王建国' AS info;
SELECT '所属医院: 北京协和医院' AS info;
SELECT '科室: 心血管内科' AS info;
SELECT '职称: 主任医师' AS info;
SELECT '========================================' AS '';
