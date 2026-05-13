-- ========================================
-- 修正版：家属端数据修复脚本（符合实际表结构）
-- 日期：2026-05-11
-- ========================================

USE medical_health;

-- ========================================
-- 第一步：修正家属关联（已确认需要执行）
-- ========================================

SELECT '=== 1. 修正家属user_id为21 ===' AS '';

UPDATE family_member 
SET user_id = 21, update_time = NOW() 
WHERE is_deleted = 0;

SELECT CONCAT('✅ 已更新 ', ROW_COUNT(), ' 条家属记录') AS 结果;

-- 验证
SELECT id, name, user_id AS 关联患者ID FROM family_member WHERE is_deleted = 0;

-- ========================================
-- 第二步：添加病历记录（使用正确的字段名）
-- medical_record表实际字段：
-- id, userId, hospitalId, doctorId, diagnosis, treatment, 
-- recordTime, isDesensitized, createTime, updateTime, isDeleted
-- ========================================

SELECT '=== 2. 添加病历数据 ===' AS '';

INSERT IGNORE INTO medical_record (
  userId, 
  hospitalId, 
  doctorId, 
  diagnosis, 
  treatment, 
  recordTime, 
  isDesensitized,
  is_deleted, 
  create_time, 
  update_time
) VALUES 
(21, 1, 1, '高血压', '降压治疗，每日服用硝苯地平30mg', NOW(), 0, 0, NOW(), NOW()),
(21, 1, 2, '2型糖尿病', '控制血糖，口服二甲双胍500mg', DATE_SUB(NOW(), INTERVAL 30 DAY), 0, 0, NOW(), NOW());

SELECT CONCAT('✅ 已插入 ', ROW_COUNT(), ' 条病历记录') AS 结果;

-- 验证病历
SELECT id, userId, diagnosis, treatment, recordTime 
FROM medical_record 
WHERE userId = 21 AND is_deleted = 0;

-- ========================================
-- 第三步：添加处方记录
-- ========================================

SELECT '=== 3. 添加处方数据 ===' AS '';

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
      'frequency', '每日3次 餐后服用',
      'quantity', 90,
      'unit', '片'
    )
  ),
  '餐后服用，监测血糖',
  'ACTIVE',
  NOW(),
  DATE_ADD(NOW(), INTERVAL 60 DAY)
);

SELECT CONCAT('✅ 已插入 ', ROW_COUNT(), ' 条处方记录') AS 结果;

-- 验证处方
SELECT id, doctor_name, diagnosis, status, created_at 
FROM prescription 
WHERE patient_id = 21;

-- ========================================
-- 第四步：添加用药提醒记录（用于用药管理页面）
-- ========================================

SELECT '=== 4. 添加用药提醒 ===' AS '';

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

SELECT CONCAT('✅ 已插入 ', ROW_COUNT(), ' 条用药提醒') AS 结果;

-- ========================================
-- 第五步：完整性验证
-- ========================================

SELECT '' AS '';
SELECT '========================================' AS '';
SELECT '✅ 数据修复完成！验证结果如下：' AS '';
SELECT '========================================' AS '';

SELECT '-- 5.1 家属信息 --' AS '';
SELECT 
  fm.id AS 家属ID,
  fm.name AS 姓名,
  fm.user_id AS 关联患者ID,
  u.username AS 患者名
FROM family_member fm
LEFT JOIN user u ON fm.user_id = u.id
WHERE fm.is_deleted = 0;

SELECT '-- 5.2 病历数量 --' AS '';
SELECT COUNT(*) AS 病历总数 FROM medical_record WHERE user_id = 21 AND is_deleted = 0;

SELECT '-- 5.3 处方数量 --' AS '';
SELECT COUNT(*) AS 处方总数 FROM prescription WHERE patient_id = 21;

SELECT '-- 5.4 用药提醒数量 --' AS '';
SELECT COUNT(*) AS 提醒总数 FROM medication_reminder WHERE patient_id = 21;

SELECT '' AS '';
SELECT '🎉 所有数据修复完成！请重启后端服务并刷新前端。' AS '';