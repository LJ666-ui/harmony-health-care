-- =====================================================
-- 护士端患者数据 - 一键修复脚本
-- 问题：nurse_patient_relation表的patient_id与user表实际ID不匹配
-- 解决：更新patient_id为正确的user表ID
-- =====================================================

-- 第1步：查看当前状态（修复前）
SELECT '=== 修复前的数据 ===' AS 步骤;
SELECT 
    id,
    nurse_id AS 护士ID,
    patient_id AS 当前患者ID(错误),
    is_deleted
FROM nurse_patient_relation 
WHERE nurse_id = 1 AND is_deleted = 0;

-- 第2步：执行修复 - 更新patient_id为正确的user表ID
UPDATE nurse_patient_relation 
SET 
    patient_id = CASE id
        WHEN 17 THEN 111  -- 张三
        WHEN 18 THEN 112  -- 李四
        WHEN 19 THEN 113  -- 王五
        ELSE patient_id
    END,
    update_time = NOW()
WHERE id IN (17, 18, 19) AND nurse_id = 1;

-- 第3步：验证修复结果
SELECT '=== 修复后的数据 ===' AS 步骤;
SELECT 
    npr.id,
    npr.nurse_id AS 护士ID,
    npr.patient_id AS 修复后患者ID(正确),
    u.real_name AS 患者姓名,
    u.username AS 用户名,
    u.phone AS 手机号,
    u.age AS 年龄,
    CASE u.gender WHEN 1 THEN '男' WHEN 2 THEN '女' ELSE '未知' END AS 性别,
    npr.is_deleted AS 是否删除
FROM nurse_patient_relation npr
LEFT JOIN user u ON u.id = npr.patient_id
WHERE npr.nurse_id = 1 AND npr.is_deleted = 0
ORDER BY npr.id;

-- 第4步：最终验证 - 模拟后端查询
SELECT '=== 模拟后端查询结果 ===' AS 步骤;
SELECT 
    u.id AS 用户ID,
    u.real_name AS 真实姓名,
    u.phone AS 手机号,
    u.age AS 年龄,
    CASE u.gender WHEN 1 THEN '男' WHEN 2 THEN '女' ELSE '未知' END AS 性别,
    u.user_type AS 用户类型
FROM user u
WHERE u.id IN (
    SELECT patient_id 
    FROM nurse_patient_relation 
    WHERE nurse_id = 1 AND is_deleted = 0
)
AND u.user_type = 0
AND u.is_deleted = 0
ORDER BY u.id DESC;

-- 第5步：修复完成提示
SELECT '✅ 修复完成！护士端现在应该能正常显示3名患者了！' AS 结果;
