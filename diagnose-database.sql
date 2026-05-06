-- ========================================
-- 数据库诊断脚本
-- 检查数据库表结构和数据
-- ========================================

USE medical_health;

-- 1. 检查user表是否存在
SELECT '检查user表是否存在...' AS step;
SHOW TABLES LIKE 'user';

-- 2. 检查user表结构
SELECT '检查user表结构...' AS step;
DESC user;

-- 3. 检查是否有real_name字段
SELECT '检查real_name字段是否存在...' AS step;
SELECT COUNT(*) AS field_count 
FROM information_schema.COLUMNS 
WHERE TABLE_SCHEMA = 'medical_health' 
  AND TABLE_NAME = 'user' 
  AND COLUMN_NAME = 'real_name';

-- 4. 检查所有字段
SELECT 'user表所有字段列表...' AS step;
SELECT COLUMN_NAME, DATA_TYPE, IS_NULLABLE, COLUMN_DEFAULT, COLUMN_COMMENT
FROM information_schema.COLUMNS
WHERE TABLE_SCHEMA = 'medical_health' 
  AND TABLE_NAME = 'user'
ORDER BY ORDINAL_POSITION;

-- 5. 检查现有用户数据
SELECT '检查现有用户数据...' AS step;
SELECT * FROM user LIMIT 5;

-- 6. 检查是否有重复用户名
SELECT '检查重复用户名...' AS step;
SELECT username, COUNT(*) as count 
FROM user 
GROUP BY username 
HAVING count > 1;

-- 7. 检查索引
SELECT '检查索引...' AS step;
SHOW INDEX FROM user;

-- 8. 检查表状态
SELECT '检查表状态...' AS step;
SHOW TABLE STATUS LIKE 'user';

-- 诊断完成
SELECT '数据库诊断完成！' AS message;
SELECT '如果real_name字段不存在，请执行 update-user-table.sql 脚本' AS next_step;
