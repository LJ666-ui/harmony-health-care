-- ============================================================
-- 修复医生端患者数据显示问题
-- 问题：patient_group_relation表的patient_id错误地关联了医生用户
-- 解决：将错误的patient_id替换为正确的患者用户ID
-- 执行日期: 2026-05-11
-- ============================================================

-- 1. 先查看当前问题数据
SELECT '=== 当前有问题的关联关系 ===' AS info;
SELECT
    pgr.id AS relation_id,
    pgr.group_id,
    pgr.patient_id,
    u.username,
    u.user_type,
    CASE u.user_type
        WHEN 0 THEN '✅ 患者'
        WHEN 1 THEN '❌ 医生(错误)'
        ELSE '❓ 未知'
    END AS user_type_desc
FROM patient_group_relation pgr
LEFT JOIN user u ON pgr.patient_id = u.id
WHERE u.user_type = 1 OR u.id IS NULL;

-- 2. 查看可用的患者用户(user_type=0)
SELECT '=== 可用的患者用户列表 ===' AS info;
SELECT id, username, phone, age, user_type
FROM user
WHERE user_type = 0 AND is_deleted = 0
ORDER BY id
LIMIT 30;

-- 3. 备份当前的patient_group_relation数据
CREATE TABLE IF NOT EXISTS patient_group_relation_backup_20260511 AS
SELECT * FROM patient_group_relation;

SELECT '✅ 已备份原数据到 patient_group_relation_backup_20260511' AS info;

-- 4. 修复方案：
-- 将错误的患者ID(10-13,这些是医生)映射到正确的患者ID(21-24等)
-- 映射关系：
--   10 -> 21 (马建军, 64岁)
--   11 -> 22 (任桂英, 36岁)
--   12 -> 23 (冯志强, 60岁)
--   13 -> 24 (袁丽华, 59岁)

-- 4.1 更新ID为10的记录->改为21
UPDATE patient_group_relation SET patient_id = 21 WHERE patient_id = 10;
SELECT CONCAT('✅ 已更新 ', ROW_COUNT(), ' 条记录: patient_id 10 -> 21') AS result;

-- 4.2 更新ID为11的记录->改为22
UPDATE patient_group_relation SET patient_id = 22 WHERE patient_id = 11;
SELECT CONCAT('✅ 已更新 ', ROW_COUNT(), ' 条记录: patient_id 11 -> 22') AS result;

-- 4.3 更新ID为12的记录->改为23
UPDATE patient_group_relation SET patient_id = 23 WHERE patient_id = 12;
SELECT CONCAT('✅ 已更新 ', ROW_COUNT(), ' 条记录: patient_id 12 -> 23') AS result;

-- 4.4 更新ID为13的记录->改为24
UPDATE patient_group_relation SET patient_id = 24 WHERE patient_id = 13;
SELECT CONCAT('✅ 已更新 ', ROW_COUNT(), ' 条记录: patient_id 13 -> 24') AS result;

-- 5. 验证修复结果
SELECT '=== 修复后的关联关系验证 ===' AS info;
SELECT
    pg.group_name,
    pgr.patient_id,
    u.username AS patient_name,
    u.phone,
    u.age,
    u.user_type,
    CASE u.user_type
        WHEN 0 THEN '✅ 正确(患者)'
        ELSE '❌ 错误'
    END AS status,
    pgr.create_time
FROM patient_group_relation pgr
JOIN patient_group pg ON pgr.group_id = pg.id
JOIN user u ON pgr.patient_id = u.id
WHERE pg.doctor_id = 1 AND pg.is_deleted = 0
ORDER BY pg.sort_order, pgr.create_time;

-- 6. 测试医生端查询（模拟应用层查询）
SELECT '=== 医生端患者列表查询测试 (doctor_id=1) ===' AS info;
SELECT DISTINCT
    u.id AS patient_user_id,
    u.username AS patient_name,
    u.phone,
    u.age,
    pg.group_name,
    d.real_name AS doctor_name
FROM doctor d
JOIN patient_group pg ON d.id = pg.doctor_id AND pg.is_deleted = 0
JOIN patient_group_relation pgr ON pg.id = pgr.group_id
JOIN user u ON pgr.patient_id = u.id AND u.user_type = 0 AND u.is_deleted = 0
WHERE d.id = 1
ORDER BY pg.sort_order, u.username;

-- 7. 统计修复后数据
SELECT '=== 修复后统计信息 ===' AS info;
SELECT
    (SELECT COUNT(*) FROM patient_group WHERE doctor_id = 1 AND is_deleted = 0) AS total_groups,
    (SELECT COUNT(*) FROM patient_group_relation pgr
     JOIN patient_group pg ON pgr.group_id = pg.id
     JOIN user u ON pgr.patient_id = u.id
     WHERE pg.doctor_id = 1 AND pg.is_deleted = 0 AND u.user_type = 0) AS total_valid_patients;

-- 8. 如果需要回滚，执行以下语句：
/*
-- 回滚到备份数据
TRUNCATE TABLE patient_group_relation;
INSERT INTO patient_group_relation SELECT * FROM patient_group_relation_backup_20260511;
SELECT '⚠️  已回滚到修复前状态' AS info;
*/

SELECT '🎉 修复完成！医生端应该可以正常显示患者信息了。' AS final_status;
