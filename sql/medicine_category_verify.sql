-- 药品分类迁移验证脚本
-- 创建时间：2026-05-07
-- 说明：验证分类数据迁移的正确性

SET NAMES utf8mb4;

SELECT '========================================' AS separator;
SELECT '药品分类迁移验证报告' AS title;
SELECT '========================================' AS separator;
SELECT CONCAT('验证时间: ', NOW()) AS verify_time;

-- ----------------------------
-- 1. 基础数据验证
-- ----------------------------
SELECT '=== 1. 基础数据验证 ===' AS step;

-- 检查分类字典表数据
SELECT 
  '分类字典表' AS table_name,
  COUNT(*) AS total_count,
  SUM(CASE WHEN level = 1 THEN 1 ELSE 0 END) AS level1_count,
  SUM(CASE WHEN level = 2 THEN 1 ELSE 0 END) AS level2_count,
  SUM(CASE WHEN status = 1 THEN 1 ELSE 0 END) AS active_count
FROM `medicine_categories` WHERE is_deleted = 0;

-- 检查映射规则表数据
SELECT 
  '映射规则表' AS table_name,
  COUNT(*) AS total_count,
  SUM(CASE WHEN status = 1 THEN 1 ELSE 0 END) AS active_count
FROM `category_name_mapping`;

-- 检查迁移日志表数据
SELECT 
  '迁移日志表' AS table_name,
  COUNT(*) AS total_count,
  SUM(CASE WHEN status = 'success' THEN 1 ELSE 0 END) AS success_count,
  SUM(CASE WHEN status = 'failed' THEN 1 ELSE 0 END) AS failed_count
FROM `category_migration_log`;

-- ----------------------------
-- 2. 迁移完整性验证
-- ----------------------------
SELECT '=== 2. 迁移完整性验证 ===' AS step;

-- 药品总数统计
SELECT 
  COUNT(*) AS total_medicine_count,
  SUM(CASE WHEN category_code IS NOT NULL THEN 1 ELSE 0 END) AS migrated_count,
  SUM(CASE WHEN category_code IS NULL THEN 1 ELSE 0 END) AS not_migrated_count,
  ROUND(SUM(CASE WHEN category_code IS NOT NULL THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS migration_rate
FROM `medicine` WHERE is_deleted = 0;

-- 迁移成功率判断
SELECT CASE 
  WHEN (SELECT ROUND(SUM(CASE WHEN category_code IS NOT NULL THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) 
        FROM `medicine` WHERE is_deleted = 0) >= 95 THEN '✓ 迁移成功率 ≥ 95%，验证通过'
  ELSE '✗ 迁移成功率 < 95%，请检查未迁移数据'
END AS validation_result;

-- ----------------------------
-- 3. 数据一致性验证
-- ----------------------------
SELECT '=== 3. 数据一致性验证 ===' AS step;

-- 检查分类编码唯一性
SELECT CASE 
  WHEN COUNT(*) = 0 THEN '✓ 分类编码唯一性验证通过'
  ELSE CONCAT('✗ 发现 ', COUNT(*), ' 个重复分类编码')
END AS check_result
FROM (
  SELECT category_code, COUNT(*) as cnt
  FROM `medicine_categories`
  WHERE is_deleted = 0
  GROUP BY category_code
  HAVING cnt > 1
) t;

-- 检查分类编码有效性（所有medicine.category_code都存在于medicine_categories）
SELECT CASE 
  WHEN COUNT(*) = 0 THEN '✓ 所有药品分类编码都有效'
  ELSE CONCAT('✗ 发现 ', COUNT(*), ' 个无效分类编码')
END AS check_result,
  GROUP_CONCAT(DISTINCT category_code) AS invalid_codes
FROM `medicine` m
WHERE m.category_code IS NOT NULL 
  AND NOT EXISTS (
    SELECT 1 FROM `medicine_categories` mc 
    WHERE mc.category_code = m.category_code AND mc.is_deleted = 0
  )
  AND m.is_deleted = 0;

-- 检查父分类关系正确性
SELECT CASE 
  WHEN COUNT(*) = 0 THEN '✓ 父分类关系验证通过'
  ELSE CONCAT('✗ 发现 ', COUNT(*), ' 个错误的父分类关系')
END AS check_result
FROM `medicine_categories` mc1
WHERE mc1.parent_code IS NOT NULL
  AND NOT EXISTS (
    SELECT 1 FROM `medicine_categories` mc2
    WHERE mc2.category_code = mc1.parent_code AND mc2.is_deleted = 0
  )
  AND mc1.is_deleted = 0;

-- ----------------------------
-- 4. 分类统计准确性验证
-- ----------------------------
SELECT '=== 4. 分类统计准确性验证 ===' AS step;

-- 每个分类的药品数量统计
SELECT 
  mc.category_code,
  mc.category_name,
  mc.level,
  COUNT(m.id) AS medicine_count
FROM `medicine_categories` mc
LEFT JOIN `medicine` m ON m.category_code = mc.category_code AND m.is_deleted = 0
WHERE mc.is_deleted = 0 AND mc.status = 1
GROUP BY mc.category_code, mc.category_name, mc.level
ORDER BY mc.category_code;

-- 检查未分类的药品
SELECT '=== 未分类药品详情 ===' AS step;
SELECT 
  id, name, category, category_code, source
FROM `medicine`
WHERE category_code IS NULL AND is_deleted = 0
LIMIT 20;

-- ----------------------------
-- 5. 层级分类验证
-- ----------------------------
SELECT '=== 5. 层级分类验证 ===' AS step;

-- 一级分类统计
SELECT 
  '一级分类' AS level_type,
  COUNT(*) AS count
FROM `medicine_categories`
WHERE level = 1 AND is_deleted = 0;

-- 二级分类统计
SELECT 
  '二级分类' AS level_type,
  COUNT(*) AS count
FROM `medicine_categories`
WHERE level = 2 AND is_deleted = 0;

-- 显示层级分类树
SELECT '=== 分类层级结构 ===' AS step;
SELECT 
  CASE mc.level
    WHEN 1 THEN CONCAT('└─ ', mc.category_code, ' ', mc.category_name)
    WHEN 2 THEN CONCAT('   └─ ', mc.category_code, ' ', mc.category_name)
    WHEN 3 THEN CONCAT('      └─ ', mc.category_code, ' ', mc.category_name)
  END AS category_tree,
  COUNT(m.id) AS medicine_count
FROM `medicine_categories` mc
LEFT JOIN `medicine` m ON m.category_code = mc.category_code AND m.is_deleted = 0
WHERE mc.is_deleted = 0 AND mc.status = 1
GROUP BY mc.category_code, mc.category_name, mc.level
ORDER BY mc.category_code;

-- ----------------------------
-- 6. 迁移日志验证
-- ----------------------------
SELECT '=== 6. 迁移日志验证 ===' AS step;

SELECT 
  batch_no,
  old_category_name,
  new_category_code,
  medicine_count,
  status,
  create_time
FROM `category_migration_log`
ORDER BY create_time DESC
LIMIT 20;

-- ----------------------------
-- 7. 验证总结
-- ----------------------------
SELECT '========================================' AS separator;
SELECT '验证总结' AS title;
SELECT '========================================' AS separator;

SELECT 
  CASE 
    WHEN (SELECT ROUND(SUM(CASE WHEN category_code IS NOT NULL THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) 
          FROM `medicine` WHERE is_deleted = 0) >= 95 THEN '✓ 迁移验证通过'
    ELSE '✗ 迁移验证未通过'
  END AS final_result,
  
  (SELECT ROUND(SUM(CASE WHEN category_code IS NOT NULL THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) 
   FROM `medicine` WHERE is_deleted = 0) AS migration_rate,
   
  (SELECT COUNT(*) FROM `medicine` WHERE is_deleted = 0) AS total_medicine,
  
  (SELECT COUNT(*) FROM `medicine` WHERE category_code IS NOT NULL AND is_deleted = 0) AS migrated_count,
  
  (SELECT COUNT(*) FROM `medicine` WHERE category_code IS NULL AND is_deleted = 0) AS not_migrated_count;

SELECT '验证完成！' AS message;
