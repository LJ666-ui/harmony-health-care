-- 药品分类数据迁移脚本
-- 创建时间：2026-05-07
-- 说明：将medicine表的category字段迁移到标准分类编码

SET NAMES utf8mb4;

-- ----------------------------
-- 1. 迁移前置检查
-- ----------------------------
SELECT '=== 迁移前置检查 ===' AS step;

-- 检查分类字典表是否存在
SELECT CASE 
  WHEN COUNT(*) > 0 THEN '✓ 分类字典表已存在'
  ELSE '✗ 分类字典表不存在，请先执行medicine_category_tables.sql'
END AS check_result
FROM information_schema.tables 
WHERE table_schema = DATABASE() AND table_name = 'medicine_categories';

-- 检查映射规则表是否存在
SELECT CASE 
  WHEN COUNT(*) > 0 THEN '✓ 映射规则表已存在'
  ELSE '✗ 映射规则表不存在'
END AS check_result
FROM information_schema.tables 
WHERE table_schema = DATABASE() AND table_name = 'category_name_mapping';

-- 检查medicine表是否有数据
SELECT CASE 
  WHEN COUNT(*) > 0 THEN CONCAT('✓ medicine表有 ', COUNT(*), ' 条数据')
  ELSE '✗ medicine表无数据'
END AS check_result
FROM `medicine` WHERE is_deleted = 0;

-- ----------------------------
-- 2. 执行分类数据迁移
-- ----------------------------
SELECT '=== 开始执行迁移 ===' AS step;

-- 生成迁移批次号
SET @batch_no = CONCAT('MIG', DATE_FORMAT(NOW(), '%Y%m%d%H%i%s'));
SELECT CONCAT('迁移批次号: ', @batch_no) AS batch_info;

-- 创建临时表存储迁移结果
DROP TEMPORARY TABLE IF EXISTS temp_migration_result;
CREATE TEMPORARY TABLE temp_migration_result (
  old_category VARCHAR(100),
  new_category_code VARCHAR(10),
  medicine_count INT
);

-- 执行分类映射迁移（逐个分类处理）
-- 消化系统用药（胃）
INSERT INTO temp_migration_result 
SELECT '消化系统用药（胃）' AS old_category, '01-01' AS new_category_code, COUNT(*) AS medicine_count
FROM `medicine` WHERE category LIKE '%消化系统用药%胃%' AND is_deleted = 0;
UPDATE `medicine` SET category_code = '01-01' WHERE category LIKE '%消化系统用药%胃%' AND is_deleted = 0;

-- 抗过敏药物
INSERT INTO temp_migration_result 
SELECT '抗过敏药物' AS old_category, '02' AS new_category_code, COUNT(*) AS medicine_count
FROM `medicine` WHERE category LIKE '%抗过敏%' AND is_deleted = 0;
UPDATE `medicine` SET category_code = '02' WHERE category LIKE '%抗过敏%' AND is_deleted = 0;

-- 内分泌系统用药（胰岛素）
INSERT INTO temp_migration_result 
SELECT '内分泌系统用药（胰岛素）' AS old_category, '03-01' AS new_category_code, COUNT(*) AS medicine_count
FROM `medicine` WHERE category LIKE '%内分泌%胰岛素%' AND is_deleted = 0;
UPDATE `medicine` SET category_code = '03-01' WHERE category LIKE '%内分泌%胰岛素%' AND is_deleted = 0;

-- 内分泌系统用药（降糖）
INSERT INTO temp_migration_result 
SELECT '内分泌系统用药（降糖）' AS old_category, '03-02' AS new_category_code, COUNT(*) AS medicine_count
FROM `medicine` WHERE category LIKE '%内分泌%降糖%' AND is_deleted = 0;
UPDATE `medicine` SET category_code = '03-02' WHERE category LIKE '%内分泌%降糖%' AND is_deleted = 0;

-- 内分泌系统用药（通用）
INSERT INTO temp_migration_result 
SELECT '内分泌系统用药' AS old_category, '03' AS new_category_code, COUNT(*) AS medicine_count
FROM `medicine` WHERE category LIKE '%内分泌系统用药%' AND category_code IS NULL AND is_deleted = 0;
UPDATE `medicine` SET category_code = '03' WHERE category LIKE '%内分泌系统用药%' AND category_code IS NULL AND is_deleted = 0;

-- 利尿剂
INSERT INTO temp_migration_result 
SELECT '利尿剂' AS old_category, '04' AS new_category_code, COUNT(*) AS medicine_count
FROM `medicine` WHERE category LIKE '%利尿%' AND is_deleted = 0;
UPDATE `medicine` SET category_code = '04' WHERE category LIKE '%利尿%' AND is_deleted = 0;

-- 神经系统用药（抗抑郁）
INSERT INTO temp_migration_result 
SELECT '神经系统用药（抗抑郁）' AS old_category, '05-01' AS new_category_code, COUNT(*) AS medicine_count
FROM `medicine` WHERE category LIKE '%神经系统%抗抑郁%' AND is_deleted = 0;
UPDATE `medicine` SET category_code = '05-01' WHERE category LIKE '%神经系统%抗抑郁%' AND is_deleted = 0;

-- 精神神经系统用药
INSERT INTO temp_migration_result 
SELECT '精神神经系统用药' AS old_category, '05' AS new_category_code, COUNT(*) AS medicine_count
FROM `medicine` WHERE category LIKE '%精神神经%' AND is_deleted = 0;
UPDATE `medicine` SET category_code = '05' WHERE category LIKE '%精神神经%' AND is_deleted = 0;

-- 神经系统用药（通用）
INSERT INTO temp_migration_result 
SELECT '神经系统用药' AS old_category, '05' AS new_category_code, COUNT(*) AS medicine_count
FROM `medicine` WHERE category LIKE '%神经系统用药%' AND category_code IS NULL AND is_deleted = 0;
UPDATE `medicine` SET category_code = '05' WHERE category LIKE '%神经系统用药%' AND category_code IS NULL AND is_deleted = 0;

-- 心血管系统用药（降压）
INSERT INTO temp_migration_result 
SELECT '心血管系统用药（降压）' AS old_category, '06-01' AS new_category_code, COUNT(*) AS medicine_count
FROM `medicine` WHERE (category LIKE '%心血管%降压%' OR category LIKE '%心用药%降压%') AND is_deleted = 0;
UPDATE `medicine` SET category_code = '06-01' WHERE (category LIKE '%心血管%降压%' OR category LIKE '%心用药%降压%') AND is_deleted = 0;

-- 心血管系统用药（抗心绞痛）
INSERT INTO temp_migration_result 
SELECT '心血管系统用药（抗心绞痛）' AS old_category, '06-02' AS new_category_code, COUNT(*) AS medicine_count
FROM `medicine` WHERE category LIKE '%心血管%心绞痛%' AND is_deleted = 0;
UPDATE `medicine` SET category_code = '06-02' WHERE category LIKE '%心血管%心绞痛%' AND is_deleted = 0;

-- 心血管系统用药（通用）
INSERT INTO temp_migration_result 
SELECT '心血管系统用药' AS old_category, '06' AS new_category_code, COUNT(*) AS medicine_count
FROM `medicine` WHERE (category LIKE '%心血管系统用药%' OR category LIKE '%心血管用药%') AND category_code IS NULL AND is_deleted = 0;
UPDATE `medicine` SET category_code = '06' WHERE (category LIKE '%心血管系统用药%' OR category LIKE '%心血管用药%') AND category_code IS NULL AND is_deleted = 0;

-- 呼吸系统用药（平喘）
INSERT INTO temp_migration_result 
SELECT '呼吸系统用药（平喘）' AS old_category, '07-01' AS new_category_code, COUNT(*) AS medicine_count
FROM `medicine` WHERE category LIKE '%呼吸%平喘%' AND is_deleted = 0;
UPDATE `medicine` SET category_code = '07-01' WHERE category LIKE '%呼吸%平喘%' AND is_deleted = 0;

-- 呼吸系统用药（通用）
INSERT INTO temp_migration_result 
SELECT '呼吸系统用药' AS old_category, '07' AS new_category_code, COUNT(*) AS medicine_count
FROM `medicine` WHERE category LIKE '%呼吸系统用药%' AND category_code IS NULL AND is_deleted = 0;
UPDATE `medicine` SET category_code = '07' WHERE category LIKE '%呼吸系统用药%' AND category_code IS NULL AND is_deleted = 0;

-- 抗生素/抗感染药物
INSERT INTO temp_migration_result 
SELECT '抗生素/抗感染药物' AS old_category, '08' AS new_category_code, COUNT(*) AS medicine_count
FROM `medicine` WHERE category LIKE '%抗生素%' OR category LIKE '%抗感染%' AND is_deleted = 0;
UPDATE `medicine` SET category_code = '08' WHERE (category LIKE '%抗生素%' OR category LIKE '%抗感染%') AND is_deleted = 0;

-- 免疫调节药物
INSERT INTO temp_migration_result 
SELECT '免疫调节药物' AS old_category, '09' AS new_category_code, COUNT(*) AS medicine_count
FROM `medicine` WHERE (category LIKE '%免疫调节%' OR category LIKE '%免疫调节节%') AND is_deleted = 0;
UPDATE `medicine` SET category_code = '09' WHERE (category LIKE '%免疫调节%' OR category LIKE '%免疫调节节%') AND is_deleted = 0;

-- 输液及电解质平衡
INSERT INTO temp_migration_result 
SELECT '输液及电解质平衡' AS old_category, '10' AS new_category_code, COUNT(*) AS medicine_count
FROM `medicine` WHERE category LIKE '%输液%' OR category LIKE '%电解质%' AND is_deleted = 0;
UPDATE `medicine` SET category_code = '10' WHERE (category LIKE '%输液%' OR category LIKE '%电解质%') AND is_deleted = 0;

-- 肝脏疾病用药（保肝）
INSERT INTO temp_migration_result 
SELECT '肝脏疾病用药（保肝）' AS old_category, '11-01' AS new_category_code, COUNT(*) AS medicine_count
FROM `medicine` WHERE category LIKE '%肝脏%保肝%' AND is_deleted = 0;
UPDATE `medicine` SET category_code = '11-01' WHERE category LIKE '%肝脏%保肝%' AND is_deleted = 0;

-- 肝脏疾病用药（通用）
INSERT INTO temp_migration_result 
SELECT '肝脏疾病用药' AS old_category, '11' AS new_category_code, COUNT(*) AS medicine_count
FROM `medicine` WHERE category LIKE '%肝脏疾病用药%' AND category_code IS NULL AND is_deleted = 0;
UPDATE `medicine` SET category_code = '11' WHERE category LIKE '%肝脏疾病用药%' AND category_code IS NULL AND is_deleted = 0;

-- 镇痛药物
INSERT INTO temp_migration_result 
SELECT '镇痛药物' AS old_category, '12' AS new_category_code, COUNT(*) AS medicine_count
FROM `medicine` WHERE category LIKE '%镇痛%' AND is_deleted = 0;
UPDATE `medicine` SET category_code = '12' WHERE category LIKE '%镇痛%' AND is_deleted = 0;

-- 抗真菌药物
INSERT INTO temp_migration_result 
SELECT '抗真菌药物' AS old_category, '13' AS new_category_code, COUNT(*) AS medicine_count
FROM `medicine` WHERE category LIKE '%抗真菌%' AND is_deleted = 0;
UPDATE `medicine` SET category_code = '13' WHERE category LIKE '%抗真菌%' AND is_deleted = 0;

-- 眼科用药
INSERT INTO temp_migration_result 
SELECT '眼科用药' AS old_category, '14' AS new_category_code, COUNT(*) AS medicine_count
FROM `medicine` WHERE category LIKE '%眼科%' AND is_deleted = 0;
UPDATE `medicine` SET category_code = '14' WHERE category LIKE '%眼科%' AND is_deleted = 0;

-- 抗凝血/抗血小板
INSERT INTO temp_migration_result 
SELECT '抗凝血/抗血小板' AS old_category, '15' AS new_category_code, COUNT(*) AS medicine_count
FROM `medicine` WHERE (category LIKE '%抗凝血%' OR category LIKE '%抗血小板%') AND is_deleted = 0;
UPDATE `medicine` SET category_code = '15' WHERE (category LIKE '%抗凝血%' OR category LIKE '%抗血小板%') AND is_deleted = 0;

-- 耳鼻喉科用药
INSERT INTO temp_migration_result 
SELECT '耳鼻喉科用药' AS old_category, '16' AS new_category_code, COUNT(*) AS medicine_count
FROM `medicine` WHERE category LIKE '%耳鼻喉%' AND is_deleted = 0;
UPDATE `medicine` SET category_code = '16' WHERE category LIKE '%耳鼻喉%' AND is_deleted = 0;

-- 抑郁症和其伴随之焦虑（归类到神经系统）
INSERT INTO temp_migration_result 
SELECT '抑郁症和其伴随之焦虑' AS old_category, '05-01' AS new_category_code, COUNT(*) AS medicine_count
FROM `medicine` WHERE category LIKE '%抑郁%' AND is_deleted = 0;
UPDATE `medicine` SET category_code = '05-01' WHERE category LIKE '%抑郁%' AND category_code IS NULL AND is_deleted = 0;

-- ----------------------------
-- 3. 记录迁移日志
-- ----------------------------
INSERT INTO `category_migration_log` (`batch_no`, `old_category_name`, `new_category_code`, `medicine_count`, `status`, `operator_id`, `remark`)
SELECT @batch_no, old_category, new_category_code, medicine_count, 'success', 1, 
       CONCAT('分类迁移: ', old_category, ' -> ', new_category_code)
FROM temp_migration_result WHERE medicine_count > 0;

-- ----------------------------
-- 4. 迁移结果统计
-- ----------------------------
SELECT '=== 迁移结果统计 ===' AS step;

SELECT 
  CONCAT('总药品数: ', COUNT(*)) AS total_count
FROM `medicine` WHERE is_deleted = 0;

SELECT 
  CONCAT('已迁移药品数: ', COUNT(*)) AS migrated_count,
  CONCAT('迁移率: ', ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM `medicine` WHERE is_deleted = 0), 2), '%') AS migration_rate
FROM `medicine` WHERE category_code IS NOT NULL AND is_deleted = 0;

SELECT 
  CONCAT('未迁移药品数: ', COUNT(*)) AS not_migrated_count
FROM `medicine` WHERE category_code IS NULL AND is_deleted = 0;

-- 显示迁移详情
SELECT '=== 分类迁移详情 ===' AS step;
SELECT * FROM temp_migration_result WHERE medicine_count > 0 ORDER BY medicine_count DESC;

-- 显示未匹配的分类
SELECT '=== 未匹配的分类 ===' AS step;
SELECT DISTINCT category, COUNT(*) AS count
FROM `medicine`
WHERE category_code IS NULL AND is_deleted = 0
GROUP BY category
ORDER BY count DESC;

-- 清理临时表
DROP TEMPORARY TABLE IF EXISTS temp_migration_result;

SELECT CONCAT('迁移完成！批次号: ', @batch_no) AS result;
