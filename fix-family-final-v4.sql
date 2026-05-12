-- ========================================
-- ✅ 最终修复脚本 v4.0（使用正确的下划线列名）
-- 问题：数据库表列名是 user_id 而非 userId
-- 日期：2026-05-11
-- ========================================

USE medical_health;

-- ========================================
-- 第一步：查看表结构（确认列名）
-- ========================================

SELECT '=== 查看medical_record表结构 ===' AS '';
SHOW COLUMNS FROM medical_record;

SELECT '=== 查看prescription表结构 ===' AS '';
SHOW COLUMNS FROM prescription;

SELECT '=== 查看medication_reminder表结构 ===' AS '';
SHOW COLUMNS FROM medication_reminder;

-- ========================================
-- 第二步：修正家属关联
-- ========================================

SELECT '' AS '';
SELECT '=== 修正家属关联到患者21 ===' AS '';

UPDATE family_member 
SET user_id = 21, update_time = NOW() 
WHERE is_deleted = 0;

SELECT CONCAT('✅ 已更新 ', ROW_COUNT(), ' 条家属记录') AS 结果;

-- 验证修改
SELECT id, name, user_id AS 关联患者ID FROM family_member WHERE is_deleted = 0;

-- ========================================
-- 第三步：添加病历记录（使用下划线列名）
-- medical_record表列名应该是：user_id, hospital_id, doctor_id等
-- ========================================

SELECT '' AS '';
SELECT '=== 添加病历数据 ===' AS '';

-- 先尝试插入（如果失败会提示具体错误）
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
(21, 1, 1, '高血压', '降压治疗，每日服用硝苯地平30mg', NOW(), 0, 0, NOW(), NOW()),
(21, 1, 2, '2型糖尿病', '控制血糖，口服二甲双胍500mg', DATE_SUB(NOW(), INTERVAL 30 DAY), 0, 0, NOW(), NOW());

SELECT CONCAT('✅ 病历插入结果: ', ROW_COUNT(), ' 条') AS 状态;

-- 验证
SELECT id, user_id, diagnosis, record_time 
FROM medical_record 
WHERE user_id = 21 AND is_deleted = 0;

-- ========================================
-- 第四步：添加处方记录
-- ========================================

SELECT '' AS '';
SELECT '=== 添加处方数据 ===' AS '';

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
      'frequency', '每日1次',
      'quantity', 30,
      'unit', '片'
    )
  ),
  '按时服药，定期监测血压',
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
      'frequency', '每日3次',
      'quantity', 90,
      'unit', '片'
    )
  ),
  '餐后服用，监测血糖',
  'ACTIVE',
  NOW(),
  DATE_ADD(NOW(), INTERVAL 60 DAY)
);

SELECT CONCAT('✅ 处方插入结果: ', ROW_COUNT(), ' 条') AS 状态;

-- 验证
SELECT id, doctor_name, diagnosis, status, created_at 
FROM prescription 
WHERE patient_id = 21;

-- ========================================
-- 第五步：添加用药提醒记录
-- ========================================

SELECT '' AS '';
SELECT '=== 添加用药提醒 ===' AS '';

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
(21, '硝苯地平控释片', '30mg', '每日1次', '08:00', CURDATE(), DATE_ADD(CURDATE(), INTERVAL 30 DAY), 'PENDING', '早餐前服用', NOW(), NOW()),
(21, '盐酸二甲双胍片', '500mg', '每日3次', '08:00,12:00,18:00', CURDATE(), DATE_ADD(CURDATE(), INTERVAL 60 DAY), 'PENDING', '餐后服用', NOW(), NOW());

SELECT CONCAT('✅ 用药提醒插入结果: ', ROW_COUNT(), ' 条') AS 状态;

-- 验证
SELECT id, medication_name, dosage, frequency, time_of_day 
FROM medication_reminder 
WHERE patient_id = 21;

-- ========================================
-- 第六步：完整性验证
-- ========================================

SELECT '' AS '';
SELECT '========================================' AS '';
SELECT '🎉 数据修复完成！最终验证：' AS '';
SELECT '========================================' AS '';

SELECT '-- 6.1 家属信息 --' AS '';
SELECT 
  fm.id AS 家属ID,
  fm.name AS 姓名,
  fm.user_id AS 关联患者ID,
  u.username AS 患者名
FROM family_member fm
LEFT JOIN user u ON fm.user_id = u.id
WHERE fm.is_deleted = 0;

SELECT '-- 6.2 病历数量 --' AS '';
SELECT COUNT(*) AS 病历总数 FROM medical_record WHERE user_id = 21 AND is_deleted = 0;

SELECT '-- 6.3 处方数量 --' AS '';
SELECT COUNT(*) AS 处方总数 FROM prescription WHERE patient_id = 21;

SELECT '-- 6.4 用药提醒数量 --' AS '';
SELECT COUNT(*) AS 提醒总数 FROM medication_reminder WHERE patient_id = 21;

SELECT '' AS '';
SELECT '========================================' AS '';
SELECT '✅ 所有操作完成！请重启后端服务并刷新前端。' AS '';
SELECT '========================================' AS '';

-- 如果上面的INSERT还是报错，请执行下面的诊断语句查看真实列名：
/*
SELECT '=== 如果还有错误，请运行以下诊断 ===' AS '';

-- 查看medical_record的真实列名
SELECT COLUMN_NAME, DATA_TYPE 
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_SCHEMA = 'medical_health' 
AND TABLE_NAME = 'medical_record'
ORDER BY ORDINAL_POSITION;
*/