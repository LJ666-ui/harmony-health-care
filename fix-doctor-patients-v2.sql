-- ============================================================
-- 修复方案V2：处理唯一约束冲突
-- 问题：UPDATE会导致 uk_group_patient 唯一约束冲突
-- 策略：先删除错误的记录，再插入正确的（或保留已有的正确记录）
-- 执行日期: 2026-05-11
-- ============================================================

-- 0. 先查看当前完整数据状态
SELECT '=== 当前 patient_group_relation 完整数据 ===' AS info;
SELECT * FROM patient_group_relation ORDER BY group_id, patient_id;

SELECT '=== 检查哪些是医生，哪些是患者 ===' AS info;
SELECT
    pgr.id,
    pgr.group_id,
    pgr.patient_id,
    u.username,
    u.user_type,
    CASE u.user_type
        WHEN 0 THEN '✅ 患者'
        WHEN 1 THEN '❌ 医生(需删除)'
        ELSE '❓ 缺失'
    END AS type_desc
FROM patient_group_relation pgr
LEFT JOIN user u ON pgr.patient_id = u.id
ORDER BY pgr.group_id, pgr.id;

-- 1. 删除所有关联到医生用户的错误记录(user_type=1)
DELETE pgr FROM patient_group_relation pgr
JOIN user u ON pgr.patient_id = u.id
WHERE u.user_type = 1;

SELECT CONCAT('✅ 已删除 ', ROW_COUNT(), ' 条错误记录(关联到医生用户)') AS result;

-- 2. 验证删除后的数据
SELECT '=== 删除后的剩余记录 ===' AS info;
SELECT
    pgr.id,
    pgr.group_id,
    pgr.patient_id,
    u.username,
    u.user_type,
    CASE u.user_type
        WHEN 0 THEN '✅ 正确(患者)'
        ELSE '⚠️ 需检查'
    END AS status
FROM patient_group_relation pgr
JOIN user u ON pgr.patient_id = u.id
ORDER BY pgr.group_id, pgr.id;

-- 3. 补充缺失的患者数据（如果某些分组没有患者了）
-- 检查每个分组是否都有至少一个患者
SELECT '=== 各分组患者数量统计 ===' AS info;
SELECT
    pg.id AS group_id,
    pg.group_name,
    pg.doctor_id,
    COUNT(pgr.id) AS patient_count
FROM patient_group pg
LEFT JOIN patient_group_relation pgr ON pg.id = pgr.group_id
WHERE pg.doctor_id = 1 AND pg.is_deleted = 0
GROUP BY pg.id, pg.group_name, pg.doctor_id
ORDER BY pg.sort_order;

-- 4. 为空分组添加示例患者（可选）
-- 高血压患者分组添加更多患者
INSERT IGNORE INTO patient_group_relation (group_id, patient_id, create_time)
SELECT 1, id, NOW()
FROM user
WHERE user_type = 0 AND is_deleted = 0
AND id BETWEEN 25 AND 26  -- 叶建明、苏秀兰
LIMIT 2;

SELECT CONCAT('✅ 为高血压分组添加了 ', ROW_COUNT(), ' 位患者') AS result;

-- 糖尿病患者分组添加更多患者
INSERT IGNORE INTO patient_group_relation (group_id, patient_id, create_time)
SELECT 2, id, NOW()
FROM user
WHERE user_type = 0 AND is_deleted = 0
AND id BETWEEN 27 AND 28  -- 程伟、魏淑敏
LIMIT 2;

SELECT CONCAT('✅ 为糖尿病分组添加了 ', ROW_COUNT(), ' 位患者') AS result;

-- 重点关注分组添加更多患者
INSERT IGNORE INTO patient_group_relation (group_id, patient_id, create_time)
SELECT 3, id, NOW()
FROM user
WHERE user_type = 0 AND is_deleted = 0
AND id BETWEEN 29 AND 30  -- 吕小军、丁艳
LIMIT 2;

SELECT CONCAT('✅ 为重点关注分组添加了 ', ROW_COUNT(), ' 位患者') AS result;

-- 5. 最终验证：完整的医生端查询测试
SELECT '========== 最终验证结果 ==========' AS header;

SELECT '--- 医生信息 ---' AS section;
SELECT id, user_id, real_name, hospital, department FROM doctor WHERE id = 1;

SELECT '--- 该医生的所有患者列表 ---' AS section;
SELECT DISTINCT
    pg.group_name,
    u.id AS patient_user_id,
    u.username AS patient_name,
    u.phone,
    u.age,
    u.user_type,
    pgr.create_time AS add_time
FROM doctor d
JOIN patient_group pg ON d.id = pg.doctor_id AND pg.is_deleted = 0
JOIN patient_group_relation pgr ON pg.id = pgr.group_id
JOIN user u ON pgr.patient_id = u.id
WHERE d.id = 1 AND u.user_type = 0 AND u.is_deleted = 0
ORDER BY pg.sort_order, pg.group_name, u.username;

-- 6. 统计汇总
SELECT '--- 数据统计 ---' AS section;
SELECT
    '总分组数' AS metric,
    COUNT(*) AS value
FROM patient_group
WHERE doctor_id = 1 AND is_deleted = 0
UNION ALL
SELECT
    '总患者数(去重)',
    COUNT(DISTINCT pgr.patient_id)
FROM patient_group_relation pgr
JOIN patient_group pg ON pgr.group_id = pg.id
WHERE pg.doctor_id = 1 AND pg.is_deleted = 0
JOIN user u ON pgr.patient_id = u.id AND u.user_type = 0;

SELECT '';
SELECT '🎉 V2修复完成！现在刷新医生端页面应该可以看到正确的患者列表。' AS final_status;
SELECT '💡 提示：如果还有问题，可以检查应用层的SQL查询是否过滤了 user_type=0' AS tip;
