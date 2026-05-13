-- ============================================================
-- 修复方案V4：最终修正版
-- 修复内容：移除不必要的复杂查询，使用最简单可靠的SQL
-- 执行日期: 2026-05-11
-- ============================================================

-- 1. 查看当前状态（简单直接）
SELECT '=== 当前 patient_group_relation 数据 ===' AS info;
SELECT * FROM patient_group_relation ORDER BY id;

-- 2. 清理所有关联到医生用户的记录
DELETE pgr FROM patient_group_relation pgr
INNER JOIN user u ON pgr.patient_id = u.id
WHERE u.user_type = 1;

SELECT CONCAT('✅ 已删除 ', ROW_COUNT(), ' 条医生记录') AS result;

-- 3. 验证清理结果
SELECT '=== 清理后的数据 ===' AS info;
SELECT
    pgr.id,
    pgr.group_id,
    pgr.patient_id,
    u.username,
    u.user_type
FROM patient_group_relation pgr
LEFT JOIN user u ON pgr.patient_id = u.id
ORDER BY pgr.group_id, pgr.id;

-- 4. 为各分组添加示例患者
INSERT IGNORE INTO patient_group_relation (group_id, patient_id, create_time) VALUES
(1, 21, NOW()),
(1, 22, NOW()),
(1, 25, NOW()),
(1, 26, NOW());

SELECT CONCAT('✅ 高血压分组添加 ', ROW_COUNT(), ' 位患者') AS result;

INSERT IGNORE INTO patient_group_relation (group_id, patient_id, create_time) VALUES
(2, 23, NOW()),
(2, 24, NOW()),
(2, 27, NOW()),
(2, 28, NOW());

SELECT CONCAT('✅ 糖尿病分组添加 ', ROW_COUNT(), ' 位患者') AS result;

INSERT IGNORE INTO patient_group_relation (group_id, patient_id, create_time) VALUES
(3, 21, NOW()),
(3, 24, NOW()),
(3, 29, NOW()),
(3, 30, NOW());

SELECT CONCAT('✅ 重点关注分组添加 ', ROW_COUNT(), ' 位患者') AS result;

-- 5. 最终验证 - 医生端查询测试
SELECT '';
SELECT '========== 最终验证 ==========' AS header;

SELECT '--- 医生信息 ---' AS section;
SELECT id, real_name, hospital, department, title 
FROM doctor WHERE id = 1;

SELECT '--- 患者列表 ---' AS section;
SELECT
    pg.group_name,
    u.id AS user_id,
    u.username,
    u.phone,
    u.age,
    CASE WHEN u.user_type = 0 THEN '✅' ELSE '❌' END AS type
FROM patient_group pg
JOIN patient_group_relation pgr ON pg.id = pgr.group_id
JOIN user u ON pgr.patient_id = u.id
WHERE pg.doctor_id = 1
  AND pg.is_deleted = 0
  AND u.user_type = 0
ORDER BY pg.sort_order, u.username;

SELECT '--- 分组统计 ---' AS section;
SELECT
    pg.group_name,
    COUNT(*) AS count
FROM patient_group pg
JOIN patient_group_relation pgr ON pg.id = pgr.group_id
JOIN user u ON pgr.patient_id = u.id
WHERE pg.doctor_id = 1
  AND pg.is_deleted = 0
  AND u.user_type = 0
GROUP BY pg.group_name
ORDER BY pg.sort_order;

SELECT '';
SELECT '✅ V4修复完成！请刷新医生端页面查看效果。' AS final;
