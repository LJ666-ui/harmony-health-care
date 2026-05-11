-- =====================================================
-- 护士端患者数据问题 - 完整诊断脚本
-- 执行此脚本可以快速定位问题根源
-- =====================================================

-- 第1步：查看nurse_patient_relation表中护士关联的患者ID
SELECT '=== 第1步：护士-患者关系表数据 ===' AS 诊断步骤;
SELECT 
    id,
    nurse_id AS 护士ID,
    patient_id AS 患者ID,
    relation_type AS 关系类型,
    is_deleted AS 是否删除
FROM nurse_patient_relation 
WHERE nurse_id = 1 AND is_deleted = 0
ORDER BY id;

-- 第2步：查看这些patient_id在user表中是否存在
SELECT '=== 第2步：检查关联的患者ID在user表中的存在性 ===' AS 诊断步骤;
SELECT 
    npr.patient_id AS 关联的患者ID,
    CASE 
        WHEN u.id IS NOT NULL THEN '✅ 存在'
        ELSE '❌ 不存在'
    END AS user表状态,
    u.id AS user表实际ID,
    u.username AS 用户名,
    u.real_name AS 真实姓名,
    u.user_type AS 用户类型,
    CASE u.user_type 
        WHEN 0 THEN '✅ 患者'
        WHEN 1 THEN '医生'
        WHEN 2 THEN '护士'
        ELSE '其他(' || CAST(u.user_type AS CHAR) || ')'
    END AS 类型说明,
    u.is_deleted AS 是否删除,
    CASE u.is_deleted
        WHEN 0 THEN '✅ 正常'
        ELSE '❌ 已删除'
    END AS 删除状态
FROM (
    SELECT patient_id 
    FROM nurse_patient_relation 
    WHERE nurse_id = 1 AND is_deleted = 0
) npr
LEFT JOIN user u ON u.id = npr.patient_id;

-- 第3步：查看user表最后3条记录（张三、李四、王五）的实际ID
SELECT '=== 第3步：user表最后3条患者记录 ===' AS 诊断步骤;
SELECT 
    id AS 用户ID,
    username AS 用户名,
    real_name AS 真实姓名,
    phone AS 手机号,
    age AS 年龄,
    gender AS 性别,
    user_type AS 用户类型,
    department AS 科室,
    is_deleted AS 是否删除
FROM user 
WHERE user_type = 0 AND real_name IS NOT NULL AND real_name != ''
ORDER BY id DESC
LIMIT 3;

-- 第4步：对比分析 - 找出不匹配的问题
SELECT '=== 第4步：问题根因分析 ===' AS 诊断步骤;
SELECT 
    CASE 
        WHEN COUNT(CASE WHEN u.id IS NULL THEN 1 END) > 0 THEN 
            '❌ 问题发现：有 ' || CAST(COUNT(CASE WHEN u.id IS NULL THEN 1 END) AS CHAR) || ' 个patient_id在user表中不存在'
        WHEN COUNT(CASE WHEN u.user_type != 0 THEN 1 END) > 0 THEN
            '❌ 问题发现：有 ' || CAST(COUNT(CASE WHEN u.user_type != 0 THEN 1 END) AS CHAR) || ' 个用户user_type不是0（患者）'
        WHEN COUNT(CASE WHEN u.is_deleted != 0 THEN 1 END) > 0 THEN
            '❌ 问题发现：有 ' || CAST(COUNT(CASE WHEN u.is_deleted != 0 THEN 1 END) AS CHAR) || ' 个用户已被标记为删除'
        ELSE
            '✅ 数据看起来正常，可能是其他原因（如Token、网络等）'
    END AS 诊断结果
FROM (
    SELECT patient_id 
    FROM nurse_patient_relation 
    WHERE nurse_id = 1 AND is_deleted = 0
) npr
LEFT JOIN user u ON u.id = npr.patient_id;

-- 第5步：如果发现问题，提供修复建议
SELECT '=== 第5步：修复建议 ===' AS 诊断步骤;
SELECT 
    '请根据上面的诊断结果执行相应修复：' AS 说明
UNION ALL
SELECT '1. 如果patient_id不存在：需要更新nurse_patient_relation表的patient_id为正确的user表ID'
UNION ALL
SELECT '2. 如果user_type不对：需要更新user表的user_type字段为0（患者）'
UNION ALL
SELECT '3. 如果is_deleted不为0：需要将is_deleted更新为0（恢复数据）';
