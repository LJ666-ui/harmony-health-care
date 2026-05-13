-- ==========================================
-- 星云医疗助手项目优化 - 数据库修复脚本（简化版）
-- 版本: v1.0
-- 日期: 2026-05-10
-- 说明: 修复索引添加失败的问题
-- ==========================================

USE medical_health;

SELECT '========================================' AS '';
SELECT '数据库修复脚本开始执行' AS '';
SELECT '========================================' AS '';

-- ==========================================
-- 添加 health_record 表索引
-- ==========================================

-- 添加 idx_record_time 索引
ALTER TABLE `health_record` ADD INDEX IF NOT EXISTS `idx_record_time` (`record_time`);

-- 添加 idx_user_record_type 索引
ALTER TABLE `health_record` ADD INDEX IF NOT EXISTS `idx_user_record_type` (`user_id`, `record_type`);

SELECT 'health_record 表索引添加完成' AS '';

-- ==========================================
-- 显示修复结果
-- ==========================================

SELECT '========================================' AS '';
SELECT '修复结果' AS '';
SELECT '========================================' AS '';

-- 显示 health_record 表的所有索引
SELECT
    TABLE_NAME AS '表名',
    INDEX_NAME AS '索引名',
    COLUMN_NAME AS '列名'
FROM information_schema.STATISTICS
WHERE TABLE_SCHEMA = 'medical_health'
  AND TABLE_NAME = 'health_record'
  AND INDEX_NAME IN ('idx_record_time', 'idx_user_record_type')
ORDER BY INDEX_NAME, SEQ_IN_INDEX;

SELECT '';

-- 统计汇总
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
    'health_record 新增索引:' AS '统计项',
    COUNT(DISTINCT INDEX_NAME) AS '数量'
FROM information_schema.STATISTICS
WHERE TABLE_SCHEMA = 'medical_health'
  AND TABLE_NAME = 'health_record'
  AND INDEX_NAME IN ('idx_record_time', 'idx_user_record_type');

SELECT '';
SELECT '========================================' AS '';
SELECT '修复脚本执行完成！' AS '';
SELECT '========================================' AS '';
