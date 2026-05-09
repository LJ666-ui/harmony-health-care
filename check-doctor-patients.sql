-- 检查并补充医生端患者数据显示
-- 执行日期: 2026-05-11

-- 1. 检查当前patient_group_relation表中的患者ID
SELECT '=== patient_group_relation 表中的患者ID ===' AS info;
SELECT DISTINCT patient_id FROM patient_group_relation;

-- 2. 检查这些患者是否在user表中存在
SELECT '=== 检查患者用户是否存在 ===' AS info;
SELECT 
    pgr.patient_id,
    u.username,
    u.user_type,
    CASE WHEN u.id IS NULL THEN '❌ 不存在' ELSE '✅ 存在' END AS status
FROM (
    SELECT DISTINCT patient_id 
    FROM patient_group_relation
) pgr
LEFT JOIN user u ON pgr.patient_id = u.id;

-- 3. 如果有缺失的患者用户，插入测试数据（根据需要取消注释）
/*
INSERT IGNORE INTO user (id, username, password, phone, age, user_type, real_name, is_deleted) VALUES
(10, '张三', '$2a$10$drI53FwlB2.tdaOYC4MkCOKlAW4PiYG0qLn.S7LoiJq07QcJpZEV.', '13800000010', 45, 0, '张三', 0),
(11, '李四', '$2a$10$drI53FwlB2.tdaOYC4MkCOKlAW4PiYG0qLn.S7LoiJq07QcJpZEV.', '13800000011', 52, 0, '李四', 0),
(12, '王五', '$2a$10$drI53FwlB2.tdaOYC4MkCOKlAW4PiYG0qLn.S7LoiJq07QcJpZEV.', '13800000012', 38, 0, '王五', 0),
(13, '赵六', '$2a$10$drI53FwlB2.tdaOYC4MkCOKlAW4PiYG0qLn.S7LoiJq07QcJpZEV.', '13800000013', 67, 0, '赵六', 0),
(21, '孙七', '$2a$10$drI53FwlB2.tdaOYC4MkCOKlAW4PiYG0qLn.S7LoiJq07QcJpZEV.', '13800000021', 55, 0, '孙七', 0);
*/

-- 4. 显示doctor_id=1的医生信息及其关联的患者分组
SELECT '=== 医生信息 (doctor_id=1) ===' AS info;
SELECT * FROM doctor WHERE id = 1;

SELECT '=== 该医生的患者分组 ===' AS info;
SELECT * FROM patient_group WHERE doctor_id = 1 AND is_deleted = 0;

SELECT '=== 分组中的患者关系 ===' AS info;
SELECT 
    pg.group_name,
    pgr.patient_id,
    u.username AS patient_name,
    pgr.create_time
FROM patient_group_relation pgr
JOIN patient_group pg ON pgr.group_id = pg.id
LEFT JOIN user u ON pgr.patient_id = u.id
WHERE pg.doctor_id = 1 AND pg.is_deleted = 0
ORDER BY pg.sort_order, pgr.create_time;

-- 5. 统计信息
SELECT '=== 统计信息 ===' AS info;
SELECT 
    (SELECT COUNT(*) FROM patient_group WHERE doctor_id = 1 AND is_deleted = 0) AS total_groups,
    (SELECT COUNT(DISTINCT patient_id) FROM patient_group_relation pgr 
     JOIN patient_group pg ON pgr.group_id = pg.id 
     WHERE pg.doctor_id = 1 AND pg.is_deleted = 0) AS total_patients;
