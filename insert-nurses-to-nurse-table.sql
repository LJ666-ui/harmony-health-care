-- ============================================================
-- 将User表中的所有护士数据插入到Nurse表
-- 数据来源：user表 (user_type=3)
-- 排除已存在的记录
-- 创建时间: 2026-05-12
-- ============================================================

INSERT INTO `nurse` (`user_id`, `nurse_no`, `department`, `title`, `status`, `is_deleted`)
SELECT 
    u.id as user_id,
    CONCAT('N', LPAD(u.id, 6, '0')) as nurse_no,
    CASE 
        WHEN u.id % 6 = 0 THEN '内科'
        WHEN u.id % 6 = 1 THEN '外科'
        WHEN u.id % 6 = 2 THEN '骨科'
        WHEN u.id % 6 = 3 THEN '呼吸科'
        WHEN u.id % 6 = 4 THEN '神经科'
        ELSE '护理部'
    END as department,
    CASE 
        WHEN u.age >= 35 THEN '主管护师'
        WHEN u.age >= 30 THEN '护师'
        ELSE '护士'
    END as title,
    1 as status,
    0 as is_deleted
FROM `user` u
WHERE u.user_type = 3 
  AND u.is_deleted = 0
  AND NOT EXISTS (
      SELECT 1 FROM nurse n WHERE n.user_id = u.id AND n.is_deleted = 0
  );

-- 验证插入结果
SELECT COUNT(*) as '护士总数' FROM nurse WHERE is_deleted = 0;

-- 显示所有护士列表
SELECT 
    n.id as '护士ID',
    n.user_id as '用户ID',
    n.nurse_no as '工号',
    u.real_name as '姓名',
    u.phone as '手机号',
    n.department as '科室',
    n.title as '职称',
    n.status as '状态'
FROM nurse n
LEFT JOIN user u ON n.user_id = u.id
WHERE n.is_deleted = 0
ORDER BY n.id;
