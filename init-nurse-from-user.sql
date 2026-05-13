-- ============================================================
-- 护士表初始化脚本 - 从user表导入真实护士数据（完整修复版）
-- 执行环境: medical_health 数据库
-- 数据来源: user表 (user_type=1)
-- 修复内容: 
--   1. 移除不存在的nurse_name字段
--   2. 添加必填字段shift_start, shift_end, patient_count
-- 创建时间: 2026-05-12
-- ============================================================

-- ============================================================
-- 第一部分：从user表导入护士到nurse表
-- ============================================================

INSERT INTO `nurse` (`user_id`, `nurse_no`, `name`, `phone`, `department`, `title`, `status`, `create_time`, `update_time`, `is_deleted`)
SELECT 
    u.id as user_id,
    CONCAT('N', LPAD(u.id, 6, '0')) as nurse_no,
    u.real_name as name,
    u.phone as phone,
    COALESCE(u.department, '综合科室') as department,
    CASE 
        WHEN u.real_name LIKE '%主任%' THEN '主任护师'
        WHEN u.real_name LIKE '%护士长%' THEN '主管护师'
        WHEN u.real_name LIKE '%医生%' OR u.real_name LIKE '%医师%' THEN '医师'
        ELSE '护师'
    END as title,
    1 as status,
    NOW() as create_time,
    NOW() as update_time,
    0 as is_deleted
FROM `user` u
WHERE u.user_type = 1 
  AND u.is_deleted = 0
  AND NOT EXISTS (
      SELECT 1 FROM nurse n WHERE n.user_id = u.id AND n.is_deleted = 0
  );

-- 验证导入结果
SELECT 
    COUNT(*) as '护士总数',
    SUM(CASE WHEN department = '内科' THEN 1 ELSE 0 END) as '内科',
    SUM(CASE WHEN department = '外科' THEN 1 ELSE 0 END) as '外科',
    SUM(CASE WHEN department = '骨科' THEN 1 ELSE 0 END) as '骨科',
    SUM(CASE WHEN department = '呼吸科' THEN 1 ELSE 0 END) as '呼吸科',
    SUM(CASE WHEN department = '神经科' THEN 1 ELSE 0 END) as '神经科',
    SUM(CASE WHEN department = '护理部' THEN 1 ELSE 0 END) as '护理部',
    SUM(CASE WHEN department = '综合科室' THEN 1 ELSE 0 END) as '综合科室'
FROM nurse 
WHERE is_deleted = 0;

-- 显示所有护士列表
SELECT 
    n.id as '护士ID',
    n.user_id as '用户ID',
    n.nurse_no as '工号',
    n.name as '姓名',
    n.phone as '手机号',
    n.department as '科室',
    n.title as '职称',
    n.status as '状态'
FROM nurse n
WHERE n.is_deleted = 0
ORDER BY n.id;

-- ============================================================
-- 第二部分：基于真实护士数据生成排班表（完整版）
-- 包含所有必填字段：shift_start, shift_end, patient_count
-- ============================================================

SET @start_date = '2026-05-12';

-- 第1天 (2026-05-12 周二)
INSERT INTO `nurse_schedule` (`nurse_id`, `department`, `schedule_date`, `shift_type`, `shift_start`, `shift_end`, `ward_area`, `bed_count`, `patient_count`, `status`, `remark`)
SELECT 
    n.id as nurse_id,
    n.department as department,
    @start_date as schedule_date,
    CASE 
        WHEN (n.id % 3) = 1 THEN 1  
        WHEN (n.id % 3) = 2 THEN 2  
        ELSE 3                        
    END as shift_type,
    CASE 
        WHEN (n.id % 3) = 1 THEN '07:00:00'
        WHEN (n.id % 3) = 2 THEN '15:00:00'
        ELSE '23:00:00'
    END as shift_start,
    CASE 
        WHEN (n.id % 3) = 1 THEN '15:00:00'
        WHEN (n.id % 3) = 2 THEN '23:00:00'
        ELSE '07:00:00'
    END as shift_end,
    CASE 
        WHEN (n.id % 3) = 1 THEN 'A区'
        WHEN (n.id % 3) = 2 THEN 'B区'
        ELSE 'C区'
    END as ward_area,
    FLOOR(8 + RAND() * 5) as bed_count,
    FLOOR(10 + RAND() * 10) as patient_count,
    1 as status,
    CASE 
        WHEN (n.id % 3) = 0 THEN '夜班'
        ELSE NULL
    END as remark
FROM nurse n
WHERE n.is_deleted = 0 AND n.status = 1;

-- 第2天 (2026-05-13 周三) - 班次轮换
INSERT INTO `nurse_schedule` (`nurse_id`, `department`, `schedule_date`, `shift_type`, `shift_start`, `shift_end`, `ward_area`, `bed_count`, `patient_count`, `status`, `remark`)
SELECT 
    n.id,
    n.department,
    DATE_ADD(@start_date, INTERVAL 1 DAY),
    CASE 
        WHEN (n.id % 3) = 2 THEN 1
        WHEN (n.id % 3) = 0 THEN 2
        ELSE 3
    END,
    CASE 
        WHEN (n.id % 3) = 2 THEN '07:00:00'
        WHEN (n.id % 3) = 0 THEN '15:00:00'
        ELSE '23:00:00'
    END,
    CASE 
        WHEN (n.id % 3) = 2 THEN '15:00:00'
        WHEN (n.id % 3) = 0 THEN '23:00:00'
        ELSE '07:00:00'
    END,
    CASE 
        WHEN (n.id % 3) = 2 THEN 'B区'
        WHEN (n.id % 3) = 0 THEN 'C区'
        ELSE 'A区'
    END,
    FLOOR(8 + RAND() * 5),
    FLOOR(10 + RAND() * 10),
    1,
    CASE 
        WHEN (n.id % 3) = 1 THEN '夜班'
        ELSE NULL
    END
FROM nurse n
WHERE n.is_deleted = 0 AND n.status = 1;

-- 第3天 (2026-05-14 周四)
INSERT INTO `nurse_schedule` (`nurse_id`, `department`, `schedule_date`, `shift_type`, `shift_start`, `shift_end`, `ward_area`, `bed_count`, `patient_count`, `status`, `remark`)
SELECT 
    n.id,
    n.department,
    DATE_ADD(@start_date, INTERVAL 2 DAY),
    CASE 
        WHEN (n.id % 3) = 0 THEN 1
        WHEN (n.id % 3) = 1 THEN 2
        ELSE 3
    END,
    CASE 
        WHEN (n.id % 3) = 0 THEN '07:00:00'
        WHEN (n.id % 3) = 1 THEN '15:00:00'
        ELSE '23:00:00'
    END,
    CASE 
        WHEN (n.id % 3) = 0 THEN '15:00:00'
        WHEN (n.id % 3) = 1 THEN '23:00:00'
        ELSE '07:00:00'
    END,
    CASE 
        WHEN (n.id % 3) = 0 THEN 'C区'
        WHEN (n.id % 3) = 1 THEN 'A区'
        ELSE 'B区'
    END,
    FLOOR(8 + RAND() * 5),
    FLOOR(10 + RAND() * 10),
    1,
    CASE 
        WHEN (n.id % 3) = 2 THEN '夜班'
        ELSE NULL
    END
FROM nurse n
WHERE n.is_deleted = 0 AND n.status = 1;

-- 第4天 (2026-05-15 周五)
INSERT INTO `nurse_schedule` (`nurse_id`, `department`, `schedule_date`, `shift_type`, `shift_start`, `shift_end`, `ward_area`, `bed_count`, `patient_count`, `status`, `remark`)
SELECT 
    n.id,
    n.department,
    DATE_ADD(@start_date, INTERVAL 3 DAY),
    CASE 
        WHEN (n.id % 3) = 1 THEN 1
        WHEN (n.id % 3) = 2 THEN 2
        ELSE 3
    END,
    CASE 
        WHEN (n.id % 3) = 1 THEN '07:00:00'
        WHEN (n.id % 3) = 2 THEN '15:00:00'
        ELSE '23:00:00'
    END,
    CASE 
        WHEN (n.id % 3) = 1 THEN '15:00:00'
        WHEN (n.id % 3) = 2 THEN '23:00:00'
        ELSE '07:00:00'
    END,
    CASE 
        WHEN (n.id % 3) = 1 THEN 'A区'
        WHEN (n.id % 3) = 2 THEN 'B区'
        ELSE 'C区'
    END,
    FLOOR(8 + RAND() * 5),
    FLOOR(10 + RAND() * 10),
    1,
    CASE 
        WHEN (n.id % 3) = 0 THEN '夜班'
        ELSE NULL
    END
FROM nurse n
WHERE n.is_deleted = 0 AND n.status = 1;

-- 第5天 (2026-05-16 周六)
INSERT INTO `nurse_schedule` (`nurse_id`, `department`, `schedule_date`, `shift_type`, `shift_start`, `shift_end`, `ward_area`, `bed_count`, `patient_count`, `status`, `remark`)
SELECT 
    n.id,
    n.department,
    DATE_ADD(@start_date, INTERVAL 4 DAY),
    CASE 
        WHEN (n.id % 3) = 2 THEN 1
        WHEN (n.id % 3) = 0 THEN 2
        ELSE 3
    END,
    CASE 
        WHEN (n.id % 3) = 2 THEN '07:00:00'
        WHEN (n.id % 3) = 0 THEN '15:00:00'
        ELSE '23:00:00'
    END,
    CASE 
        WHEN (n.id % 3) = 2 THEN '15:00:00'
        WHEN (n.id % 3) = 0 THEN '23:00:00'
        ELSE '07:00:00'
    END,
    CASE 
        WHEN (n.id % 3) = 2 THEN 'B区'
        WHEN (n.id % 3) = 0 THEN 'C区'
        ELSE 'A区'
    END,
    FLOOR(8 + RAND() * 5),
    FLOOR(10 + RAND() * 10),
    1,
    CASE 
        WHEN (n.id % 3) = 1 THEN '夜班'
        ELSE NULL
    END
FROM nurse n
WHERE n.is_deleted = 0 AND n.status = 1;

-- 第6天 (2026-05-17 周日)
INSERT INTO `nurse_schedule` (`nurse_id`, `department`, `schedule_date`, `shift_type`, `shift_start`, `shift_end`, `ward_area`, `bed_count`, `patient_count`, `status`, `remark`)
SELECT 
    n.id,
    n.department,
    DATE_ADD(@start_date, INTERVAL 5 DAY),
    CASE 
        WHEN (n.id % 3) = 0 THEN 1
        WHEN (n.id % 3) = 1 THEN 2
        ELSE 3
    END,
    CASE 
        WHEN (n.id % 3) = 0 THEN '07:00:00'
        WHEN (n.id % 3) = 1 THEN '15:00:00'
        ELSE '23:00:00'
    END,
    CASE 
        WHEN (n.id % 3) = 0 THEN '15:00:00'
        WHEN (n.id % 3) = 1 THEN '23:00:00'
        ELSE '07:00:00'
    END,
    CASE 
        WHEN (n.id % 3) = 0 THEN 'C区'
        WHEN (n.id % 3) = 1 THEN 'A区'
        ELSE 'B区'
    END,
    FLOOR(8 + RAND() * 5),
    FLOOR(10 + RAND() * 10),
    1,
    CASE 
        WHEN (n.id % 3) = 2 THEN '夜班'
        ELSE NULL
    END
FROM nurse n
WHERE n.is_deleted = 0 AND n.status = 1;

-- 第7天 (2026-05-18 周一)
INSERT INTO `nurse_schedule` (`nurse_id`, `department`, `schedule_date`, `shift_type`, `shift_start`, `shift_end`, `ward_area`, `bed_count`, `patient_count`, `status`, `remark`)
SELECT 
    n.id,
    n.department,
    DATE_ADD(@start_date, INTERVAL 6 DAY),
    CASE 
        WHEN (n.id % 3) = 1 THEN 1
        WHEN (n.id % 3) = 2 THEN 2
        ELSE 3
    END,
    CASE 
        WHEN (n.id % 3) = 1 THEN '07:00:00'
        WHEN (n.id % 3) = 2 THEN '15:00:00'
        ELSE '23:00:00'
    END,
    CASE 
        WHEN (n.id % 3) = 1 THEN '15:00:00'
        WHEN (n.id % 3) = 2 THEN '23:00:00'
        ELSE '07:00:00'
    END,
    CASE 
        WHEN (n.id % 3) = 1 THEN 'A区'
        WHEN (n.id % 3) = 2 THEN 'B区'
        ELSE 'C区'
    END,
    FLOOR(8 + RAND() * 5),
    FLOOR(10 + RAND() * 10),
    1,
    CASE 
        WHEN (n.id % 3) = 0 THEN '夜班'
        ELSE NULL
    END
FROM nurse n
WHERE n.is_deleted = 0 AND n.status = 1;

-- ============================================================
-- 第三部分：验证查询
-- ============================================================

-- 统计排班总数
SELECT 
    COUNT(*) as '总排班记录数',
    COUNT(DISTINCT nurse_id) as '涉及护士数',
    COUNT(DISTINCT schedule_date) as '覆盖天数'
FROM nurse_schedule 
WHERE is_deleted = 0;

-- 按日期统计各班次人数
SELECT 
    schedule_date as '日期',
    DAYOFWEEK(schedule_date) as '星期',
    SUM(CASE WHEN shift_type = 1 THEN 1 ELSE 0 END) as '早班人数',
    SUM(CASE WHEN shift_type = 2 THEN 1 ELSE 0 END) as '中班人数',
    SUM(CASE WHEN shift_type = 3 THEN 1 ELSE 0 END) as '夜班人数',
    COUNT(*) as '当日总人数'
FROM nurse_schedule 
WHERE is_deleted = 0
GROUP BY schedule_date
ORDER BY schedule_date;

-- 今日排班详情 (2026-05-12)
SELECT 
    ns.id as '排班ID',
    n.name as '护士姓名',
    n.department as '科室',
    ns.schedule_date as '日期',
    ns.shift_start as '上班时间',
    ns.shift_end as '下班时间',
    CASE ns.shift_type
        WHEN 1 THEN '早班'
        WHEN 2 THEN '中班'
        WHEN 3 THEN '夜班'
    END as '班次类型',
    ns.ward_area as '病区',
    ns.bed_count as '床位数',
    ns.patient_count as '患者数',
    ns.status as '状态',
    ns.remark as '备注'
FROM nurse_schedule ns
JOIN nurse n ON ns.nurse_id = n.id
WHERE ns.schedule_date = @start_date 
  AND ns.is_deleted = 0
ORDER BY ns.shift_type, n.name;

-- 每个护士本周排班概览
SELECT 
    n.name as '护士姓名',
    n.department as '科室',
    GROUP_CONCAT(
        CONCAT(
            DATE_FORMAT(ns.schedule_date, '%m/%d'),
            ':',
            CASE ns.shift_type
                WHEN 1 THEN '早'
                WHEN 2 THEN '中'
                WHEN 3 THEN '夜'
            END
        )
        ORDER BY ns.schedule_date
        SEPARATOR ' | '
    ) as '本周排班'
FROM nurse_schedule ns
JOIN nurse n ON ns.nurse_id = n.id
WHERE ns.schedule_date BETWEEN @start_date AND DATE_ADD(@start_date, INTERVAL 6 DAY)
  AND ns.is_deleted = 0
  AND n.is_deleted = 0
GROUP BY n.id, n.name, n.department
ORDER BY n.id;

-- 完成！
SELECT CONCAT('✅ 初始化完成！') as '状态';
SELECT CONCAT('📊 护士表: ', (SELECT COUNT(*) FROM nurse WHERE is_deleted = 0), ' 人') as '护士数量';
SELECT CONCAT('📅 排班表: ', (SELECT COUNT(*) FROM nurse_schedule WHERE is_deleted = 0), ' 条记录') as '排班数量';
SELECT CONCAT('📆 覆盖范围: ', @start_date, ' 至 ', DATE_ADD(@start_date, INTERVAL 6 DAY)) as '时间范围';
