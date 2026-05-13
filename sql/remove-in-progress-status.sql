-- ============================================================
-- 用药状态简化：移除"进行中"状态
-- 将所有"进行中"(status=1) 的记录改为"已完成"(status=2)
-- 执行时间: 2026-05-13
-- ============================================================

-- 1. 查看当前各状态的记录数量
SELECT '=== 当前状态分布 ===' AS 说明;

SELECT
    status,
    CASE status
        WHEN 0 THEN '待执行'
        WHEN 1 THEN '进行中 (将被删除)'
        WHEN 2 THEN '已完成'
        WHEN 3 THEN '已取消'
        ELSE '未知'
    END AS 状态名称,
    COUNT(*) AS 记录数
FROM patient_medication_record
WHERE is_deleted = 0
GROUP BY status
ORDER BY status;

-- 2. 将所有"进行中"(status=1) 更新为"已完成"(status=2)
UPDATE patient_medication_record
SET status = 2,
    update_time = NOW(),
    remark = CONCAT(IFNULL(remark, ''), ' [系统自动完成]')
WHERE status = 1
  AND is_deleted = 0;

-- 3. 验证更新结果
SELECT '=== 更新后状态分布 ===' AS 说明;

SELECT
    status,
    CASE status
        WHEN 0 THEN '✅ 待执行'
        WHEN 2 THEN '✅ 已完成'
        WHEN 3 THEN '已取消'
        ELSE '未知'
    END AS 状态名称,
    COUNT(*) AS 记录数
FROM patient_medication_record
WHERE is_deleted = 0
GROUP BY status
ORDER BY status;

-- 4. 显示受影响的记录示例（前5条）
SELECT '=== 已完成的记录示例（前5条）===' AS 说明;

SELECT
    id,
    patient_id,
    drug_name AS 药品名称,
    dosage AS 剂量,
    frequency AS 用法,
    DATE_FORMAT(start_time, '%Y-%m-%d %H:%i') AS 开始时间,
    remark AS 备注
FROM patient_medication_record
WHERE is_deleted = 0
ORDER BY update_time DESC
LIMIT 5;

-- ============================================================
-- ✅ 执行完成后：
-- 1. 重启后端服务
-- 2. 现在只有两种状态：待执行(0) 和 已完成(2)
-- 3. 点击"确认用药"会直接从"待执行"变为"已完成"
-- 4. 不再有"进行中"这个中间状态
-- ============================================================
