-- ============================================================
-- 安全修复nursing_record表结构 - 带检查的添加字段
-- ============================================================

-- 查看当前表结构
SELECT '当前表结构:' AS status;
DESC nursing_record;

-- 方式1: 使用存储过程安全添加字段
DROP PROCEDURE IF EXISTS add_column_if_not_exists;

DELIMITER //
CREATE PROCEDURE add_column_if_not_exists()
BEGIN
    -- 检查并添加 nurse_id 字段
    IF NOT EXISTS (
        SELECT * FROM information_schema.COLUMNS 
        WHERE TABLE_SCHEMA = DATABASE() 
          AND TABLE_NAME = 'nursing_record' 
          AND COLUMN_NAME = 'nurse_id'
    ) THEN
        ALTER TABLE `nursing_record` ADD COLUMN `nurse_id` bigint NULL DEFAULT NULL COMMENT '护士ID，关联nurse表id' AFTER `patient_id`;
        SELECT '已添加 nurse_id 字段' AS result;
    ELSE
        SELECT 'nurse_id 字段已存在，跳过' AS result;
    END IF;
    
    -- 检查并添加 vital_signs 字段
    IF NOT EXISTS (
        SELECT * FROM information_schema.COLUMNS 
        WHERE TABLE_SCHEMA = DATABASE() 
          AND TABLE_NAME = 'nursing_record' 
          AND COLUMN_NAME = 'vital_signs'
    ) THEN
        ALTER TABLE `nursing_record` ADD COLUMN `vital_signs` json NULL DEFAULT NULL COMMENT '生命体征数据JSON' AFTER `remark`;
        SELECT '已添加 vital_signs 字段' AS result;
    ELSE
        SELECT 'vital_signs 字段已存在，跳过' AS result;
    END IF;
    
    -- 检查并添加 care_time 字段
    IF NOT EXISTS (
        SELECT * FROM information_schema.COLUMNS 
        WHERE TABLE_SCHEMA = DATABASE() 
          AND TABLE_NAME = 'nursing_record' 
          AND COLUMN_NAME = 'care_time'
    ) THEN
        ALTER TABLE `nursing_record` ADD COLUMN `care_time` datetime NULL DEFAULT NULL COMMENT '护理时间' AFTER `vital_signs`;
        SELECT '已添加 care_time 字段' AS result;
    ELSE
        SELECT 'care_time 字段已存在，跳过' AS result;
    END IF;
    
    -- 添加索引
    IF NOT EXISTS (
        SELECT * FROM information_schema.STATISTICS 
        WHERE TABLE_SCHEMA = DATABASE() 
          AND TABLE_NAME = 'nursing_record' 
          AND INDEX_NAME = 'idx_nurse_id'
    ) THEN
        ALTER TABLE `nursing_record` ADD INDEX `idx_nurse_id`(`nurse_id`);
        SELECT '已添加 idx_nurse_id 索引' AS result;
    END IF;
    
    IF NOT EXISTS (
        SELECT * FROM information_schema.STATISTICS 
        WHERE TABLE_SCHEMA = DATABASE() 
          AND TABLE_NAME = 'nursing_record' 
          AND INDEX_NAME = 'idx_care_time'
    ) THEN
        ALTER TABLE `nursing_record` ADD INDEX `idx_care_time`(`care_time`);
        SELECT '已添加 idx_care_time 索引' AS result;
    END IF;
END //
DELIMITER ;

-- 执行存储过程
CALL add_column_if_not_exists();

-- 删除存储过程
DROP PROCEDURE IF EXISTS add_column_if_not_exists;

-- 验证表结构
SELECT '修复后的表结构:' AS status;
SELECT 
    COLUMN_NAME AS '字段名',
    COLUMN_TYPE AS '类型',
    IS_NULLABLE AS '允许空',
    COLUMN_DEFAULT AS '默认值',
    COLUMN_COMMENT AS '注释'
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = DATABASE() 
  AND TABLE_NAME = 'nursing_record'
ORDER BY ORDINAL_POSITION;

SELECT '表结构修复完成！' AS status;
