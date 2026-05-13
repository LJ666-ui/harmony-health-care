-- ============================================================
-- 修复方案V5：最简版本（兼容 ONLY_FULL_GROUP_BY）
-- 特点：只使用最基本的SQL，避免所有高级特性
-- 执行日期: 2026-05-11
-- ============================================================

-- 1. 清理错误的医生关联记录
DELETE pgr FROM patient_group_relation pgr
INNER JOIN user u ON pgr.patient_id = u.id
WHERE u.user_type = 1;

SELECT '✅ 清理完成' AS status;

-- 2. 添加患者数据
INSERT IGNORE INTO patient_group_relation (group_id, patient_id, create_time) VALUES
(1, 21, NOW()),
(1, 22, NOW()),
(1, 25, NOW()),
(1, 26, NOW());

INSERT IGNORE INTO patient_group_relation (group_id, patient_id, create_time) VALUES
(2, 23, NOW()),
(2, 24, NOW()),
(2, 27, NOW()),
(2, 28, NOW());

INSERT IGNORE INTO patient_group_relation (group_id, patient_id, create_time) VALUES
(3, 21, NOW()),
(3, 24, NOW()),
(3, 29, NOW()),
(3, 30, NOW());

SELECT '✅ 数据添加完成' AS status;

-- 3. 简单验证 - 查看所有数据
SELECT '=== 验证：patient_group_relation 表 ===' AS info;
SELECT * FROM patient_group_relation;

SELECT '=== 验证：关联的用户信息 ===' AS info;
SELECT
    pgr.id,
    pgr.group_id,
    pgr.patient_id,
    u.username,
    u.user_type,
    CASE u.user_type WHEN 0 THEN 'OK' ELSE 'ERROR' END AS check_type
FROM patient_group_relation pgr
LEFT JOIN user u ON pgr.patient_id = u.id;

-- 4. 医生端查询测试（应用层实际使用的简单查询）
SELECT '=== 医生端患者列表（模拟应用层查询）===' AS info;
SELECT
    pg.group_name,
    u.id,
    u.username,
    u.phone,
    u.age
FROM patient_group pg
JOIN patient_group_relation pgr ON pg.id = pgr.group_id
JOIN user u ON pgr.patient_id = u.id
WHERE pg.doctor_id = 1
  AND pg.is_deleted = 0
  AND u.user_type = 0;

SELECT '';
SELECT '✅ V5修复完成！' AS result;
