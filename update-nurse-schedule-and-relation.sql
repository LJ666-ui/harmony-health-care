-- ============================================================
-- 护士值班表和护士患者关联表数据更新脚本
-- 功能：
--   1. 清理旧数据
--   2. 为31个护士生成7天值班表（每天3班）
--   3. 为每个护士分配5-10个患者
-- 创建时间: 2026-05-12
-- ============================================================

SET @start_date = '2026-05-12';

-- ============================================================
-- 第一部分：清理旧数据
-- ============================================================
DELETE FROM `nurse_schedule` WHERE is_deleted = 0;
DELETE FROM `nurse_patient_relation` WHERE is_deleted = 0;

-- ============================================================
-- 第二部分：生成7天值班表（2026-05-12 到 2026-05-18）
-- 每个护士每天1个班次，轮换早/中/夜班
-- ============================================================

INSERT INTO `nurse_schedule` (`nurse_id`, `department`, `ward_area`, `schedule_date`, `shift_type`, `shift_start`, `shift_end`, `bed_count`, `patient_count`, `status`, `remark`, `is_deleted`)
SELECT 
    n.id as nurse_id,
    n.department as department,
    CASE 
        WHEN (n.id % 3) = 0 THEN 'A区'
        WHEN (n.id % 3) = 1 THEN 'B区'
        ELSE 'C区'
    END as ward_area,
    DATE_ADD(@start_date, INTERVAL d.day_num DAY) as schedule_date,
    ((n.id + d.day_num) % 3) + 1 as shift_type,
    CASE 
        WHEN ((n.id + d.day_num) % 3) = 0 THEN '07:00:00'
        WHEN ((n.id + d.day_num) % 3) = 1 THEN '15:00:00'
        ELSE '23:00:00'
    END as shift_start,
    CASE 
        WHEN ((n.id + d.day_num) % 3) = 0 THEN '15:00:00'
        WHEN ((n.id + d.day_num) % 3) = 1 THEN '23:00:00'
        ELSE '07:00:00'
    END as shift_end,
    FLOOR(8 + RAND() * 5) as bed_count,
    FLOOR(10 + RAND() * 10) as patient_count,
    1 as status,
    CASE 
        WHEN ((n.id + d.day_num) % 3) = 2 THEN '夜班'
        ELSE NULL
    END as remark,
    0 as is_deleted
FROM (
    SELECT 0 as day_num UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL 
    SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6
) d
CROSS JOIN nurse n
WHERE n.is_deleted = 0;

-- 验证值班表数据
SELECT COUNT(*) as '值班记录总数' FROM nurse_schedule WHERE is_deleted = 0;
SELECT 
    COUNT(DISTINCT nurse_id) as '涉及护士数',
    COUNT(DISTINCT schedule_date) as '涉及天数',
    SUM(CASE WHEN shift_type=1 THEN 1 ELSE 0 END) as '早班数',
    SUM(CASE WHEN shift_type=2 THEN 1 ELSE 0 END) as '中班数',
    SUM(CASE WHEN shift_type=3 THEN 1 ELSE 0 END) as '夜班数'
FROM nurse_schedule 
WHERE is_deleted = 0;

-- ============================================================
-- 第三部分：生成护士-患者关联数据
-- 每个护士负责5-10个患者
-- ============================================================

INSERT INTO `nurse_patient_relation` (`nurse_id`, `patient_id`, `relation_type`, `is_deleted`)
SELECT 
    n.id as nurse_id,
    p.id as patient_id,
    1 as relation_type,
    0 as is_deleted
FROM nurse n
CROSS JOIN (
    SELECT id, ROW_NUMBER() OVER (ORDER BY id) as rn 
    FROM user 
    WHERE user_type = 0 AND is_deleted = 0
) p
WHERE n.is_deleted = 0
  AND p.rn <= (5 + (n.id % 6))  -- 每个护士5-10个患者
  AND NOT EXISTS (
      SELECT 1 FROM nurse_patient_relation r 
      WHERE r.nurse_id = n.id AND r.patient_id = p.id AND r.is_deleted = 0
  );

-- 验证关联表数据
SELECT COUNT(*) as '关联记录总数' FROM nurse_patient_relation WHERE is_deleted = 0;

-- 显示各护士的患者分配情况
SELECT 
    n.id as '护士ID',
    u.real_name as '护士姓名',
    n.department as '科室',
    COUNT(r.id) as '负责患者数',
    GROUP_CONCAT(p.real_name SEPARATOR ', ') as '患者列表'
FROM nurse n
LEFT JOIN user u ON n.user_id = u.id
LEFT JOIN nurse_patient_relation r ON n.id = r.nurse_id AND r.is_deleted = 0
LEFT JOIN user p ON r.patient_id = p.id AND p.is_deleted = 0
WHERE n.is_deleted = 0
GROUP BY n.id, u.real_name, n.department
ORDER BY n.id
LIMIT 35;
