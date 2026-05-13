-- ============================================================
-- 修复护士排班功能 - 添加缺失字段并重新生成数据
-- 执行环境: medical_health 数据库
-- 问题: 数据库nurse_schedule表缺少 nurse_name, department, patient_ids字段
--       导致前端报错: Invalid response format
-- ============================================================

-- 1. 添加缺失的字段
ALTER TABLE `nurse_schedule`
  ADD COLUMN `nurse_name` varchar(50) DEFAULT NULL COMMENT '护士姓名' AFTER `nurse_id`,
  ADD COLUMN `department` varchar(100) DEFAULT NULL COMMENT '科室' AFTER `nurse_name`,
  ADD COLUMN `patient_ids` varchar(500) DEFAULT NULL COMMENT '患者ID列表' AFTER `bed_count`;

-- 2. 清空旧的排班数据
DELETE FROM `nurse_schedule` WHERE is_deleted = 0;

-- 3. 为所有31个护士生成7天排班数据（2026-05-12 到 2026-05-18）
INSERT INTO `nurse_schedule`
(`nurse_id`, `nurse_name`, `department`, `schedule_date`, `shift_type`,
 `ward_area`, `bed_count`, `patient_ids`, `status`, `remark`)
SELECT
    n.id as nurse_id,
    u.real_name as nurse_name,
    n.department,
    d.date_val as schedule_date,
    s.shift_type,
    CASE s.shift_type
        WHEN 1 THEN 'A区'
        WHEN 2 THEN 'B区'
        ELSE 'C区'
    END as ward_area,
    FLOOR(8 + RAND() * 5) as bed_count,
    NULL as patient_ids,
    1 as status,
    CASE s.shift_type
        WHEN 3 THEN '夜班'
        ELSE NULL
    END as remark
FROM
    nurse n
JOIN user u ON n.user_id = u.id
CROSS JOIN (
    SELECT DATE_ADD('2026-05-12', INTERVAL seq DAY) as date_val
    FROM (
        SELECT 0 as seq UNION SELECT 1 UNION SELECT 2 UNION SELECT 3
        UNION SELECT 4 UNION SELECT 5 UNION SELECT 6
    ) dates
) d
CROSS JOIN (
    SELECT 1 as shift_type UNION SELECT 2 UNION SELECT 3
) s
WHERE n.is_deleted = 0 AND u.is_deleted = 0
ORDER BY n.id, d.date_val, s.shift_type;

-- 4. 验证结果
SELECT '=== 排班数据统计 ===' as '';
SELECT COUNT(*) as '总记录数' FROM nurse_schedule WHERE is_deleted = 0;

SELECT '' as '';
SELECT '=== 各护士排班数 ===' as '';
SELECT ns.nurse_id, ns.nurse_name, ns.department, COUNT(*) as '排班数'
FROM nurse_schedule ns
WHERE ns.is_deleted = 0
GROUP BY ns.nurse_id, ns.nurse_name, ns.department
ORDER BY ns.nurse_id;

SELECT '' as '';
SELECT '=== 今日排班示例(前10条) ===' as '';
SELECT id, nurse_id, nurse_name, department, schedule_date,
       shift_type, ward_area, bed_count, status
FROM nurse_schedule
WHERE schedule_date = '2026-05-12' AND is_deleted = 0
LIMIT 10;
