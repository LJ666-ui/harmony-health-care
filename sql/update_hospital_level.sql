-- 更新医院等级字段
-- 根据医院名称中的关键词判断医院等级

-- 1. 更新三级甲等医院
UPDATE hospital SET level = '三级甲等' WHERE 
name LIKE '%协和医院%' OR
name LIKE '%同仁医院%' OR
name LIKE '%积水潭医院%' OR
name LIKE '%天坛医院%' OR
name LIKE '%安贞医院%' OR
name LIKE '%朝阳医院%' OR
name LIKE '%中日友好医院%' OR
name LIKE '%北京大学第一医院%' OR
name LIKE '%北京大学人民医院%' OR
name LIKE '%北京大学第三医院%' OR
name LIKE '%宣武医院%' OR
name LIKE '%阜外医院%' OR
name LIKE '%肿瘤医院%' OR
name LIKE '%儿童医院%' OR
name LIKE '%妇产医院%' OR
name LIKE '%首都医科大学附属%' AND name NOT LIKE '%社区卫生%' OR
name LIKE '%三甲%';

-- 2. 更新三级乙等医院
UPDATE hospital SET level = '三级乙等' WHERE 
name LIKE '%三乙%' OR
name LIKE '%区人民医院%' AND name NOT LIKE '%社区卫生%';

-- 3. 更新二级甲等医院
UPDATE hospital SET level = '二级甲等' WHERE 
name LIKE '%二甲%' OR
name LIKE '%县人民医院%' OR
name LIKE '%区第二人民医院%' OR
name LIKE '%区中医院%' AND name NOT LIKE '%社区卫生%';

-- 4. 更新二级乙等医院
UPDATE hospital SET level = '二级乙等' WHERE 
name LIKE '%二乙%' OR
name LIKE '%镇卫生院%' OR
name LIKE '%乡卫生院%';

-- 5. 更新一级甲等医院
UPDATE hospital SET level = '一级甲等' WHERE 
name LIKE '%一甲%' OR
name LIKE '%社区卫生服务中心%' AND name NOT LIKE '%站%';

-- 6. 更新一级乙等医院
UPDATE hospital SET level = '一级乙等' WHERE 
name LIKE '%一乙%' OR
name LIKE '%社区卫生服务站%';

-- 7. 更新综合医院
UPDATE hospital SET level = '综合医院' WHERE 
name LIKE '%人民医院%' AND level IS NULL OR
name LIKE '%中心医院%' AND level IS NULL OR
name LIKE '%总医院%' AND level IS NULL;

-- 8. 更新专科医院
UPDATE hospital SET level = '专科医院' WHERE 
name LIKE '%中医院%' AND level IS NULL OR
name LIKE '%妇幼%' AND level IS NULL OR
name LIKE '%口腔医院%' AND level IS NULL OR
name LIKE '%眼科医院%' AND level IS NULL OR
name LIKE '%骨科医院%' AND level IS NULL OR
name LIKE '%肿瘤医院%' AND level IS NULL OR
name LIKE '%精神病医院%' AND level IS NULL OR
name LIKE '%传染病医院%' AND level IS NULL OR
name LIKE '%康复医院%' AND level IS NULL OR
name LIKE '%美容医院%' AND level IS NULL OR
name LIKE '%整形医院%' AND level IS NULL;

-- 9. 为剩余未分类的医院设置默认等级
UPDATE hospital SET level = '综合医院' WHERE level IS NULL;

-- 查看更新结果
SELECT level, COUNT(*) as count FROM hospital GROUP BY level ORDER BY count DESC;
