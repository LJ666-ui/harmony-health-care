-- ==========================================
-- 星云医疗助手项目优化 - 数据库更新验证脚本
-- 版本: v1.0
-- 日期: 2026-05-10
-- 说明: 验证数据库更新是否成功
-- ==========================================

USE medical_health;

SELECT '========================================' AS '';
SELECT '数据库更新验证报告' AS '';
SELECT '========================================' AS '';
SELECT '';

-- 1. 验证新建表
SELECT '1. 新建表验证' AS '';
SELECT '========================================' AS '';
SELECT
    TABLE_NAME AS '表名',
    TABLE_COMMENT AS '表说明',
    CREATE_TIME AS '创建时间'
FROM information_schema.TABLES
WHERE TABLE_SCHEMA = 'medical_health'
  AND TABLE_NAME IN (
    'doctor_schedule',
    'prescription_template',
    'medical_record_template',
    'consultation',
    'consultation_participant',
    'consultation_record',
    'data_access_application',
    'sensitive_operation',
    'abnormal_login'
  )
ORDER BY TABLE_NAME;
SELECT '';

-- 2. 验证新增索引
SELECT '2. 新增索引验证' AS '';
SELECT '========================================' AS '';
SELECT
    TABLE_NAME AS '表名',
    INDEX_NAME AS '索引名',
    COLUMN_NAME AS '列名',
    SEQ_IN_INDEX AS '序号'
FROM information_schema.STATISTICS
WHERE TABLE_SCHEMA = 'medical_health'
  AND INDEX_NAME IN (
    'idx_record_time',
    'idx_user_record_type',
    'idx_patient_doctor',
    'idx_created_at',
    'idx_patient_reminder_time',
    'idx_status',
    'idx_session_send_time',
    'idx_receiver_read_status',
    'idx_accessor_data',
    'idx_access_time',
    'idx_doctor_id',
    'idx_schedule_date',
    'idx_hospital_department',
    'idx_is_public',
    'idx_initiator_id',
    'idx_patient_id',
    'idx_scheduled_time',
    'idx_consultation_id',
    'idx_requester_id',
    'idx_approver_id',
    'idx_data',
    'idx_user_id',
    'idx_login_time',
    'idx_risk_level',
    'idx_is_handled',
    'idx_resource'
  )
ORDER BY TABLE_NAME, INDEX_NAME, SEQ_IN_INDEX;
SELECT '';

-- 3. 验证测试数据
SELECT '3. 测试数据验证' AS '';
SELECT '========================================' AS '';

-- 医生排班表
SELECT 'doctor_schedule 表数据:' AS '';
SELECT COUNT(*) AS '记录数' FROM doctor_schedule;
SELECT * FROM doctor_schedule LIMIT 5;
SELECT '';

-- 处方模板表
SELECT 'prescription_template 表数据:' AS '';
SELECT COUNT(*) AS '记录数' FROM prescription_template;
SELECT id, doctor_id, template_name, is_public, usage_count FROM prescription_template LIMIT 5;
SELECT '';

-- 病历模板表
SELECT 'medical_record_template 表数据:' AS '';
SELECT COUNT(*) AS '记录数' FROM medical_record_template;
SELECT id, doctor_id, template_name, is_public, usage_count FROM medical_record_template LIMIT 5;
SELECT '';

-- 会诊表
SELECT 'consultation 表数据:' AS '';
SELECT COUNT(*) AS '记录数' FROM consultation;
SELECT id, initiator_id, patient_id, title, status FROM consultation LIMIT 5;
SELECT '';

-- 会诊参与人表
SELECT 'consultation_participant 表数据:' AS '';
SELECT COUNT(*) AS '记录数' FROM consultation_participant;
SELECT * FROM consultation_participant LIMIT 5;
SELECT '';

-- 会诊记录表
SELECT 'consultation_record 表数据:' AS '';
SELECT COUNT(*) AS '记录数' FROM consultation_record;
SELECT * FROM consultation_record LIMIT 5;
SELECT '';

-- 4. 统计汇总
SELECT '4. 统计汇总' AS '';
SELECT '========================================' AS '';
SELECT
    '新建表总数:' AS '统计项',
    COUNT(*) AS '数量'
FROM information_schema.TABLES
WHERE TABLE_SCHEMA = 'medical_health'
  AND TABLE_NAME IN (
    'doctor_schedule',
    'prescription_template',
    'medical_record_template',
    'consultation',
    'consultation_participant',
    'consultation_record',
    'data_access_application',
    'sensitive_operation',
    'abnormal_login'
  )
UNION ALL
SELECT
    '新增索引总数:' AS '统计项',
    COUNT(DISTINCT INDEX_NAME) AS '数量'
FROM information_schema.STATISTICS
WHERE TABLE_SCHEMA = 'medical_health'
  AND INDEX_NAME IN (
    'idx_record_time',
    'idx_user_record_type',
    'idx_patient_doctor',
    'idx_created_at',
    'idx_patient_reminder_time',
    'idx_status',
    'idx_session_send_time',
    'idx_receiver_read_status',
    'idx_accessor_data',
    'idx_access_time',
    'idx_doctor_id',
    'idx_schedule_date',
    'idx_hospital_department',
    'idx_is_public',
    'idx_initiator_id',
    'idx_patient_id',
    'idx_scheduled_time',
    'idx_consultation_id',
    'idx_requester_id',
    'idx_approver_id',
    'idx_data',
    'idx_user_id',
    'idx_login_time',
    'idx_risk_level',
    'idx_is_handled',
    'idx_resource'
  );

SELECT '';
SELECT '========================================' AS '';
SELECT '验证完成！' AS '';
SELECT '========================================' AS '';
