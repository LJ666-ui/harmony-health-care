-- ========================================
-- 家属功能完整修复脚本
-- 解决问题：家属关联医生、缺少病例和健康记录数据
-- 作者：CodeArts Agent
-- 日期：2026-05-11
-- ========================================

USE medical_health;

-- ========================================
-- 第一步：修正家属关联（从医生改为患者）
-- ========================================

SELECT '========================================' AS '';
SELECT '第一步：修正家属关联' AS '';
SELECT '========================================' AS '';

-- 将家属关联到患者21（马建军，64岁）
UPDATE family_member SET user_id = 21, update_time = NOW() WHERE id IN (1, 2, 3);

-- 将家属关联到患者22（任桂英，36岁）
UPDATE family_member SET user_id = 22, update_time = NOW() WHERE id IN (4, 5);

-- 验证修正结果
SELECT 
    '修正后关联状态' AS 分析项,
    fm.id AS 家属ID,
    fm.name AS 家属姓名,
    fm.relation AS 关系,
    fm.user_id AS 关联用户ID,
    u.username AS 关联用户名,
    u.user_type AS 关联用户类型,
    CASE u.user_type 
        WHEN 0 THEN '✅ 正确：关联患者'
        ELSE '❌ 仍然错误'
    END AS 验证结果
FROM family_member fm
LEFT JOIN user u ON fm.user_id = u.id
WHERE fm.is_deleted = 0;

-- ========================================
-- 第二步：为患者添加病例数据
-- ========================================

SELECT '========================================' AS '';
SELECT '第二步：为患者添加病例数据' AS '';
SELECT '========================================' AS '';

-- 为患者21（马建军）添加病例
INSERT INTO medical_record (
    user_id, hospital_id, doctor_id, 
    diagnosis, treatment, record_time, 
    is_desensitized, is_deleted, create_time, update_time
) VALUES 
(21, 1, 1, '高血压病3级（极高危）', 
 '降压药物治疗：氨氯地平5mg qd + 缬沙坦80mg qd\n低盐低脂饮食\n定期监测血压', 
 '2026-05-01 10:00:00', 0, 0, NOW(), NOW()),
 
(21, 1, 1, '2型糖尿病', 
 '口服降糖药：二甲双胍0.5g tid\n饮食控制\n定期监测血糖', 
 '2026-04-15 14:30:00', 0, 0, NOW(), NOW()),
 
(21, 1, 1, '冠心病', 
 '抗血小板治疗：阿司匹林100mg qd\n调脂治疗：阿托伐他汀20mg qn', 
 '2026-03-20 09:00:00', 0, 0, NOW(), NOW());

-- 为患者22（任桂英）添加病例
INSERT INTO medical_record (
    user_id, hospital_id, doctor_id, 
    diagnosis, treatment, record_time, 
    is_desensitized, is_deleted, create_time, update_time
) VALUES 
(22, 1, 1, '慢性浅表性胃炎', 
 '抑酸治疗：奥美拉唑20mg qd\n胃黏膜保护：铝碳酸镁1g tid', 
 '2026-04-28 11:00:00', 0, 0, NOW(), NOW()),
 
(22, 1, 1, '颈椎病', 
 '物理治疗：颈椎牵引\n避免长时间低头', 
 '2026-04-10 15:00:00', 0, 0, NOW(), NOW());

SELECT '✅ 病例数据插入完成' AS '';

-- ========================================
-- 第三步：为患者添加健康记录
-- ========================================

SELECT '========================================' AS '';
SELECT '第三步：为患者添加健康记录' AS '';
SELECT '========================================' AS '';

-- 为患者21（马建国）添加健康记录
INSERT INTO health_record (
    user_id, 
    blood_pressure, 
    blood_sugar, 
    heart_rate, 
    weight, 
    height,
    step_count,
    sleep_duration,
    record_time, 
    is_deleted, 
    create_time, 
    update_time
) VALUES 
(21, '145/92', 7.2, 78, 72.5, 170, 8500, 7.5, '2026-05-10 08:00:00', 0, NOW(), NOW()),
(21, '138/85', 6.8, 82, 72.8, 170, 9200, 7.0, '2026-05-09 08:00:00', 0, NOW(), NOW()),
(21, '142/88', 7.5, 76, 72.6, 170, 7800, 8.0, '2026-05-08 08:00:00', 0, NOW(), NOW()),
(21, '140/86', 7.0, 80, 72.7, 170, 8800, 7.2, '2026-05-07 08:00:00', 0, NOW(), NOW()),
(21, '148/94', 7.8, 84, 72.9, 170, 6500, 6.5, '2026-05-06 08:00:00', 0, NOW(), NOW());

-- 为患者22（任桂英）添加健康记录
INSERT INTO health_record (
    user_id, 
    blood_pressure, 
    blood_sugar, 
    heart_rate, 
    weight, 
    height,
    step_count,
    sleep_duration,
    record_time, 
    is_deleted, 
    create_time, 
    update_time
) VALUES 
(22, '118/76', 5.6, 72, 58.5, 165, 10000, 8.0, '2026-05-10 08:00:00', 0, NOW(), NOW()),
(22, '120/78', 5.8, 70, 58.3, 165, 9500, 7.5, '2026-05-09 08:00:00', 0, NOW(), NOW()),
(22, '116/74', 5.5, 68, 58.4, 165, 11000, 8.2, '2026-05-08 08:00:00', 0, NOW(), NOW()),
(22, '122/80', 5.9, 74, 58.6, 165, 8500, 7.8, '2026-05-07 08:00:00', 0, NOW(), NOW());

SELECT '✅ 健康记录数据插入完成' AS '';

-- ========================================
-- 第四步：验证最终结果
-- ========================================

SELECT '========================================' AS '';
SELECT '第四步：验证最终结果' AS '';
SELECT '========================================' AS '';

-- 验证家属查看能力
SELECT 
    '家属查看能力汇总' AS 检查项,
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
SELECT '✅ 所有修复完成！' AS '';
SELECT '========================================' AS '';
SELECT '家属现在可以查看患者的病例和健康记录了' AS '';
SELECT '请重启后端服务并测试前端功能' AS '';
SELECT '========================================' AS '';
