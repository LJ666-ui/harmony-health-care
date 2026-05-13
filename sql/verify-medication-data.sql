-- ============================================================
-- 用药管理功能最终验证脚本
-- 验证护士ID、患者关联、用药记录的完整数据链
-- 执行时间: 2026-05-13
-- ============================================================

-- ============================================================
-- 第1步：确认登录账号对应的护士信息
-- ============================================================
SELECT '=== 步骤1: 登录账号信息 ===' AS 说明;

SELECT 
    u.id AS user_id,
    u.username,
    u.real_name AS 姓名,
    u.phone AS 手机号,
    u.user_type AS 用户类型
FROM user u
WHERE u.phone = '13900001001';

-- ============================================================
-- 第2步：确认该用户对应的nurse记录
-- ============================================================
SELECT '=== 步骤2: 护士记录 ===' AS 说明;

SELECT 
    n.id AS nurse_id,        -- ⭐ 这是前端应该传递给API的值！
    n.user_id,               -- 关联到user表的ID
    n.nurse_no AS 工号,
    n.department AS 科室,
    n.status AS 状态
FROM nurse n
WHERE n.user_id = (SELECT id FROM user WHERE phone = '13900001001');

-- ============================================================
-- 第3步：该护士负责的患者数量
-- ============================================================
SELECT '=== 步骤3: 护士-患者关联统计 ===' AS 说明;

SELECT 
    COUNT(*) AS 负责患者总数,
    COUNT(CASE WHEN status = 1 THEN 1 END) AS 有效关联数
FROM nurse_patient_relation
WHERE nurse_id = (
    SELECT id FROM nurse 
    WHERE user_id = (SELECT id FROM user WHERE phone = '13900001001')
)
AND is_deleted = 0;

-- ============================================================
-- 第4步：这些患者的用药记录总数
-- ============================================================
SELECT '=== 步骤4: 可见用药记录统计 ===' AS 说明;

SELECT 
    COUNT(*) AS 总用药记录数,
    COUNT(CASE WHEN status = 0 THEN 1 END) AS 待执行,
    COUNT(CASE WHEN status = 1 THEN 1 END) AS 进行中,
    COUNT(CASE WHEN status = 2 THEN 1 END) AS 已完成
FROM patient_medication_record pmr
WHERE pmr.patient_id IN (
    SELECT npr.patient_id 
    FROM nurse_patient_relation npr
    WHERE npr.nurse_id = (
        SELECT id FROM nurse 
        WHERE user_id = (SELECT id FROM user WHERE phone = '13900001001')
    )
    AND npr.is_deleted = 0
)
AND pmr.is_deleted = 0;

-- ============================================================
-- 第5步：预览API返回的数据（前5条）
-- ============================================================
SELECT '=== 步骤5: API返回数据预览（前5条）===' AS 说明;

SELECT 
    pmr.id,
    pmr.patient_id,
    u.real_name AS patientName,
    pmr.drug_name AS medicineName,
    pmr.dosage,
    pmr.frequency,
    DATE_FORMAT(pmr.start_time, '%Y-%m-%d %H:%i:%s') AS startTime,
    DATE_FORMAT(pmr.end_time, '%Y-%m-%d %H:%i:%s') AS endTime,
    CASE pmr.status
        WHEN 0 THEN '待执行'
        WHEN 1 THEN '进行中'
        WHEN 2 THEN '已完成'
        ELSE '未知'
    END AS statusText,
    pmr.status,
    pmr.remark AS notes
FROM patient_medication_record pmr
LEFT JOIN user u ON pmr.patient_id = u.id
WHERE pmr.patient_id IN (
    SELECT npr.patient_id 
    FROM nurse_patient_relation npr
    WHERE npr.nurse_id = (
        SELECT id FROM nurse 
        WHERE user_id = (SELECT id FROM user WHERE phone = '13900001001')
    )
    AND npr.is_deleted = 0
)
AND pmr.is_deleted = 0
ORDER BY pmr.create_time DESC
LIMIT 5;

-- ============================================================
-- 总结报告
-- ============================================================
SELECT '=== 📊 数据完整性验证报告 ===' AS 报告标题;

SELECT 
    '登录手机号' AS 项目,
    '13900001001' AS 值
UNION ALL
SELECT 
    'User表ID',
    CAST((SELECT id FROM user WHERE phone = '13900001001') AS CHAR)
UNION ALL
SELECT 
    'Nurse表ID (⭐API参数)',
    CAST((SELECT id FROM nurse WHERE user_id = (SELECT id FROM user WHERE phone = '13900001001')) AS CHAR)
UNION ALL
SELECT 
    '负责患者数',
    CAST((
        SELECT COUNT(*) 
        FROM nurse_patient_relation 
        WHERE nurse_id = (SELECT id FROM nurse WHERE user_id = (SELECT id FROM user WHERE phone = '13900001001'))
        AND is_deleted = 0
    ) AS CHAR)
UNION ALL
SELECT 
    '可见用药记录数',
    CAST((
        SELECT COUNT(*) 
        FROM patient_medication_record 
        WHERE patient_id IN (
            SELECT patient_id FROM nurse_patient_relation 
            WHERE nurse_id = (SELECT id FROM nurse WHERE user_id = (SELECT id FROM user WHERE phone = '13900001001'))
            AND is_deleted = 0
        )
        AND is_deleted = 0
    ) AS CHAR);

-- ============================================================
-- ✅ 如果上面的查询都返回了正确数据，说明：
-- 1. 数据库数据完整 ✅
-- 2. 护士-患者关联正常 ✅  
-- 3. 用药记录存在 ✅
--
-- 🔧 接下来需要：
-- 1. 重新运行前端应用
-- 2. 使用 13900001001 / 123456 登录
-- 3. 查看HiLog日志中的 [NurseMedication] 信息
-- 4. 确认前端传递的 nurseId 是否正确
-- ============================================================
