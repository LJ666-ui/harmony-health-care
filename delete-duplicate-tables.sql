-- ==========================================
-- 删除之前脚本中重复创建的表
-- 版本: v1.0
-- 日期: 2026-05-10
-- 说明: 删除 add-missing-tables.sql 中可能重复创建的表
--       这些表在您的数据库中已经存在
-- ==========================================

USE medical_health;

-- ==========================================
-- 删除重复的表（如果存在且是刚才创建的）
-- ==========================================

-- 注意：以下表在您的数据库中已经存在，不需要重复创建
-- consultation - 已存在
-- prescription_template - 已存在
-- department - 您使用的是 hospital_department，不需要单独的 department 表

-- 如果之前执行了 add-missing-tables.sql，可以执行以下语句清理
-- 但由于使用了 CREATE TABLE IF NOT EXISTS，不会创建重复表
-- 所以这个脚本主要用于说明哪些表不需要创建

SELECT '========================================' AS '';
SELECT '重复表检查报告' AS message;
SELECT '========================================' AS '';

-- 检查 consultation 表是否存在
SELECT 
  CASE 
    WHEN COUNT(*) > 0 THEN '✅ consultation 表已存在，无需创建'
    ELSE '❌ consultation 表不存在'
  END AS status
FROM information_schema.TABLES 
WHERE TABLE_SCHEMA = 'medical_health' 
AND TABLE_NAME = 'consultation';

-- 检查 prescription_template 表是否存在
SELECT 
  CASE 
    WHEN COUNT(*) > 0 THEN '✅ prescription_template 表已存在，无需创建'
    ELSE '❌ prescription_template 表不存在'
  END AS status
FROM information_schema.TABLES 
WHERE TABLE_SCHEMA = 'medical_health' 
AND TABLE_NAME = 'prescription_template';

-- 检查 hospital_department 表是否存在
SELECT 
  CASE 
    WHEN COUNT(*) > 0 THEN '✅ hospital_department 表已存在，无需创建 department 表'
    ELSE '❌ hospital_department 表不存在'
  END AS status
FROM information_schema.TABLES 
WHERE TABLE_SCHEMA = 'medical_health' 
AND TABLE_NAME = 'hospital_department';

-- 检查 department 表是否存在（如果存在，说明之前可能重复创建了）
SELECT 
  CASE 
    WHEN COUNT(*) > 0 THEN '⚠️  department 表存在，可能与 hospital_department 重复'
    ELSE '✅ department 表不存在，使用 hospital_department 即可'
  END AS status
FROM information_schema.TABLES 
WHERE TABLE_SCHEMA = 'medical_health' 
AND TABLE_NAME = 'department';

SELECT '========================================' AS '';
SELECT '建议：' AS message;
SELECT '1. 使用 hospital_department 表代替 department 表' AS suggestion;
SELECT '2. consultation 和 prescription_template 已存在，无需重复创建' AS suggestion;
SELECT '3. 执行 add-missing-tables-v2.sql 补充真正缺失的表' AS suggestion;
SELECT '========================================' AS '';

-- 如果确实创建了重复的 department 表，可以删除（谨慎操作）
-- DROP TABLE IF EXISTS `department`;
