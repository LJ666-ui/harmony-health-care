-- ========================================
-- ✅ 最终数据完整性检查与补充脚本 v5.0
-- 目的：确保患者ID=21拥有所有必要的数据
-- 日期：2026-05-11
-- ========================================

USE medical_health;

SELECT '========================================' AS '';
SELECT '开始数据完整性检查和补充...' AS '';
SELECT '========================================' AS '';

-- ========================================
-- 第一步：确认家属关联正确（应该已经是21了）
-- ========================================

SELECT '--- 1. 检查家属关联 ---' AS '';
SELECT id, name, user_id FROM family_member WHERE is_deleted = 0;

-- ========================================
-- 第二步：确认/创建用户21的基本信息
-- ========================================

SELECT '--- 2. 检查用户21是否存在 ---' AS '';
SELECT id, username, real_name, phone, age, gender, user_type 
FROM user 
WHERE id = 21 AND is_deleted = 0;

-- 如果用户21不存在，创建它
INSERT IGNORE INTO user (id, username, password, phone, real_name, age, gender, user_type, is_deleted, create_time)
VALUES (21, 'majianjun21', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOs7K8h5KMkqI', '13812345021', '马建军', 65, 1, 0, 0, NOW());

SELECT CONCAT('✅ 用户21处理完成') AS 状态;

-- 更新用户21的详细信息（如果存在则更新）
UPDATE user SET 
  real_name = '马建军',
  phone = '13812345021',
  age = 65,
  gender = 1,
  user_type = 0
WHERE id = 21 AND is_deleted = 0;

-- ========================================
-- 第三步：添加/确认病历数据
-- ========================================

SELECT '' AS '';
SELECT '--- 3. 检查并添加病历数据 ---' AS '';

-- 先查看当前病历数量
SELECT COUNT(*) AS 当前病历数 FROM medical_record WHERE user_id = 21 AND is_deleted = 0;

-- 使用正确的列名格式（根据实际表结构）
-- 注意：这里使用下划线格式，如果报错说明表用的是驼峰格式
INSERT IGNORE INTO medical_record (
  user_id,
  hospital_id,
  doctor_id,
  diagnosis,
  treatment,
  record_time,
  is_desensitized,
  is_deleted,
  create_time,
  update_time
) VALUES
(21, 1, 1, '高血压（原发性）', '降压治疗，口服硝苯地平控释片30mg qd，监测血压', NOW(), 0, 0, NOW(), NOW()),
(21, 1, 2, '2型糖尿病', '控制血糖，口服二甲双胍500mg tid，定期监测空腹及餐后血糖', DATE_SUB(NOW(), INTERVAL 30 DAY), 0, 0, NOW(), NOW()),
(21, 1, 1, '冠心病（稳定性心绞痛）', '抗血小板治疗，阿司匹林100mg qn，他汀类调脂', DATE_SUB(NOW(), INTERVAL 60 DAY), 0, 0, NOW(), NOW());

SELECT CONCAT('✅ 病历数据已准备，当前总数: ', (SELECT COUNT(*) FROM medical_record WHERE user_id = 21 AND is_deleted = 0)) AS 结果;

-- 验证病历数据
SELECT id, diagnosis, treatment, record_time 
FROM medical_record 
WHERE user_id = 21 AND is_deleted = 0
ORDER BY record_time DESC;

-- ========================================
-- 第四步：添加/确认处方数据
-- ========================================

SELECT '' AS '';
SELECT '--- 4. 检查并添加处方数据 ---' AS '';

-- 查看当前处方数量
SELECT COUNT(*) AS 当前处方数 FROM prescription WHERE patient_id = 21;

INSERT IGNORE INTO prescription (
  patient_id,
  patient_name,
  doctor_id,
  doctor_name,
  diagnosis,
  medications,
  notes,
  status,
  created_at,
  valid_until
) VALUES
(
  21,
  '马建军',
  1,
  '张医生',
  '高血压',
  JSON_ARRAY(
    JSON_OBJECT(
      'medicineName', '硝苯地平控释片',
      'specification', '30mg',
      'dosage', '1片',
      'frequency', '每日1次 早餐前',
      'quantity', 30,
      'unit', '片',
      'instructions', '整片吞服，不可嚼碎'
    )
  ),
  '按时服药，定期监测血压，如有不适及时就诊',
  'ACTIVE',
  NOW(),
  DATE_ADD(NOW(), INTERVAL 30 DAY)
),
(
  21,
  '马建军',
  2,
  '李医生',
  '2型糖尿病',
  JSON_ARRAY(
    JSON_OBJECT(
      'medicineName', '盐酸二甲双胍片',
      'specification', '500mg',
      'dosage', '1片',
      'frequency', '每日3次 餐后30分钟',
      'quantity', 90,
      'unit', '片',
      'instructions', '餐后服用，减少胃肠道反应'
    ),
    JSON_OBJECT(
      'medicineName', '阿卡波糖片',
      'specification', '50mg',
      'dosage', '1片',
      'frequency', '每日3次 嚼服',
      'quantity', 90,
      'unit', '片',
      'instructions', '与第一口主食同时嚼服'
    )
  ),
  '规律用药，监测血糖，注意低血糖反应',
  'ACTIVE',
  DATE_SUB(NOW(), INTERVAL 15 DAY),
  DATE_ADD(NOW(), INTERVAL 45 DAY)
),
(
  21,
  '马建军',
  1,
  '张医生',
  '冠心病',
  JSON_ARRAY(
    JSON_OBJECT(
      'medicineName', '阿司匹林肠溶片',
      'specification', '100mg',
      'dosage', '1片',
      'frequency', '每日1次 晚餐后',
      'quantity', 30,
      'unit', '片',
      'instructions': '长期服用，不可随意停药'
    ),
    JSON_OBJECT(
      'medicineName', '阿托伐他汀钙片',
      'specification', '20mg',
      'dosage', '1片',
      'frequency', '每日1次 晚餐后',
      'quantity', 30,
      'unit', '片',
      'instructions': '定期复查肝功能'
    )
  ),
  '长期服药，定期复查心电图、肝功能、血脂',
  'ACTIVE',
  DATE_SUB(NOW(), INTERVAL 45 DAY),
  DATE_ADD(NOW(), INTERVAL 90 DAY)
);

SELECT CONCAT('✅ 处方数据已准备，当前总数: ', (SELECT COUNT(*) FROM prescription WHERE patient_id = 21)) AS 结果;

-- 验证处方数据
SELECT id, doctor_name, diagnosis, status, created_at 
FROM prescription 
WHERE patient_id = 21
ORDER BY created_at DESC;

-- ========================================
-- 第五步：添加用药提醒（用于"用药管理"页面）
-- ========================================

SELECT '' AS '';
SELECT '--- 5. 添加用药提醒 ---' AS '';

INSERT IGNORE INTO medication_reminder (
  patient_id,
  medication_name,
  dosage,
  frequency,
  time_of_day,
  start_date,
  end_date,
  status,
  notes,
  create_time,
  update_time
) VALUES
(21, '硝苯地平控释片', '30mg', '每日1次', '08:00', CURDATE(), DATE_ADD(CURDATE(), INTERVAL 30 DAY), 'PENDING', '早餐前30分钟服用', NOW(), NOW()),
(21, '盐酸二甲双胍片', '500mg', '每日3次', '08:00,12:00,18:00', CURDATE(), DATE_ADD(CURDATE(), INTERVAL 30 DAY), 'PENDING', '餐后30分钟服用', NOW(), NOW()),
(21, '阿卡波糖片', '50mg', '每日3次', '08:00,12:00,18:00', CURDATE(), DATE_ADD(CURDATE(), INTERVAL 30 DAY), 'PENDING', '嚼服，与第一口主食同服', NOW(), NOW()),
(21, '阿司匹林肠溶片', '100mg', '每日1次', '20:00', CURDATE(), DATE_ADD(CURDATE(), INTERVAL 90 DAY), 'PENDING', '晚餐后服用', NOW(), NOW()),
(21, '阿托伐他汀钙片', '20mg', '每日1次', '20:00', CURDATE(), DATE_ADD(CURDATE(), INTERVAL 90 DAY), 'PENDING', '晚餐后服用', NOW(), NOW());

SELECT CONCAT('✅ 用药提醒已准备，当前总数: ', (SELECT COUNT(*) FROM medication_reminder WHERE patient_id = 21)) AS 结果;

-- ========================================
-- 第六步：最终验证
-- ========================================

SELECT '' AS '';
SELECT '========================================' AS '';
SELECT '🎉 数据完整性检查完成！最终结果：' AS '';
SELECT '========================================' AS '';

SELECT '' AS '';
SELECT '-- 6.1 家属信息 --' AS '';
SELECT 
  fm.id AS 家属ID,
  fm.name AS 家属姓名,
  fm.user_id AS 关联患者ID,
  u.username AS 患者账号,
  u.real_name AS 患者姓名,
  u.phone AS 联系电话
FROM family_member fm
LEFT JOIN user u ON fm.user_id = u.id
WHERE fm.is_deleted = 0;

SELECT '' AS '';
SELECT '-- 6.2 数据统计 --' AS '';
SELECT 
  (SELECT COUNT(*) FROM medical_record WHERE user_id = 21 AND is_deleted = 0) AS 病历数,
  (SELECT COUNT(*) FROM prescription WHERE patient_id = 21) AS 处方数,
  (SELECT COUNT(*) FROM medication_reminder WHERE patient_id = 21) AS 用药提醒数;

SELECT '' AS '';
SELECT '========================================' AS '';
SELECT '✅ 所有数据已准备完毕！' AS '';
SELECT '' AS '';
SELECT '接下来请执行以下操作：' AS '';
SELECT '1. 重启后端服务（Ctrl+C 然后 mvn spring-boot:run）' AS '';
SELECT '2. 在鸿蒙模拟器中完全关闭家属端应用' AS '';
SELECT '3. 重新打开应用并登录家属账号' AS '';
SELECT '4. 测试以下功能：' AS '';
SELECT '   - 点击"查看详情 >"（应能跳转到患者详情页）' AS '';
SELECT '   - 点击"病情诊断"/"病历记录"（应显示3条病历）' AS '';
SELECT '   - 点击"处方药品"（应显示3张处方）' AS '';
SELECT '   - 点击"健康数据"/"用药管理"（应显示药品列表）' AS '';
SELECT '========================================' AS '';