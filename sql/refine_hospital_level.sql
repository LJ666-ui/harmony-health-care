-- 根据department字段更新level字段，使医院分类更丰富
-- 这样可以让前端筛选更精准

-- 1. 首先清理并重新分类

-- 三级甲等医院
UPDATE hospital SET level = '三级甲等' WHERE 
department = '三级甲等医院' OR
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
name LIKE '%友谊医院%';

-- 三级乙等医院（区级人民医院、市级专科医院）
UPDATE hospital SET level = '三级乙等' WHERE 
level IS NULL AND (
name LIKE '%区人民医院%' OR
name LIKE '%市人民医院%' OR
name LIKE '%市中医院%'
);

-- 二级甲等医院（县级医院、区级专科医院）
UPDATE hospital SET level = '二级甲等' WHERE 
level IS NULL AND (
name LIKE '%县人民医院%' OR
name LIKE '%县中医院%' OR
name LIKE '%区第二人民医院%' OR
name LIKE '%区中医院%'
);

-- 二级乙等医院（乡镇卫生院）
UPDATE hospital SET level = '二级乙等' WHERE 
level IS NULL AND (
department = '卫生院' OR
name LIKE '%镇卫生院%' OR
name LIKE '%乡卫生院%'
);

-- 一级甲等医院（社区卫生服务中心）
UPDATE hospital SET level = '一级甲等' WHERE 
name LIKE '%社区卫生服务中心%' AND name NOT LIKE '%站%';

-- 一级乙等医院（社区卫生服务站）
UPDATE hospital SET level = '一级乙等' WHERE 
name LIKE '%社区卫生服务站%';

-- 综合医院（人民医院、中心医院等）
UPDATE hospital SET level = '综合医院' WHERE 
level IS NULL AND (
department = '综合医院' OR
name LIKE '%人民医院%' OR
name LIKE '%中心医院%' OR
name LIKE '%总医院%'
);

-- 专科医院
UPDATE hospital SET level = '专科医院' WHERE 
level IS NULL AND (
department = '专科医院' OR
name LIKE '%中医院%' OR
name LIKE '%妇幼%' OR
name LIKE '%口腔医院%' OR
name LIKE '%眼科医院%' OR
name LIKE '%骨科医院%' OR
name LIKE '%肿瘤医院%' OR
name LIKE '%精神病医院%' OR
name LIKE '%传染病医院%' OR
name LIKE '%康复医院%' OR
name LIKE '%美容医院%' OR
name LIKE '%整形医院%' OR
name LIKE '%耳鼻喉医院%'
);

-- 卫生院（二级乙等）
UPDATE hospital SET level = '二级乙等' WHERE 
level IS NULL AND department = '卫生院';

-- 其他未分类的设为综合医院
UPDATE hospital SET level = '综合医院' WHERE level IS NULL;

-- 查看更新后的结果
SELECT level, COUNT(*) as count FROM hospital GROUP BY level ORDER BY count DESC;
