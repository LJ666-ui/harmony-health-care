-- ==========================================
-- 星云医疗助手项目优化 - 数据库修复脚本
-- 版本: v1.0
-- 日期: 2026-05-10
-- 说明: 修复索引添加失败的问题
-- ==========================================

USE medical_health;

SELECT '========================================' AS '';
SELECT '数据库修复脚本开始执行' AS '';
SELECT '========================================' AS '';
SELECT '';

-- ==========================================
-- 第一部分：检查并添加可用的索引
-- ==========================================

-- 1. health_record 表索引（record_type 字段存在）
SELECT '1. 检查 health_record 表索引...' AS '';
-- 检查 idx_record_time 是否存在
SET @index_exists = (SELECT COUNT(*) FROM information_schema.STATISTICS 
                     WHERE TABLE_SCHEMA = 'medical_health' 
                     AND TABLE_NAME = 'health_record' 
                     AND INDEX_NAME = 'idx_record_time');
                     
IF @index_exists = 0 THEN
    ALTER TABLE `health_record` ADD INDEX `idx_record_time` (`record_time`);
    SELECT '  - idx_record_time 添加成功' AS '';
ELSE
    SELECT '  - idx_record_time 已存在，跳过' AS '';
END IF;

-- 检查 idx_user_record_type 是否存在
SET @index_exists = (SELECT COUNT(*) FROM information_schema.STATISTICS 
                     WHERE TABLE_SCHEMA = 'medical_health' 
                     AND TABLE_NAME = 'health_record' 
                     AND INDEX_NAME = 'idx_user_record_type');
                     
IF @index_exists = 0 THEN
    ALTER TABLE `health_record` ADD INDEX `idx_user_record_type` (`user_id`, `record_type`);
    SELECT '  - idx_user_record_type 添加成功' AS '';
ELSE
    SELECT '  - idx_user_record_type 已存在，跳过' AS '';
END IF;

SELECT '';

-- 2. 检查其他表的索引
SELECT '2. 检查其他表索引...' AS '';

-- doctor_message 表索引（如果表存在且有相应字段）
SET @table_exists = (SELECT COUNT(*) FROM information_schema.TABLES 
                     WHERE TABLE_SCHEMA = 'medical_health' 
                     AND TABLE_NAME = 'doctor_message');

IF @table_exists > 0 THEN
    -- 检查是否有 session_id 字段
    SET @column_exists = (SELECT COUNT(*) FROM information_schema.COLUMNS 
                          WHERE TABLE_SCHEMA = 'medical_health' 
                          AND TABLE_NAME = 'doctor_message' 
                          AND COLUMN_NAME = 'session_id');
    
    IF @column_exists > 0 THEN
        SET @index_exists = (SELECT COUNT(*) FROM information_schema.STATISTICS 
                             WHERE TABLE_SCHEMA = 'medical_health' 
                             AND TABLE_NAME = 'doctor_message' 
                             AND INDEX_NAME = 'idx_session_send_time');
        
        IF @index_exists = 0 THEN
            ALTER TABLE `doctor_message` ADD INDEX `idx_session_send_time` (`session_id`, `send_time`);
            SELECT '  - doctor_message.idx_session_send_time 添加成功' AS '';
        END IF;
    END IF;
ELSE
    SELECT '  - doctor_message 表不存在，跳过' AS '';
END IF;

-- data_access_log 表索引（如果表存在且有相应字段）
SET @table_exists = (SELECT COUNT(*) FROM information_schema.TABLES 
                     WHERE TABLE_SCHEMA = 'medical_health' 
                     AND TABLE_NAME = 'data_access_log');

IF @table_exists > 0 THEN
    -- 检查是否有 access_time 字段
    SET @column_exists = (SELECT COUNT(*) FROM information_schema.COLUMNS 
                          WHERE TABLE_SCHEMA = 'medical_health' 
                          AND TABLE_NAME = 'data_access_log' 
                          AND COLUMN_NAME = 'access_time');
    
    IF @column_exists > 0 THEN
        SET @index_exists = (SELECT COUNT(*) FROM information_schema.STATISTICS 
                             WHERE TABLE_SCHEMA = 'medical_health' 
                             AND TABLE_NAME = 'data_access_log' 
                             AND INDEX_NAME = 'idx_access_time');
        
        IF @index_exists = 0 THEN
            ALTER TABLE `data_access_log` ADD INDEX `idx_access_time` (`access_time`);
            SELECT '  - data_access_log.idx_access_time 添加成功' AS '';
        END IF;
    END IF;
ELSE
    SELECT '  - data_access_log 表不存在，跳过' AS '';
END IF;

SELECT '';

-- ==========================================
-- 第二部分：修复测试数据
-- ==========================================

SELECT '3. 修复测试数据...' AS '';

-- 检查 doctor_schedule 表结构
SELECT '  - 检查 doctor_schedule 表结构...' AS '';
SHOW COLUMNS FROM doctor_schedule;

-- 如果 doctor_schedule 表没有 hospital_id 字段，则不插入测试数据
SET @column_exists = (SELECT COUNT(*) FROM information_schema.COLUMNS 
                      WHERE TABLE_SCHEMA = 'medical_health' 
                      AND TABLE_NAME = 'doctor_schedule' 
                      AND COLUMN_NAME = 'hospital_id');

IF @column_exists = 0 THEN
    SELECT '  - doctor_schedule 表缺少 hospital_id 字段，跳过测试数据插入' AS '';
    SELECT '  - 建议：请手动检查 doctor_schedule 表结构' AS '';
ELSE
    -- 检查是否已有测试数据
    SET @data_count = (SELECT COUNT(*) FROM doctor_schedule WHERE doctor_id = 1);
    
    IF @data_count = 0 THEN
        -- 尝试插入测试数据
        INSERT INTO `doctor_schedule` (`doctor_id`, `hospital_id`, `department_id`, `schedule_date`, `time_slot_id`, `start_time`, `end_time`, `max_appointments`, `booked_appointments`, `status`)
        VALUES
        (1, 1, 1, CURDATE(), 1, '08:00:00', '12:00:00', 20, 15, 'available'),
        (1, 1, 1, CURDATE(), 2, '14:00:00', '17:00:00', 15, 10, 'available');
        
        SELECT '  - doctor_schedule 测试数据插入成功' AS '';
    ELSE
        SELECT '  - doctor_schedule 已有测试数据，跳过' AS '';
    END IF;
END IF;

SELECT '';

-- ==========================================
-- 第三部分：生成修复报告
-- ==========================================

SELECT '========================================' AS '';
SELECT '修复报告' AS '';
SELECT '========================================' AS '';
SELECT '';

-- 显示所有新建表
SELECT '新建表列表:' AS '';
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

-- 显示所有新增索引
SELECT '新增索引列表:' AS '';
SELECT DISTINCT
    TABLE_NAME AS '表名',
    INDEX_NAME AS '索引名'
FROM information_schema.STATISTICS
WHERE TABLE_SCHEMA = 'medical_health'
  AND INDEX_NAME IN (
    'idx_record_time',
    'idx_user_record_type',
    'idx_doctor_id',
    'idx_schedule_date',
    'idx_hospital_department',
    'idx_is_public',
    'idx_initiator_id',
    'idx_patient_id',
    'idx_status',
    'idx_scheduled_time',
    'idx_consultation_id',
    'idx_requester_id',
    'idx_approver_id',
    'idx_data',
    'idx_user_id',
    'idx_login_time',
    'idx_risk_level',
    'idx_is_handled',
    'idx_resource',
    'idx_session_send_time',
    'idx_access_time'
  )
ORDER BY TABLE_NAME, INDEX_NAME;

SELECT '';

-- 统计汇总
SELECT '统计汇总:' AS '';
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
    'idx_doctor_id',
    'idx_schedule_date',
    'idx_hospital_department',
    'idx_is_public',
    'idx_initiator_id',
    'idx_patient_id',
    'idx_status',
    'idx_scheduled_time',
    'idx_consultation_id',
    'idx_requester_id',
    'idx_approver_id',
    'idx_data',
    'idx_user_id',
    'idx_login_time',
    'idx_risk_level',
    'idx_is_handled',
    'idx_resource',
    'idx_session_send_time',
    'idx_access_time'
  );

SELECT '';
SELECT '========================================' AS '';
SELECT '修复脚本执行完成！' AS '';
SELECT '========================================' AS '';
