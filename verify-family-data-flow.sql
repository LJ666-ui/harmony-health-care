-- ========================================
-- 家属功能数据流通验证脚本
-- 目的：验证家属能否正确查看患者的所有信息
-- 作者：CodeArts Agent
-- 日期：2026-05-11
-- ========================================

USE medical_health;

-- ========================================
-- 第一部分：数据完整性验证
-- ========================================

SELECT '========================================' AS '';
SELECT '第一部分：数据完整性验证' AS '';
SELECT '========================================' AS '';

-- 1. 验证家属关联是否正确
SELECT 
    '1. 家属关联验证' AS 检查项,
    fm.id AS 家属ID,
    fm.name AS 家属姓名,
    fm.relation AS 关系,
    fm.user_id AS 关联患者ID,
    u.username AS 患者用户名,
    u.phone AS 患者手机号,
    u.age AS 患者年龄,
    CASE 
        WHEN u.user_type = 0 THEN '✅ 正确：关联患者'
        WHEN u.user_type = 1 THEN '❌ 错误：关联医生'
        ELSE '⚠️ 其他类型'
    END AS 验证结果
FROM family_member fm
LEFT JOIN user u ON fm.user_id = u.id
WHERE fm.is_deleted = 0;

-- 2. 验证患者是否有病例数据
SELECT 
    '2. 患者病例数据验证' AS 检查项,
    u.id AS 患者ID,
    u.username AS 患者姓名,
    COUNT(mr.id) AS 病例数量,
    CASE 
        WHEN COUNT(mr.id) > 0 THEN '✅ 有病例数据'
        ELSE '❌ 无病例数据'
    END AS 验证结果
FROM user u
LEFT JOIN medical_record mr ON u.id = mr.user_id AND mr.is_deleted = 0
WHERE u.user_type = 0 AND u.is_deleted = 0
GROUP BY u.id, u.username
ORDER BY u.id
LIMIT 10;

-- 3. 验证患者是否有健康记录
SELECT 
    '3. 患者健康记录验证' AS 检查项,
    u.id AS 患者ID,
    u.username AS 患者姓名,
    COUNT(hr.id) AS 健康记录数量,
    CASE 
        WHEN COUNT(hr.id) > 0 THEN '✅ 有健康记录'
        ELSE '❌ 无健康记录'
    END AS 验证结果
FROM user u
LEFT JOIN health_record hr ON u.id = hr.user_id AND hr.is_deleted = 0
WHERE u.user_type = 0 AND u.is_deleted = 0
GROUP BY u.id, u.username
ORDER BY u.id
LIMIT 10;

-- ========================================
-- 第二部分：家属查看权限验证
-- ========================================

SELECT '========================================' AS '';
SELECT '第二部分：家属查看权限验证' AS '';
SELECT '========================================' AS '';

-- 4. 家属可查看的病例详情
SELECT 
    '4. 家属可查看病例详情' AS 检查项,
    fm.name AS 家属姓名,
    fm.relation AS 关系,
    u.username AS 患者,
    mr.diagnosis AS 诊断,
    mr.treatment AS 治疗,
    mr.record_time AS 就诊时间
FROM family_member fm
LEFT JOIN user u ON fm.user_id = u.id
LEFT JOIN medical_record mr ON u.id = mr.user_id AND mr.is_deleted = 0
WHERE fm.is_deleted = 0
ORDER BY fm.id, mr.record_time DESC;

-- 5. 家属可查看的健康记录详情
SELECT 
    '5. 家属可查看健康记录详情' AS 检查项,
    fm.name AS 家属姓名,
    fm.relation AS 关系,
    u.username AS 患者,
    hr.record_type AS 记录类型,
    hr.value AS 数值,
    hr.unit AS 单位,
    hr.record_time AS 记录时间
FROM family_member fm
LEFT JOIN user u ON fm.user_id = u.id
LEFT JOIN health_record hr ON u.id = hr.user_id AND hr.is_deleted = 0
WHERE fm.is_deleted = 0
ORDER BY fm.id, hr.record_time DESC
LIMIT 20;

-- ========================================
-- 第三部分：API接口数据验证
-- ========================================

SELECT '========================================' AS '';
SELECT '第三部分：API接口数据验证' AS '';
SELECT '========================================' AS '';

-- 6. 模拟 /family/info 接口返回的数据
SELECT 
    '6. /family/info 接口数据' AS 检查项,
    fm.id AS familyId,
    fm.name AS name,
    fm.phone AS phone,
    fm.relation AS relation,
    fm.user_id AS userId,
    fm.is_emergency_contact AS isEmergencyContact,
    fm.health_condition AS healthCondition
FROM family_member fm
WHERE fm.is_deleted = 0;

-- 7. 模拟 /medical/record/my 接口返回的数据
SELECT 
    '7. /medical/record/my 接口数据' AS 检查项,
    mr.id,
    mr.user_id AS userId,
    mr.hospital_id AS hospitalId,
    mr.doctor_id AS doctorId,
    mr.diagnosis,
    mr.treatment,
    mr.record_time AS recordTime
FROM medical_record mr
WHERE mr.is_deleted = 0
ORDER BY mr.record_time DESC
LIMIT 10;

-- 8. 模拟 /healthRecord/my 接口返回的数据
SELECT 
    '8. /healthRecord/my 接口数据' AS 检查项,
    hr.id,
    hr.user_id AS userId,
    hr.record_type AS recordType,
    hr.value,
    hr.unit,
    hr.record_time AS recordTime
FROM health_record hr
WHERE hr.is_deleted = 0
ORDER BY hr.record_time DESC
LIMIT 10;

-- ========================================
-- 第四部分：数据统计汇总
-- ========================================

SELECT '========================================' AS '';
SELECT '第四部分：数据统计汇总' AS '';
SELECT '========================================' AS '';

-- 9. 家属功能数据统计
SELECT 
    '9. 家属功能数据统计' AS 检查项,
    (SELECT COUNT(*) FROM family_member WHERE is_deleted = 0) AS 家属总数,
    (SELECT COUNT(*) FROM user WHERE user_type = 0 AND is_deleted = 0) AS 患者总数,
    (SELECT COUNT(*) FROM medical_record WHERE is_deleted = 0) AS 病例总数,
    (SELECT COUNT(*) FROM health_record WHERE is_deleted = 0) AS 健康记录总数;

-- 10. 家属查看能力汇总
SELECT 
    '10. 家属查看能力汇总' AS 检查项,
    fm.name AS 家属姓名,
    fm.relation AS 关系,
    u.username AS 关联患者,
    COUNT(DISTINCT mr.id) AS 可查看病例数,
    COUNT(DISTINCT hr.id) AS 可查看健康记录数,
    CASE 
        WHEN COUNT(DISTINCT mr.id) > 0 AND COUNT(DISTINCT hr.id) > 0 THEN '✅ 完整'
        WHEN COUNT(DISTINCT mr.id) > 0 OR COUNT(DISTINCT hr.id) > 0 THEN '⚠️ 部分'
        ELSE '❌ 无数据'
    END AS 数据完整性
FROM family_member fm
LEFT JOIN user u ON fm.user_id = u.id
LEFT JOIN medical_record mr ON u.id = mr.user_id AND mr.is_deleted = 0
LEFT JOIN health_record hr ON u.id = hr.user_id AND hr.is_deleted = 0
WHERE fm.is_deleted = 0
GROUP BY fm.id, fm.name, fm.relation, u.username;

-- ========================================
-- 完成
-- ========================================

SELECT '========================================' AS '';
SELECT '✅ 数据流通验证完成！' AS '';
SELECT '========================================' AS '';
SELECT '如果所有验证结果都显示 ✅，说明数据流通正常' AS '';
SELECT '如果出现 ❌，请检查对应的数据' AS '';
SELECT '========================================' AS '';
