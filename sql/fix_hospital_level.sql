-- =============================================
-- 医院等级(level)字段填充修复脚本
-- 问题：hospital表的level字段全部为NULL
-- 方案：根据department字段智能推断level值
-- 执行方式：在MySQL中直接执行此SQL
-- =============================================

-- 先查看当前状态（执行前）
SELECT 
  department,
  COUNT(*) as cnt,
  SUM(CASE WHEN level IS NULL THEN 1 ELSE 0 END) as null_level_cnt
FROM hospital 
GROUP BY department;

-- ========== 开始修复 ==========

-- 1. 三级甲等医院 → 三级甲等
UPDATE hospital SET level = '三级甲等' WHERE department = '三级甲等医院';

-- 2. 综合医院 → 综合医院
UPDATE hospital SET level = '综合医院' WHERE department = '综合医院';

-- 3. 专科医院 → 专科医院
UPDATE hospital SET level = '专科医院' WHERE department = '专科医院';

-- 4. 医疗保健服务场所 → 保健机构
UPDATE hospital SET level = '保健机构' WHERE department = '医疗保健服务场所';

-- 5. 卫生院 → 卫生院
UPDATE hospital SET level = '卫生院' WHERE department = '卫生院';

-- 6. 诊所 → 诊所
UPDATE hospital SET level = '诊所' WHERE department = '诊所';

-- 7. 社区卫生服务中心/站 → 社区医院
UPDATE hospital SET level = '社区医院' 
WHERE (department LIKE '%社区卫生服务中心%' OR department LIKE '%社区卫生站%');

-- ========== 验证修复结果 ==========

SELECT level, COUNT(*) as 数量 FROM hospital GROUP BY level ORDER BY COUNT(*) DESC;

-- 确认没有遗漏的NULL
SELECT COUNT(*) as 仍为NULL的数量 FROM hospital WHERE level IS NULL;
