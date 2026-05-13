-- ============================================================
-- 修复护士-患者关联表数据
-- 问题：所有护士都关联到相同的前几个患者
-- 解决：为每个护士分配不同的患者子集
-- 创建时间: 2026-05-12
-- ============================================================

-- 第1步：清理旧的关联数据
DELETE FROM `nurse_patient_relation` WHERE is_deleted = 0;

-- 第2步：重新生成关联数据
-- 策略：将88个患者均匀分配给31个护士
-- 每个护士负责2-4个不同患者（确保覆盖更多患者）

INSERT INTO `nurse_patient_relation` (`nurse_id`, `patient_id`, `relation_type`, `is_deleted`)
SELECT 
    n.id as nurse_id,
    p.id as patient_id,
    1 as relation_type,
    0 as is_deleted
FROM (
    SELECT id, 
           ROW_NUMBER() OVER (ORDER BY id) as rn,
           (ROW_NUMBER() OVER (ORDER BY id) - 1) % 31 + 1 as assigned_nurse_id
    FROM user 
    WHERE user_type = 0 AND is_deleted = 0
) p
JOIN nurse n ON n.id = p.assigned_nurse_id
WHERE n.is_deleted = 0;

-- 验证结果
SELECT '=== 修复后的数据统计 ===' as '';
SELECT COUNT(*) as '总关联记录数' FROM nurse_patient_relation WHERE is_deleted = 0;

SELECT '' as '';
SELECT '=== 各护士负责的患者分布(前15条) ===' as '';
SELECT 
    npr.nurse_id,
    u_n.real_name as '护士姓名',
    COUNT(*) as '负责患者数',
    GROUP_CONCAT(u_p.real_name ORDER BY u_p.real_name SEPARATOR ', ') as '患者列表'
FROM nurse_patient_relation npr
LEFT JOIN nurse n ON npr.nurse_id = n.id
LEFT JOIN user u_n ON n.user_id = u_n.id
LEFT JOIN user u_p ON npr.patient_id = u_p.id
WHERE npr.is_deleted = 0
GROUP BY npr.nurse_id, u_n.real_name
ORDER BY npr.nurse_id
LIMIT 20;

SELECT '' as '';
SELECT '=== 被分配的患者数量 ===' as '';
SELECT 
    COUNT(DISTINCT patient_id) as '被分配的不同患者数',
    COUNT(DISTINCT nurse_id) as '有患者的护士数'
FROM nurse_patient_relation 
WHERE is_deleted = 0;
