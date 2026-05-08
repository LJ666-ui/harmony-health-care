-- 补充分类迁移脚本
-- 执行时间：2026-05-08

SET NAMES utf8mb4;

-- 皮肤科用药 -> 新增分类17
INSERT IGNORE INTO `medicine_categories` (`category_code`, `category_name`, `parent_code`, `level`, `display_order`, `status`) VALUES
('17', '皮肤科用药', NULL, 1, 17, 1);
UPDATE `medicine` SET category_code = '17' WHERE (category LIKE '%皮肤科%' OR category LIKE '%局部外用%') AND category_code IS NULL AND is_deleted = 0;

-- 维生素及营养类药物 -> 新增分类18
INSERT IGNORE INTO `medicine_categories` (`category_code`, `category_name`, `parent_code`, `level`, `display_order`, `status`) VALUES
('18', '维生素及营养类药物', NULL, 1, 18, 1);
UPDATE `medicine` SET category_code = '18' WHERE (category LIKE '%维生素%' OR category LIKE '%营养%') AND category_code IS NULL AND is_deleted = 0;

-- 血液系统用药 -> 新增分类19
INSERT IGNORE INTO `medicine_categories` (`category_code`, `category_name`, `parent_code`, `level`, `display_order`, `status`) VALUES
('19', '血液系统用药', NULL, 1, 19, 1);
UPDATE `medicine` SET category_code = '19' WHERE category LIKE '%血液系统%' AND category_code IS NULL AND is_deleted = 0;

-- 消化系统用药（其他）
UPDATE `medicine` SET category_code = '01' WHERE category LIKE '%消化系统%' AND category_code IS NULL AND is_deleted = 0;

-- 妇产科用药 -> 新增分类20
INSERT IGNORE INTO `medicine_categories` (`category_code`, `category_name`, `parent_code`, `level`, `display_order`, `status`) VALUES
('20', '妇产科用药', NULL, 1, 20, 1);
UPDATE `medicine` SET category_code = '20' WHERE (category LIKE '%妇产科%' OR category LIKE '%泌尿系统%') AND category_code IS NULL AND is_deleted = 0;

-- 骨骼肌肉系统用药 -> 新增分类21
INSERT IGNORE INTO `medicine_categories` (`category_code`, `category_name`, `parent_code`, `level`, `display_order`, `status`) VALUES
('21', '骨骼肌肉系统用药', NULL, 1, 21, 1);
UPDATE `medicine` SET category_code = '21' WHERE category LIKE '%骨骼肌肉%' AND category_code IS NULL AND is_deleted = 0;

-- 解毒药物 -> 新增分类22
INSERT IGNORE INTO `medicine_categories` (`category_code`, `category_name`, `parent_code`, `level`, `display_order`, `status`) VALUES
('22', '解毒药物', NULL, 1, 22, 1);
UPDATE `medicine` SET category_code = '22' WHERE category LIKE '%解毒%' AND category_code IS NULL AND is_deleted = 0;

-- 口腔科用药 -> 新增分类23
INSERT IGNORE INTO `medicine_categories` (`category_code`, `category_name`, `parent_code`, `level`, `display_order`, `status`) VALUES
('23', '口腔科用药', NULL, 1, 23, 1);
UPDATE `medicine` SET category_code = '23' WHERE category LIKE '%口腔科%' AND category_code IS NULL AND is_deleted = 0;

-- 抗病毒药物 -> 归类到08
UPDATE `medicine` SET category_code = '08' WHERE category LIKE '%抗病毒%' AND category_code IS NULL AND is_deleted = 0;

-- 抗肿瘤药物 -> 新增分类24
INSERT IGNORE INTO `medicine_categories` (`category_code`, `category_name`, `parent_code`, `level`, `display_order`, `status`) VALUES
('24', '抗肿瘤药物', NULL, 1, 24, 1);
UPDATE `medicine` SET category_code = '24' WHERE category LIKE '%抗肿瘤%' AND category_code IS NULL AND is_deleted = 0;

-- 诊断用药 -> 新增分类25
INSERT IGNORE INTO `medicine_categories` (`category_code`, `category_name`, `parent_code`, `level`, `display_order`, `status`) VALUES
('25', '诊断用药', NULL, 1, 25, 1);
UPDATE `medicine` SET category_code = '25' WHERE category LIKE '%诊断用药%' AND category_code IS NULL AND is_deleted = 0;

-- 中成药 -> 新增分类26
INSERT IGNORE INTO `medicine_categories` (`category_code`, `category_name`, `parent_code`, `level`, `display_order`, `status`) VALUES
('26', '中成药', NULL, 1, 26, 1);
UPDATE `medicine` SET category_code = '26' WHERE category LIKE '%中成药%' AND category_code IS NULL AND is_deleted = 0;

-- 口服制剂 -> 归类到其他
UPDATE `medicine` SET category_code = '99' WHERE category LIKE '%口服制剂%' AND category_code IS NULL AND is_deleted = 0;

-- 其他未分类药品 -> 新增分类99
INSERT IGNORE INTO `medicine_categories` (`category_code`, `category_name`, `parent_code`, `level`, `display_order`, `status`) VALUES
('99', '其他药品', NULL, 1, 99, 1);
UPDATE `medicine` SET category_code = '99' WHERE category_code IS NULL AND is_deleted = 0;

-- 显示最终结果
SELECT '=== 补充迁移结果 ===' AS step;
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
