-- ============================================================
-- 修复nursing_record表结构 - 添加缺失字段
-- ============================================================

-- 查看当前表结构
SELECT '当前表结构:' AS status;
DESC nursing_record;

-- 添加 nurse_id 字段
-- 注意：如果字段已存在会报错，可以忽略或先删除再添加
ALTER TABLE `nursing_record` 
ADD COLUMN `nurse_id` bigint NULL DEFAULT NULL COMMENT '护士ID，关联nurse表id' AFTER `patient_id`;

-- 添加 vital_signs 字段
ALTER TABLE `nursing_record` 
ADD COLUMN `vital_signs` json NULL DEFAULT NULL COMMENT '生命体征数据JSON' AFTER `remark`;

-- 添加 care_time 字段
ALTER TABLE `nursing_record` 
ADD COLUMN `care_time` datetime NULL DEFAULT NULL COMMENT '护理时间' AFTER `vital_signs`;

-- 添加索引
ALTER TABLE `nursing_record` ADD INDEX `idx_nurse_id`(`nurse_id`);
ALTER TABLE `nursing_record` ADD INDEX `idx_care_time`(`care_time`);

-- 验证表结构
SELECT '修复后的表结构:' AS status;
DESC nursing_record;

SELECT '表结构修复完成！' AS status;
