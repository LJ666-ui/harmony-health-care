-- ============================================================
-- 修复方案V3：修正SQL语法错误
-- 修复内容：
--   1. DISTINCT与ORDER BY兼容性问题
--   2. UNION子查询语法错误
-- 执行日期: 2026-05-11
-- ============================================================

-- 注意：如果已执行过V2，数据应该已经清理完成，此脚本主要用于验证和补充

-- 0. 先查看当前状态
SELECT '=== 当前 patient_group_relation 数据状态 ===' AS info;
SELECT
    pgr.id,
    pgr.group_id,
    pg.group_name,
    pgr.patient_id,
    u.username,
    u.user_type,
    CASE
        WHEN u.user_type = 0 THEN '✅ 患者'
        WHEN u.user_type = 1 THEN '❌ 医生'
        ELSE '❓ 缺失'
    END AS type_desc
FROM patient_group_relation pgr
LEFT JOIN patient_group pg ON pgr.group_id = pg.id
LEFT JOIN user u ON pgr.patient_id = u.id
ORDER BY pgr.group_id, pgr.id;

-- 1. 清理残留的错误记录（关联到医生用户的）
DELETE pgr FROM patient_group_relation pgr
JOIN user u ON pgr.patient_id = u.id
WHERE u.user_type = 1;

SELECT CONCAT('✅ 清理了 ', ROW_COUNT(), ' 条医生记录') AS result;

-- 2. 为各分组补充患者数据（使用INSERT IGNORE避免重复）
-- 高血压患者 (group_id=1)
INSERT IGNORE INTO patient_group_relation (group_id, patient_id, create_time)
VALUES
    (1, 25, NOW()),
    (1, 26, NOW());

SELECT CONCAT('✅ 高血压分组添加: ', ROW_COUNT(), ' 位患者') AS result;

-- 糖尿病患者 (group_id=2)
INSERT IGNORE INTO patient_group_relation (group_id, patient_id, create_time)
VALUES
    (2, 27, NOW()),
    (2, 28, NOW());

SELECT CONCAT('✅ 糖尿病分组添加: ', ROW_COUNT(), ' 位患者') AS result;

-- 重点关注 (group_id=3)
INSERT IGNORE INTO patient_group_relation (group_id, patient_id, create_time)
VALUES
    (3, 29, NOW()),
    (3, 30, NOW());

SELECT CONCAT('✅ 重点关注分组添加: ', ROW_COUNT(), ' 位患者') AS result;

-- 3. 最终验证（修复后的正确查询）
SELECT '========== 最终验证结果 ==========' AS header;

-- 3.1 医生信息
SELECT '--- 医生信息 (doctor_id=1) ---' AS section;
SELECT id, user_id, real_name, hospital, department, title
FROM doctor WHERE id = 1;

-- 3.2 该医生的所有患者列表（修复DISTINCT+ORDER BY问题）
SELECT '--- 患者完整列表 ---' AS section;
SELECT
    pg.sort_order,
    pg.group_name,
    u.id AS patient_user_id,
    u.username AS patient_name,
    u.phone,
    u.age,
    pgr.create_time AS add_time
FROM (
    SELECT DISTINCT
        pg.sort_order,
        pg.group_name,
        pgr.patient_id,
        pgr.create_time
    FROM doctor d
    JOIN patient_group pg ON d.id = pg.doctor_id AND pg.is_deleted = 0
    JOIN patient_group_relation pgr ON pg.id = pgr.group_id
    WHERE d.id = 1
) tmp
JOIN patient_group pg ON tmp.group_name = pg.group_name AND pg.doctor_id = 1
JOIN user u ON tmp.patient_id = u.id
WHERE u.user_type = 0 AND u.is_deleted = 0
ORDER BY pg.sort_order, u.username;

-- 3.3 各分组统计
SELECT '--- 各分组患者数量 ---' AS section;
SELECT
    pg.id AS group_id,
    pg.group_name,
    COUNT(pgr.id) AS patient_count,
    GROUP_CONCAT(DISTINCT u.username SEPARATOR ', ') AS patients_list
FROM patient_group pg
LEFT JOIN patient_group_relation pgr ON pg.id = pgr.group_id
LEFT JOIN user u ON pgr.patient_id = u.id AND u.user_type = 0
WHERE pg.doctor_id = 1 AND pg.is_deleted = 0
GROUP BY pg.id, pg.group_name
ORDER BY pg.sort_order;

-- 4. 统计汇总（修复UNION语法错误）
SELECT '--- 数据统计 ---' AS section;
SELECT '总分组数' AS metric, COUNT(*) AS value
FROM patient_group
WHERE doctor_id = 1 AND is_deleted = 0;

SELECT '总患者数(去重)' AS metric,
       (SELECT COUNT(DISTINCT patient_id)
        FROM patient_group_relation pgr
        JOIN patient_group pg ON pgr.group_id = pg.id
        WHERE pg.doctor_id = 1 AND pg.is_deleted = 0) AS total_patients;

-- 5. 应用层模拟测试（实际使用的查询语句）
SELECT '=== 医生端应用层查询测试 ===' AS info;
SELECT
    u.id,
    u.username,
    u.phone,
    u.age,
    pg.group_name
FROM patient_group pg
JOIN patient_group_relation pgr ON pg.id = pgr.group_id
JOIN user u ON pgr.patient_id = u.id
WHERE pg.doctor_id = 1
  AND pg.is_deleted = 0
  AND u.user_type = 0
  AND u.is_deleted = 0
ORDER BY pg.sort_order, u.username;

SELECT '';
SELECT '✅ V3修复完成！所有SQL语法错误已修正。' AS status;
SELECT '📱 请刷新医生端页面验证效果。' AS next_step;
