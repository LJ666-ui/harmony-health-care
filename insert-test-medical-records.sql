-- ========================================
-- 测试病例数据插入脚本
-- 目的：为患者添加病例数据，使家属能够查看
-- 作者：CodeArts Agent
-- 日期：2026-05-11
-- ========================================

USE medical_health;

-- ========================================
-- 第一步：查看现有数据
-- ========================================

SELECT '========================================' AS '';
SELECT '第一步：查看现有医院和医生数据' AS '';
SELECT '========================================' AS '';

-- 查看医院
SELECT 
    id AS 医院ID,
    name AS 医院名称,
    level AS 医院等级,
    address AS 地址
FROM hospital
WHERE is_deleted = 0
LIMIT 5;

-- 查看医生
SELECT 
    d.id AS 医生ID,
    d.real_name AS 医生姓名,
    d.title AS 职称,
    d.specialty AS 擅长,
    d.hospital AS 所属医院
FROM doctor d
WHERE d.is_deleted = 0
LIMIT 10;

-- 查看患者（user_type=0）
SELECT 
    id AS 患者ID,
    username AS 用户名,
    phone AS 手机号,
    age AS 年龄
FROM user
WHERE user_type = 0 AND is_deleted = 0
LIMIT 10;

-- ========================================
-- 第二步：插入测试病例数据
-- ========================================

SELECT '========================================' AS '';
SELECT '第二步：插入测试病例数据' AS '';
SELECT '========================================' AS '';
SELECT '⚠️ 注意：以下INSERT语句已注释，请根据实际情况取消注释' AS '';

-- 为患者21（马建军，64岁）添加病例
-- INSERT INTO medical_record (
--     user_id, 
--     hospital_id, 
--     doctor_id, 
--     diagnosis, 
--     treatment, 
--     record_time, 
--     is_desensitized, 
--     is_deleted,
--     create_time,
--     update_time
-- ) VALUES 
-- -- 高血压
-- (21, 1, 1, 
--  '高血压病3级（极高危）', 
--  '1. 降压药物治疗：氨氯地平5mg qd + 缬沙坦80mg qd\n2. 低盐低脂饮食\n3. 定期监测血压，目标<130/80mmHg\n4. 适量运动，控制体重', 
--  '2026-05-01 10:00:00', 0, 0, NOW(), NOW()),
-- 
-- -- 2型糖尿病
-- (21, 1, 2, 
--  '2型糖尿病', 
--  '1. 口服降糖药：二甲双胍0.5g tid\n2. 饮食控制：低糖低脂饮食\n3. 定期监测血糖，空腹血糖目标<7.0mmol/L\n4. 适量运动，每周至少150分钟', 
--  '2026-04-15 14:30:00', 0, 0, NOW(), NOW()),
-- 
-- -- 冠心病
-- (21, 1, 1, 
--  '冠状动脉粥样硬化性心脏病', 
--  '1. 抗血小板治疗：阿司匹林100mg qd\n2. 调脂治疗：阿托伐他汀20mg qn\n3. 改善心肌供血：单硝酸异山梨酯20mg bid\n4. 定期复查心电图、心脏超声', 
--  '2026-03-20 09:00:00', 0, 0, NOW(), NOW()),
-- 
-- -- 脑梗死病史
-- (21, 1, 3, 
--  '脑梗死（陈旧性）', 
--  '1. 二级预防：阿司匹林100mg qd + 氯吡格雷75mg qd\n2. 控制危险因素：降压、降糖、调脂\n3. 康复训练：肢体功能锻炼\n4. 定期复查头颅CT/MRI', 
--  '2026-02-10 11:00:00', 0, 0, NOW(), NOW());

-- 为患者22（任桂英，36岁）添加病例
-- INSERT INTO medical_record (
--     user_id, 
--     hospital_id, 
--     doctor_id, 
--     diagnosis, 
--     treatment, 
--     record_time, 
--     is_desensitized, 
--     is_deleted,
--     create_time,
--     update_time
-- ) VALUES 
-- -- 慢性胃炎
-- (22, 1, 4, 
--  '慢性浅表性胃炎', 
--  '1. 抑酸治疗：奥美拉唑20mg qd\n2. 胃黏膜保护：铝碳酸镁1g tid\n3. 饮食调理：少食多餐，避免辛辣刺激\n4. 根除幽门螺杆菌（如阳性）', 
--  '2026-04-28 11:00:00', 0, 0, NOW(), NOW()),
-- 
-- -- 颈椎病
-- (22, 1, 5, 
--  '颈椎病（神经根型）', 
--  '1. 物理治疗：颈椎牵引、理疗\n2. 药物治疗：颈复康颗粒 + 甲钴胺0.5mg tid\n3. 避免长时间低头，保持正确坐姿\n4. 颈椎操锻炼', 
--  '2026-04-10 15:00:00', 0, 0, NOW(), NOW()),
-- 
-- -- 月经不调
-- (22, 1, 6, 
--  '月经不调', 
--  '1. 中药调理：乌鸡白凤丸\n2. 规律作息，避免熬夜\n3. 保持心情舒畅\n4. 定期妇科检查', 
--  '2026-03-25 16:00:00', 0, 0, NOW(), NOW());

-- 为患者23（冯志强，60岁）添加病例
-- INSERT INTO medical_record (
--     user_id, 
--     hospital_id, 
--     doctor_id, 
--     diagnosis, 
--     treatment, 
--     record_time, 
--     is_desensitized, 
--     is_deleted,
--     create_time,
--     update_time
-- ) VALUES 
-- -- 慢性支气管炎
-- (23, 1, 7, 
--  '慢性支气管炎', 
--  '1. 抗感染治疗：阿莫西林0.5g tid（急性发作时）\n2. 止咳化痰：氨溴索30mg tid\n3. 戒烟，避免粉尘刺激\n4. 增强体质，预防感冒', 
--  '2026-05-05 09:30:00', 0, 0, NOW(), NOW()),
-- 
-- -- 前列腺增生
-- (23, 1, 8, 
--  '前列腺增生', 
--  '1. 药物治疗：坦索罗辛0.2mg qn\n2. 定期复查前列腺超声、PSA\n3. 避免久坐，适量运动\n4. 如症状加重考虑手术治疗', 
--  '2026-04-20 14:00:00', 0, 0, NOW(), NOW());

-- ========================================
-- 第三步：验证插入结果
-- ========================================

SELECT '========================================' AS '';
SELECT '第三步：验证插入结果（执行INSERT后取消注释查看）' AS '';
SELECT '========================================' AS '';

-- SELECT 
--     '病例数据验证' AS 分析项,
--     mr.id AS 病例ID,
--     mr.user_id AS 患者ID,
--     u.username AS 患者姓名,
--     u.age AS 年龄,
--     mr.diagnosis AS 诊断,
--     LEFT(mr.treatment, 50) AS 治疗方案摘要,
--     mr.record_time AS 就诊时间,
--     h.name AS 医院
-- FROM medical_record mr
-- LEFT JOIN user u ON mr.user_id = u.id
-- LEFT JOIN hospital h ON mr.hospital_id = h.id
-- WHERE mr.is_deleted = 0
-- ORDER BY mr.record_time DESC
-- LIMIT 20;

-- ========================================
-- 第四步：验证家属能否查看病例
-- ========================================

SELECT '========================================' AS '';
SELECT '第四步：验证家属能否查看病例（需要先修正family_member关联）' AS '';
SELECT '========================================' AS '';

-- SELECT 
--     '家属病例查看验证' AS 分析项,
--     fm.id AS 家属ID,
--     fm.name AS 家属姓名,
--     fm.relation AS 关系,
--     fm.user_id AS 关联患者ID,
--     u.username AS 患者姓名,
--     COUNT(mr.id) AS 可查看病例数,
--     CASE 
--         WHEN COUNT(mr.id) > 0 THEN '✅ 可以查看病例'
--         ELSE '❌ 无法查看病例（需要添加病例数据）'
--     END AS 验证结果
-- FROM family_member fm
-- LEFT JOIN user u ON fm.user_id = u.id
-- LEFT JOIN medical_record mr ON u.id = mr.user_id AND mr.is_deleted = 0
-- WHERE fm.is_deleted = 0
-- GROUP BY fm.id, fm.name, fm.relation, fm.user_id, u.username;

-- ========================================
-- 完成
-- ========================================

SELECT '========================================' AS '';
SELECT '✅ 测试病例数据插入脚本已生成！' AS '';
SELECT '请按顺序执行：' AS '';
SELECT '1. 先执行fix-family-data-association.sql修正关联' AS '';
SELECT '2. 再执行本脚本插入病例数据' AS '';
SELECT '========================================' AS '';
